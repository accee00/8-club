import 'package:logging/logging.dart';

final Logger appLogger = Logger('AppLogger');

void logInfo(Object message) => appLogger.info(message);
void logWarning(Object message) => appLogger.warning(message);
void logError(Object message, [Object? error, StackTrace? stackTrace]) =>
    appLogger.severe(message, error, stackTrace);
