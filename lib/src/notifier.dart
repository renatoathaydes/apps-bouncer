import 'dart:io';

import 'package:logging/logging.dart';

import 'process_data.dart';

final _logger = Logger('notifier');

Future<void> userNotify(ProcessData processData) async {
  if (Platform.isMacOS) {
    await _macosUserNotify(processData);
  } else {
    _logger.warning(processData);
  }
}

Future<void> _macosUserNotify(ProcessData proc) async {
  final process = await Process.run('osascript', [
    '-e',
    '''
  set userCanceled to false

  try
    set dialogResult to display dialog ¬
      "Kill process '${proc.command}'?" buttons {"No", "Yes"} ¬
      with icon caution ¬
      default button "Yes" cancel button ¬
      "No" giving up after 60
  on error number -128
    set userCanceled to true
  end try
  
  if button returned of dialogResult is "Yes" then
    do shell script "kill ${proc.pid}"  
    display dialog "Yay"
  end if
  
  end
  '''
  ]);

  final code = process.exitCode;
  if (code == 0) {
    _logger.fine(() => 'MacOS notification successful for: $proc');
  } else {
    _logger.warning(() => 'MacOS notification script exited with $code');
  }
  _logger.fine('=========== stdout ============');
  _logger.fine(process.stdout);
  _logger.fine('===============================');
  _logger.fine('=========== stderr ============');
  _logger.fine(process.stderr);
  _logger.fine('===============================');
}
