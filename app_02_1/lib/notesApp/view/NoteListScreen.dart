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
  late Future<List<Note>> _notesFuture;
  bool _isGridView = false;
  int? _filterPriority;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  String _sortBy = 'priority';

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  Future<void> _refreshNotes() async {
    setState(() {
      if (_searchQuery.isNotEmpty) {
        _notesFuture = NoteDatabaseHelper.instance.searchNotes(_searchQuery);
      } else if (_filterPriority != null) {
        _notesFuture = NoteDatabaseHelper.instance.getNotesByPriority(_filterPriority!);
      } else {
        _notesFuture = NoteDatabaseHelper.instance.getAllNotes();
      }
    });
  }

  List<Note> _sortNotes(List<Note> notes) {
    if (_sortBy == 'priority') {
      return notes..sort((a, b) => b.priority.compareTo(a.priority));
    } else {
      return notes..sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('📒 Danh sách ghi chú'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshNotes,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              setState(() {
                switch (value) {
                  case 'grid':
                    _isGridView = true;
                    break;
                  case 'list':
                    _isGridView = false;
                    break;
                  case 'priority':
                  case 'time':
                    _sortBy = value;
                    break;
                  case 'filter_low':
                    _filterPriority = 1;
                    break;
                  case 'filter_medium':
                    _filterPriority = 2;
                    break;
                  case 'filter_high':
                    _filterPriority = 3;
                    break;
                  case 'filter_none':
                    _filterPriority = null;
                    break;
                }
                _refreshNotes();
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
              controller: _searchController,
              decoration: InputDecoration(
                labelText: ' Tìm kiếm ghi chú',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _refreshNotes();
                    });
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _refreshNotes();
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<Note>>(
              future: _notesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Không có ghi chú nào.'));
                } else {
                  final notes = _sortNotes(snapshot.data!);
                  return _isGridView
                      ? GridView.builder(
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
                      : ListView.builder(
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
            MaterialPageRoute(builder: (context) => const NoteForm()),
          );
          if (newNote != null) {
            await NoteDatabaseHelper.instance.insertNote(newNote);
            _refreshNotes();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Thêm ghi chú'),
      ),
    );
  }
}
