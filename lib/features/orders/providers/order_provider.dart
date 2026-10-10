import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/order_model.dart';
import '../../../core/models/cart_model.dart';

class OrderRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  Future<Database> get _db async => _dbHelper.database;

  Future<int> createOrder(OrderModel order) async {
    final db = await _db;
    return await db.insert('orders', order.toMap());
  }

  Future<void> insertOrderDetail(OrderDetailModel detail) async {
    final db = await _db;
    await db.insert('order_detail', detail.toMap());
  }

  Future<void> insertStatusHistory(OrderStatusHistory history) async {
    final db = await _db;
    await db.insert('order_status_history', history.toMap());
  }

  Future<void> insertPayment(Map<String, dynamic> payment) async {
    final db = await _db;
    await db.insert('payment', payment);
  }

  Future<List<OrderModel>> getOrdersByUserId(int userId) async {
    final db = await _db;
    final maps = await db.rawQuery('''
      SELECT o.*, u.name
      FROM orders o
      LEFT JOIN users u ON o.user_id = u.user_id
      WHERE o.user_id = ?
      ORDER BY o.order_date DESC
    ''', [userId]);

    List<OrderModel> orders = [];
    for (final map in maps) {
      final items = await getOrderDetails(map['order_id'] as int);
      orders.add(OrderModel.fromMap(map, items: items));
    }
    return orders;
  }

  Future<List<OrderModel>> getAllOrders() async {
    final db = await _db;
    final maps = await db.rawQuery('''
      SELECT o.*, u.name
      FROM orders o
      LEFT JOIN users u ON o.user_id = u.user_id
      ORDER BY o.order_date DESC
    ''');

    List<OrderModel> orders = [];
    for (final map in maps) {
      final items = await getOrderDetails(map['order_id'] as int);
      orders.add(OrderModel.fromMap(map, items: items));
    }
    return orders;
  }

  Future<OrderModel?> getOrderById(int orderId) async {
    final db = await _db;
    final maps = await db.rawQuery('''
      SELECT o.*, u.name, ua.address_detail
      FROM orders o
      LEFT JOIN users u ON o.user_id = u.user_id
      LEFT JOIN user_address ua ON o.address_id = ua.address_id
      WHERE o.order_id = ?
    ''', [orderId]);

    if (maps.isEmpty) return null;
    final items = await getOrderDetails(orderId);
    return OrderModel.fromMap(maps.first, items: items);
  }

  Future<List<OrderDetailModel>> getOrderDetails(int orderId) async {
    final db = await _db;
    final maps = await db.rawQuery('''
      SELECT od.*, p.product_name, p.image
      FROM order_detail od
      LEFT JOIN product p ON od.product_id = p.product_id
      WHERE od.order_id = ?
    ''', [orderId]);
    return maps.map(OrderDetailModel.fromMap).toList();
  }

  Future<List<OrderStatusHistory>> getStatusHistory(int orderId) async {
    final db = await _db;
    final maps = await db.query(
      'order_status_history',
      where: 'order_id = ?',
      whereArgs: [orderId],
      orderBy: 'created_at ASC',
    );
    return maps.map(OrderStatusHistory.fromMap).toList();
  }

  Future<int> updateOrderStatus(int orderId, String status) async {
    final db = await _db;
    return await db.update(
      'orders',
      {'status': status},
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
  }
}

class OrderProvider extends ChangeNotifier {
  final OrderRepository _orderRepo = OrderRepository();

  List<OrderModel> _userOrders = [];
  List<OrderModel> _allOrders = [];
  OrderModel? _currentOrder;
  List<OrderStatusHistory> _statusHistory = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  List<OrderModel> get userOrders => _userOrders;
  List<OrderModel> get allOrders => _allOrders;
  OrderModel? get currentOrder => _currentOrder;
  List<OrderStatusHistory> get statusHistory => _statusHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<void> loadUserOrders(int userId) async {
    _setLoading(true);
    try {
      _userOrders = await _orderRepo.getOrdersByUserId(userId);
    } catch (e) {
      _errorMessage = 'Gagal memuat pesanan';
    }
    _setLoading(false);
  }

