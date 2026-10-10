import 'package:flutter/foundation.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/cart_model.dart';
import 'package:sqflite/sqflite.dart';

class CartRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  Future<Database> get _db async => _dbHelper.database;

  Future<CartModel?> getCartByUserId(int userId) async {
    final db = await _db;
    final cartMaps = await db.query(
      'cart',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (cartMaps.isEmpty) return null;

    final cartId = cartMaps.first['cart_id'] as int;
    final items = await getCartItems(cartId);
    return CartModel.fromMap(cartMaps.first, items: items);
  }

  Future<List<CartDetailModel>> getCartItems(int cartId) async {
    final db = await _db;
    final maps = await db.rawQuery('''
      SELECT cd.*, p.product_name, p.image, ps.quantity AS quantity_stock
      FROM cart_detail cd
      LEFT JOIN product p ON cd.product_id = p.product_id
      LEFT JOIN product_stock ps ON cd.product_id = ps.product_id
      WHERE cd.cart_id = ?
    ''', [cartId]);
    return maps.map(CartDetailModel.fromMap).toList();
  }

  Future<int> createCart(int userId) async {
    final db = await _db;
    return await db.insert('cart', {
      'user_id': userId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> addOrUpdateItem(
      int cartId, int productId, int quantity, double price, String? note) async {
    final db = await _db;

    // Check if item already exists
    final existing = await db.query(
      'cart_detail',
      where: 'cart_id = ? AND product_id = ?',
      whereArgs: [cartId, productId],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      // Update quantity
      final currentQty = existing.first['quantity'] as int;
      await db.update(
        'cart_detail',
        {'quantity': currentQty + quantity, if (note != null) 'note': note},
        where: 'cart_detail_id = ?',
        whereArgs: [existing.first['cart_detail_id']],
      );
    } else {
      // Insert new item
      await db.insert('cart_detail', {
        'cart_id': cartId,
        'product_id': productId,
        'quantity': quantity,
        'note': note,
        'price': price,
      });
    }
  }

  Future<void> updateItemQuantity(int cartDetailId, int quantity) async {
    final db = await _db;
    if (quantity <= 0) {
      await db.delete(
        'cart_detail',
        where: 'cart_detail_id = ?',
        whereArgs: [cartDetailId],
      );
    } else {
      await db.update(
        'cart_detail',
        {'quantity': quantity},
        where: 'cart_detail_id = ?',
        whereArgs: [cartDetailId],
      );
    }
  }

  Future<void> removeItem(int cartDetailId) async {
    final db = await _db;
    await db.delete(
      'cart_detail',
      where: 'cart_detail_id = ?',
      whereArgs: [cartDetailId],
    );
  }

  Future<void> clearCart(int cartId) async {
    final db = await _db;
    await db.delete(
      'cart_detail',
      where: 'cart_id = ?',
      whereArgs: [cartId],
    );
  }
}

class CartProvider extends ChangeNotifier {
  final CartRepository _cartRepo = CartRepository();

  CartModel? _cart;
  bool _isLoading = false;
  String? _errorMessage;

  CartModel? get cart => _cart;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get itemCount => _cart?.totalItems ?? 0;
  double get subtotal => _cart?.subtotal ?? 0;
  List<CartDetailModel> get items => _cart?.items ?? [];

  Future<void> loadCart(int userId) async {
    _setLoading(true);
    try {
      _cart = await _cartRepo.getCartByUserId(userId);
      if (_cart == null) {
        final cartId = await _cartRepo.createCart(userId);
        _cart = CartModel(
          cartId: cartId,
          userId: userId,
          createdAt: DateTime.now().toIso8601String(),
          items: [],
        );
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat keranjang';
    }
    _setLoading(false);
  }

  Future<void> addToCart({
    required int userId,
    required int productId,
    required double price,
    required int quantity,
    String? note,
  }) async {
    try {
      if (_cart == null) await loadCart(userId);
      await _cartRepo.addOrUpdateItem(
          _cart!.cartId!, productId, quantity, price, note);
      await _refreshCart();
    } catch (e) {
      _errorMessage = 'Gagal menambah ke keranjang';
      notifyListeners();
    }
  }

  Future<void> updateQuantity(int cartDetailId, int quantity) async {
    try {
      await _cartRepo.updateItemQuantity(cartDetailId, quantity);
      await _refreshCart();
    } catch (e) {
      _errorMessage = 'Gagal mengubah jumlah';
      notifyListeners();
    }
  }

  Future<void> removeItem(int cartDetailId) async {
    try {
      await _cartRepo.removeItem(cartDetailId);
      await _refreshCart();
    } catch (e) {
      _errorMessage = 'Gagal menghapus item';
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    try {
      if (_cart?.cartId != null) {
        await _cartRepo.clearCart(_cart!.cartId!);
        await _refreshCart();
      }
    } catch (e) {
      _errorMessage = 'Gagal mengosongkan keranjang';
      notifyListeners();
    }
  }

  Future<void> _refreshCart() async {
    if (_cart?.userId != null) {
      _cart = await _cartRepo.getCartByUserId(_cart!.userId);
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void reset() {
    _cart = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
