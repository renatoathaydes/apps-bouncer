import 'package:apps_bouncer/apps_bouncer.dart' as bouncer;
import 'package:yaml/yaml.dart';

main() async {
  final yaml = loadYaml('''
  periodSeconds: 5
  logLevel: error
  ''');
  final config = bouncer.BouncerConfig.fromJson(yaml);
  print(config);

  // run the bouncer
  await bouncer.run(config);
}
