/// Data about a specific OS process.
class ProcessData {
  static const psFmt = 'pid,%mem,%cpu,command';
  static final psOutPattern =
      RegExp(r'\s*(\d+)\s+(\d+(\.\d+)?)\s+(\d+(\.\d+)?)\s+(.+)');
  final int pid;
  final String command;
  double memoryUsage;
  double cpuUsage;

  ProcessData({
    required this.pid,
    required this.command,
    required this.memoryUsage,
    required this.cpuUsage,
  });

  factory ProcessData.fromPs(String line) {
    final match = psOutPattern.matchAsPrefix(line);
    if (match == null || match.groupCount != 6) {
      throw ArgumentError("Unrecognized ps output line: '$line'", 'line');
    }
    return ProcessData(
      pid: int.parse(match.group(1)!),
      memoryUsage: double.parse(match.group(2)!),
      cpuUsage: double.parse(match.group(4)!),
      command: match.group(6)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProcessData &&
          runtimeType == other.runtimeType &&
          pid == other.pid &&
          command == other.command &&
          memoryUsage == other.memoryUsage &&
          cpuUsage == other.cpuUsage;

  @override
  int get hashCode =>
      pid.hashCode ^
      command.hashCode ^
      memoryUsage.hashCode ^
      cpuUsage.hashCode;

  @override
  String toString() {
    return 'ProcessData{pid: $pid, command: $command, memoryUsage: $memoryUsage, cpuUsage: $cpuUsage}';
  }

  bool isOverThreshold(double cpuThreshold, double memoryThreshold) {
    return cpuUsage > cpuThreshold || memoryUsage > memoryThreshold;
  }
}
