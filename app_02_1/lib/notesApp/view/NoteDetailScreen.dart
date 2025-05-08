import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_02_1/notesApp/model/Note.dart';
import 'package:app_02_1/notesApp/view/NoteForm.dart';

class NoteDetailScreen extends StatelessWidget {
  final Note note; // Lưu trữ thông tin của ghi chú cần hiển thị

  const NoteDetailScreen({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết ghi chú'), // Tiêu đề của AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.edit), // Nút chỉnh sửa
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteForm(note: note), // Chuyển đến màn hình chỉnh sửa ghi chú
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView( // Scroll cho phép cuộn nếu nội dung dài
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Căn lề trái cho các phần tử
          children: [
            // Tiêu đề của ghi chú
            Text(
              note.title,
              style: const TextStyle(
                fontSize: 24, // Kích thước chữ lớn
                fontWeight: FontWeight.bold, // Chữ in đậm
                color: Colors.black87, // Màu chữ
              ),
            ),
            const SizedBox(height: 8), // Khoảng cách giữa các phần tử

            // Hiển thị mức độ ưu tiên
            Text(
              'Ưu tiên: ${note.priority == 3 ? "Cao" : note.priority == 2 ? "Trung bình" : "Thấp"}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: note.priority == 3
                    ? Colors.red // Màu đỏ cho ưu tiên cao
                    : note.priority == 2
                    ? Colors.yellow.shade800 // Màu vàng cho ưu tiên trung bình
                    : Colors.green, // Màu xanh cho ưu tiên thấp
              ),
            ),
            const SizedBox(height: 8),

            // Hiển thị ngày tạo và ngày sửa đổi ghi chú
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

            // Hiển thị các thẻ (tags) của ghi chú
            if (note.tags != null && note.tags!.isNotEmpty)
              Wrap(
                spacing: 8, // Khoảng cách giữa các thẻ
                children: note.tags!
                    .map(
                      (tag) => Chip(
                    label: Text(tag), // Nội dung thẻ
                    backgroundColor: Colors.blue.shade100, // Màu nền của thẻ
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Bo góc của thẻ
                    ),
                  ),
                )
                    .toList(),
              ),
            const SizedBox(height: 16),

            // Hiển thị nội dung ghi chú
            Text(
              note.content,
              style: const TextStyle(fontSize: 16), // Kích thước chữ cho nội dung
            ),
          ],
        ),
      ),
    );
  }
}

