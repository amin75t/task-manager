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

  Future<void> _toggleTaskCompletion(TaskModel task) async {
    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
      completedAt: !task.isCompleted ? DateTime.now() : null,
    );
    await _taskRepository.updateTask(updatedTask);
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarker,
      appBar: AppBar(
        title: const Text(
          '',
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: AppColors.backgroundDarker,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textLight),
        actions: [
          // Filter dropdown
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accent.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.filter_list_rounded,
                  color: AppColors.accent,
                  size: 20,
                ),
              ),
              color: AppColors.backgroundDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: AppColors.textLight.withOpacity(0.15),
                  width: 1,
                ),
              ),
              onSelected: (value) {
                setState(() {
                  _filterType = value;
                  _loadTasks();
                });
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'all',
                  child: Row(
                    children: [
                      Icon(
                        Icons.list_alt_rounded,
                        color: _filterType == 'all' ? AppColors.accent : AppColors.textLight,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'All Tasks',
                        style: TextStyle(
                          color: _filterType == 'all' ? AppColors.accent : AppColors.textLight,
                          fontWeight: _filterType == 'all' ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'pending',
                  child: Row(
                    children: [
                      Icon(
                        Icons.pending_actions_rounded,
                        color: _filterType == 'pending' ? AppColors.warning : AppColors.textLight,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Pending',
                        style: TextStyle(
                          color: _filterType == 'pending' ? AppColors.warning : AppColors.textLight,
                          fontWeight: _filterType == 'pending' ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'completed',
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: _filterType == 'completed' ? AppColors.success : AppColors.textLight,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Completed',
                        style: TextStyle(
                          color: _filterType == 'completed' ? AppColors.success : AppColors.textLight,
                          fontWeight: _filterType == 'completed' ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accent,
                      AppColors.accent.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: AppColors.surfaceWhite,
                  size: 20,
                ),
              ),
              onPressed: () async {
                await context.pushNamed(AppRoutes.addTask);
                _loadTasks();
              },
            ),
          ),
        ],
      ),
      body: _tasks.isEmpty
          ? _buildEmptyState(context)
          : RefreshIndicator(
              color: AppColors.accent,
              backgroundColor: AppColors.backgroundDark,
              onRefresh: () async {
                _loadTasks();
              },
              child: Column(
                children: [
                  // Task stats summary
                  _buildTaskSummary(),
                  // Active filter indicator
                  if (_filterType != 'all') _buildFilterIndicator(),
                  // Task list
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 20, top: 8),
                      itemCount: _tasks.length,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return TaskCard(
                          task: _tasks[index],
                          onToggleComplete: () => _toggleTaskCompletion(_tasks[index]),
                        );
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
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _filterType == 'completed'
                ? 'Complete some tasks to see them here'
                : 'Create your first task to get started',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMedium.withOpacity(0.7),
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
    final completionRate = totalTasks > 0 ? (completedTasks / totalTasks * 100).round() : 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.backgroundDark,
            AppColors.backgroundDark.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accent.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Task Overview',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textLight.withOpacity(0.7),
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.success.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      size: 14,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$completionRate%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Total', totalTasks, Icons.list_alt_rounded, AppColors.info),
              Container(
                width: 1.5,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.textLight.withOpacity(0.0),
                      AppColors.textLight.withOpacity(0.15),
                      AppColors.textLight.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
              _buildSummaryItem('Pending', pendingTasks, Icons.pending_actions_rounded, AppColors.warning),
              Container(
                width: 1.5,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.textLight.withOpacity(0.0),
                      AppColors.textLight.withOpacity(0.15),
                      AppColors.textLight.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
              _buildSummaryItem('Done', completedTasks, Icons.check_circle_rounded, AppColors.success),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterIndicator() {
    final filterInfo = _filterType == 'pending'
        ? {'label': 'Pending Tasks', 'icon': Icons.pending_actions_rounded, 'color': AppColors.warning}
        : {'label': 'Completed Tasks', 'icon': Icons.check_circle_rounded, 'color': AppColors.success};

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: (filterInfo['color'] as Color).withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (filterInfo['color'] as Color).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            filterInfo['icon'] as IconData,
            size: 18,
            color: filterInfo['color'] as Color,
          ),
          const SizedBox(width: 10),
          Text(
            'Showing: ${filterInfo['label']}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: filterInfo['color'] as Color,
              letterSpacing: 0.2,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              setState(() {
                _filterType = 'all';
                _loadTasks();
              });
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: (filterInfo['color'] as Color).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: filterInfo['color'] as Color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, int count, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textLight,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textLight.withOpacity(0.6),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
