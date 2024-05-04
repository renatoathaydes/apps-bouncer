import 'package:apps_bouncer/src/process_data.dart';
import 'package:test/test.dart';

void main() {
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
    expect(
        () => ProcessData.fromPs('foo bar 1.0'), throwsA(isA<ArgumentError>()));
  });
}
