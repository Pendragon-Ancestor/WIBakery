import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/user_model.dart';

class UserRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<Database> get _db async => _dbHelper.database;

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await _db;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<UserModel?> getUserById(int userId) async {
    final db = await _db;
    final maps = await db.query(
      'users',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<int> createUser(UserModel user) async {
    final db = await _db;
    return await db.insert('users', user.toMap());
  }

  Future<bool> emailExists(String email) async {
    final user = await getUserByEmail(email);
    return user != null;
  }

  Future<bool> phoneExists(String phone) async {
    final db = await _db;
    final maps = await db.query(
      'users',
      where: 'phone = ?',
      whereArgs: [phone],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  Future<int> updateUser(UserModel user) async {
    final db = await _db;
    return await db.update(
      'users',
      user.toMap(),
      where: 'user_id = ?',
      whereArgs: [user.userId],
    );
  }

  Future<List<UserModel>> getAllCustomers() async {
    final db = await _db;
    final maps = await db.query(
      'users',
      where: 'role = ?',
      whereArgs: ['customer'],
      orderBy: 'created_at DESC',
    );
    return maps.map(UserModel.fromMap).toList();
  }
}
