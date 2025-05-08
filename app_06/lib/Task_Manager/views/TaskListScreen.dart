import 'package:flutter/material.dart';
import '../models/Task.dart';
import '../db/DatabaseHelper.dart';
import '../views/AddEditTaskScreen.dart';
import '../views/TaskItem.dart';
import '../models/User.dart';
import '../views/LoginScreen.dart';

class TaskListScreen extends StatefulWidget {
  final User? loggedInUser;

  TaskListScreen({this.loggedInUser});

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Task>> _taskListFuture;
  List<Task> _taskList = [];
  List<User> _userList = [];

  String? _selectedStatus;
  String? _searchKeyword;
  bool _isKanbanView = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadUsers();
    await _loadTasks();
  }

  Future<void> _loadUsers() async {
    _userList = await _dbHelper.getAllUsers();
  }

  Future<void> _loadTasks({String? status, String? keyword}) async {
    setState(() {
      _selectedStatus = status;
      _searchKeyword = keyword;
      _taskListFuture = _dbHelper.filterTasks(
        status: status,
        title: keyword?.isEmpty == true ? null : keyword,
      );
    });
  }

  Future<void> _updateTaskStatus(String id, String newStatus) async {
    await _dbHelper.updateTaskStatus(id, newStatus);
    _loadTasks(status: _selectedStatus, keyword: _searchKeyword);
  }

  Future<void> _deleteTask(Task task) async {
    await _dbHelper.deleteTask(task.id!);
    _loadTasks(status: _selectedStatus, keyword: _searchKeyword);
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Xác nhận'),
        content: Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('Hủy')),
          TextButton(
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => LoginScreen()));
              },
              child: Text('Đăng xuất')),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          icon: Icon(Icons.search),
          hintText: 'Tìm công việc...',
          border: InputBorder.none,
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              _loadTasks(status: _selectedStatus, keyword: null);
            },
          )
              : null,
        ),
        onChanged: (value) => _loadTasks(status: _selectedStatus, keyword: value),
      ),
    );
  }

  Widget _buildToolbar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DropdownButton<String>(
            value: _selectedStatus ?? 'Tất cả',
            items: ['Tất cả', 'Cần làm', 'Đang làm', 'Đã xong', 'Đã hủy']
                .map((status) => DropdownMenuItem(
                value: status, child: Text(status)))
                .toList(),
            onChanged: (status) =>
                _loadTasks(status: status == 'Tất cả' ? null : status),
          ),
          IconButton(
            icon: Icon(_isKanbanView ? Icons.list : Icons.view_column),
            onPressed: () {
              setState(() {
                _isKanbanView = !_isKanbanView;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTaskView() {
    return _isKanbanView ? _buildKanbanBoard() : _buildTaskList();
  }

  Widget _buildTaskList() {
    return FutureBuilder<List<Task>>(
      future: _taskListFuture,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());
        if (snapshot.hasError)
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return Center(child: Text('Không có công việc nào.'));
        _taskList = snapshot.data!;
        return ListView.builder(
          itemCount: _taskList.length,
          itemBuilder: (_, index) {
            final task = _taskList[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: TaskItem(
                task: task,
                onEdit: _navigateToEditTaskScreen,
                onDelete: (id) => _deleteTask(task),
                onComplete: (id) => _updateTaskStatus(id, task.completed ? 'Cần làm' : 'Đã xong'),
                isKanbanView: false,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildKanbanBoard() {
    Map<String, List<Task>> columns = {
      'Cần làm': [],
      'Đang làm': [],
      'Đã xong': [],
      'Đã hủy': [],
    };
    for (var task in _taskList) {
      columns[task.status]?.add(task);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: columns.entries.map((entry) {
          return Container(
            width: 250,
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Column(
              children: [
                Text(entry.key,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                ...entry.value.map((task) => Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TaskItem(
                    task: task,
                    onEdit: _navigateToEditTaskScreen,
                    onDelete: (id) => _deleteTask(task),
                    onComplete: (id) => _updateTaskStatus(
                        id, task.completed ? 'Cần làm' : 'Đã xong'),
                    isKanbanView: true,
                  ),
                )),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  void _navigateToEditTaskScreen(Task task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditTaskScreen(
          task: task,
          loggedInUser: widget.loggedInUser,
          availableUsers: _userList,
        ),
      ),
    );
    if (result == true) {
      _loadTasks(status: _selectedStatus, keyword: _searchKeyword);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: Text('Task Manager'),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          // Chỉnh sửa AppBar để chứa Dropdown và Icon button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                // Dropdown bộ lọc trạng thái
                DropdownButton<String>(
                  value: _selectedStatus ?? 'Tất cả',
                  items: ['Tất cả', 'Cần làm', 'Đang làm', 'Đã xong', 'Đã hủy']
                      .map((status) => DropdownMenuItem(
                      value: status, child: Text(status)))
                      .toList(),
                  onChanged: (status) =>
                      _loadTasks(status: status == 'Tất cả' ? null : status),
                ),
                // Chỉnh sửa IconButton để chuyển chế độ xem
                IconButton(
                  icon: Icon(_isKanbanView ? Icons.list : Icons.view_column),
                  onPressed: () {
                    setState(() {
                      _isKanbanView = !_isKanbanView;
                    });
                  },
                ),
                // Nút đăng xuất
                IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: _showLogoutDialog,
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _buildTaskView(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditTaskScreen(
                loggedInUser: widget.loggedInUser,
                availableUsers: _userList,
              ),
            ),
          );
          if (result == true) {
            _loadTasks(status: _selectedStatus, keyword: _searchKeyword);
          }
        },
        label: Text('Thêm mới'),
        icon: Icon(Icons.add),
        backgroundColor: Colors.lightBlueAccent,
      ),
    );
  }

}
