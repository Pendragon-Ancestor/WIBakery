import 'package:flutter/foundation.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/promo_model.dart';

class PromoProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<PromoModel> _promos = [];
  List<PromoModel> _allPromos = [];
  PromoModel? _appliedPromo;
  bool _isLoading = false;
  String? _errorMessage;
  double _discountAmount = 0;

  List<PromoModel> get promos => _promos;
  List<PromoModel> get allPromos => _allPromos;
  PromoModel? get appliedPromo => _appliedPromo;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get discountAmount => _discountAmount;
  bool get hasAppliedPromo => _appliedPromo != null;

  Future<void> loadPromos() async {
    _setLoading(true);
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'promo',
        where: 'status = 1',
        orderBy: 'promo_id ASC',
      );
      _promos = maps.map(PromoModel.fromMap).toList();
    } catch (e) {
      _errorMessage = 'Gagal memuat promo';
    }
    _setLoading(false);
  }

  Future<void> loadAllPromos() async {
    _setLoading(true);
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'promo',
        orderBy: 'promo_id DESC',
      );
      _allPromos = maps.map(PromoModel.fromMap).toList();
    } catch (e) {
      _errorMessage = 'Gagal memuat semua promo';
    }
    _setLoading(false);
  }

  Future<bool> createPromo(PromoModel promo) async {
    try {
      final db = await _dbHelper.database;
      await db.insert('promo', promo.toMap());
      await loadAllPromos();
      await loadPromos();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menambah promo: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePromo(PromoModel promo) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'promo',
        promo.toMap(),
        where: 'promo_id = ?',
        whereArgs: [promo.promoId],
      );
      await loadAllPromos();
      await loadPromos();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengupdate promo: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> togglePromoStatus(int promoId, bool currentStatus) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'promo',
        {'status': currentStatus ? 0 : 1},
        where: 'promo_id = ?',
        whereArgs: [promoId],
      );
      await loadAllPromos();
      await loadPromos();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengubah status promo';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePromo(int promoId) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        'promo',
        where: 'promo_id = ?',
        whereArgs: [promoId],
      );
      await loadAllPromos();
      await loadPromos();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus promo: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> applyPromo(String code, double subtotal) async {
    _errorMessage = null;
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'promo',
        where: 'promo_code = ? AND status = 1',
        whereArgs: [code.trim().toUpperCase()],
        limit: 1,
      );

      if (maps.isEmpty) {
        _errorMessage = 'Kode promo tidak valid';
        notifyListeners();
        return false;
      }

      final promo = PromoModel.fromMap(maps.first);

      if (!promo.isValid) {
        _errorMessage = 'Kode promo sudah kadaluarsa';
        notifyListeners();
        return false;
      }

      if (subtotal < promo.minTransaction) {
        _errorMessage =
            'Minimum transaksi Rp ${promo.minTransaction.toStringAsFixed(0)} untuk menggunakan promo ini';
        notifyListeners();
        return false;
      }

      _appliedPromo = promo;
      _discountAmount = promo.calculateDiscount(subtotal);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal memvalidasi promo';
      notifyListeners();
      return false;
    }
  }

  void removePromo() {
    _appliedPromo = null;
    _discountAmount = 0;
    _errorMessage = null;
    notifyListeners();
  }

  void updateDiscount(double subtotal) {
    if (_appliedPromo != null) {
      _discountAmount = _appliedPromo!.calculateDiscount(subtotal);
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
