class CartDetailModel {
  final int? cartDetailId;
  final int cartId;
  final int productId;
  int quantity;
  final String? note;
  final double price;
  // Joined
  final String? productName;
  final String? productImage;
  final int? stock;

  CartDetailModel({
    this.cartDetailId,
    required this.cartId,
    required this.productId,
    required this.quantity,
    this.note,
    required this.price,
    this.productName,
    this.productImage,
    this.stock,
  });

  factory CartDetailModel.fromMap(Map<String, dynamic> map) {
    return CartDetailModel(
      cartDetailId: map['cart_detail_id'] as int?,
      cartId: map['cart_id'] as int,
      productId: map['product_id'] as int,
      quantity: map['quantity'] as int,
      note: map['note'] as String?,
      price: (map['price'] as num).toDouble(),
      productName: map['product_name'] as String?,
      productImage: map['image'] as String?,
      stock: map['quantity_stock'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (cartDetailId != null) 'cart_detail_id': cartDetailId,
      'cart_id': cartId,
      'product_id': productId,
      'quantity': quantity,
      'note': note,
      'price': price,
    };
  }

  double get subtotal => price * quantity;

  String get formattedPrice {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  String get formattedSubtotal {
    return 'Rp ${subtotal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }
}

class CartModel {
  final int? cartId;
  final int userId;
  final String createdAt;
  final List<CartDetailModel> items;

  const CartModel({
    this.cartId,
    required this.userId,
    required this.createdAt,
    this.items = const [],
  });

  factory CartModel.fromMap(Map<String, dynamic> map,
      {List<CartDetailModel>? items}) {
    return CartModel(
      cartId: map['cart_id'] as int?,
      userId: map['user_id'] as int,
      createdAt: map['created_at'] as String,
      items: items ?? [],
    );
  }

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);
}
