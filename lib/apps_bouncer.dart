import 'src/bouncer.dart';

export 'src/bouncer.dart';
export 'src/notifier.dart';
export 'src/process_data.dart';

Future<void> run() async {
  await runBouncer(period: Duration(seconds: 2));
}
