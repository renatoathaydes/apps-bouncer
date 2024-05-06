import 'src/bouncer.dart';
import 'src/config.g.dart';

export 'src/bouncer.dart';
export 'src/config.g.dart';
export 'src/notifier.dart';
export 'src/process_data.dart';

/// Run the bouncer.
///
/// Provide a configuration object if you want to use non-defaults.
///
/// Use the [runBouncer] function for more flexibility..
Future<void> run([BouncerConfig config = const BouncerConfig()]) async {
  await runBouncer(config: config);
}
