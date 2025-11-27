import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/config/theme/app_colors.dart';
import 'package:task_manager/core/models/task_model.dart';
import 'package:task_manager/core/models/category_model.dart';
import 'package:task_manager/core/models/tag_model.dart';
import 'package:task_manager/core/repositories/task_repository.dart';
import 'package:task_manager/core/repositories/category_repository.dart';
import 'package:task_manager/core/repositories/tag_repository.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final TaskRepository _taskRepository = TaskRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();
  final TagRepository _tagRepository = TagRepository();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  TaskPriority _selectedPriority = TaskPriority.medium;
  String? _selectedCategory;
  List<String> _selectedTags = [];
  DateTime? _selectedDueDate;

  List<CategoryModel> _categories = [];
  List<TagModel> _tags = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _categories = _categoryRepository.getAllCategories();
      _tags = _tagRepository.getAllTags();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accent,
              surface: AppColors.backgroundDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      final task = TaskModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        createdAt: DateTime.now(),
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
        category: _selectedCategory,
        tags: _selectedTags.isEmpty ? null : _selectedTags,
      );

      await _taskRepository.addTask(task);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarker,
      appBar: AppBar(
        title: const Text(
          'Add Task',
          style: TextStyle(color: AppColors.textLight),
        ),
        backgroundColor: AppColors.backgroundDarker,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textLight),
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Title Input
            _buildLabel('Title'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              style: const TextStyle(color: AppColors.textLight),
              decoration: _buildInputDecoration(
                hint: 'Enter task title',
                icon: Icons.title,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Description Input
            _buildLabel('Description (Optional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              style: const TextStyle(color: AppColors.textLight),
              maxLines: 4,
              decoration: _buildInputDecoration(
                hint: 'Enter task description',
                icon: Icons.description,
              ),
            ),
            const SizedBox(height: 24),

            // Category Selection
            _buildLabel('Category'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.textLight.withOpacity(0.2),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  hint: const Text(
                    'Select category',
                    style: TextStyle(color: AppColors.textLight),
                  ),
                  isExpanded: true,
                  dropdownColor: AppColors.backgroundDark,
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.accent),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category.name,
                      child: Row(
                        children: [
                          Text(
                            category.icon ?? '📁',
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            category.name,
                            style: const TextStyle(color: AppColors.textLight),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Priority Selection
            _buildLabel('Priority'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: TaskPriority.values.map((priority) {
                final isSelected = _selectedPriority == priority;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPriority = priority;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _getPriorityColor(priority).withOpacity(0.2)
                          : AppColors.backgroundDark,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? _getPriorityColor(priority)
                            : AppColors.textLight.withOpacity(0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getPriorityColor(priority),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getPriorityLabel(priority),
                          style: TextStyle(
                            color: isSelected
                                ? _getPriorityColor(priority)
                                : AppColors.textLight,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Due Date
            _buildLabel('Due Date (Optional)'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectDueDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.textLight.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: AppColors.accent,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDueDate == null
                          ? 'Select due date'
                          : '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}',
                      style: TextStyle(
                        color: _selectedDueDate == null
                            ? AppColors.textLight.withOpacity(0.6)
                            : AppColors.textLight,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    if (_selectedDueDate != null)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDueDate = null;
                          });
                        },
                        child: const Icon(
                          Icons.clear,
                          color: AppColors.textLight,
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tags
            _buildLabel('Tags (Optional)'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tags.map((tag) {
                final isSelected = _selectedTags.contains(tag.name);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedTags.remove(tag.name);
                      } else {
                        _selectedTags.add(tag.name);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.accent.withOpacity(0.2)
                          : AppColors.backgroundDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.accent
                            : AppColors.textLight.withOpacity(0.2),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      '#${tag.name}',
                      style: TextStyle(
                        color: isSelected ? AppColors.accent : AppColors.textLight,
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textLight,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: AppColors.textLight.withOpacity(0.4),
      ),
      prefixIcon: Icon(icon, color: AppColors.accent),
      filled: true,
      fillColor: AppColors.backgroundDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.textLight.withOpacity(0.2),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.textLight.withOpacity(0.2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.accent,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.error,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 2,
        ),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return AppColors.error;
      case TaskPriority.high:
        return AppColors.warning;
      case TaskPriority.medium:
        return AppColors.info;
      case TaskPriority.low:
        return AppColors.success;
    }
  }

  String _getPriorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return 'Urgent';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }
}
