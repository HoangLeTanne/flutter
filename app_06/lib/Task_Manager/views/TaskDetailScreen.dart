import 'package:flutter/material.dart';
import '../models/Task.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({Key? key, required this.task}) : super(key: key);

  Widget buildInfoSection(String label, String content) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade200, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
          SizedBox(height: 4.0),
          Text(content, style: TextStyle(fontSize: 16.0)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết Công việc'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildInfoSection('Tiêu đề', task.title),
            buildInfoSection('Mô tả', task.description),
            buildInfoSection('Trạng thái', task.status),
            buildInfoSection('Độ ưu tiên', '${task.priority}'),
            if (task.dueDate != null)
              buildInfoSection('Hạn hoàn thành', task.dueDate!.toLocal().toString()),
            buildInfoSection('Người tạo', task.createdBy),
            if (task.assignedTo != null)
              buildInfoSection('Người được giao', task.assignedTo!),
            if (task.category != null)
              buildInfoSection('Phân loại', task.category!),
            if (task.attachments != null && task.attachments!.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade200, blurRadius: 4, offset: Offset(2, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tệp đính kèm',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                    SizedBox(height: 4.0),
                    ...task.attachments!.map((file) => Text(file)).toList(),
                  ],
                ),
              ),
            SizedBox(height: 20.0),
            ElevatedButton.icon(
              onPressed: () {
                print('Cập nhật trạng thái công việc');
              },
              icon: Icon(Icons.edit),
              label: Text('Cập nhật Trạng thái'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
