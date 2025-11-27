import 'package:flutter/material.dart';
import 'package:task_manager/config/theme/app_colors.dart';
import 'package:task_manager/core/models/task_model.dart';

class PrioritySettingsPage extends StatelessWidget {
  const PrioritySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarker,
      appBar: AppBar(
        title: const Text(
          'Priority Levels',
          style: TextStyle(color: AppColors.textLight),
        ),
        backgroundColor: AppColors.backgroundDarker,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textLight),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              'Task Priority Levels',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textLight,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildPriorityCard(
            priority: TaskPriority.urgent,
            title: 'Urgent',
            description: 'Requires immediate attention',
            color: AppColors.error,
            icon: Icons.priority_high,
          ),
          const SizedBox(height: 12),
          _buildPriorityCard(
            priority: TaskPriority.high,
            title: 'High',
            description: 'Important and time-sensitive',
            color: AppColors.warning,
            icon: Icons.arrow_upward,
          ),
          const SizedBox(height: 12),
          _buildPriorityCard(
            priority: TaskPriority.medium,
            title: 'Medium',
            description: 'Standard priority tasks',
            color: AppColors.info,
            icon: Icons.drag_handle,
          ),
          const SizedBox(height: 12),
          _buildPriorityCard(
            priority: TaskPriority.low,
            title: 'Low',
            description: 'Can be done when time permits',
            color: AppColors.success,
            icon: Icons.arrow_downward,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.info.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.info,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Priority Guide',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  'Priority levels help you organize tasks by importance and urgency. Use these levels to focus on what matters most.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textLight,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityCard({
    required TaskPriority priority,
    required String title,
    required String description,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
