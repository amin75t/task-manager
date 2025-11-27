import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/config/theme/app_colors.dart';
import 'package:task_manager/core/models/task_model.dart';
import 'package:task_manager/core/repositories/task_repository.dart';

class TaskDetailPage extends StatefulWidget {
  final String taskId;
  const TaskDetailPage({super.key, required this.taskId});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final TaskRepository _taskRepository = TaskRepository();
  TaskModel? _task;

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  void _loadTask() {
    setState(() {
      _task = _taskRepository.getTaskById(widget.taskId);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_task == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Task Detail'),
        ),
        body: const Center(
          child: Text('Task not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Detail'),
        actions: [
          IconButton(
            icon: Icon(
              _task!.isCompleted ? Icons.check_circle : Icons.circle_outlined,
            ),
            onPressed: () async {
              await _taskRepository.toggleTaskCompletion(widget.taskId);
              _loadTask();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category/Theme header
            if (_task!.category != null) _buildCategoryHeader(),

            // Task title
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                _task!.title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  decoration: _task!.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),

            // Tags
            if (_task!.tags != null && _task!.tags!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _task!.tags!.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.accent.withOpacity(0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        '#$tag',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 24),

            // Description
            if (_task!.description != null && _task!.description!.isNotEmpty)
              _buildInfoSection(
                'Description',
                Icons.description,
                _task!.description!,
              ),

            // Deadline
            if (_task!.dueDate != null)
              _buildDateSection(
                'Deadline',
                Icons.calendar_today,
                _task!.dueDate!,
              ),

            // Priority
            _buildPrioritySection(),

            // Additional info
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Divider(),
            ),

            // Created date
            _buildInfoRow(
              Icons.access_time,
              'Created',
              _formatDateTime(_task!.createdAt),
            ),

            // Updated date
            if (_task!.updatedAt != null)
              _buildInfoRow(
                Icons.update,
                'Last Updated',
                _formatDateTime(_task!.updatedAt!),
              ),

            // Completed date
            if (_task!.isCompleted && _task!.completedAt != null)
              _buildInfoRow(
                Icons.check_circle,
                'Completed',
                _formatDateTime(_task!.completedAt!),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: _getCategoryColor(_task!.category!),
        gradient: LinearGradient(
          colors: [
            _getCategoryColor(_task!.category!),
            _getCategoryColor(_task!.category!).withOpacity(0.7),
          ],
        ),
      ),
      child: Text(
        _task!.category!,
        style: const TextStyle(
          color: AppColors.surfaceWhite,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, IconData icon, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.accent, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accent.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textDark,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection(String title, IconData icon, DateTime date) {
    final isOverdue = date.isBefore(DateTime.now()) && !_task!.isCompleted;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.accent, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isOverdue
                  ? AppColors.error.withOpacity(0.1)
                  : AppColors.backgroundLight.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isOverdue ? AppColors.error : AppColors.accent.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Text(
                  _formatDateTime(date),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isOverdue ? AppColors.error : AppColors.textDark,
                  ),
                ),
                if (isOverdue) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Overdue',
                      style: TextStyle(
                        color: AppColors.surfaceWhite,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrioritySection() {
    Color priorityColor;
    String priorityLabel;

    switch (_task!.priority) {
      case TaskPriority.urgent:
        priorityColor = AppColors.error;
        priorityLabel = 'Urgent';
        break;
      case TaskPriority.high:
        priorityColor = AppColors.warning;
        priorityLabel = 'High';
        break;
      case TaskPriority.medium:
        priorityColor = AppColors.info;
        priorityLabel = 'Medium';
        break;
      case TaskPriority.low:
        priorityColor = AppColors.success;
        priorityLabel = 'Low';
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.flag, color: AppColors.accent, size: 20),
              SizedBox(width: 8),
              Text(
                'Priority',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: priorityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: priorityColor, width: 2),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: priorityColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  priorityLabel,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: priorityColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent.withOpacity(0.7), size: 18),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textMedium.withOpacity(0.8),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getCategoryColor(String category) {
    final colors = [
      AppColors.accent,
      AppColors.accentDark,
      AppColors.accentMedium,
      AppColors.success,
      AppColors.info,
    ];

    final hash = category.hashCode.abs();
    return colors[hash % colors.length];
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _taskRepository.deleteTask(widget.taskId);
              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                context.pop(); // Go back to task list
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
