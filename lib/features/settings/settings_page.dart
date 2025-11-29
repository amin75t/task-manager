import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/config/theme/app_colors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarker,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: AppColors.textLight),
        ),
        backgroundColor: AppColors.backgroundDarker,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textLight),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Categories Section
          _buildSectionCard(
            context,
            title: 'Categories',
            description: 'Manage task categories',
            icon: Icons.category,
            iconColor: AppColors.accent,
            onTap: () {
              GoRouter.of(context).push('/settings/categories');
            },
          ),
          const SizedBox(height: 12),

          // Priority Section
          _buildSectionCard(
            context,
            title: 'Priority Levels',
            description: 'Configure priority settings',
            icon: Icons.flag,
            iconColor: AppColors.warning,
            onTap: () {
              GoRouter.of(context).push('/settings/priority');
            },
          ),
          const SizedBox(height: 12),

          // Tags Section
          _buildSectionCard(
            context,
            title: 'Tags',
            description: 'Manage task tags',
            icon: Icons.label,
            iconColor: AppColors.success,
            onTap: () {
              GoRouter.of(context).push('/settings/tags');
            },
          ),
          const SizedBox(height: 24),

          // Additional Settings Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              'Other Settings',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textLight,
              ),
            ),
          ),

          _buildSectionCard(
            context,
            title: 'About',
            description: 'App information and version',
            icon: Icons.info_outline,
            iconColor: AppColors.info,
            onTap: () {
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textLight.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textLight.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textLight.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDark,
        title: const Text(
          'About Task Manager',
          style: TextStyle(color: AppColors.textLight),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version: 1.0.0',
              style: TextStyle(color: AppColors.textLight),
            ),
            SizedBox(height: 8),
            Text(
              'A modern task management app with voice transcription.',
              style: TextStyle(color: AppColors.textLight),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
