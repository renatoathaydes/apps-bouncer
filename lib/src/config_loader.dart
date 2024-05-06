import 'dart:io';

import 'package:yaml/yaml.dart';

import 'config.g.dart';

/// Load the Bouncer configuration from the provided path if any, throwing
/// an error if that does not exist.
///
/// Otherwise, try to read the `apps-bouncer.yaml` file in the working
/// directory, and if that does not exist, in the file
/// `$HOME/.config/apps-bouncer/config.yaml`.
///
/// If none of these exists, the default [BouncerConfig] instance is returned.
Future<BouncerConfig> loadConfig([String? path]) async {
  File file;
  if (path == null) {
    file = File('apps-bouncer.yaml');
    if (!await file.exists() && Platform.environment.containsKey('HOME')) {
      file = File(
          '${Platform.environment['HOME']}/.config/apps-bouncer/config.yaml');
      if (!await file.exists()) {
        return const BouncerConfig();
      }
    }
  } else {
    file = File(path);
  }
  return BouncerConfig.fromJson(loadYaml(await file.readAsString()));
}
