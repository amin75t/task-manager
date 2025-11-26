import 'package:flutter/material.dart';
import 'package:task_manager/config/router.dart';
import 'package:task_manager/config/theme/app_theme.dart';
import 'package:task_manager/locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup service locator and initialize services
  await setupLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Follows system theme
      routerConfig: appRouter,
    );
  }
}
