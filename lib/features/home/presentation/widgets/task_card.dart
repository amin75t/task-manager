import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/config/router.dart';
import 'package:task_manager/config/theme/app_colors.dart';
import 'package:task_manager/core/models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;

  const TaskCard({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarker,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.goNamed(
              AppRoutes.taskDetail,
              pathParameters: {'id': task.id},
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category/Theme chip and tags row
                Row(
                  children: [
                    // Category chip
                    if (task.category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(task.category!),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          task.category!,
                          style: const TextStyle(
                            color: AppColors.surfaceWhite,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const Spacer(),
                    // Priority indicator
                    _buildPriorityIndicator(task.priority),
                  ],
                ),
                const SizedBox(height: 12),

                // Task title
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.surfaceWhite,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    decorationColor: AppColors.surfaceWhite.withOpacity(0.6),
                    decorationThickness: 2,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // Tags
                if (task.tags != null && task.tags!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: task.tags!.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.accent.withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            color: AppColors.accent.withOpacity(0.95),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                // Due date if present
                if (task.dueDate != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: _isOverdue(task.dueDate!)
                            ? AppColors.error
                            : AppColors.surfaceWhite.withOpacity(0.7),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatDueDate(task.dueDate!),
                        style: TextStyle(
                          fontSize: 12,
                          color: _isOverdue(task.dueDate!)
                              ? AppColors.error
                              : AppColors.surfaceWhite.withOpacity(0.7),
                          fontWeight: _isOverdue(task.dueDate!)
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator(TaskPriority priority) {
    Color priorityColor;
    String priorityLabel;

    switch (priority) {
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: priorityColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: priorityColor.withOpacity(0.8), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: priorityColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            priorityLabel,
            style: TextStyle(
              color: priorityColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    // You can customize this to return different colors for different categories
    final colors = [
      AppColors.accent,
      AppColors.accentDark,
      AppColors.accentMedium,
      AppColors.success,
      AppColors.info,
    ];

    // Simple hash to get consistent color for same category
    final hash = category.hashCode.abs();
    return colors[hash % colors.length];
  }

  bool _isOverdue(DateTime dueDate) {
    return dueDate.isBefore(DateTime.now());
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (dueDay == today) {
      return 'Due Today';
    } else if (dueDay == tomorrow) {
      return 'Due Tomorrow';
    } else if (dueDay.isBefore(today)) {
      final difference = today.difference(dueDay).inDays;
      return 'Overdue by $difference day${difference > 1 ? 's' : ''}';
    } else {
      final difference = dueDay.difference(today).inDays;
      if (difference <= 7) {
        return 'Due in $difference day${difference > 1 ? 's' : ''}';
      } else {
        return 'Due ${dueDate.day}/${dueDate.month}/${dueDate.year}';
      }
    }
  }
}
