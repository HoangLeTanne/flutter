import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_02_1/notesApp/model/Note.dart';
import 'package:app_02_1/notesApp/view/NoteForm.dart';

class NoteDetailScreen extends StatelessWidget {
  final Note note;

  const NoteDetailScreen({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết ghi chú'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteForm(note: note),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              note.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // Priority
            Text(
              'Ưu tiên: ${note.priority == 3 ? "Cao" : note.priority == 2 ? "Trung bình" : "Thấp"}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: note.priority == 3
                    ? Colors.red
                    : note.priority == 2
                    ? Colors.yellow.shade800
                    : Colors.green,
              ),
            ),
            const SizedBox(height: 8),

            // Date Created and Modified
            Text(
              'Tạo: ${DateFormat('dd/MM/yyyy HH:mm').format(note.createdAt)}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              'Cập nhật: ${DateFormat('dd/MM/yyyy HH:mm').format(note.modifiedAt)}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Tags
            if (note.tags != null && note.tags!.isNotEmpty)
              Wrap(
                spacing: 8,
                children: note.tags!
                    .map(
                      (tag) => Chip(
                    label: Text(tag),
                    backgroundColor: Colors.blue.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                )
                    .toList(),
              ),
            const SizedBox(height: 16),

            // Content
            Text(
              note.content,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
