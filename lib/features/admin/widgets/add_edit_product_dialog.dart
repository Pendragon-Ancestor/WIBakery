import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/product_model.dart';
import '../../products/providers/product_provider.dart';

class AddEditProductDialog extends StatefulWidget {
  final ProductModel? product;

  const AddEditProductDialog({super.key, this.product});

  @override
  State<AddEditProductDialog> createState() => _AddEditProductDialogState();
}

class _AddEditProductDialogState extends State<AddEditProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _descController;
  int _selectedCategoryId = 1;
  String _status = 'active';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _categoryOptions = [
    {'id': 1, 'name': 'Roti Manis'},
    {'id': 2, 'name': 'Roti Tawar'},
    {'id': 3, 'name': 'Pastry & Croissant'},
    {'id': 4, 'name': 'Cake & Tart'},
    {'id': 5, 'name': 'Minuman'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.product?.productName ?? '');
    _priceController = TextEditingController(
        text: widget.product != null
            ? widget.product!.price.toInt().toString()
            : '');
    _stockController = TextEditingController(
        text: widget.product?.stock != null
            ? widget.product!.stock.toString()
            : '20');
    _descController =
        TextEditingController(text: widget.product?.description ?? '');
    _selectedCategoryId = widget.product?.categoryId ?? 1;
    _status = widget.product?.status ?? 'active';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider = context.read<ProductProvider>();
    final isEditing = widget.product != null;

    final product = ProductModel(
      productId: widget.product?.productId,
      categoryId: _selectedCategoryId,
      productName: _nameController.text.trim(),
      description: _descController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? 0,
      image: widget.product?.image ?? 'assets/images/bread_default.png',
      status: _status,
      sold: widget.product?.sold ?? 0,
      rating: widget.product?.rating ?? 5.0,
      createdAt: widget.product?.createdAt ?? DateTime.now().toIso8601String(),
    );

    final stock = int.tryParse(_stockController.text.trim()) ?? 0;

    bool success;
    if (isEditing) {
      success = await provider.updateProduct(product);
      if (success) {
        await provider.updateStock(product.productId!, stock);
      }
    } else {
      success = await provider.addProduct(product, stock);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing
                ? 'Produk berhasil diperbarui!'
                : 'Produk berhasil ditambahkan!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Gagal menyimpan produk'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'Edit Produk Bakery' : 'Tambah Produk Baru',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      splashRadius: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Product Name
                const Text(
                  'Nama Produk',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Roti Cokelat Keju',
                    prefixIcon: Icon(Icons.bakery_dining_outlined),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Nama produk harus diisi'
                      : null,
                ),
                const SizedBox(height: 14),

                // Category & Status Row
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kategori',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<int>(
                            value: _selectedCategoryId,
                            items: _categoryOptions.map((c) {
                              return DropdownMenuItem<int>(
                                value: c['id'] as int,
                                child: Text(
                                  c['name'] as String,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedCategoryId = val);
                              }
                            },
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _status,
                            items: const [
                              DropdownMenuItem(
                                  value: 'active',
                                  child: Text('Aktif',
                                      style: TextStyle(fontSize: 13))),
                              DropdownMenuItem(
                                  value: 'inactive',
                                  child: Text('Nonaktif',
                                      style: TextStyle(fontSize: 13))),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _status = val);
                            },
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Price & Stock Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Harga (Rp)',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: '15000',
                              prefixText: 'Rp ',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Wajib diisi';
                              }
                              if (double.tryParse(v.trim()) == null) {
                                return 'Angka tidak valid';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Stok',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _stockController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: '25',
                              suffixText: 'pcs',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Wajib diisi';
                              }
                              if (int.tryParse(v.trim()) == null) {
                                return 'Angka tidak valid';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Description
                const Text(
                  'Deskripsi Produk',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Deskripsi bahan, kelezatan, dan tekstur roti...',
                  ),
                ),
                const SizedBox(height: 24),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isEditing ? 'Simpan Perubahan' : 'Tambah Produk',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
