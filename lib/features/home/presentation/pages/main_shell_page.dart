import 'package:flutter/material.dart';
import 'package:task_manager/features/home/presentation/pages/home_page.dart';
import 'package:task_manager/features/tasks/presentation/tasks_page.dart';
import 'package:task_manager/features/home/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:task_manager/features/chat/presentation/pages/chat_page.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(title: 'Home'),
    const TasksPage(),
    ChatPage(),
  ];

  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }
}
