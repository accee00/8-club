import 'package:eightclub/core/constants/app_theme.dart';
import 'package:eightclub/core/di/init_di.dart';
import 'package:eightclub/features/experience_selection/presentation/bloc/selection_bloc.dart';
import 'package:eightclub/features/experience_selection/presentation/view/selection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initDi();
  runApp(
    MultiBlocProvider(
      providers: [BlocProvider(create: (_) => serviceLocator<SelectionBloc>())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: ExperienceSelectionScreen(),
    );
  }
}
