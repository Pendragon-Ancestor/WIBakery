class ProductModel {
  final int? productId;
  final int categoryId;
  final String productName;
  final String? description;
  final double price;
  final String? image;
  final String status;
  final int sold;
  final double rating;
  final String createdAt;
  // Joined fields
  final String? categoryName;
  final int? stock;

  const ProductModel({
    this.productId,
    required this.categoryId,
    required this.productName,
    this.description,
    required this.price,
    this.image,
    this.status = 'active',
    this.sold = 0,
    this.rating = 0.0,
    required this.createdAt,
    this.categoryName,
    this.stock,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      productId: map['product_id'] as int?,
      categoryId: map['category_id'] as int,
      productName: map['product_name'] as String,
      description: map['description'] as String?,
      price: (map['price'] as num).toDouble(),
      image: map['image'] as String?,
      status: map['status'] as String? ?? 'active',
      sold: map['sold'] as int? ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['created_at'] as String? ?? DateTime.now().toIso8601String(),
      categoryName: map['category_name'] as String?,
      stock: map['quantity'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (productId != null) 'product_id': productId,
      'category_id': categoryId,
      'product_name': productName,
      'description': description,
      'price': price,
      'image': image,
      'status': status,
      'sold': sold,
      'rating': rating,
      'created_at': createdAt,
    };
  }

  bool get isActive => status == 'active';

  String get formattedPrice {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }
}
