import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/Task.dart';
import '../models/User.dart';
import '../db/DatabaseHelper.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;
  final User? loggedInUser;
  final List<User>? availableUsers;

  const AddEditTaskScreen({Key? key, this.task, this.loggedInUser, this.availableUsers}) : super(key: key);

  @override
  _AddEditTaskScreenState createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _status;
  int? _priority;
  DateTime? _dueDate;
  String? _assignedToId;
  String? _category;
  List<String> _attachments = [];

  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _status = widget.task!.status ?? 'Cần làm';
      _priority = widget.task!.priority ?? 1;
      _dueDate = widget.task!.dueDate;
      _assignedToId = widget.task!.assignedTo;
      _category = widget.task!.category;
      _attachments = widget.task!.attachments ?? [];
    } else {
      _status = 'Cần làm';
      _priority = 1;
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _uploadAttachment() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _attachments.add(result.files.first.name);
      });
    }
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final newTask = Task(
        id: widget.task?.id ?? now.millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        status: _status!,
        priority: _priority!,
        dueDate: _dueDate,
        createdAt: widget.task?.createdAt ?? now,
        updatedAt: now,
        assignedTo: _assignedToId,
        createdBy: widget.loggedInUser?.id ?? 'unknown',
        category: _category,
        attachments: _attachments,
        completed: widget.task?.completed ?? false,
      );

      if (widget.task == null) {
        await _dbHelper.createTask(newTask);
      } else {
        await _dbHelper.updateTask(newTask);
      }
      Navigator.pop(context, true);
    }
  }

  Future<void> _deleteTask() async {
    if (widget.task != null) {
      await _dbHelper.deleteTask(widget.task!.id);
      Navigator.pop(context, true);
    }
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Thêm Công việc' : 'Sửa Công việc'),
        actions: [
          if (widget.task != null)
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteTask,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildSection(
                title: 'Tiêu đề',
                child: TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Nhập tiêu đề công việc',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
                ),
              ),
              _buildSection(
                title: 'Mô tả',
                child: TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Nhập mô tả chi tiết',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                  ),
                ),
              ),
              _buildSection(
                title: 'Trạng thái',
                child: Wrap(
                  spacing: 20,
                  runSpacing: 8,
                  children: ['Cần làm', 'Đang làm', 'Đã xong', 'Đã hủy'].map((status) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width / 2 - 40,
                      child: RadioListTile<String>(
                        dense: true,
                        title: Text(status, style: TextStyle(fontSize: 14)),
                        value: status,
                        groupValue: _status,
                        onChanged: (value) => setState(() => _status = value),
                        contentPadding: EdgeInsets.zero,
                      ),
                    );
                  }).toList(),
                ),
              ),

              _buildSection(
                title: 'Độ ưu tiên',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [1, 2, 3].map((level) {
                    return Row(
                      children: [
                        Radio<int>(
                          value: level,
                          groupValue: _priority,
                          onChanged: (value) => setState(() => _priority = value),
                        ),
                        Text('Mức $level'),
                      ],
                    );
                  }).toList(),
                ),
              ),
              _buildSection(
                title: 'Ngày đến hạn',
                child: ListTile(
                  title: Text(_dueDate == null
                      ? 'Chưa chọn'
                      : DateFormat('yyyy-MM-dd').format(_dueDate!)),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () => _selectDueDate(context),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                ),
              ),
              if (widget.availableUsers != null && widget.availableUsers!.isNotEmpty)
                _buildSection(
                  title: 'Gán cho người dùng',
                  child: DropdownButtonFormField<String>(
                    value: _assignedToId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                    ),
                    items: widget.availableUsers!
                        .map((user) => DropdownMenuItem<String>(
                      value: user.id,
                      child: Text(user.username),
                    ))
                        .toList(),
                    onChanged: (value) => setState(() => _assignedToId = value),
                  ),
                ),
              _buildSection(
                title: 'Tệp đính kèm',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_attachments.isEmpty)
                      Text('Chưa có tệp nào', style: TextStyle(color: Colors.grey)),
                    ..._attachments.map((attachment) => Row(
                      children: [
                        Icon(Icons.attach_file, size: 20),
                        Expanded(child: Text(attachment, overflow: TextOverflow.ellipsis)),
                      ],
                    )),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _uploadAttachment,
                      icon: Icon(Icons.upload_file),
                      label: Text('Tải lên tệp đính kèm'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                        backgroundColor: Colors.blue.shade50,
                        foregroundColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveTask,
                child: Text(widget.task == null ? 'Thêm công việc' : 'Lưu công việc'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 32.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
