import 'package:flutter/material.dart';
import 'package:task_manager/config/theme/app_colors.dart';
import 'package:task_manager/core/models/tag_model.dart';
import 'package:task_manager/core/repositories/tag_repository.dart';

class TagsSettingsPage extends StatefulWidget {
  const TagsSettingsPage({super.key});

  @override
  State<TagsSettingsPage> createState() => _TagsSettingsPageState();
}

class _TagsSettingsPageState extends State<TagsSettingsPage> {
  final TagRepository _tagRepository = TagRepository();
  List<TagModel> _tags = [];

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  void _loadTags() {
    setState(() {
      _tags = _tagRepository.getTagsSortedByUsage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tags'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTagDialog(),
          ),
        ],
      ),
      body: _tags.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _tags.length,
              itemBuilder: (context, index) {
                final tag = _tags[index];
                return _buildTagCard(tag);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.label_outline,
            size: 80,
            color: AppColors.accent.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No tags yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + to add your first tag',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagCard(TagModel tag) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getColorByIndex(tag.colorIndex).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Icon(
              Icons.label,
              color: AppColors.accent,
              size: 24,
            ),
          ),
        ),
        title: Text(
          '#${tag.name}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tag.description != null) ...[
              const SizedBox(height: 4),
              Text(
                tag.description!,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textMedium.withOpacity(0.7),
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              'Used ${tag.usageCount} ${tag.usageCount == 1 ? 'time' : 'times'}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.info,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          color: AppColors.error,
          onPressed: () => _deleteTag(tag),
        ),
      ),
    );
  }

  void _showAddTagDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    int selectedColorIndex = 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add Tag'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Tag Name',
                      prefixText: '#',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    final tag = TagModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text,
                      description: descriptionController.text.isEmpty
                          ? null
                          : descriptionController.text,
                      colorIndex: selectedColorIndex,
                      createdAt: DateTime.now(),
                    );
                    _tagRepository.addTag(tag);
                    Navigator.pop(context);
                    _loadTags();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.surfaceWhite,
                ),
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _deleteTag(TagModel tag) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tag'),
        content: Text('Are you sure you want to delete "#${tag.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _tagRepository.deleteTag(tag.id);
              if (context.mounted) {
                Navigator.pop(context);
                _loadTags();
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

  Color _getColorByIndex(int index) {
    final colors = [
      AppColors.accent,
      AppColors.accentDark,
      AppColors.accentMedium,
      AppColors.success,
      AppColors.info,
    ];
    return colors[index % colors.length];
  }
}
