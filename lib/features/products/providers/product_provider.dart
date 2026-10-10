import 'package:flutter/foundation.dart';
import '../../../core/models/product_model.dart';
import '../../../core/models/category_model.dart';
import '../repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository _productRepo = ProductRepository();

  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  List<ProductModel> _popularProducts = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  int? _selectedCategoryId;
  String _selectedCategoryName = 'Semua';

  List<ProductModel> get allProducts => _allProducts;
  List<ProductModel> get filteredProducts => _filteredProducts;
  List<ProductModel> get popularProducts => _popularProducts;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  int? get selectedCategoryId => _selectedCategoryId;
  String get selectedCategoryName => _selectedCategoryName;

  Future<void> loadAll() async {
    _setLoading(true);
    try {
      await Future.wait([
        _loadCategories(),
        _loadPopularProducts(),
        _loadAllProducts(),
      ]);
    } catch (e) {
      _errorMessage = 'Gagal memuat data produk';
    }
    _setLoading(false);
  }

  Future<void> _loadCategories() async {
    _categories = await _productRepo.getAllCategories();
  }

  Future<void> _loadPopularProducts() async {
    _popularProducts = await _productRepo.getPopularProducts(limit: 10);
  }

  Future<void> _loadAllProducts() async {
    _allProducts = await _productRepo.getAllProducts(status: 'active');
    _filteredProducts = List.from(_allProducts);
  }

  Future<void> loadAdminProducts() async {
    _setLoading(true);
    try {
      _allProducts = await _productRepo.getAllProducts();
      _filteredProducts = List.from(_allProducts);
    } catch (e) {
      _errorMessage = 'Gagal memuat produk';
    }
    _setLoading(false);
  }

  void searchProducts(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void filterByCategory(int? categoryId, String categoryName) {
    _selectedCategoryId = categoryId;
    _selectedCategoryName = categoryName;
    _applyFilters();
  }

  void _applyFilters() {
    List<ProductModel> result = List.from(_allProducts);

    if (_selectedCategoryId != null) {
      result =
          result.where((p) => p.categoryId == _selectedCategoryId).toList();
    }

    if (_searchQuery.isNotEmpty) {
      result = result
          .where((p) => p.productName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    _filteredProducts = result;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategoryId = null;
    _selectedCategoryName = 'Semua';
    _filteredProducts = List.from(_allProducts);
    notifyListeners();
  }

  Future<ProductModel?> getProductById(int id) async {
    return await _productRepo.getProductById(id);
  }

  Future<bool> addProduct(ProductModel product, int initialStock) async {
    try {
      final productId = await _productRepo.createProduct(product);
      await _productRepo.insertStock(productId, initialStock);
      await loadAdminProducts();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menambah produk: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(int productId) async {
    try {
      await _productRepo.deleteProduct(productId);
      await loadAdminProducts();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus produk: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(ProductModel product) async {
    try {
      await _productRepo.updateProduct(product);
      await loadAdminProducts();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengupdate produk';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStock(int productId, int quantity) async {
    try {
      await _productRepo.updateStock(productId, quantity);
      await loadAdminProducts();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengupdate stok';
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleProductStatus(int productId, String currentStatus) async {
    try {
      final newStatus = currentStatus == 'active' ? 'inactive' : 'active';
      await _productRepo.updateProductStatus(productId, newStatus);
      await loadAdminProducts();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengubah status produk';
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
