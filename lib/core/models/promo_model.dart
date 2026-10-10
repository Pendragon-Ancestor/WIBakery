class PromoModel {
  final int? promoId;
  final String promoCode;
  final String promoName;
  final String discountType; // 'percent' or 'fixed'
  final double discountValue;
  final double minTransaction;
  final double? maxDiscount;
  final String startDate;
  final String endDate;
  final bool status;

  const PromoModel({
    this.promoId,
    required this.promoCode,
    required this.promoName,
    required this.discountType,
    required this.discountValue,
    this.minTransaction = 0,
    this.maxDiscount,
    required this.startDate,
    required this.endDate,
    this.status = true,
  });

  factory PromoModel.fromMap(Map<String, dynamic> map) {
    return PromoModel(
      promoId: map['promo_id'] as int?,
      promoCode: map['promo_code'] as String,
      promoName: map['promo_name'] as String,
      discountType: map['discount_type'] as String,
      discountValue: (map['discount_value'] as num).toDouble(),
      minTransaction: (map['min_transaction'] as num?)?.toDouble() ?? 0,
      maxDiscount: (map['max_discount'] as num?)?.toDouble(),
      startDate: map['start_date'] as String,
      endDate: map['end_date'] as String,
      status: (map['status'] as int? ?? 1) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (promoId != null) 'promo_id': promoId,
      'promo_code': promoCode,
      'promo_name': promoName,
      'discount_type': discountType,
      'discount_value': discountValue,
      'min_transaction': minTransaction,
      'max_discount': maxDiscount,
      'start_date': startDate,
      'end_date': endDate,
      'status': status ? 1 : 0,
    };
  }

  bool get isValid {
    final now = DateTime.now();
    final start = DateTime.parse(startDate);
    final end = DateTime.parse(endDate);
    return status && now.isAfter(start) && now.isBefore(end);
  }

  double calculateDiscount(double subtotal) {
    if (subtotal < minTransaction) return 0;
    if (discountType == 'percent') {
      double disc = subtotal * discountValue / 100;
      if (maxDiscount != null && disc > maxDiscount!) {
        disc = maxDiscount!;
      }
      return disc;
    } else {
      return discountValue;
    }
  }

  String get discountLabel {
    if (discountType == 'percent') {
      return '${discountValue.toInt()}%';
    } else {
      return 'Rp ${discountValue.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
    }
  }
}
