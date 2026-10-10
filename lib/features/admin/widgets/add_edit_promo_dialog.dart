import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/promo_model.dart';
import '../../promo/providers/promo_provider.dart';

class AddEditPromoDialog extends StatefulWidget {
  final PromoModel? promo;

  const AddEditPromoDialog({super.key, this.promo});

  @override
  State<AddEditPromoDialog> createState() => _AddEditPromoDialogState();
}

class _AddEditPromoDialogState extends State<AddEditPromoDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _valueController;
  late TextEditingController _minTxController;
  late TextEditingController _maxDiscController;
  String _discountType = 'percent';
  bool _status = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _codeController =
        TextEditingController(text: widget.promo?.promoCode ?? '');
    _nameController =
        TextEditingController(text: widget.promo?.promoName ?? '');
    _valueController = TextEditingController(
        text: widget.promo != null
            ? widget.promo!.discountValue.toInt().toString()
            : '15');
    _minTxController = TextEditingController(
        text: widget.promo != null
            ? widget.promo!.minTransaction.toInt().toString()
            : '30000');
    _maxDiscController = TextEditingController(
        text: widget.promo?.maxDiscount != null
            ? widget.promo!.maxDiscount!.toInt().toString()
            : '20000');
    _discountType = widget.promo?.discountType ?? 'percent';
    _status = widget.promo?.status ?? true;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _valueController.dispose();
    _minTxController.dispose();
    _maxDiscController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider = context.read<PromoProvider>();
    final isEditing = widget.promo != null;

    final now = DateTime.now();
    final promo = PromoModel(
      promoId: widget.promo?.promoId,
      promoCode: _codeController.text.trim().toUpperCase(),
      promoName: _nameController.text.trim(),
      discountType: _discountType,
      discountValue: double.tryParse(_valueController.text.trim()) ?? 0,
      minTransaction: double.tryParse(_minTxController.text.trim()) ?? 0,
      maxDiscount: _discountType == 'percent'
          ? double.tryParse(_maxDiscController.text.trim())
          : null,
      startDate: widget.promo?.startDate ?? now.toIso8601String(),
      endDate: widget.promo?.endDate ??
          now.add(const Duration(days: 60)).toIso8601String(),
      status: _status,
    );

    final success = isEditing
        ? await provider.updatePromo(promo)
        : await provider.createPromo(promo);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing
                ? 'Promo berhasil diperbarui!'
                : 'Promo baru berhasil dibuat!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Gagal menyimpan promo'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.promo != null;

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
                      isEditing ? 'Edit Kode Promo' : 'Tambah Promo Baru',
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

                // Promo Code
                const Text(
                  'Kode Promo (Kupon)',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: WIBBAKERY20',
                    prefixIcon: Icon(Icons.local_offer_outlined),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Kode promo wajib diisi'
                      : null,
                ),
                const SizedBox(height: 14),

                // Promo Name
                const Text(
                  'Nama / Judul Promo',
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
                    hintText: 'Diskon Spesial Hari Ini',
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Nama promo wajib diisi'
                      : null,
                ),
                const SizedBox(height: 14),

                // Discount Type & Value Row
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tipe Diskon',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _discountType,
                            items: const [
                              DropdownMenuItem(
                                  value: 'percent',
                                  child: Text('Persentase (%)',
                                      style: TextStyle(fontSize: 13))),
                              DropdownMenuItem(
                                  value: 'fixed',
                                  child: Text('Nominal (Rp)',
                                      style: TextStyle(fontSize: 13))),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _discountType = val);
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
                          Text(
                            _discountType == 'percent'
                                ? 'Nilai (%)'
                                : 'Nilai (Rp)',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _valueController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText:
                                  _discountType == 'percent' ? '15' : '10000',
                              suffixText:
                                  _discountType == 'percent' ? '%' : 'Rp',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Wajib diisi';
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

                // Min Transaction & Max Discount Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Min. Belanja (Rp)',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _minTxController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: '30000',
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_discountType == 'percent') ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Maks. Diskon (Rp)',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _maxDiscController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: '20000',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),

                // Status Switch
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Promo Aktif & Dapat Digunakan',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Switch(
                      value: _status,
                      activeColor: AppColors.primary,
                      onChanged: (val) => setState(() => _status = val),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Submit button
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
                            isEditing ? 'Simpan Perubahan' : 'Tambah Promo',
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
