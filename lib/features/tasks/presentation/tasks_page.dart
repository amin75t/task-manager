import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/config/router.dart';
import 'package:task_manager/config/theme/app_colors.dart';
import 'package:task_manager/core/models/task_model.dart';
import 'package:task_manager/core/repositories/task_repository.dart';
import 'package:task_manager/features/home/presentation/widgets/task_card.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final TaskRepository _taskRepository = TaskRepository();
  List<TaskModel> _tasks = [];
  String _filterType = 'all'; // all, pending, completed

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    setState(() {
      switch (_filterType) {
        case 'pending':
          _tasks = _taskRepository.getPendingTasks();
          break;
        case 'completed':
          _tasks = _taskRepository.getCompletedTasks();
          break;
        default:
          _tasks = _taskRepository.getTasksSortedByDate();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Tasks',
          style: TextStyle(color: AppColors.surfaceWhite),
        ),
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.surfaceWhite),
        actions: [
          // Filter dropdown
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filterType = value;
                _loadTasks();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Tasks'),
              ),
              const PopupMenuItem(
                value: 'pending',
                child: Text('Pending'),
              ),
              const PopupMenuItem(
                value: 'completed',
                child: Text('Completed'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await context.pushNamed(AppRoutes.addTask);
              _loadTasks(); // Refresh after adding task
            },
          ),
        ],
      ),
      body: _tasks.isEmpty
          ? _buildEmptyState(context)
          : RefreshIndicator(
              onRefresh: () async {
                _loadTasks();
              },
              child: Column(
                children: [
                  // Task stats summary
                  _buildTaskSummary(),
                  // Task list
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16, top: 8),
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        return TaskCard(task: _tasks[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _filterType == 'completed'
                ? Icons.check_circle_outline
                : Icons.task_alt,
            size: 80,
            color: AppColors.accent.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          Text(
            _filterType == 'completed'
                ? 'No completed tasks yet!'
                : _filterType == 'pending'
                    ? 'No pending tasks!'
                    : 'No tasks yet!',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.surfaceWhite,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _filterType == 'completed'
                ? 'Complete some tasks to see them here'
                : 'Create your first task to get started',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.surfaceWhite.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () async {
              await context.pushNamed(AppRoutes.addTask);
              _loadTasks();
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Task'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.surfaceWhite,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskSummary() {
    final totalTasks = _taskRepository.getTotalCount();
    final completedTasks = _taskRepository.getCompletedCount();
    final pendingTasks = _taskRepository.getPendingCount();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.textDark,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Total', totalTasks, Icons.list_alt, AppColors.info),
          Container(
            width: 1,
            height: 40,
            color: AppColors.backgroundDark,
          ),
          _buildSummaryItem('Pending', pendingTasks, Icons.pending_actions, AppColors.warning),
          Container(
            width: 1,
            height: 40,
            color: AppColors.backgroundDark,
          ),
          _buildSummaryItem('Done', completedTasks, Icons.check_circle, AppColors.success),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, int count, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.surfaceWhite,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.surfaceWhite.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
