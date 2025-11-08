import 'package:eightclub/core/dio/dio_client.dart';
import 'package:eightclub/core/logger/init_logger.dart';
import 'package:eightclub/features/experience_selection/presentation/bloc/selection_bloc.dart';
import 'package:eightclub/service/get_experience_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

final GetIt serviceLocator = GetIt.instance;

void initDi() {
  initLogger(level: kDebugMode ? Level.ALL : Level.SEVERE);

  /// Register DioClient
  serviceLocator.registerLazySingleton<DioClient>(() => DioClient());

  /// Register GetExperienceService
  serviceLocator.registerLazySingleton<GetExperienceService>(
    () => GetExperienceService(serviceLocator<DioClient>()),
  );

  /// Register Bloc
  serviceLocator.registerFactory<SelectionBloc>(
    () => SelectionBloc(serviceLocator<GetExperienceService>()),
  );
}
