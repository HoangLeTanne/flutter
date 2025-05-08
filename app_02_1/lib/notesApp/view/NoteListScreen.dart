import 'package:flutter/material.dart';
import 'package:app_02_1/notesApp/db/NoteDatabaseHelper.dart';
import 'package:app_02_1/notesApp/model/Note.dart';
import 'package:app_02_1/notesApp/view/NoteForm.dart';
import 'package:app_02_1/notesApp/view/NoteItem.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({Key? key}) : super(key: key);

  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  late Future<List<Note>> _notesFuture;  // Future chứa danh sách ghi chú
  bool _isGridView = false;  // Biến để xác định xem có đang ở chế độ GridView hay không
  int? _filterPriority;  // Biến để lọc ghi chú theo mức ưu tiên
  String _searchQuery = '';  // Biến lưu trữ truy vấn tìm kiếm
  final _searchController = TextEditingController();  // Controller cho TextField tìm kiếm
  String _sortBy = 'priority';  // Biến để xác định kiểu sắp xếp (theo ưu tiên hoặc thời gian)

  @override
  void initState() {
    super.initState();
    _refreshNotes();  // Lấy dữ liệu ghi chú ban đầu
  }

  Future<void> _refreshNotes() async {
    setState(() {
      if (_searchQuery.isNotEmpty) {
        // Nếu có tìm kiếm, lấy ghi chú theo truy vấn tìm kiếm
        _notesFuture = NoteDatabaseHelper.instance.searchNotes(_searchQuery);
      } else if (_filterPriority != null) {
        // Nếu có lọc theo ưu tiên, lấy ghi chú theo mức ưu tiên
        _notesFuture = NoteDatabaseHelper.instance.getNotesByPriority(_filterPriority!);
      } else {
        // Nếu không có điều kiện tìm kiếm hoặc lọc, lấy tất cả ghi chú
        _notesFuture = NoteDatabaseHelper.instance.getAllNotes();
      }
    });
  }

  List<Note> _sortNotes(List<Note> notes) {
    // Sắp xếp danh sách ghi chú theo ưu tiên hoặc thời gian
    if (_sortBy == 'priority') {
      return notes..sort((a, b) => b.priority.compareTo(a.priority));
    } else {
      return notes..sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],  // Màu nền cho màn hình
      appBar: AppBar(
        title: const Text('📒 Danh sách ghi chú'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),  // Nút làm mới
            onPressed: _refreshNotes,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),  // Nút menu cho các lựa chọn khác
            onSelected: (value) {
              setState(() {
                switch (value) {
                  case 'grid':
                    _isGridView = true;  // Chuyển sang chế độ GridView
                    break;
                  case 'list':
                    _isGridView = false;  // Chuyển sang chế độ ListView
                    break;
                  case 'priority':
                  case 'time':
                    _sortBy = value;  // Sắp xếp theo ưu tiên hoặc thời gian
                    break;
                  case 'filter_low':
                    _filterPriority = 1;  // Lọc theo ưu tiên thấp
                    break;
                  case 'filter_medium':
                    _filterPriority = 2;  // Lọc theo ưu tiên trung bình
                    break;
                  case 'filter_high':
                    _filterPriority = 3;  // Lọc theo ưu tiên cao
                    break;
                  case 'filter_none':
                    _filterPriority = null;  // Bỏ lọc
                    break;
                }
                _refreshNotes();  // Làm mới ghi chú sau khi thay đổi
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'grid', child: ListTile(leading: Icon(Icons.grid_view), title: Text('Chế độ Grid'))),
              const PopupMenuItem(value: 'list', child: ListTile(leading: Icon(Icons.view_list), title: Text('Chế độ List'))),
              const PopupMenuItem(value: 'priority', child: ListTile(leading: Icon(Icons.low_priority), title: Text('Sắp xếp theo ưu tiên'))),
              const PopupMenuItem(value: 'time', child: ListTile(leading: Icon(Icons.access_time), title: Text('Sắp xếp theo thời gian'))),
              const PopupMenuItem(value: 'filter_low', child: ListTile(leading: Icon(Icons.filter_1), title: Text('Lọc: Ưu tiên thấp'))),
              const PopupMenuItem(value: 'filter_medium', child: ListTile(leading: Icon(Icons.filter_2), title: Text('Lọc: Ưu tiên trung bình'))),
              const PopupMenuItem(value: 'filter_high', child: ListTile(leading: Icon(Icons.filter_3), title: Text('Lọc: Ưu tiên cao'))),
              const PopupMenuItem(value: 'filter_none', child: ListTile(leading: Icon(Icons.filter_none), title: Text('Bỏ lọc'))),
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: TextField(
              controller: _searchController,  // Controller cho TextField tìm kiếm
              decoration: InputDecoration(
                labelText: ' Tìm kiếm ghi chú',  // Văn bản hướng dẫn
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),  // Biểu tượng tìm kiếm
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),  // Nút xóa tìm kiếm
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _refreshNotes();  // Làm mới khi xóa tìm kiếm
                    });
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;  // Cập nhật truy vấn tìm kiếm khi người dùng gõ
                  _refreshNotes();  // Làm mới ghi chú theo tìm kiếm
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<Note>>(
              future: _notesFuture,  // Dữ liệu ghi chú từ cơ sở dữ liệu
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());  // Đang tải
                } else if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));  // Nếu có lỗi
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Không có ghi chú nào.'));  // Nếu không có dữ liệu
                } else {
                  final notes = _sortNotes(snapshot.data!);  // Sắp xếp ghi chú
                  return _isGridView
                      ? GridView.builder(  // Chế độ GridView
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return NoteItem(
                        note: note,
                        isGridView: _isGridView,
                        onDelete: () async {
                          await NoteDatabaseHelper.instance.deleteNote(note.id!);
                          _refreshNotes();
                        },
                        onEdit: (updatedNote) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => NoteForm(note: updatedNote)),
                          ).then((value) => _refreshNotes());
                        },
                        onToggleComplete: (note) async {
                          final updated = note.copyWith(isCompleted: !note.isCompleted);
                          await NoteDatabaseHelper.instance.updateNote(updated);
                          _refreshNotes();
                        },
                      );
                    },
                  )
                      : ListView.builder(  // Chế độ ListView
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return NoteItem(
                        note: note,
                        isGridView: _isGridView,
                        onDelete: () async {
                          await NoteDatabaseHelper.instance.deleteNote(note.id!);
                          _refreshNotes();
                        },
                        onEdit: (updatedNote) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => NoteForm(note: updatedNote)),
                          ).then((value) => _refreshNotes());
                        },
                        onToggleComplete: (note) async {
                          final updated = note.copyWith(isCompleted: !note.isCompleted);
                          await NoteDatabaseHelper.instance.updateNote(updated);
                          _refreshNotes();
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newNote = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NoteForm()),  // Mở màn hình tạo ghi chú mới
          );
          if (newNote != null) {
            await NoteDatabaseHelper.instance.insertNote(newNote);  // Thêm ghi chú mới vào cơ sở dữ liệu
            _refreshNotes();  // Làm mới danh sách ghi chú
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Thêm ghi chú'),
      ),
    );
  }
}
