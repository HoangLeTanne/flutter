import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:app_02_1/notesApp/model/Note.dart';

class NoteForm extends StatefulWidget {
  final Note? note;

  const NoteForm({Key? key, this.note}) : super(key: key);

  @override
  _NoteFormState createState() => _NoteFormState();
}

class _NoteFormState extends State<NoteForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();

  int _priority = 1;
  List<String> _tags = [];
  String? _color;

  @override
  void initState() {
    super.initState();
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
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    String tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

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
                '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
              });
            },
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Xong'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

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
      Navigator.pop(context, note);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Cập nhật ghi chú' : 'Thêm ghi chú mới'),
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
                value == null || value.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
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
                value == null || value.isEmpty ? 'Vui lòng nhập nội dung' : null,
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
                  if (value != null) setState(() => _priority = value);
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
                      onSubmitted: (_) => _addTag(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addTag,
                    child: const Text('Thêm'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_tags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _tags
                      .map((tag) => Chip(
                    label: Text(tag),
                    backgroundColor: Colors.lightBlue.shade50,
                    deleteIcon: const Icon(Icons.close),
                    onDeleted: () => _removeTag(tag),
                  ))
                      .toList(),
                ),
              const SizedBox(height: 16),

              // Màu sắc
              const Text('Màu sắc ghi chú:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickColor,
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
                    Text(_color ?? 'Chưa chọn màu'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Nút Thêm/Cập nhật
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
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
