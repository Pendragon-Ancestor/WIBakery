import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'wib_bakery.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // TABLE: USERS
    await db.execute('''
      CREATE TABLE users (
        user_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        phone TEXT UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'customer',
        photo TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // TABLE: USER_ADDRESS
    await db.execute('''
      CREATE TABLE user_address (
        address_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        label TEXT NOT NULL,
        receiver_name TEXT NOT NULL,
        phone TEXT NOT NULL,
        address_detail TEXT NOT NULL,
        city TEXT NOT NULL,
        postal_code TEXT NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
      )
    ''');

    // TABLE: CATEGORY
    await db.execute('''
      CREATE TABLE category (
        category_id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_name TEXT UNIQUE NOT NULL,
        description TEXT,
        image TEXT,
        status INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // TABLE: PRODUCT
    await db.execute('''
      CREATE TABLE product (
        product_id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        image TEXT,
        status TEXT NOT NULL DEFAULT 'active',
        sold INTEGER NOT NULL DEFAULT 0,
        rating REAL NOT NULL DEFAULT 0.0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES category(category_id)
      )
    ''');

    // TABLE: PRODUCT_STOCK
    await db.execute('''
      CREATE TABLE product_stock (
        stock_id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER UNIQUE NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 0,
        min_stock INTEGER NOT NULL DEFAULT 5,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (product_id) REFERENCES product(product_id),
        CHECK (quantity >= 0)
      )
    ''');

    // TABLE: PROMO
    await db.execute('''
      CREATE TABLE promo (
        promo_id INTEGER PRIMARY KEY AUTOINCREMENT,
        promo_code TEXT UNIQUE NOT NULL,
        promo_name TEXT NOT NULL,
        discount_type TEXT NOT NULL,
        discount_value REAL NOT NULL,
        min_transaction REAL NOT NULL DEFAULT 0,
        max_discount REAL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        status INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // TABLE: PRODUCT_PROMO (N:M)
    await db.execute('''
      CREATE TABLE product_promo (
        product_promo_id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        promo_id INTEGER NOT NULL,
        FOREIGN KEY (product_id) REFERENCES product(product_id),
        FOREIGN KEY (promo_id) REFERENCES promo(promo_id)
      )
    ''');

    // TABLE: CART
    await db.execute('''
      CREATE TABLE cart (
        cart_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER UNIQUE NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
      )
    ''');

    // TABLE: CART_DETAIL
    await db.execute('''
      CREATE TABLE cart_detail (
        cart_detail_id INTEGER PRIMARY KEY AUTOINCREMENT,
        cart_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        note TEXT,
        price REAL NOT NULL,
        FOREIGN KEY (cart_id) REFERENCES cart(cart_id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES product(product_id)
      )
    ''');

    // TABLE: ORDERS
    await db.execute('''
      CREATE TABLE orders (
        order_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        address_id INTEGER,
        order_number TEXT UNIQUE NOT NULL,
        subtotal REAL NOT NULL,
        discount REAL NOT NULL DEFAULT 0,
        shipping_cost REAL NOT NULL DEFAULT 10000,
        total_price REAL NOT NULL,
        promo_code TEXT,
        status TEXT NOT NULL DEFAULT 'pending',
        order_date TEXT NOT NULL,
        note TEXT,
        FOREIGN KEY (user_id) REFERENCES users(user_id),
        FOREIGN KEY (address_id) REFERENCES user_address(address_id)
      )
    ''');

    // TABLE: ORDER_DETAIL
    await db.execute('''
      CREATE TABLE order_detail (
        order_detail_id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        subtotal REAL NOT NULL,
        note TEXT,
        FOREIGN KEY (order_id) REFERENCES orders(order_id),
        FOREIGN KEY (product_id) REFERENCES product(product_id)
      )
    ''');

    // TABLE: PAYMENT
    await db.execute('''
      CREATE TABLE payment (
        payment_id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER UNIQUE NOT NULL,
        payment_method TEXT NOT NULL,
        payment_status TEXT NOT NULL DEFAULT 'pending',
        payment_date TEXT,
        transaction_id TEXT,
        amount REAL NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders(order_id)
      )
    ''');

    // TABLE: ORDER_STATUS_HISTORY
    await db.execute('''
      CREATE TABLE order_status_history (
        history_id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        status TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders(order_id)
      )
    ''');

    // TABLE: REVIEW
    await db.execute('''
      CREATE TABLE review (
        review_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
        comment TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(user_id),
        FOREIGN KEY (product_id) REFERENCES product(product_id)
      )
    ''');

    // TABLE: FAVORITE
    await db.execute('''
      CREATE TABLE favorite (
        favorite_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        UNIQUE(user_id, product_id),
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES product(product_id)
      )
    ''');

    // Insert seed data
    await _insertSeedData(db);
  }

  Future<void> _insertSeedData(Database db) async {
    final now = DateTime.now().toIso8601String();
    final adminPass = _hashPassword('admin123');
    final custPass = _hashPassword('customer123');

    // Insert admin user
    await db.insert('users', {
      'name': 'Admin WIB Bakery',
      'email': 'admin@wibbakery.com',
      'phone': '081234567890',
      'password': adminPass,
      'role': 'admin',
      'photo': null,
      'created_at': now,
      'updated_at': now,
    });

    // Insert demo customer
    await db.insert('users', {
      'name': 'Fanduy',
      'email': 'fanduy@gmail.com',
      'phone': '081234567891',
      'password': custPass,
      'role': 'customer',
      'photo': null,
      'created_at': now,
      'updated_at': now,
    });

    // Insert address for demo customer
    await db.insert('user_address', {
      'user_id': 2,
      'label': 'Rumah',
      'receiver_name': 'Fanduy',
      'phone': '081234567891',
      'address_detail': 'Jl. Kebayoran Baru No. 12',
      'city': 'Jakarta Selatan',
      'postal_code': '12120',
      'is_default': 1,
    });

    // Insert categories
    final categories = [
      {'category_name': 'Roti', 'description': 'Berbagai jenis roti segar', 'image': 'roti', 'status': 1},
      {'category_name': 'Kue', 'description': 'Kue tradisional dan modern', 'image': 'kue', 'status': 1},
      {'category_name': 'Pastry', 'description': 'Pastry premium berkualitas', 'image': 'pastry', 'status': 1},
      {'category_name': 'Minuman', 'description': 'Minuman segar pendamping', 'image': 'minuman', 'status': 1},
    ];

    for (final cat in categories) {
      await db.insert('category', cat);
    }

    // Insert products
    final products = [
      {
        'category_id': 3, // Pastry
        'product_name': 'Almond Croissant',
        'description': 'Pastry klasik dengan krim almond yang lezat dan renyah. Dibuat dari adonan mentega pilihan dengan taburan irisan almond panggang.',
        'price': 28000.0,
        'image': 'almond_croissant',
        'status': 'active',
        'sold': 152,
        'rating': 4.8,
        'created_at': now,
      },
      {
        'category_id': 1, // Roti
        'product_name': 'Roti Sisir Mentega',
        'description': 'Roti empuk dengan mentega premium yang meleleh di mulut. Dibuat dengan resep tradisional WIB Bakery.',
        'price': 18000.0,
        'image': 'roti_sisir',
        'status': 'active',
        'sold': 243,
        'rating': 4.6,
        'created_at': now,
      },
      {
        'category_id': 2, // Kue
        'product_name': 'Kue Lumpur Surga',
        'description': 'Kue tradisional pandan dengan tekstur lembut dan aroma daun pandan yang harum. Resep turun-temurun.',
        'price': 15000.0,
        'image': 'kue_lumpur',
        'status': 'active',
        'sold': 189,
        'rating': 4.7,
        'created_at': now,
      },
      {
        'category_id': 4, // Minuman
        'product_name': 'Es Kopi Susu Aren',
        'description': 'Kopi robusta susu dengan gula aren pilihan. Perpaduan sempurna antara rasa pahit kopi dan manis gula aren.',
        'price': 18000.0,
        'image': 'kopi_susu',
        'status': 'active',
        'sold': 310,
        'rating': 4.9,
        'created_at': now,
      },
      {
        'category_id': 3, // Pastry
        'product_name': 'Cinnamon Roll',
        'description': 'Gulungan kayu manis dengan topping cream cheese frosting yang lembut. Aroma kayu manis yang menggugah selera.',
        'price': 25000.0,
        'image': 'cinnamon_roll',
        'status': 'active',
        'sold': 98,
        'rating': 4.7,
        'created_at': now,
      },
      {
        'category_id': 1, // Roti
        'product_name': 'Sourdough Plain',
        'description': 'Roti ragi alami tanpa pengawet. Proses fermentasi 24 jam menghasilkan tekstur kenyal dan rasa asam yang khas.',
        'price': 45000.0,
        'image': 'sourdough',
        'status': 'active',
        'sold': 67,
        'rating': 4.5,
        'created_at': now,
      },
      {
        'category_id': 2, // Kue
        'product_name': 'Brownies Cokelat',
        'description': 'Brownies lembut dengan cokelat belgia premium. Tekstur fudgy yang kaya rasa dan aroma cokelat yang pekat.',
        'price': 32000.0,
        'image': 'brownies',
        'status': 'active',
        'sold': 134,
        'rating': 4.6,
        'created_at': now,
      },
      {
        'category_id': 4, // Minuman
        'product_name': 'Matcha Latte',
        'description': 'Matcha premium grade asal Jepang dengan susu segar. Rasa sedikit pahit yang menyegarkan dan menyehatkan.',
        'price': 22000.0,
        'image': 'matcha_latte',
        'status': 'active',
        'sold': 88,
        'rating': 4.4,
        'created_at': now,
      },
    ];

    for (final product in products) {
      final productId = await db.insert('product', product);
      // Insert stock for each product
      await db.insert('product_stock', {
        'product_id': productId,
        'quantity': 50,
        'min_stock': 5,
        'updated_at': now,
      });
    }

    // Insert promo
    await db.insert('promo', {
      'promo_code': 'WIBANGET',
      'promo_name': 'Diskon 20% Semua Pastry',
      'discount_type': 'percent',
      'discount_value': 20.0,
      'min_transaction': 50000.0,
      'max_discount': 30000.0,
      'start_date': '2024-01-01',
      'end_date': '2025-12-31',
      'status': 1,
    });

    await db.insert('promo', {
      'promo_code': 'WIBNEW',
      'promo_name': 'Diskon Rp 10.000 Member Baru',
      'discount_type': 'fixed',
      'discount_value': 10000.0,
      'min_transaction': 30000.0,
      'max_discount': null,
      'start_date': '2024-01-01',
      'end_date': '2025-12-31',
      'status': 1,
    });
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
