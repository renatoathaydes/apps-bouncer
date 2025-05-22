import 'package:apps_bouncer/apps_bouncer.dart';
import 'package:schemake/schemake.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  group('config', () {
    test('can load from YAML', () async {
      final yaml = loadYaml('''
  periodSeconds: 5
  logLevel: error
  ''');
      final config = BouncerConfig.fromJson(yaml);
      expect(
          config,
          equals(BouncerConfig(
            periodSeconds: 5,
            logLevel: LogLevel.error,
          )));
    });

    test('cannot provide empty strings for excludedProcesses', () {
      expect(() {
        BouncerConfig.fromJson({
          'excludedProcesses': ['', 'foo']
        });
      },
          throwsA(isA<PropertyValidationException>()
              .having((err) => err.errors, 'error messages',
                  equals(['blank string']))
              .having((err) => err.propertyPath, 'path',
                  equals(['excludedProcesses']))));
    });
  });
}
