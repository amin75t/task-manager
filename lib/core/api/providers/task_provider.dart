import 'package:fpdart/fpdart.dart';
import 'package:task_manager/core/api/api_client.dart';
import 'package:task_manager/core/models/task_model.dart';

/// Task API Provider
///
/// Handles all task-related API requests to the backend
/// Uses Either pattern for error handling
class TaskProvider {
  final ApiClient _apiClient;

  TaskProvider(this._apiClient);

  /// Fetch all tasks from server
  ///
  /// GET /tasks
  /// Returns list of tasks from server
  Future<List<TaskModel>> fetchTasks() async {
    try {
      print('📥 [TaskProvider] Fetching tasks from server...');
      final response = await _apiClient.dio.get('/tasks');

      if (response.statusCode == 200) {
        // Handle both array response and object with tasks key
        List<dynamic> data;
        if (response.data is List) {
          data = response.data as List<dynamic>;
        } else if (response.data is Map && response.data['tasks'] != null) {
          data = response.data['tasks'] as List<dynamic>;
        } else {
          print('📥 [TaskProvider] Unexpected response format: ${response.data.runtimeType}');
          data = [];
        }

        print('📥 [TaskProvider] Parsing ${data.length} tasks...');
        final tasks = data.map((json) {
          try {
            return TaskModel.fromJson(json as Map<String, dynamic>);
          } catch (e) {
            print('📥 [TaskProvider] Error parsing task: $e');
            print('📥 [TaskProvider] Task data: $json');
            rethrow;
          }
        }).toList();

        print('📥 [TaskProvider] ✅ Fetched ${tasks.length} tasks');
        return tasks;
      } else {
        throw Exception('Failed to fetch tasks: ${response.statusCode}');
      }
    } catch (e) {
      print('📥 [TaskProvider] ❌ Error fetching tasks: $e');
      rethrow;
    }
  }

  /// Create a new task on server
  ///
  /// POST /tasks
  /// Returns Either<String, TaskModel>
  /// Left: Error message
  /// Right: Created task with server-generated data
  Future<Either<String, TaskModel>> createTask(TaskModel task) async {
    try {
      print('📤 [TaskProvider] Creating task: ${task.title}');

      // Use API format for request body
      final response = await _apiClient.dio.post(
        '/tasks',
        data: task.toApiJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('📤 [TaskProvider] ✅ Task created successfully');
        print('📤 [TaskProvider] Response: ${response.data}');

        // Map server response back to TaskModel
        final createdTask = TaskModel.fromJson({
          ...response.data,
          'id': task.id, // Use local ID if server doesn't provide one
        });

        return Right(createdTask);
      } else {
        final error = 'Failed to create task: ${response.statusCode}';
        print('📤 [TaskProvider] ❌ $error');
        return Left(error);
      }
    } catch (e) {
      final error = 'Error creating task: $e';
      print('📤 [TaskProvider] ❌ $error');
      return Left(error);
    }
  }

  /// Update a task on server
  ///
  /// PUT /tasks/:id
  /// Returns the updated task
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      print('📤 [TaskProvider] Updating task: ${task.id}');
      final response = await _apiClient.dio.put(
        '/tasks/${task.id}',
        data: task.toJson(),
      );

      if (response.statusCode == 200) {
        final updatedTask = TaskModel.fromJson(response.data);
        print('📤 [TaskProvider] ✅ Task updated successfully');
        return updatedTask;
      } else {
        throw Exception('Failed to update task: ${response.statusCode}');
      }
    } catch (e) {
      print('📤 [TaskProvider] ❌ Error updating task: $e');
      rethrow;
    }
  }

  /// Delete a task on server
  ///
  /// DELETE /tasks/:id
  Future<void> deleteTask(String taskId) async {
    try {
      print('📤 [TaskProvider] Deleting task: $taskId');
      final response = await _apiClient.dio.delete('/tasks/$taskId');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('📤 [TaskProvider] ✅ Task deleted successfully');
      } else {
        throw Exception('Failed to delete task: ${response.statusCode}');
      }
    } catch (e) {
      print('📤 [TaskProvider] ❌ Error deleting task: $e');
      rethrow;
    }
  }

  /// Batch sync tasks
  ///
  /// POST /tasks/sync
  /// Send local tasks to server and get back synchronized data
  Future<List<TaskModel>> syncTasks(List<TaskModel> localTasks) async {
    try {
      print('🔄 [TaskProvider] Syncing ${localTasks.length} tasks...');
      final response = await _apiClient.dio.post(
        '/tasks/sync',
        data: {
          'tasks': localTasks.map((t) => t.toJson()).toList(),
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['tasks'] ?? response.data;
        final tasks = data.map((json) => TaskModel.fromJson(json)).toList();
        print('🔄 [TaskProvider] ✅ Synced ${tasks.length} tasks');
        return tasks;
      } else {
        throw Exception('Failed to sync tasks: ${response.statusCode}');
      }
    } catch (e) {
      print('🔄 [TaskProvider] ❌ Error syncing tasks: $e');
      rethrow;
    }
  }
}
