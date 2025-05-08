import 'package:flutter/material.dart';
import '../models/Task.dart';
import '../views/TaskDetailScreen.dart';
import '../views/AddEditTaskScreen.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final Function(String) onComplete;
  final Function(String) onDelete;
  final Function(Task) onEdit;
  final bool isKanbanView;

  const TaskItem({
    Key? key,
    required this.task,
    required this.onComplete,
    required this.onDelete,
    required this.onEdit,
    this.isKanbanView = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color priorityColor;
    switch (task.priority) {
      case 1:
        priorityColor = Colors.green.shade400;
        break;
      case 2:
        priorityColor = Colors.orange.shade500;
        break;
      case 3:
        priorityColor = Colors.red.shade500;
        break;
      default:
        priorityColor = Colors.grey.shade400;
    }

    Color statusColor;
    switch (task.status) {
      case 'Cần làm':
        statusColor = Colors.blue.shade400;
        break;
      case 'Đang làm':
        statusColor = Colors.amber.shade600;
        break;
      case 'Đã xong':
        statusColor = Colors.green.shade600;
        break;
      case 'Hủy':
        statusColor = Colors.grey.shade600;
        break;
      default:
        statusColor = Colors.grey.shade400;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
        );
      },
      child: Card(
        elevation: 8.0,
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [priorityColor.withOpacity(0.4), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                task.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  decoration: task.completed ? TextDecoration.lineThrough : null,
                ),
              ),
              SizedBox(height: 10),
              // Description (if any)
              if (task.description != null && task.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    task.description!,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              // Status and Due Date Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Priority info
                  Row(
                    children: [
                      Icon(Icons.flag, size: 18, color: priorityColor),
                      SizedBox(width: 6),
                      Text(
                        'Ưu tiên: ${task.priority}',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                  // Status info
                  Row(
                    children: [
                      Icon(Icons.info, size: 18, color: statusColor),
                      SizedBox(width: 6),
                      Text(
                        'Trạng thái: ${task.status}',
                        style: TextStyle(color: statusColor, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
              // Due Date (if any)
              if (task.dueDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                      SizedBox(width: 6),
                      Text(
                        'Hạn: ${task.dueDate!.toLocal().toString().split(' ')[0]}',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 12),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Complete task
                  IconButton(
                    tooltip: 'Hoàn thành',
                    icon: Icon(
                      task.completed ? Icons.check_box : Icons.check_box_outline_blank,
                      color: Colors.green,
                    ),
                    onPressed: () {
                      // Chuyển trạng thái hoàn thành và gọi lại phương thức onComplete
                      onComplete(task.id!); // Cập nhật lại trạng thái hoàn thành
                    },
                  ),
                  // Edit task
                  IconButton(
                    tooltip: 'Chỉnh sửa',
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => onEdit(task),
                  ),
                  // Delete task
                  IconButton(
                    tooltip: 'Xóa',
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteConfirmationDialog(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Xác nhận xóa'),
        content: Text('Bạn có muốn xóa công việc này không?'),
        actions: [
          TextButton(
            child: Text('Hủy'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Xóa', style: TextStyle(color: Colors.red)),
            onPressed: () {
              onDelete(task.id!);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
