import 'dart:convert';
import 'dart:io';

import 'package:apps_bouncer/src/process_data.dart';

Future<void> runBouncer() async {
  final ps = await Process.start('ps', const ['acx', '-o', ProcessData.psFmt]);
  final lines = <String>[];
  ps.stdout
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .forEach(lines.add);
  final exitCode = await ps.exitCode;
  if (exitCode != 0) {
    print("Command 'ps' failed with code $exitCode");
  } else {
    final data = collectProcessData(lines.iterator);
    print(data);
  }
}

List<ProcessData> collectProcessData(Iterator<String> lines,
    {double cpuThreshold = 20.0, double memoryThreshold = 40.0}) {
  // discard the header
  if (!lines.moveNext()) return const [];
  final result = <ProcessData>[];
  while (lines.moveNext()) {
    final data = ProcessData.fromPs(lines.current);
    if (data.isOverThreshold(cpuThreshold, memoryThreshold)) {
      result.add(data);
    }
  }
  return result;
}
