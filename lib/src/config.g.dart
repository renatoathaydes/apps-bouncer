import 'dart:convert';
import 'package:schemake/schemake.dart';

class BouncerConfig {
  final int periodSeconds;
  final int misbehavingChances;
  final double cpuThreshold;
  final double memoryThreshold;
  final int postNotificationPeriodMinutes;
  final LogLevel logLevel;
  const BouncerConfig({
    this.periodSeconds = 2,
    this.misbehavingChances = 4,
    this.cpuThreshold = 50.0,
    this.memoryThreshold = 25.0,
    this.postNotificationPeriodMinutes = 60,
    this.logLevel = LogLevel.info,
  });
  @override
  String toString() => 'BouncerConfig{'
      'periodSeconds: $periodSeconds, '
      'misbehavingChances: $misbehavingChances, '
      'cpuThreshold: $cpuThreshold, '
      'memoryThreshold: $memoryThreshold, '
      'postNotificationPeriodMinutes: $postNotificationPeriodMinutes, '
      'logLevel: $logLevel'
      '}';
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BouncerConfig &&
          runtimeType == other.runtimeType &&
          periodSeconds == other.periodSeconds &&
          misbehavingChances == other.misbehavingChances &&
          cpuThreshold == other.cpuThreshold &&
          memoryThreshold == other.memoryThreshold &&
          postNotificationPeriodMinutes ==
              other.postNotificationPeriodMinutes &&
          logLevel == other.logLevel;
  @override
  int get hashCode =>
      periodSeconds.hashCode ^
      misbehavingChances.hashCode ^
      cpuThreshold.hashCode ^
      memoryThreshold.hashCode ^
      postNotificationPeriodMinutes.hashCode ^
      logLevel.hashCode;
  static BouncerConfig fromJson(Object? value) =>
      const _BouncerConfigJsonReviver().convert(switch (value) {
        String() => jsonDecode(value),
        List<int>() => jsonDecode(utf8.decode(value)),
        _ => value,
      });
}

enum LogLevel {
  finer,
  fine,
  info,
  warning,
  error,
  ;

  static LogLevel from(String s) => switch (s) {
        'finer' => finer,
        'fine' => fine,
        'info' => info,
        'warning' => warning,
        'error' => error,
        _ => throw ValidationException([
            'value not allowed for LogLevel: "$s" - should be one of {finer, fine, info, warning, error}'
          ]),
      };
}

class _LogLevelConverter extends Converter<Object?, LogLevel> {
  const _LogLevelConverter();
  @override
  LogLevel convert(Object? input) {
    return LogLevel.from(const Strings().convert(input));
  }
}

class _BouncerConfigJsonReviver extends ObjectsBase<BouncerConfig> {
  const _BouncerConfigJsonReviver()
      : super("BouncerConfig",
            unknownPropertiesStrategy: UnknownPropertiesStrategy.forbid);

  @override
  BouncerConfig convert(Object? value) {
    if (value is! Map) throw TypeException(BouncerConfig, value);
    final keys = value.keys.map((key) {
      if (key is! String) {
        throw TypeException(String, key, "object key is not a String");
      }
      return key;
    }).toSet();
    checkRequiredProperties(keys);
    const knownProperties = {
      'periodSeconds',
      'misbehavingChances',
      'cpuThreshold',
      'memoryThreshold',
      'postNotificationPeriodMinutes',
      'logLevel'
    };
    final unknownKey =
        keys.where((k) => !knownProperties.contains(k)).firstOrNull;
    if (unknownKey != null) {
      throw UnknownPropertyException([unknownKey], BouncerConfig);
    }
    return BouncerConfig(
      periodSeconds: convertPropertyOrDefault(
          const Validatable(Ints(), IntRangeValidator(1, 360)),
          'periodSeconds',
          value,
          2),
      misbehavingChances: convertPropertyOrDefault(
          const Validatable(Ints(), IntRangeValidator(1, 100)),
          'misbehavingChances',
          value,
          4),
      cpuThreshold: convertPropertyOrDefault(
          const Validatable(Floats(), FloatRangeValidator(1.0, 100.0)),
          'cpuThreshold',
          value,
          50.0),
      memoryThreshold: convertPropertyOrDefault(
          const Validatable(Floats(), FloatRangeValidator(1.0, 100.0)),
          'memoryThreshold',
          value,
          25.0),
      postNotificationPeriodMinutes: convertPropertyOrDefault(
          const Validatable(Ints(), IntRangeValidator(1, 43200)),
          'postNotificationPeriodMinutes',
          value,
          60),
      logLevel: convertPropertyOrDefault(
          const _LogLevelConverter(), 'logLevel', value, LogLevel.info),
    );
  }

  @override
  Converter<Object?, Object?>? getPropertyConverter(String property) {
    switch (property) {
      case 'periodSeconds':
        return const Validatable(Ints(), IntRangeValidator(1, 360));
      case 'misbehavingChances':
        return const Validatable(Ints(), IntRangeValidator(1, 100));
      case 'cpuThreshold':
        return const Validatable(Floats(), FloatRangeValidator(1.0, 100.0));
      case 'memoryThreshold':
        return const Validatable(Floats(), FloatRangeValidator(1.0, 100.0));
      case 'postNotificationPeriodMinutes':
        return const Validatable(Ints(), IntRangeValidator(1, 43200));
      case 'logLevel':
        return const _LogLevelConverter();
      default:
        return null;
    }
  }

  @override
  Iterable<String> getRequiredProperties() {
    return const {};
  }

  @override
  String toString() => 'BouncerConfig';
}
