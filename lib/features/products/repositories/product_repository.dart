import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/product_model.dart';
import '../../../core/models/category_model.dart';

class ProductRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<Database> get _db async => _dbHelper.database;

  Future<List<ProductModel>> getAllProducts({String? status}) async {
    final db = await _db;
    final maps = await db.rawQuery('''
      SELECT p.*, c.category_name, ps.quantity
      FROM product p
      LEFT JOIN category c ON p.category_id = c.category_id
      LEFT JOIN product_stock ps ON p.product_id = ps.product_id
      ${status != null ? "WHERE p.status = '$status'" : ""}
      ORDER BY p.sold DESC
    ''');
    return maps.map(ProductModel.fromMap).toList();
  }

  Future<List<ProductModel>> getPopularProducts({int limit = 10}) async {
    final db = await _db;
    final maps = await db.rawQuery('''
      SELECT p.*, c.category_name, ps.quantity
      FROM product p
      LEFT JOIN category c ON p.category_id = c.category_id
      LEFT JOIN product_stock ps ON p.product_id = ps.product_id
      WHERE p.status = 'active'
      ORDER BY p.sold DESC
      LIMIT $limit
    ''');
    return maps.map(ProductModel.fromMap).toList();
  }

  Future<List<ProductModel>> getProductsByCategory(int categoryId) async {
    final db = await _db;
    final maps = await db.rawQuery('''
      SELECT p.*, c.category_name, ps.quantity
      FROM product p
      LEFT JOIN category c ON p.category_id = c.category_id
      LEFT JOIN product_stock ps ON p.product_id = ps.product_id
      WHERE p.category_id = ? AND p.status = 'active'
      ORDER BY p.sold DESC
    ''', [categoryId]);
    return maps.map(ProductModel.fromMap).toList();
  }

  Future<List<ProductModel>> searchProducts(String keyword) async {
    final db = await _db;
    final maps = await db.rawQuery('''
      SELECT p.*, c.category_name, ps.quantity
      FROM product p
      LEFT JOIN category c ON p.category_id = c.category_id
      LEFT JOIN product_stock ps ON p.product_id = ps.product_id
      WHERE p.product_name LIKE ? AND p.status = 'active'
      ORDER BY p.sold DESC
    ''', ['%$keyword%']);
    return maps.map(ProductModel.fromMap).toList();
  }

  Future<ProductModel?> getProductById(int productId) async {
    final db = await _db;
    final maps = await db.rawQuery('''
      SELECT p.*, c.category_name, ps.quantity
      FROM product p
      LEFT JOIN category c ON p.category_id = c.category_id
      LEFT JOIN product_stock ps ON p.product_id = ps.product_id
      WHERE p.product_id = ?
    ''', [productId]);
    if (maps.isEmpty) return null;
    return ProductModel.fromMap(maps.first);
  }

  Future<List<CategoryModel>> getAllCategories() async {
    final db = await _db;
    final maps = await db.query(
      'category',
      where: 'status = 1',
      orderBy: 'category_id ASC',
    );
    return maps.map(CategoryModel.fromMap).toList();
  }

  Future<int> createProduct(ProductModel product) async {
    final db = await _db;
    return await db.insert('product', product.toMap());
  }

  Future<int> updateProduct(ProductModel product) async {
    final db = await _db;
    return await db.update(
      'product',
      product.toMap(),
      where: 'product_id = ?',
      whereArgs: [product.productId],
    );
  }

  Future<void> updateStock(int productId, int newQuantity) async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();
    await db.update(
      'product_stock',
      {'quantity': newQuantity, 'updated_at': now},
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  Future<void> decreaseStock(int productId, int amount) async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();
    await db.rawUpdate(
      '''UPDATE product_stock 
         SET quantity = MAX(0, quantity - ?), updated_at = ? 
         WHERE product_id = ?''',
      [amount, now, productId],
    );
    // Also update sold count
    await db.rawUpdate(
      'UPDATE product SET sold = sold + ? WHERE product_id = ?',
      [amount, productId],
    );
  }

  Future<int> updateProductStatus(int productId, String status) async {
    final db = await _db;
    return await db.update(
      'product',
      {'status': status},
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  Future<void> insertStock(int productId, int initialStock) async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();
    await db.insert(
      'product_stock',
      {
        'product_id': productId,
        'quantity': initialStock,
        'min_stock': 5,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteProduct(int productId) async {
    final db = await _db;
    await db.delete('product_stock', where: 'product_id = ?', whereArgs: [productId]);
    return await db.delete('product', where: 'product_id = ?', whereArgs: [productId]);
  }
}
