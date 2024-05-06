import 'dart:io';

import 'package:dartle/dartle.dart';
import 'package:schemake/dart_gen.dart' as dg;
import 'package:schemake/schemake.dart';

const outputFile = 'lib/src/config.g.dart';

Property<int> _intRange(
        {required int min, required int max, required int defaultValue}) =>
    Property(Validatable(Ints(), IntRangeValidator(min, max)),
        defaultValue: defaultValue);

Property<double> _floatRange(
        {required double min,
        required double max,
        required double defaultValue}) =>
    Property(Validatable(Floats(), FloatRangeValidator(min, max)),
        defaultValue: defaultValue);

/// The BouncerConfig Schema.
final bouncerConfigSchema = Objects('BouncerConfig', {
  'periodSeconds': _intRange(min: 1, max: 360, defaultValue: 2),
  'misbehavingChances': _intRange(min: 1, max: 100, defaultValue: 4),
  'cpuThreshold': _floatRange(min: 1, max: 100, defaultValue: 50),
  'memoryThreshold': _floatRange(min: 1, max: 100, defaultValue: 25),
  'postNotificationPeriodMinutes':
      _intRange(min: 1, max: 30 * 24 * 60, defaultValue: 60),
  'logLevel': Property(
      Enums(EnumValidator(
          'LogLevel', {'finer', 'fine', 'info', 'warning', 'error'})),
      defaultValue: 'info'),
});

final generateConfigTask = Task(
    (_) async => File(outputFile)
        .writeAsString(dg.generateDartClasses([bouncerConfigSchema],
            options: const dg.DartGeneratorOptions(methodGenerators: [
              ...dg.DartGeneratorOptions.defaultMethodGenerators,
              dg.DartFromJsonMethodGenerator(),
            ])).toString()),
    name: 'generateConfig',
    description: 'Generates the configuration object.',
    runCondition: RunOnChanges(
        inputs: files(
            ['dartle-src/generate_config.dart', 'dartle.dart', 'pubspec.yaml']),
        outputs: file(outputFile)));
