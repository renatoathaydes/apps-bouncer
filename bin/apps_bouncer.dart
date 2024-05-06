import 'dart:io';

import 'package:apps_bouncer/apps_bouncer.dart' as apps_bouncer;
import 'package:apps_bouncer/src/config_loader.dart';
import 'package:logging/logging.dart';

main(List<String> args) async {
  if (args.length > 1) {
    print('ERROR: at most one argument, the config file, may be provided');
    exit(1);
  }
  Logger.root.onRecord.listen((record) {
    print('${record.time} [${record.level.name}] ${record.message}');
  });
  final config = await loadConfig(args.isEmpty ? null : args.first);
  Logger.root.level = _logLevel(config.logLevel);
  await apps_bouncer.run(config, Logger('Bouncer'));
}

Level _logLevel(apps_bouncer.LogLevel logLevel) => switch (logLevel) {
      apps_bouncer.LogLevel.finer => Level.FINER,
      apps_bouncer.LogLevel.fine => Level.FINE,
      apps_bouncer.LogLevel.info => Level.INFO,
      apps_bouncer.LogLevel.warning => Level.WARNING,
      apps_bouncer.LogLevel.error => Level.SEVERE,
    };
