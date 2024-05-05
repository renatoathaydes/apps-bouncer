import 'package:apps_bouncer/apps_bouncer.dart' as apps_bouncer;
import 'package:logging/logging.dart';

main() async {
  Logger.root.onRecord.listen((record) {
    print('${record.time} [${record.level.name}] ${record.message}');
  });
  await apps_bouncer.run();
}
