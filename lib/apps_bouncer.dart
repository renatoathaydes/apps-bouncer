import 'src/bouncer.dart';

Future<void> run() async {
  while (true) {
    await runBouncer();
    await Future.delayed(Duration(seconds: 2));
  }
}
