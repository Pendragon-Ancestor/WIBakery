class AddressModel {
  final int? addressId;
  final int userId;
  final String label;
  final String receiverName;
  final String phone;
  final String addressDetail;
  final String city;
  final String postalCode;
  final bool isDefault;

  const AddressModel({
    this.addressId,
    required this.userId,
    required this.label,
    required this.receiverName,
    required this.phone,
    required this.addressDetail,
    required this.city,
    required this.postalCode,
    this.isDefault = false,
  });

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      addressId: map['address_id'] as int?,
      userId: map['user_id'] as int,
      label: map['label'] as String,
      receiverName: map['receiver_name'] as String,
      phone: map['phone'] as String,
      addressDetail: map['address_detail'] as String,
      city: map['city'] as String,
      postalCode: map['postal_code'] as String,
      isDefault: (map['is_default'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (addressId != null) 'address_id': addressId,
      'user_id': userId,
      'label': label,
      'receiver_name': receiverName,
      'phone': phone,
      'address_detail': addressDetail,
      'city': city,
      'postal_code': postalCode,
      'is_default': isDefault ? 1 : 0,
    };
  }

  String get fullAddress => '$addressDetail, $city $postalCode';
}
