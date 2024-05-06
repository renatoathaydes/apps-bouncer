import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';

import 'config.g.dart';
import 'notifier.dart';
import 'process_data.dart';

Future<void> runBouncer({
  BouncerConfig config = const BouncerConfig(),
  Logger? logger,
  Stream<ProcessData> Function() collector = collectProcessData,
  Future<void> Function(ProcessData) notify = userNotify,
  Future<bool> Function() keepRunning = _onlyTrue,
  DateTime Function() currentTime = _now,
}) async {
  final period = Duration(seconds: config.periodSeconds);
  final postNotificationPeriod =
      Duration(minutes: config.postNotificationPeriodMinutes);

  final notifiedPids = <int, DateTime>{};

  final state = <int, List<ProcessData>>{};
  while (await keepRunning()) {
    final procData = await collector()
        .where((data) =>
            data.isOverThreshold(config.cpuThreshold, config.memoryThreshold))
        .toList();
    state.removeOneEntryIfAbsentIn(procData, logger);
    logger?.finer(() => 'Current state: $state');
    for (var proc in procData) {
      if (notifiedPids.containsKey(proc.pid)) continue;
      final entries = state.update(proc.pid, (current) {
        current.add(proc);
        return current;
      }, ifAbsent: () => [proc]);
      logger?.finer(() => 'Current entries: $entries');
      if (entries.length > config.misbehavingChances) {
        state.remove(proc.pid);
        final expiresAt = currentTime().add(postNotificationPeriod);
        notifiedPids[proc.pid] = expiresAt;
        final avgEntry = entries.average();
        logger?.info(() =>
            'Notifying user (notification expires at $expiresAt): $avgEntry');
        try {
          await notify(avgEntry);
        } catch (e) {
          logger?.warning('Notifier failed', e);
        }
      }
    }
    _removeExpiredEntries(notifiedPids);
    await Future.delayed(period);
  }
}

/// Collect process data by asking the Operating System.
Stream<ProcessData> collectProcessData() async* {
  final ps = await Process.start('ps', const ['acx', '-o', ProcessData.psFmt]);
  final lines = <String>[];
  ps.stdout
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .forEach(lines.add);
  final exitCode = await ps.exitCode;
  if (exitCode != 0) {
    throw Exception('ps command failed with code $exitCode');
  } else {
    for (final entry in parseProcessData(lines.iterator)) {
      yield entry;
    }
  }
}

Iterable<ProcessData> parseProcessData(Iterator<String> lines) sync* {
  // discard the header
  if (!lines.moveNext()) return;
  while (lines.moveNext()) {
    yield ProcessData.fromPs(lines.current);
  }
}

void _removeExpiredEntries(Map<int, DateTime> entries) {
  final now = DateTime.now();
  final toRemove = entries.entries
      .where((e) {
        final expiresAt = e.value;
        return now.isAfter(expiresAt);
      })
      .map((e) => e.key)
      .toSet();
  entries.removeWhere((pid, _) => toRemove.contains(pid));
}

DateTime _now() => DateTime.now();

Future<bool> _onlyTrue() async => true;

extension ProcStats on List<ProcessData> {
  ProcessData average() {
    double cpu = 0;
    double mem = 0;
    for (final entry in this) {
      cpu += entry.cpuUsage;
      mem += entry.memoryUsage;
    }
    return ProcessData(
        pid: first.pid,
        command: first.command,
        memoryUsage: mem / length,
        cpuUsage: cpu / length);
  }
}

extension on Map<int, List<ProcessData>> {
  void removeOneEntryIfAbsentIn(List<ProcessData> data, Logger? logger) {
    final dataPids = data.map((p) => p.pid).toSet();
    final toRemove = <int>{};
    forEach((pid, proc) {
      if (!dataPids.contains(pid)) {
        proc.removeAt(0);
        if (proc.isEmpty) {
          toRemove.add(pid);
          logger?.fine(() => 'Removed all entries for PID=$pid');
        } else {
          logger?.fine(
              () => 'Removed entry for PID=$pid, ${proc.length} remaining');
        }
      }
    });
    removeWhere((pid, _) => toRemove.contains(pid));
  }
}
