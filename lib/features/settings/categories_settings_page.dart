import 'package:flutter/material.dart';
import 'package:task_manager/config/theme/app_colors.dart';
import 'package:task_manager/core/models/category_model.dart';
import 'package:task_manager/core/repositories/category_repository.dart';

class CategoriesSettingsPage extends StatefulWidget {
  const CategoriesSettingsPage({super.key});

  @override
  State<CategoriesSettingsPage> createState() => _CategoriesSettingsPageState();
}

class _CategoriesSettingsPageState extends State<CategoriesSettingsPage> {
  final CategoryRepository _categoryRepository = CategoryRepository();
  List<CategoryModel> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    setState(() {
      _categories = _categoryRepository.getCategoriesSortedByName();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCategoryDialog(),
          ),
        ],
      ),
      body: _categories.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return _buildCategoryCard(category);
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
            Icons.category_outlined,
            size: 80,
            color: AppColors.accent.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No categories yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + to add your first category',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(CategoryModel category) {
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
            color: _getColorByIndex(category.colorIndex).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              category.icon ?? '📁',
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: category.description != null
            ? Text(
                category.description!,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textMedium.withOpacity(0.7),
                ),
              )
            : null,
        trailing: category.isDefault
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Default',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.info,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : IconButton(
                icon: const Icon(Icons.delete_outline),
                color: AppColors.error,
                onPressed: () => _deleteCategory(category),
              ),
      ),
    );
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    int selectedColorIndex = 0;
    String selectedIcon = '📁';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add Category'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
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
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Icon:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['📁', '💼', '🎯', '🏠', '🎨', '⚡', '🔥', '💡']
                        .map((icon) => GestureDetector(
                              onTap: () {
                                setDialogState(() {
                                  selectedIcon = icon;
                                });
                              },
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: selectedIcon == icon
                                        ? AppColors.accent
                                        : Colors.grey.shade300,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    icon,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
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
                    final category = CategoryModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text,
                      description: descriptionController.text.isEmpty
                          ? null
                          : descriptionController.text,
                      colorIndex: selectedColorIndex,
                      icon: selectedIcon,
                      createdAt: DateTime.now(),
                    );
                    _categoryRepository.addCategory(category);
                    Navigator.pop(context);
                    _loadCategories();
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

  void _deleteCategory(CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _categoryRepository.deleteCategory(category.id);
              if (context.mounted) {
                Navigator.pop(context);
                _loadCategories();
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
