import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../orders/providers/order_provider.dart';
import '../../products/providers/product_provider.dart';
import '../../promo/providers/promo_provider.dart';
import 'admin_orders_tab.dart';
import 'admin_products_tab.dart';
import 'admin_promo_tab.dart';
import 'admin_dashboard_tab.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadAllOrders();
      context.read<ProductProvider>().loadAdminProducts();
      context.read<PromoProvider>().loadAllPromos();
    });
  }

  void _navigateToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pendingOrdersCount = context.watch<OrderProvider>().allOrders.where(
        (o) => o.status == 'pending' || o.status == 'processing').length;

    final titles = [
      'Pesanan Masuk Bakery',
      'Kelola Produk & Stok',
      'Kelola Promo & Diskon',
      'Dashboard Administrator',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[_currentIndex],
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan Data',
            onPressed: () {
              context.read<OrderProvider>().loadAllOrders();
              context.read<ProductProvider>().loadAdminProducts();
              context.read<PromoProvider>().loadAllPromos();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data bakery diperbarui'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const AdminOrdersTab(),
          const AdminProductsTab(),
          const AdminPromoTab(),
          AdminDashboardTab(
            onNavigateToOrders: () => _navigateToTab(0),
            onNavigateToProducts: () => _navigateToTab(1),
            onNavigateToPromos: () => _navigateToTab(2),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textHint,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.receipt_long_outlined),
                  if (pendingOrdersCount > 0)
                    Positioned(
                      right: -6,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          pendingOrdersCount > 9 ? '9+' : '$pendingOrdersCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              activeIcon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.receipt_long),
                  if (pendingOrdersCount > 0)
                    Positioned(
                      right: -6,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          pendingOrdersCount > 9 ? '9+' : '$pendingOrdersCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              label: 'Pesanan',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.bakery_dining_outlined),
              activeIcon: Icon(Icons.bakery_dining),
              label: 'Produk & Stok',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.local_offer_outlined),
              activeIcon: Icon(Icons.local_offer),
              label: 'Promo',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
          ],
        ),
      ),
    );
  }
}
