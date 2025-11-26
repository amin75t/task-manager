import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/features/home/presentation/pages/add_task_page.dart';
import 'package:task_manager/features/home/presentation/pages/chat_page.dart';
import 'package:task_manager/features/home/presentation/pages/home_page.dart';
import 'package:task_manager/features/home/presentation/pages/task_detail_page.dart';
import 'package:task_manager/features/home/presentation/pages/tasks_page.dart';
import 'package:task_manager/features/home/presentation/widgets/custom_bottom_nav_bar.dart';

class AppRoutes {
  // Route names
  static const String home = 'home';
  static const String tasks = 'tasks';
  static const String chat = 'chat';
  static const String taskDetail = 'task-detail';
  static const String addTask = 'add-task';
}

class AppPaths {
  // Route paths
  static const String home = '/';
  static const String tasks = '/tasks';
  static const String chat = '/chat';
  static const String taskDetail = '/tasks/:id';
  static const String addTask = '/add-task';
}

// Global key for navigator
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppPaths.home,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // Home branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppPaths.home,
              name: AppRoutes.home,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: HomePage(title: 'Home'),
              ),
            ),
          ],
        ),
        // Tasks branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppPaths.tasks,
              name: AppRoutes.tasks,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: TasksPage(),
              ),
            ),
          ],
        ),
        // Chat branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppPaths.chat,
              name: AppRoutes.chat,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ChatPage(),
              ),
            ),
          ],
        ),
      ],
    ),
    // Routes outside the shell (full screen)
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppPaths.taskDetail,
      name: AppRoutes.taskDetail,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return TaskDetailPage(taskId: id);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppPaths.addTask,
      name: AppRoutes.addTask,
      builder: (context, state) => const AddTaskPage(),
    ),
  ],
  errorBuilder: (context, state) => const ErrorPage(),
);

/// Scaffold with bottom navigation bar
class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          // If we're not on the home tab, go to home
          if (navigationShell.currentIndex != 0) {
            navigationShell.goBranch(0);
          }
        }
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => _onTap(context, index),
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: const Center(child: Text('Page not found')),
    );
  }
}
