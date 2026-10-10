import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/user_model.dart';
import '../repositories/user_repository.dart';

class AuthProvider extends ChangeNotifier {
  final UserRepository _userRepo = UserRepository();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  AuthProvider() {
    _loadUserFromPrefs();
  }

  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId != null) {
      final user = await _userRepo.getUserById(userId);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      if (email.isEmpty) {
        _errorMessage = 'Email tidak boleh kosong';
        _setLoading(false);
        return false;
      }
      if (password.isEmpty) {
        _errorMessage = 'Password tidak boleh kosong';
        _setLoading(false);
        return false;
      }

      final user = await _userRepo.getUserByEmail(email.trim().toLowerCase());
      if (user == null) {
        _errorMessage = 'Email atau password salah';
        _setLoading(false);
        return false;
      }

      final hashedPassword = DatabaseHelper.hashPassword(password);
      if (user.password != hashedPassword) {
        _errorMessage = 'Email atau password salah';
        _setLoading(false);
        return false;
      }

      _currentUser = user;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', user.userId!);

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan. Coba lagi.';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // Validations
      if (name.trim().isEmpty) {
        _errorMessage = 'Nama lengkap tidak boleh kosong';
        _setLoading(false);
        return false;
      }
      if (email.trim().isEmpty || !email.contains('@')) {
        _errorMessage = 'Email tidak valid';
        _setLoading(false);
        return false;
      }
      if (phone.trim().isEmpty) {
        _errorMessage = 'Nomor handphone tidak boleh kosong';
        _setLoading(false);
        return false;
      }
      if (password.length < 6) {
        _errorMessage = 'Password minimal 6 karakter';
        _setLoading(false);
        return false;
      }
      if (password != confirmPassword) {
        _errorMessage = 'Password dan konfirmasi password tidak cocok';
        _setLoading(false);
        return false;
      }

      final emailExists = await _userRepo.emailExists(email.trim().toLowerCase());
      if (emailExists) {
        _errorMessage = 'Email sudah digunakan';
        _setLoading(false);
        return false;
      }

      final phoneExists = await _userRepo.phoneExists(phone.trim());
      if (phoneExists) {
        _errorMessage = 'Nomor handphone sudah digunakan';
        _setLoading(false);
        return false;
      }

      final now = DateTime.now().toIso8601String();
      final hashedPassword = DatabaseHelper.hashPassword(password);

      final newUser = UserModel(
        name: name.trim(),
        email: email.trim().toLowerCase(),
        phone: phone.trim(),
        password: hashedPassword,
        role: 'customer',
        createdAt: now,
        updatedAt: now,
      );

      final userId = await _userRepo.createUser(newUser);
      _currentUser = newUser.copyWith(userId: userId);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', userId);

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan. Coba lagi.';
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    _currentUser = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
