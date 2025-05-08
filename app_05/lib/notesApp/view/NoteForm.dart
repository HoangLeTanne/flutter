import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../model/Note.dart';
import '../db/NoteDatabseHelper.dart';


class NoteForm extends StatefulWidget {
  final Note? note; // Nếu note là null -> thêm mới, nếu có -> chỉnh sửa

  const NoteForm({Key? key, this.note}) : super(key: key);

  @override
  _NoteFormState createState() => _NoteFormState();
}

class _NoteFormState extends State<NoteForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  int _priority = 1;
  Color _selectedColor = Colors.blue;
  List<String> _tags = [];
  final TextEditingController _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      // Chỉnh sửa ghi chú
      _titleController = TextEditingController(text: widget.note!.title);
      _contentController = TextEditingController(text: widget.note!.content);
      _priority = widget.note!.priority;
      _selectedColor = Color(int.parse(widget.note!.color!));
      _tags = widget.note!.tags ?? [];
    } else {
      // Thêm ghi chú mới
      _titleController = TextEditingController();
      _contentController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  // Hàm lưu ghi chú vào database
  void _saveNote() async {
    if (_formKey.currentState!.validate()) {
      // Lưu vào database
      final newNote = Note(
        id: widget.note?.id,
        title: _titleController.text,
        content: _contentController.text,
        priority: _priority,
        createdAt: widget.note?.createdAt ?? DateTime.now(),
        modifiedAt: DateTime.now(),
        tags: _tags.isEmpty ? null : _tags,
        color: '#${_selectedColor.value.toRadixString(16).substring(2)}', // Convert color to hex
      );

      if (widget.note == null) {
        // Thêm mới ghi chú
        await NoteDatabaseHelper().insertNote(newNote);
      } else {
        // Cập nhật ghi chú
        await NoteDatabaseHelper().updateNote(newNote);
      }

      // Quay lại màn hình trước
      Navigator.pop(context);
    }
  }

  // Hàm chọn màu sắc
  void _chooseColor() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chọn màu sắc'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _selectedColor,
              onColorChanged: (color) {
                setState(() {
                  _selectedColor = color;
                });
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Chọn'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Hàm thêm nhãn
  void _addTag() {
    if (_tagController.text.isNotEmpty) {
      setState(() {
        _tags.add(_tagController.text);
        _tagController.clear();
      });
    }
  }

  // Hàm xóa nhãn
  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Thêm Ghi chú' : 'Chỉnh sửa Ghi chú'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tiêu đề
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Tiêu đề'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tiêu đề không được để trống';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Nội dung
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(labelText: 'Nội dung'),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nội dung không được để trống';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Mức độ ưu tiên (Radio buttons)
                const Text('Mức độ ưu tiên'),
                Row(
                  children: [
                    Radio<int>(
                      value: 1,
                      groupValue: _priority,
                      onChanged: (int? value) {
                        setState(() {
                          _priority = value!;
                        });
                      },
                    ),
                    const Text('Thấp'),
                    Radio<int>(
                      value: 2,
                      groupValue: _priority,
                      onChanged: (int? value) {
                        setState(() {
                          _priority = value!;
                        });
                      },
                    ),
                    const Text('Trung bình'),
                    Radio<int>(
                      value: 3,
                      groupValue: _priority,
                      onChanged: (int? value) {
                        setState(() {
                          _priority = value!;
                        });
                      },
                    ),
                    const Text('Cao'),
                  ],
                ),

                const SizedBox(height: 16),

                // Màu sắc
                const Text('Chọn màu sắc'),
                GestureDetector(
                  onTap: _chooseColor,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    color: _selectedColor,
                    child: const Center(
                      child: Text(
                        'Chọn Màu',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Nhãn
                const Text('Nhãn'),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _tagController,
                        decoration: const InputDecoration(hintText: 'Nhập nhãn'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addTag,
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8.0,
                  children: _tags
                      .map(
                        (tag) => Chip(
                      label: Text(tag),
                      deleteIcon: const Icon(Icons.remove_circle),
                      onDeleted: () => _removeTag(tag),
                    ),
                  )
                      .toList(),
                ),

                const SizedBox(height: 20),

                // Nút Lưu/Cập nhật
                ElevatedButton(
                  onPressed: _saveNote,
                  child: Text(widget.note == null ? 'Lưu' : 'Cập nhật'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

