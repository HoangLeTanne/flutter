import 'package:flutter/material.dart';
import '../model/Note.dart';
import '../view/NoteForm.dart'; // Màn hình thêm/sửa ghi chú

class NoteDetailScreen extends StatelessWidget {
  final Note note;

  const NoteDetailScreen({Key? key, required this.note}) : super(key: key);

  String formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color noteColor = note.color != null
        ? Color(int.parse(note.color!))
        : getPriorityColor(note.priority).withOpacity(0.1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết ghi chú'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NoteForm(note: note),
                ),
              );
              Navigator.pop(context); // Quay lại danh sách sau khi chỉnh sửa
            },
          ),
        ],
      ),
      body: Container(
        color: noteColor,
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Tiêu đề
              Text(
                note.title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              /// Mức độ ưu tiên
              Row(
                children: [
                  const Icon(Icons.flag),
                  const SizedBox(width: 6),
                  Text(
                    'Mức ưu tiên: ${note.priority} (${{
                      1: 'Thấp',
                      2: 'Trung bình',
                      3: 'Cao'
                    }[note.priority]})',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              /// Thời gian
              Text(
                'Tạo lúc: ${formatDate(note.createdAt)}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                'Chỉnh sửa gần nhất: ${formatDate(note.modifiedAt)}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 20),

              /// Nội dung
              Text(
                note.content,
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 20),

              /// Tags
              if (note.tags != null && note.tags!.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: note.tags!
                      .map((tag) => Chip(
                    label: Text(tag),
                    backgroundColor: Colors.blue.shade50,
                  ))
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
