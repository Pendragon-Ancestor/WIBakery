class OrderDetailModel {
  final int? orderDetailId;
  final int orderId;
  final int productId;
  final int quantity;
  final double price;
  final double subtotal;
  final String? note;
  // Joined
  final String? productName;
  final String? productImage;

  const OrderDetailModel({
    this.orderDetailId,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.subtotal,
    this.note,
    this.productName,
    this.productImage,
  });

  factory OrderDetailModel.fromMap(Map<String, dynamic> map) {
    return OrderDetailModel(
      orderDetailId: map['order_detail_id'] as int?,
      orderId: map['order_id'] as int,
      productId: map['product_id'] as int,
      quantity: map['quantity'] as int,
      price: (map['price'] as num).toDouble(),
      subtotal: (map['subtotal'] as num).toDouble(),
      note: map['note'] as String?,
      productName: map['product_name'] as String?,
      productImage: map['image'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (orderDetailId != null) 'order_detail_id': orderDetailId,
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
      'note': note,
    };
  }
}

class OrderModel {
  final int? orderId;
  final int userId;
  final int? addressId;
  final String orderNumber;
  final double subtotal;
  final double discount;
  final double shippingCost;
  final double totalPrice;
  final String? promoCode;
  final String status;
  final String orderDate;
  final String? note;
  // Joined
  final String? userName;
  final String? addressDetail;
  final List<OrderDetailModel> items;

  const OrderModel({
    this.orderId,
    required this.userId,
    this.addressId,
    required this.orderNumber,
    required this.subtotal,
    this.discount = 0,
    required this.shippingCost,
    required this.totalPrice,
    this.promoCode,
    this.status = 'pending',
    required this.orderDate,
    this.note,
    this.userName,
    this.addressDetail,
    this.items = const [],
  });

  factory OrderModel.fromMap(Map<String, dynamic> map,
      {List<OrderDetailModel>? items}) {
    return OrderModel(
      orderId: map['order_id'] as int?,
      userId: map['user_id'] as int,
      addressId: map['address_id'] as int?,
      orderNumber: map['order_number'] as String,
      subtotal: (map['subtotal'] as num).toDouble(),
      discount: (map['discount'] as num?)?.toDouble() ?? 0,
      shippingCost: (map['shipping_cost'] as num).toDouble(),
      totalPrice: (map['total_price'] as num).toDouble(),
      promoCode: map['promo_code'] as String?,
      status: map['status'] as String,
      orderDate: map['order_date'] as String,
      note: map['note'] as String?,
      userName: map['name'] as String?,
      addressDetail: map['address_detail'] as String?,
      items: items ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (orderId != null) 'order_id': orderId,
      'user_id': userId,
      'address_id': addressId,
      'order_number': orderNumber,
      'subtotal': subtotal,
      'discount': discount,
      'shipping_cost': shippingCost,
      'total_price': totalPrice,
      'promo_code': promoCode,
      'status': status,
      'order_date': orderDate,
      'note': note,
    };
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Menunggu Konfirmasi';
      case 'processing':
        return 'Sedang Diproses';
      case 'ready':
        return 'Siap Diambil/Dikirim';
      case 'delivery':
        return 'Dalam Pengiriman';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  String formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  String get formattedTotalPrice => formatCurrency(totalPrice);
}

class OrderStatusHistory {
  final int? historyId;
  final int orderId;
  final String status;
  final String? description;
  final String createdAt;

  const OrderStatusHistory({
    this.historyId,
    required this.orderId,
    required this.status,
    this.description,
    required this.createdAt,
  });

  factory OrderStatusHistory.fromMap(Map<String, dynamic> map) {
    return OrderStatusHistory(
      historyId: map['history_id'] as int?,
      orderId: map['order_id'] as int,
      status: map['status'] as String,
      description: map['description'] as String?,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (historyId != null) 'history_id': historyId,
      'order_id': orderId,
      'status': status,
      'description': description,
      'created_at': createdAt,
    };
  }
}
