import 'package:flutter/material.dart';
import 'package:task_manager/config/router.dart';
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}
