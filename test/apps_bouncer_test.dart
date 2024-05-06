import 'dart:async';

import 'package:apps_bouncer/apps_bouncer.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  final logger = Logger('test');

  group('ps parser', () {
    test('can parse ps simple output', () {
      const example1 = '  375  0.2   0.0 locationd';
      expect(
          ProcessData.fromPs(example1),
          ProcessData(
              pid: 375, command: 'locationd', memoryUsage: 0.2, cpuUsage: 0.0));
    });
    test('can parse ps no-prefix-space output', () {
      const example1 = '1  0.32   1.0 launchd';
      expect(
          ProcessData.fromPs(example1),
          ProcessData(
              pid: 1, command: 'launchd', memoryUsage: 0.32, cpuUsage: 1.0));
    });
    test('can parse ps output with spaces in command', () {
      const example1 = '19787  0.3   7.4 Activity Monitor';
      expect(
          ProcessData.fromPs(example1),
          ProcessData(
              pid: 19787,
              command: 'Activity Monitor',
              memoryUsage: 0.3,
              cpuUsage: 7.4));
    });
    test('cannot parse invalid line', () {
      expect(() => ProcessData.fromPs('foo bar 1.0'),
          throwsA(isA<ArgumentError>()));
    });
  });

  group('main loop', () {
    test('notifies if process is above threshold after too many chances',
        () async {
      final collector = _mockCollector([
        [ProcessData(pid: 1, command: 'a', memoryUsage: 0.5, cpuUsage: 1.0)],
        [ProcessData(pid: 1, command: 'a', memoryUsage: 1.5, cpuUsage: 3.0)],
      ]);
      final notifications = <ProcessData>[];
      await runBouncer(
          config: BouncerConfig(
              periodSeconds: 0, misbehavingChances: 1, cpuThreshold: 0.5),
          collector: collector,
          keepRunning: _runtimes(2),
          notify: _mockNotifier(notifications));
      expect(
          notifications,
          equals([
            ProcessData(pid: 1, command: 'a', memoryUsage: 1.0, cpuUsage: 2.0)
          ]));
    });
    test('does not notify if process is above threshold but has more chances',
        () async {
      final collector = _mockCollector([
        [ProcessData(pid: 1, command: 'a', memoryUsage: 0.5, cpuUsage: 1.0)],
        [ProcessData(pid: 1, command: 'a', memoryUsage: 1.5, cpuUsage: 0.1)],
        [ProcessData(pid: 1, command: 'a', memoryUsage: 1.5, cpuUsage: 1.0)],
        [ProcessData(pid: 1, command: 'a', memoryUsage: 1.5, cpuUsage: 1.0)],
        [ProcessData(pid: 1, command: 'a', memoryUsage: 1.5, cpuUsage: 0.1)],
      ]);
      final notifications = <ProcessData>[];
      await runBouncer(
          config: BouncerConfig(
              periodSeconds: 0, misbehavingChances: 2, cpuThreshold: 0.5),
          collector: collector,
          keepRunning: _runtimes(5),
          notify: _mockNotifier(notifications));
      expect(notifications, isEmpty);
    });

    test(
        'notifies if process is above threshold after reset and too many chances',
        () async {
      final collector = _mockCollector([
        [ProcessData(pid: 1, command: 'a', memoryUsage: 1.5, cpuUsage: 0.0)],
        [ProcessData(pid: 1, command: 'a', memoryUsage: 1.3, cpuUsage: 0.0)],
        [ProcessData(pid: 1, command: 'a', memoryUsage: 0.9, cpuUsage: 0.0)],
        [ProcessData(pid: 1, command: 'a', memoryUsage: 1.5, cpuUsage: 0.0)],
        [ProcessData(pid: 1, command: 'a', memoryUsage: 3.5, cpuUsage: 0.0)],
      ]);
      final notifications = <ProcessData>[];
      await runBouncer(
          config: BouncerConfig(
              periodSeconds: 0, misbehavingChances: 2, memoryThreshold: 1.0),
          collector: collector,
          keepRunning: _runtimes(5),
          notify: _mockNotifier(notifications),
          logger: logger);
      expect(
          notifications,
          equals([
            ProcessData(pid: 1, command: 'a', memoryUsage: 2.1, cpuUsage: 0.0)
          ]));
    });
  });
}

Stream<ProcessData> Function() _mockCollector(List<List<ProcessData>> values) {
  final iter = values.iterator;
  return () {
    if (iter.moveNext()) {
      return Stream.fromIterable(iter.current);
    }
    throw StateError('no more values available');
  };
}

Future<void> Function(ProcessData) _mockNotifier(
    List<ProcessData> notifications) {
  return (data) async => notifications.add(data);
}

Future<bool> Function() _runtimes(int maxCount) {
  var count = 0;
  return () async {
    return count++ < maxCount;
  };
}
