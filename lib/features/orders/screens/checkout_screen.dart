import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../orders/providers/order_provider.dart';
import '../../promo/providers/promo_provider.dart';
import '../../../app/router.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPayment = 'transfer';
  final _promoController = TextEditingController();
  final _noteController = TextEditingController();
  static const double _shippingCost = 10000;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'id': 'cash', 'label': 'Cash (Bayar di Tempat)', 'icon': Icons.money},
    {
      'id': 'transfer',
      'label': 'Transfer Bank',
      'icon': Icons.account_balance
    },
    {'id': 'ewallet', 'label': 'E-Wallet', 'icon': Icons.wallet},
  ];

  @override
  void dispose() {
    _promoController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  Future<void> _applyPromo() async {
    final cart = context.read<CartProvider>();
    await context.read<PromoProvider>().applyPromo(
          _promoController.text,
          cart.subtotal,
        );
  }

  Future<void> _placeOrder() async {
    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    final promo = context.read<PromoProvider>();
    final orderProvider = context.read<OrderProvider>();

    if (cart.items.isEmpty) {
      _showError('Keranjang masih kosong');
      return;
    }

    final success = await orderProvider.createOrder(
      userId: auth.currentUser!.userId!,
      addressId: 1, // Default address
      cartItems: cart.items,
      subtotal: cart.subtotal,
      discount: promo.discountAmount,
      shippingCost: _shippingCost,
      promoCode: promo.appliedPromo?.promoCode,
      paymentMethod: _selectedPayment,
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );

    if (success && mounted) {
      // Clear cart
      await cart.clearCart();
      promo.removePromo();

      if (!mounted) return;

      // Navigate to order status
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.home,
        (route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Pesanan berhasil dibuat! 🎉'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ),
      );
    } else if (mounted) {
      _showError(orderProvider.errorMessage ?? 'Gagal membuat pesanan');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer3<CartProvider, PromoProvider, OrderProvider>(
        builder: (_, cart, promo, order, __) {
          final total = cart.subtotal - promo.discountAmount + _shippingCost;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Cart Items Summary
                    _buildSection(
                      'Pesanan',
                      Column(
                        children: cart.items
                            .map((item) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceVariant,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Icon(Icons.bakery_dining,
                                            size: 24,
                                            color: AppColors.textHint),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(item.productName ?? 'Produk',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 13)),
                                            Text(
                                                '${item.quantity}x ${item.formattedPrice}',
                                                style: const TextStyle(
                                                    color:
                                                        AppColors.textSecondary,
                                                    fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                      Text(item.formattedSubtotal,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary)),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Address
                    _buildSection(
                      'Alamat Pengiriman',
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.location_on,
                                color: AppColors.primary, size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Rumah • Fanduy',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13)),
                                  Text(
                                      'Jl. Kebayoran Baru No. 12, Jakarta Selatan',
                                      style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Payment Method
                    _buildSection(
                      'Metode Pembayaran',
                      Column(
                        children: _paymentMethods.map((method) {
                          final isSelected = _selectedPayment == method['id'];
                          return GestureDetector(
                            onTap: () => setState(
                                () => _selectedPayment = method['id']),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withOpacity(0.08)
                                    : AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(method['icon'] as IconData,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                      size: 22),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      method['label'] as String,
                                      style: TextStyle(
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.textPrimary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(Icons.check_circle,
                                        color: AppColors.primary, size: 20),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Voucher
                    _buildSection(
                      'Voucher / Kode Promo',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _promoController,
                                  decoration: const InputDecoration(
                                    hintText: 'Masukkan kode promo',
                                    prefixIcon: Icon(
                                        Icons.local_offer_outlined,
                                        size: 20),
                                  ),
                                  onChanged: (_) {
                                    if (promo.hasAppliedPromo) {
                                      promo.removePromo();
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: _applyPromo,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                ),
                                child: const Text('Pakai'),
                              ),
                            ],
                          ),
                          if (promo.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                promo.errorMessage!,
                                style: const TextStyle(
                                    color: AppColors.error, fontSize: 12),
                              ),
                            ),
                          if (promo.hasAppliedPromo)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: AppColors.success.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle,
                                      color: AppColors.success, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Promo "${promo.appliedPromo!.promoName}" berhasil!',
                                      style: const TextStyle(
                                          color: AppColors.success,
                                          fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Order Note
                    _buildSection(
                      'Catatan Pesanan',
                      TextField(
                        controller: _noteController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'Catatan tambahan untuk pesanan...',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Price Summary
                    _buildSection(
                      'Ringkasan Pembayaran',
                      Column(
                        children: [
                          _priceRow('Subtotal', _formatCurrency(cart.subtotal)),
                          const SizedBox(height: 6),
                          _priceRow('Ongkos Kirim',
                              _formatCurrency(_shippingCost)),
                          if (promo.discountAmount > 0) ...[
                            const SizedBox(height: 6),
                            _priceRow(
                              'Diskon Promo',
                              '- ${_formatCurrency(promo.discountAmount)}',
                              valueColor: AppColors.success,
                            ),
                          ],
                          const SizedBox(height: 10),
                          const Divider(color: AppColors.divider),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Bayar',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                _formatCurrency(total),
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              // Place Order Button
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: order.isLoading ? null : _placeOrder,
                      child: order.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Pesan Sekarang',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _formatCurrency(total),
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 14)),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: valueColor ?? AppColors.textPrimary)),
      ],
    );
  }
}
