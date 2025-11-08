import 'dart:developer' as developer;
import 'package:logging/logging.dart';

void initLogger({required Level level}) {
  Logger.root.level = level;
  Logger.root.onRecord.listen((LogRecord record) {
    developer.log(
      record.message,
      time: record.time,
      level: record.level.value,
      name: record.loggerName,
      error: record.error,
      stackTrace: record.stackTrace,
    );
  });
  Logger('InitLogger').info('Logger initialized with level: $level');
}
