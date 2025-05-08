import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:app_02_1/notesApp/model/Note.dart';

class NoteForm extends StatefulWidget {
  final Note? note; // Lưu thông tin ghi chú nếu có, dùng để chỉnh sửa

  const NoteForm({Key? key, this.note}) : super(key: key);

  @override
  _NoteFormState createState() => _NoteFormState();
}

class _NoteFormState extends State<NoteForm> {
  final _formKey = GlobalKey<FormState>(); // Khóa để xác thực form
  final _titleController = TextEditingController(); // Điều khiển cho tiêu đề
  final _contentController = TextEditingController(); // Điều khiển cho nội dung
  final _tagController = TextEditingController(); // Điều khiển cho nhãn

  int _priority = 1; // Mặc định mức độ ưu tiên là "Thấp"
  List<String> _tags = []; // Danh sách các nhãn
  String? _color; // Lưu màu sắc của ghi chú

  @override
  void initState() {
    super.initState();
    // Nếu có ghi chú (chỉnh sửa), điền thông tin vào các trường
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _priority = widget.note!.priority;
      _tags = widget.note!.tags ?? [];
      _color = widget.note!.color;
    }
  }

  @override
  void dispose() {
    // Giải phóng bộ điều khiển khi không sử dụng nữa
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  // Thêm nhãn mới vào danh sách
  void _addTag() {
    String tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear(); // Xóa nội dung trong ô nhập
      });
    }
  }

  // Xóa nhãn khỏi danh sách
  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  // Chọn màu sắc ghi chú
  void _pickColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn màu ghi chú'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _color != null
                ? Color(int.parse('0xFF${_color!.replaceFirst('#', '')}'))
                : Colors.blue,
            onColorChanged: (color) {
              setState(() {
                _color =
                '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}'; // Chuyển đổi màu sang mã hex
              });
            },
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Xong'),
            onPressed: () => Navigator.pop(context), // Đóng hộp thoại
          ),
        ],
      ),
    );
  }

  // Xử lý khi người dùng nhấn nút "Thêm" hoặc "Cập nhật"
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final note = Note(
        id: widget.note?.id,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        priority: _priority,
        createdAt: widget.note?.createdAt ?? now,
        modifiedAt: now,
        tags: _tags.isNotEmpty ? _tags : null,
        color: _color,
        isCompleted: widget.note?.isCompleted ?? false,
      );
      Navigator.pop(context, note); // Trả về ghi chú đã thay đổi hoặc mới
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null; // Kiểm tra xem là chỉnh sửa hay thêm mới

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Cập nhật ghi chú' : 'Thêm ghi chú mới'), // Tiêu đề AppBar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Vui lòng nhập tiêu đề' : null, // Kiểm tra yêu cầu tiêu đề
              ),
              const SizedBox(height: 16),

              // Nội dung
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Nội dung',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) =>
                value == null || value.isEmpty ? 'Vui lòng nhập nội dung' : null, // Kiểm tra yêu cầu nội dung
              ),
              const SizedBox(height: 16),

              // Ưu tiên
              DropdownButtonFormField<int>(
                value: _priority,
                decoration: const InputDecoration(
                  labelText: 'Mức độ ưu tiên',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('🟢 Thấp')),
                  DropdownMenuItem(value: 2, child: Text('🟡 Trung bình')),
                  DropdownMenuItem(value: 3, child: Text('🔴 Cao')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _priority = value); // Cập nhật mức độ ưu tiên
                },
              ),
              const SizedBox(height: 16),

              // Thêm nhãn
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      decoration: const InputDecoration(
                        labelText: 'Thêm nhãn',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _addTag(), // Thêm nhãn khi nhấn Enter
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addTag,
                    child: const Text('Thêm'), // Nút thêm nhãn
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Hiển thị các nhãn đã thêm
              if (_tags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _tags
                      .map((tag) => Chip(
                    label: Text(tag),
                    backgroundColor: Colors.lightBlue.shade50,
                    deleteIcon: const Icon(Icons.close),
                    onDeleted: () => _removeTag(tag), // Xóa nhãn
                  ))
                      .toList(),
                ),
              const SizedBox(height: 16),

              // Màu sắc
              const Text('Màu sắc ghi chú:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickColor, // Mở dialog chọn màu khi nhấn vào
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _color != null
                            ? Color(int.parse('0xFF${_color!.replaceFirst('#', '')}'))
                            : Colors.grey.shade400,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black26),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(_color ?? 'Chưa chọn màu'), // Hiển thị màu đã chọn
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Nút Thêm/Cập nhật
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm, // Gửi form khi nhấn nút
                  child: Text(isEditing ? 'CẬP NHẬT' : 'THÊM MỚI'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

