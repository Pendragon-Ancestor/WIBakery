class CategoryModel {
  final int? categoryId;
  final String categoryName;
  final String? description;
  final String? image;
  final bool status;

  const CategoryModel({
    this.categoryId,
    required this.categoryName,
    this.description,
    this.image,
    this.status = true,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      categoryId: map['category_id'] as int?,
      categoryName: map['category_name'] as String,
      description: map['description'] as String?,
      image: map['image'] as String?,
      status: (map['status'] as int? ?? 1) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (categoryId != null) 'category_id': categoryId,
      'category_name': categoryName,
      'description': description,
      'image': image,
      'status': status ? 1 : 0,
    };
  }
}
