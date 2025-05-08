import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:app_05/notesApp/model/Note.dart'; // Import lớp Note

class NoteDatabaseHelper {
  static final NoteDatabaseHelper _instance = NoteDatabaseHelper._internal();
  factory NoteDatabaseHelper() => _instance;
  NoteDatabaseHelper._internal();

  static Database? _database;

  // Truy cập DB (singleton)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Khởi tạo DB
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'notes.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Tạo bảng notes
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        priority INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        modifiedAt TEXT NOT NULL,
        tags TEXT,
        color TEXT
      )
    ''');
  }

  // ---------------------------
  // Các phương thức CRUD dưới đây
  // ---------------------------

  // Thêm ghi chú
  Future<int> insertNote(Note note) async {
    final db = await database;
    return await db.insert(
      'notes',
      note.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Lấy tất cả ghi chú
  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('notes');
    return maps.map((map) => Note.fromMap(_prepareMap(map))).toList();
  }

  // Lấy ghi chú theo ID
  Future<Note?> getNoteById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
    await db.query('notes', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Note.fromMap(_prepareMap(maps.first));
    }
    return null;
  }

  // Cập nhật ghi chú
  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // Xoá ghi chú
  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // Lấy ghi chú theo mức độ ưu tiên
  Future<List<Note>> getNotesByPriority(int priority) async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: 'priority = ?',
      whereArgs: [priority],
    );
    return maps.map((map) => Note.fromMap(_prepareMap(map))).toList();
  }

  // Tìm kiếm ghi chú theo từ khóa trong title hoặc content
  Future<List<Note>> searchNotes(String query) async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return maps.map((map) => Note.fromMap(_prepareMap(map))).toList();
  }

  // ---------------------------
  // Helper để xử lý tags từ chuỗi
  // ---------------------------

  Map<String, dynamic> _prepareMap(Map<String, dynamic> map) {
    map['tags'] = _decodeTags(map['tags']);
    return map;
  }

  List<String>? _decodeTags(String? tagString) {
    if (tagString == null || tagString.isEmpty) return null;
    return tagString.split(',');
  }
}