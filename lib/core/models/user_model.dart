class UserModel {
  final int? userId;
  final String name;
  final String email;
  final String? phone;
  final String password;
  final String role;
  final String? photo;
  final String createdAt;
  final String updatedAt;

  const UserModel({
    this.userId,
    required this.name,
    required this.email,
    this.phone,
    required this.password,
    this.role = 'customer',
    this.photo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['user_id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String?,
      password: map['password'] as String,
      role: map['role'] as String,
      photo: map['photo'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (userId != null) 'user_id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'role': role,
      'photo': photo,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  bool get isAdmin => role == 'admin';

  UserModel copyWith({
    int? userId,
    String? name,
    String? email,
    String? phone,
    String? password,
    String? role,
    String? photo,
  }) {
    final now = DateTime.now().toIso8601String();
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      role: role ?? this.role,
      photo: photo ?? this.photo,
      createdAt: createdAt,
      updatedAt: now,
    );
  }
}