  Future<void> loadAllOrders() async {
    _setLoading(true);
    try {
      _allOrders = await _orderRepo.getAllOrders();
    } catch (e) {
      _errorMessage = 'Gagal memuat pesanan';
    }
    _setLoading(false);
  }

  Future<void> loadOrderById(int orderId) async {
    _setLoading(true);
    try {
      _currentOrder = await _orderRepo.getOrderById(orderId);
      if (_currentOrder != null) {
        _statusHistory = await _orderRepo.getStatusHistory(orderId);
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat detail pesanan';
    }
    _setLoading(false);
  }

  Future<bool> createOrder({
    required int userId,
    required int? addressId,
    required List<CartDetailModel> cartItems,
    required double subtotal,
    required double discount,
    required double shippingCost,
    required String? promoCode,
    required String paymentMethod,
    String? note,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final uuid = const Uuid().v4().substring(0, 8).toUpperCase();
      final orderNumber = 'WIB-${DateTime.now().millisecondsSinceEpoch ~/ 1000}-$uuid';
      final totalPrice = subtotal - discount + shippingCost;
      final now = DateTime.now().toIso8601String();

      final order = OrderModel(
        userId: userId,
        addressId: addressId,
        orderNumber: orderNumber,
        subtotal: subtotal,
        discount: discount,
        shippingCost: shippingCost,
        totalPrice: totalPrice,
        promoCode: promoCode,
        status: 'pending',
        orderDate: now,
        note: note,
      );

      // Begin transaction
      final db = await DatabaseHelper.instance.database;
      await db.transaction((txn) async {
        // 1. Create order
        final orderId = await txn.insert('orders', order.toMap());

        // 2. Insert order details
        for (final item in cartItems) {
          await txn.insert('order_detail', {
            'order_id': orderId,
            'product_id': item.productId,
            'quantity': item.quantity,
            'price': item.price,
            'subtotal': item.subtotal,
            'note': item.note,
          });

          // 3. Reduce stock
          await txn.rawUpdate(
            '''UPDATE product_stock 
               SET quantity = MAX(0, quantity - ?), updated_at = ? 
               WHERE product_id = ?''',
            [item.quantity, now, item.productId],
          );

          // Update sold count
          await txn.rawUpdate(
            'UPDATE product SET sold = sold + ? WHERE product_id = ?',
            [item.quantity, item.productId],
          );
        }

        // 4. Insert payment
        await txn.insert('payment', {
          'order_id': orderId,
          'payment_method': paymentMethod,
          'payment_status': 'pending',
          'amount': totalPrice,
        });

        // 5. Insert status history
        await txn.insert('order_status_history', {
          'order_id': orderId,
          'status': 'pending',
          'description': 'Pesanan berhasil dibuat, menunggu konfirmasi',
          'created_at': now,
        });

        _currentOrder = OrderModel(
          orderId: orderId,
          userId: userId,
          addressId: addressId,
          orderNumber: orderNumber,
          subtotal: subtotal,
          discount: discount,
          shippingCost: shippingCost,
          totalPrice: totalPrice,
          promoCode: promoCode,
          status: 'pending',
          orderDate: now,
          note: note,
        );
      });

      _successMessage = 'Pesanan berhasil dibuat!';
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal membuat pesanan: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateOrderStatus(
      int orderId, String newStatus, String description) async {
    _setLoading(true);
    try {
      await _orderRepo.updateOrderStatus(orderId, newStatus);
      final now = DateTime.now().toIso8601String();
      await _orderRepo.insertStatusHistory(OrderStatusHistory(
        orderId: orderId,
        status: newStatus,
        description: description,
        createdAt: now,
      ));

      await loadAllOrders();
      _successMessage = 'Status pesanan diupdate';
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengupdate status';
      _setLoading(false);
      return false;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
