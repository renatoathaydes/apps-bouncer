import 'package:dartle/dartle_dart.dart';

import 'dartle-src/generate_config.dart';

final dartleDart = DartleDart();

void main(List<String> args) {
  dartleDart.analyzeCode.dependsOn({generateConfigTask.name});
  dartleDart.formatCode.dependsOn({generateConfigTask.name});
  run(args, tasks: {
    ...dartleDart.tasks,
    generateConfigTask,
  }, defaultTasks: {
    dartleDart.build
  });
}
