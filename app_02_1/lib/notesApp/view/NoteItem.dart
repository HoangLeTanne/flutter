import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_02_1/notesApp/model/Note.dart';
import 'package:app_02_1/notesApp/view/NoteDetailScreen.dart';

class NoteItem extends StatelessWidget {
  final Note note;
  final VoidCallback onDelete; // Hàm xóa ghi chú
  final Function(Note) onEdit; // Hàm chỉnh sửa ghi chú
  final Function(Note) onToggleComplete; // Hàm thay đổi trạng thái hoàn thành
  final bool isGridView; // Kiểm tra xem có đang ở chế độ Grid không

  const NoteItem({
    Key? key,
    required this.note,
    required this.onDelete,
    required this.onEdit,
    required this.onToggleComplete,
    required this.isGridView,
  }) : super(key: key);

  // Hàm xác định màu sắc của ghi chú dựa trên mức độ ưu tiên
  Color _getPriorityColor() {
    switch (note.priority) {
      case 3:
        return Colors.red.shade300; // Ưu tiên cao -> màu đỏ
      case 2:
        return Colors.yellow.shade300; // Ưu tiên trung bình -> màu vàng
      case 1:
      default:
        return Colors.green.shade300; // Ưu tiên thấp -> màu xanh
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Khi nhấn vào ghi chú, chuyển đến màn hình chi tiết ghi chú
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NoteDetailScreen(note: note),
          ),
        );
      },
      child: Card(
        // Nếu ghi chú có màu sắc, sử dụng màu đó; nếu không, sử dụng màu theo ưu tiên
        color: note.color != null ? Color(int.parse('0xFF${note.color!.replaceFirst('#', '')}')) : _getPriorityColor(),
        margin: const EdgeInsets.all(8),
        child: isGridView // Kiểm tra nếu đang ở chế độ Grid hay List
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                note.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  decoration: note.isCompleted ? TextDecoration.lineThrough : null, // Gạch ngang nếu ghi chú đã hoàn thành
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                note.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Cập nhật: ${DateFormat('dd/MM/yyyy HH:mm').format(note.modifiedAt)}', // Định dạng ngày giờ cập nhật
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
            if (note.tags != null && note.tags!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Wrap(
                  spacing: 4,
                  children: note.tags!.map((tag) => Chip(label: Text(tag, style: const TextStyle(fontSize: 10)))).toList(),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(note.isCompleted ? Icons.check_circle : Icons.check_circle_outline),
                  onPressed: () => onToggleComplete(note), // Thay đổi trạng thái hoàn thành
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => onEdit(note), // Mở màn hình chỉnh sửa ghi chú
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // Hiển thị hộp thoại xác nhận xóa
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Xác nhận xóa'),
                        content: const Text('Bạn có chắc chắn muốn xóa ghi chú này?'),
                        actions: [
                          TextButton(
                            child: const Text('Hủy'),
                            onPressed: () => Navigator.pop(context),
                          ),
                          TextButton(
                            child: const Text('Xóa'),
                            onPressed: () {
                              onDelete(); // Xóa ghi chú khi xác nhận
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        )
            : ListTile(
          title: Text(
            note.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              decoration: note.isCompleted ? TextDecoration.lineThrough : null, // Gạch ngang nếu hoàn thành
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.content,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Cập nhật: ${DateFormat('dd/MM/yyyy HH:mm').format(note.modifiedAt)}', // Định dạng ngày giờ cập nhật
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              if (note.tags != null && note.tags!.isNotEmpty)
                Wrap(
                  spacing: 4,
                  children: note.tags!.map((tag) => Chip(label: Text(tag, style: const TextStyle(fontSize: 10)))).toList(),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => onEdit(note), // Chỉnh sửa ghi chú
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  // Hiển thị hộp thoại xác nhận xóa
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Xác nhận xóa'),
                      content: const Text('Bạn có chắc chắn muốn xóa ghi chú này?'),
                      actions: [
                        TextButton(
                          child: const Text('Hủy'),
                          onPressed: () => Navigator.pop(context),
                        ),
                        TextButton(
                          child: const Text('Xóa'),
                          onPressed: () {
                            onDelete(); // Xóa ghi chú khi xác nhận
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
