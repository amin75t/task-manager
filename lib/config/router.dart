import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/features/home/presentation/pages/add_task_page.dart';
import 'package:task_manager/features/home/presentation/pages/home_page.dart';
import 'package:task_manager/features/home/presentation/pages/task_detail_page.dart';
import 'package:task_manager/features/home/presentation/pages/tasks_page.dart';
import 'package:task_manager/features/home/presentation/pages/voice_task_page.dart';

class AppRoutes {
  // Route names
  static const String home = 'home';
  static const String tasks = 'tasks';
  static const String taskDetail = 'task-detail';
  static const String addTask = 'add-task';
  static const String voiceTask = 'voice-task';
}

class AppPaths {
  // Route paths
  static const String home = '/';
  static const String tasks = '/tasks';
  static const String taskDetail = '/tasks/:id';
  static const String addTask = '/add-task';
  static const String voiceTask = '/voice-task';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppPaths.home,
  routes: [
    GoRoute(
      path: AppPaths.home,
      name: AppRoutes.home,
      builder: (context, state) => const HomePage(title: 'Task Manager'),
    ),
    GoRoute(
      path: AppPaths.tasks,
      name: AppRoutes.tasks,
      builder: (context, state) => const TasksPage(),
    ),
    GoRoute(
      path: AppPaths.taskDetail,
      name: AppRoutes.taskDetail,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return TaskDetailPage(taskId: id);
      },
    ),
    GoRoute(
      path: AppPaths.addTask,
      name: AppRoutes.addTask,
      builder: (context, state) => const AddTaskPage(),
    ),
    GoRoute(
      path: AppPaths.voiceTask,
      name: AppRoutes.voiceTask,
      builder: (context, state) => const VoiceTaskPage(),
    ),
  ],
  errorBuilder: (context, state) => const ErrorPage(),
);

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: const Center(
        child: Text('Page not found'),
      ),
    );
  }
}
