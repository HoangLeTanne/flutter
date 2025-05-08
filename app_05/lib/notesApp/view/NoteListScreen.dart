import 'package:flutter/material.dart';
import '../model/Note.dart';
import '../db/NoteDatabseHelper.dart';
import '../view/NoteForm.dart';
import '../view/NoteDetailScreen.dart';

class NoteListScreen extends StatefulWidget {
  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  List<Note> notes = [];
  bool isGrid = true;
  int? filterPriority;
  String searchQuery = '';
  bool sortByTime = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    List<Note> allNotes = await NoteDatabaseHelper().getAllNotes();
    setState(() {
      notes = allNotes;
    });
  }

  void _applyFilterSort() async {
    List<Note> filtered = await NoteDatabaseHelper().getAllNotes();

    if (filterPriority != null) {
      filtered = filtered.where((n) => n.priority == filterPriority).toList();
    }

    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((n) =>
      n.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          n.content.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    if (sortByTime) {
      filtered.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    } else {
      filtered.sort((a, b) => b.priority.compareTo(a.priority));
    }

    setState(() {
      notes = filtered;
    });
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.green.shade100;
      case 2:
        return Colors.orange.shade100;
      case 3:
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Widget _buildNoteItem(Note note) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note)),
      ).then((_) => _loadNotes()),
      child: Card(
        color: note.color != null ? Color(int.parse(note.color!)) : _getPriorityColor(note.priority),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(note.title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  note.content.length > 80
                      ? '${note.content.substring(0, 80)}...'
                      : note.content,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  'Ưu tiên: ${note.priority}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ghi chú của tôi'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              filterPriority = null;
              searchQuery = '';
              _loadNotes();
            },
          ),
          PopupMenuButton<int>(
            icon: Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                filterPriority = value;
              });
              _applyFilterSort();
            },
            itemBuilder: (context) => [
              PopupMenuItem(child: Text("Tất cả"), value: null),
              PopupMenuItem(child: Text("Ưu tiên thấp"), value: 1),
              PopupMenuItem(child: Text("Ưu tiên trung bình"), value: 2),
              PopupMenuItem(child: Text("Ưu tiên cao"), value: 3),
            ],
          ),
          IconButton(
            icon: Icon(isGrid ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                isGrid = !isGrid;
              });
            },
          ),
          IconButton(
            icon: Icon(sortByTime ? Icons.schedule : Icons.flag),
            onPressed: () {
              setState(() {
                sortByTime = !sortByTime;
              });
              _applyFilterSort();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              onChanged: (val) {
                setState(() => searchQuery = val);
                _applyFilterSort();
              },
              decoration: InputDecoration(
                hintText: 'Tìm kiếm ghi chú...',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: notes.isEmpty
            ? Center(child: Text('Không có ghi chú nào'))
            : isGrid
            ? GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.85),
          itemCount: notes.length,
          itemBuilder: (context, index) =>
              _buildNoteItem(notes[index]),
        )
            : ListView.separated(
          itemCount: notes.length,
          itemBuilder: (context, index) =>
              _buildNoteItem(notes[index]),
          separatorBuilder: (_, __) => SizedBox(height: 8),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NoteForm()),
          );
          _loadNotes();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
