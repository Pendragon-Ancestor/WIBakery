import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/product_model.dart';
import '../../../core/widgets/bakery_image.dart';
import '../../products/providers/product_provider.dart';
import '../widgets/add_edit_product_dialog.dart';

class AdminProductsTab extends StatefulWidget {
  const AdminProductsTab({super.key});

  @override
  State<AdminProductsTab> createState() => _AdminProductsTabState();
}

class _AdminProductsTabState extends State<AdminProductsTab> {
  final TextEditingController _searchController = TextEditingController();
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadAdminProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddEditDialog([ProductModel? product]) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddEditProductDialog(product: product),
    );
    if (result == true && mounted) {
      context.read<ProductProvider>().loadAdminProducts();
    }
  }

  void _showUpdateStockDialog(ProductModel product) {
    final controller = TextEditingController(text: '${product.stock ?? 0}');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Update Stok: ${product.productName}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan jumlah stok saat ini:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                suffixText: 'pcs',
                prefixIcon: Icon(Icons.inventory_2_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final newStock = int.tryParse(controller.text.trim());
              if (newStock != null && newStock >= 0) {
                Navigator.pop(ctx);
                final ok = await context
                    .read<ProductProvider>()
                    .updateStock(product.productId!, newStock);
                if (ok && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Stok berhasil diperbarui!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(ProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Produk?'),
        content: Text(
          'Apakah Anda yakin ingin menghapus produk "${product.productName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await context
                  .read<ProductProvider>()
                  .deleteProduct(product.productId!);
              if (ok && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Produk berhasil dihapus!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final categories = productProvider.categories;

    List<ProductModel> products = productProvider.allProducts;
    if (_selectedCategoryId != null) {
      products =
          products.where((p) => p.categoryId == _selectedCategoryId).toList();
    }
    if (_searchController.text.isNotEmpty) {
      products = products
          .where((p) => p.productName
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tambah Produk',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search & Filter header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                // Search box
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari produk bakery...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Categories filter
                SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: const Text('Semua'),
                          selected: _selectedCategoryId == null,
                          onSelected: (_) =>
                              setState(() => _selectedCategoryId = null),
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            fontSize: 11,
                            color: _selectedCategoryId == null
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      ...categories.map((c) {
                        final isSel = _selectedCategoryId == c.categoryId;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(c.categoryName),
                            selected: isSel,
                            onSelected: (_) => setState(
                                () => _selectedCategoryId = c.categoryId),
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              fontSize: 11,
                              color: isSel
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Product list
          Expanded(
            child: productProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.bakery_dining_outlined,
                                size: 56, color: AppColors.textHint),
                            const SizedBox(height: 8),
                            const Text(
                              'Tidak ada produk ditemukan',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () =>
                            productProvider.loadAdminProducts(),
                        color: AppColors.primary,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final p = products[index];
                            final stock = p.stock ?? 0;
                            final isLowStock = stock <= 5;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Image thumbnail
                                    BakeryImage(
                                      imageKey: p.image,
                                      productName: p.productName,
                                      width: 56,
                                      height: 56,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    const SizedBox(width: 12),

                                    // Product Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  p.productName,
                                                  style: const TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                    color: AppColors.textPrimary,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: p.isActive
                                                      ? AppColors.success
                                                          .withValues(alpha: 0.12)
                                                      : Colors.grey
                                                          .withValues(alpha: 0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  p.isActive
                                                      ? 'Aktif'
                                                      : 'Nonaktif',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: p.isActive
                                                      ? AppColors.success
                                                      : Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            p.formattedPrice,
                                            style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              // Stock pill
                                              GestureDetector(
                                                onTap: () =>
                                                    _showUpdateStockDialog(p),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: isLowStock
                                                        ? AppColors.error
                                                            .withValues(alpha: 0.12)
                                                        : AppColors.surfaceVariant,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    border: Border.all(
                                                      color: isLowStock
                                                          ? AppColors.error
                                                          : AppColors.border,
                                                      width: 0.8,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.inventory_2,
                                                        size: 12,
                                                        color: isLowStock
                                                            ? AppColors.error
                                                            : AppColors.textSecondary,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'Stok: $stock pcs',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: isLowStock
                                                              ? AppColors.error
                                                              : AppColors.textPrimary,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 2),
                                                      const Icon(
                                                        Icons.edit,
                                                        size: 10,
                                                        color: AppColors.textHint,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Terjual: ${p.sold}',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Action buttons
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert,
                                          color: AppColors.textSecondary),
                                      onSelected: (val) {
                                        if (val == 'edit') {
                                          _showAddEditDialog(p);
                                        } else if (val == 'stock') {
                                          _showUpdateStockDialog(p);
                                        } else if (val == 'status') {
                                          productProvider.toggleProductStatus(
                                              p.productId!, p.status);
                                        } else if (val == 'delete') {
                                          _confirmDelete(p);
                                        }
                                      },
                                      itemBuilder: (ctx) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit,
                                                  size: 16,
                                                  color: AppColors.primary),
                                              SizedBox(width: 8),
                                              Text('Edit Produk'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'stock',
                                          child: Row(
                                            children: [
                                              Icon(Icons.inventory_2,
                                                  size: 16,
                                                  color: AppColors.primary),
                                              SizedBox(width: 8),
                                              Text('Ubah Stok'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'status',
                                          child: Row(
                                            children: [
                                              Icon(
                                                p.isActive
                                                    ? Icons.visibility_off
                                                    : Icons.visibility,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(p.isActive
                                                  ? 'Nonaktifkan'
                                                  : 'Aktifkan'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete,
                                                  size: 16,
                                                  color: AppColors.error),
                                              SizedBox(width: 8),
                                              Text('Hapus Produk',
                                                  style: TextStyle(
                                                      color: AppColors.error)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
