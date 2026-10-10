# 🥖 WIB Bakery - Aplikasi Pemesanan Roti & Kue Online

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

Aplikasi mobile cross-platform untuk sistem pemesanan roti dan kue online. Dibangun menggunakan **Flutter** dengan fitur lengkap untuk customer dan admin.

---

## 📋 Daftar Isi

- [Tentang Proyek](#tentang-proyek)
- [Fitur Utama](#fitur-utama)
- [Tech Stack](#tech-stack)
- [Struktur Project](#struktur-project)
- [Instalasi & Setup](#instalasi--setup)
- [Cara Penggunaan](#cara-penggunaan)
- [Demo Account](#demo-account)
- [Dokumentasi Fitur](#dokumentasi-fitur)
- [Tim Pengembang](#tim-pengembang)

---

## 🎯 Tentang Proyek

**WIB Bakery** adalah proyek akhir mata kuliah **Pemrograman Mobile** yang mengimplementasikan aplikasi pemesanan roti dan kue secara online. Aplikasi ini dirancang untuk memudahkan customer dalam membeli produk bakery dan membantu admin dalam mengelola katalog produk, promo, dan pesanan.

**Fitur utama:**
- Katalog produk dengan kategori
- Sistem keranjang belanja
- Proses checkout dan pembayaran
- Tracking status pesanan
- Admin dashboard untuk manajemen produk dan promo
- Sistem autentikasi (login/register)

---

## ✨ Fitur Utama

### 👤 Untuk Customer

| Fitur | Deskripsi |
|-------|-----------|
| **Authentication** | Login dan Register dengan validasi email & password |
| **Browse Products** | Lihat katalog produk berdasarkan kategori (Roti, Kue, Minuman) |
| **Product Detail** | Lihat deskripsi, harga, dan rating produk |
| **Shopping Cart** | Tambah/hapus produk ke keranjang belanja |
| **Checkout** | Proses pembelian dengan pilihan alamat pengiriman |
| **Order Tracking** | Lihat status pesanan real-time (Pending, Processing, Shipped, Delivered) |
| **Order History** | Riwayat semua pesanan customer |
| **Promo & Deals** | Lihat dan gunakan kode promo tersedia |

### 🛠️ Untuk Admin

| Fitur | Deskripsi |
|-------|-----------|
| **Admin Dashboard** | Statistik penjualan, total order, dan revenue |
| **Product Management** | CRUD produk (Create, Read, Update, Delete) |
| **Category Management** | Kelola kategori produk |
| **Order Management** | Lihat dan update status pesanan |
| **Promo Management** | Buat dan kelola kode promo |
| **Sales Analytics** | Laporan penjualan dan performa |

---

## 🛠️ Tech Stack

```
Frontend:
├── Flutter 3.0+
├── Dart 3.0+
├── Provider (State Management)
├── Cached Network Image
├── Flutter SVG
├── Carousel Slider
└── Shimmer

Backend/Database:
├── SQLite (Local Database)
└── Local Storage (Shared Preferences)

Design & UI:
├── Material Design 3
├── Custom Widgets
└── Responsive Layout
```

---

## 📁 Struktur Project

```
wib_bakery/
├── lib/
│   ├── main.dart                           # Entry point aplikasi
│   ├── app/
│   │   └── router.dart                     # Navigation routing
│   ├── core/
│   │   ├── database/
│   │   │   └── database_helper.dart        # SQLite database helper
│   │   ├── models/
│   │   │   ├── user_model.dart
│   │   │   ├── product_model.dart
│   │   │   ├── category_model.dart
│   │   │   ├── cart_model.dart
│   │   │   ├── order_model.dart
│   │   │   ├── promo_model.dart
│   │   │   └── address_model.dart
│   │   ├── theme/
│   │   │   ├── app_colors.dart             # Color palette
│   │   │   └── app_theme.dart              # Theme configuration
│   │   └── widgets/
│   │       └── bakery_image.dart           # Reusable image widget
│   ├── features/
│   │   ├── auth/                           # Authentication feature
│   │   │   ├── providers/
│   │   │   ├── repositories/
│   │   │   └── screens/
│   │   ├── home/                           # Home/Dashboard feature
│   │   ├── products/                       # Product catalog
│   │   │   ├── providers/
│   │   │   ├── repositories/
│   │   │   ├── screens/
│   │   │   └── widgets/
│   │   ├── cart/                           # Shopping cart
│   │   ├── orders/                         # Order management
│   │   ├── promo/                          # Promo system
│   │   └── admin/                          # Admin dashboard
│   │       ├── screens/
│   │       └── widgets/
│   └── assets/
│       ├── images/                         # Product images
│       └── icons/                          # App icons
├── android/                                # Android native code
├── pubspec.yaml                            # Dependencies
├── pubspec.lock                            # Dependency versions
└── README.md                               # Documentation
```

---

## 🚀 Instalasi & Setup

### Prasyarat
- Flutter SDK 3.0 atau lebih tinggi
- Dart SDK 3.0 atau lebih tinggi
- Android Studio atau VS Code
- Android Emulator atau device fisik

### Langkah-Langkah Instalasi

1. **Clone Repository**
   ```bash
   git clone https://github.com/reiquasar/WIBakery.git
   cd wib_bakery
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run Aplikasi**
   ```bash
   # Di emulator/device
   flutter run
   
   # Build APK
   flutter build apk --release
   ```

4. **Build Release APK**
   ```bash
   flutter build apk --release
   # Output: build/app/outputs/flutter-apk/app-release.apk
   ```

---

## 📱 Cara Penggunaan

### Untuk Customer

1. **Register Akun**
   - Buka aplikasi → Klik "Register"
   - Isi email, nama, dan password
   - Klik "Create Account"

2. **Login**
   - Masukkan email dan password
   - Klik "Login"

3. **Browse Produk**
   - Lihat katalog produk di homepage
   - Pilih kategori (Roti, Kue, Minuman)
   - Tap produk untuk melihat detail

4. **Tambah ke Keranjang**
   - Pilih jumlah produk
   - Klik "Tambah ke Keranjang"
   - Keranjang akan terupdate

5. **Checkout**
   - Tap ikon keranjang → "Proceed to Checkout"
   - Pilih atau tambah alamat pengiriman
   - Pilih metode pembayaran
   - Klik "Confirm Order"

6. **Track Order**
   - Buka tab "Orders"
   - Lihat status pesanan (Pending → Processing → Shipped → Delivered)

### Untuk Admin

1. **Login sebagai Admin**
   - Email: `admin@wibbakery.com`
   - Password: `admin123`

2. **Dashboard**
   - Lihat statistik penjualan dan total order
   - Monitor revenue dan active orders

3. **Kelola Produk**
   - Tab "Products" → Klik "Add Product"
   - Isi nama, kategori, harga, deskripsi, stok
   - Klik "Save"

4. **Kelola Promo**
   - Tab "Promo" → Klik "Add Promo"
   - Isi kode promo, diskon, dan tanggal berlaku
   - Klik "Save"

5. **Kelola Pesanan**
   - Tab "Orders" → Lihat semua pesanan
   - Update status pesanan sesuai progress

---

## 🔐 Demo Account

Gunakan akun berikut untuk testing:

### Admin Account
```
Email:    admin@wibbakery.com
Password: admin123
```

### Customer Account
```
Email:    fanduy@gmail.com
Password: customer123
```

---

## 📚 Dokumentasi Fitur

### 1. Authentication (Login/Register)
**File:** `lib/features/auth/`

- Validasi email format
- Password hashing dengan bcryptjs
- Session management dengan Provider
- Local storage untuk remember me

### 2. Product Management
**File:** `lib/features/products/` & `lib/features/admin/`

- CRUD operasi untuk produk
- Filter berdasarkan kategori
- Search functionality
- Stock management

### 3. Cart & Checkout
**File:** `lib/features/cart/` & `lib/features/orders/`

- Add/remove items dari keranjang
- Calculate total harga + tax
- Promo code validation
- Address selection

### 4. Order Tracking
**File:** `lib/features/orders/`

- Real-time status updates
- Order history
- Order detail dengan invoice
- Delivery address tracking

### 5. Admin Dashboard
**File:** `lib/features/admin/`

- Sales analytics
- Product inventory
- Order management
- Promo campaign management

---

## 🗄️ Database Schema

### Users Table
```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  email TEXT UNIQUE,
  password TEXT,
  name TEXT,
  role TEXT (admin/customer),
  created_at TIMESTAMP
);
```

### Products Table
```sql
CREATE TABLE products (
  id INTEGER PRIMARY KEY,
  name TEXT,
  category_id INTEGER,
  price REAL,
  description TEXT,
  image_url TEXT,
  stock INTEGER,
  created_at TIMESTAMP
);
```

### Orders Table
```sql
CREATE TABLE orders (
  id INTEGER PRIMARY KEY,
  user_id INTEGER,
  total_price REAL,
  status TEXT (pending/processing/shipped/delivered),
  delivery_address TEXT,
  created_at TIMESTAMP
);
```

### Cart Items Table
```sql
CREATE TABLE cart_items (
  id INTEGER PRIMARY KEY,
  user_id INTEGER,
  product_id INTEGER,
  quantity INTEGER
);
```

---

## 🎓 Pembelajaran & Konsep

Proyek ini mengimplementasikan konsep-konsep penting:

- **State Management** dengan Provider pattern
- **Local Database** dengan SQLite
- **Responsive UI** untuk berbagai ukuran layar
- **Data Modeling** dan entity relationships
- **Clean Code Architecture** dengan separation of concerns
- **Authentication & Authorization**
- **Business Logic** untuk e-commerce

---

## 📸 Screenshots

### Customer Flow
- Splash Screen & Authentication
- Home/Browse Produk
- Product Detail
- Shopping Cart
- Checkout & Order Confirmation
- Order Tracking

### Admin Flow
- Admin Dashboard dengan statistik
- Product Management
- Order Management
- Promo Management

---

## 🐛 Known Issues & Limitations

- Database lokal (tidak ada sync ke server)
- Pembayaran simulasi (tidak real payment gateway)
- Notifikasi basic (tidak push notification)
- Offline mode limited

---

## 🚧 Future Enhancements

- [ ] Integration dengan payment gateway (Midtrans, Stripe)
- [ ] Push notifications
- [ ] Real-time order updates dengan WebSocket
- [ ] Cloud database (Firebase)
- [ ] Backend API integration
- [ ] Rating & review system
- [ ] Wishlist feature
- [ ] Multiple payment methods
- [ ] Admin analytics dashboard yang lebih detailed

---

## 👥 Tim Pengembang

**Proyek Akhir Pemrograman Mobile**
- **Kelompok:** 1
- **Tema:** Aplikasi Mobile Cross-Platform Bakery

---

## 📝 Lisensi

Proyek ini dilisensikan di bawah MIT License.

---

## 📧 Kontak & Support

Untuk pertanyaan atau saran tentang proyek ini, buka GitHub Issues.

---

## 📖 Referensi & Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [Provider Pattern](https://pub.dev/packages/provider)
- [SQLite Flutter](https://pub.dev/packages/sqflite)
- [Material Design 3](https://m3.material.io/)

---

**Happy Coding! 🚀**

*Last Updated: October 2026*
