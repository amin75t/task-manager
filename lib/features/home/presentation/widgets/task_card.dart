import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/config/router.dart';
import 'package:task_manager/config/theme/app_colors.dart';
import 'package:task_manager/core/models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onToggleComplete;

  const TaskCard({
    super.key,
    required this.task,
    this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.backgroundDark,
            AppColors.backgroundDark.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: task.isCompleted
              ? AppColors.success.withOpacity(0.3)
              : AppColors.textLight.withOpacity(0.12),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
          borderRadius: BorderRadius.circular(20),
          splashColor: AppColors.accent.withOpacity(0.1),
          highlightColor: AppColors.accent.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category and Priority row
                Row(
                  children: [
                    // Category chip
                    if (task.category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getCategoryColor(task.category!),
                              _getCategoryColor(task.category!).withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: _getCategoryColor(task.category!).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getCategoryIcon(task.category!),
                              size: 14,
                              color: AppColors.surfaceWhite,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              task.category!,
                              style: const TextStyle(
                                color: AppColors.surfaceWhite,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Spacer(),
                    // Priority indicator
                    _buildPriorityIndicator(task.priority),
                  ],
                ),
                const SizedBox(height: 16),

                // Task title with checkbox
                Row(
                  children: [
                    // Checkbox
                    GestureDetector(
                      onTap: onToggleComplete,
                      child: Container(
                        width: 28,
                        height: 28,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: task.isCompleted
                              ? AppColors.success
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: task.isCompleted
                                ? AppColors.success
                                : AppColors.textLight.withOpacity(0.4),
                            width: 2.5,
                          ),
                          boxShadow: task.isCompleted
                              ? [
                                  BoxShadow(
                                    color: AppColors.success.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: task.isCompleted
                            ? const Icon(
                                Icons.check_rounded,
                                size: 18,
                                color: AppColors.surfaceWhite,
                              )
                            : null,
                      ),
                    ),
                    // Title
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: task.isCompleted
                              ? AppColors.textLight.withOpacity(0.6)
                              : AppColors.textLight,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor: AppColors.textLight.withOpacity(0.5),
                          decorationThickness: 2,
                          height: 1.4,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // Tags
                if (task.tags != null && task.tags!.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 32,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: task.tags!.length > 3 ? 4 : task.tags!.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        if (index == 3 && task.tags!.length > 3) {
                          // Show +N more indicator
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.textLight.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                '+${task.tags!.length - 3}',
                                style: TextStyle(
                                  color: AppColors.textLight.withOpacity(0.7),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }

                        final tag = task.tags![index];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.accent.withOpacity(0.4),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.tag,
                                size: 12,
                                color: AppColors.accent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                tag,
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],

                // Due date if present
                if (task.dueDate != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _isOverdue(task.dueDate!)
                          ? AppColors.error.withOpacity(0.1)
                          : AppColors.info.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isOverdue(task.dueDate!)
                            ? AppColors.error.withOpacity(0.4)
                            : AppColors.info.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isOverdue(task.dueDate!)
                              ? Icons.warning_amber_rounded
                              : Icons.schedule_rounded,
                          size: 16,
                          color: _isOverdue(task.dueDate!)
                              ? AppColors.error
                              : AppColors.info,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDueDate(task.dueDate!),
                          style: TextStyle(
                            fontSize: 12,
                            color: _isOverdue(task.dueDate!)
                                ? AppColors.error
                                : AppColors.info,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
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
    IconData priorityIcon;

    switch (priority) {
      case TaskPriority.urgent:
        priorityColor = AppColors.error;
        priorityLabel = 'Urgent';
        priorityIcon = Icons.priority_high;
        break;
      case TaskPriority.high:
        priorityColor = AppColors.warning;
        priorityLabel = 'High';
        priorityIcon = Icons.arrow_upward;
        break;
      case TaskPriority.medium:
        priorityColor = AppColors.info;
        priorityLabel = 'Medium';
        priorityIcon = Icons.remove;
        break;
      case TaskPriority.low:
        priorityColor = AppColors.success;
        priorityLabel = 'Low';
        priorityIcon = Icons.arrow_downward;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: priorityColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: priorityColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: priorityColor.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            priorityIcon,
            size: 14,
            color: priorityColor,
          ),
          const SizedBox(width: 6),
          Text(
            priorityLabel,
            style: TextStyle(
              color: priorityColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return Icons.work_rounded;
      case 'personal':
        return Icons.person_rounded;
      case 'shopping':
        return Icons.shopping_cart_rounded;
      case 'health':
        return Icons.health_and_safety_rounded;
      case 'learning':
        return Icons.school_rounded;
      default:
        return Icons.folder_rounded;
    }
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
