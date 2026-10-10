import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../home/screens/home_screen.dart';
import '../../products/screens/menu_screen.dart';
import '../../cart/screens/cart_screen.dart';
import '../../orders/screens/order_status_screen.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/products/providers/product_provider.dart';
import '../../../features/cart/providers/cart_provider.dart';
import '../../../features/orders/providers/order_provider.dart';
import '../../../core/theme/app_colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    MenuScreen(),
    CartScreen(),
    OrderStatusScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initData());
  }

  Future<void> _initData() async {
    final auth = context.read<AuthProvider>();
    if (auth.currentUser == null) return;

    final userId = auth.currentUser!.userId!;
    await Future.wait([
      context.read<ProductProvider>().loadAll(),
      context.read<CartProvider>().loadCart(userId),
      context.read<OrderProvider>().loadUserOrders(userId),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Beranda',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: 'Menu',
            ),
            BottomNavigationBarItem(
              icon: Consumer<CartProvider>(
                builder: (_, cart, __) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.shopping_bag_outlined),
                      if (cart.itemCount > 0)
                        Positioned(
                          right: -8,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              cart.itemCount > 9 ? '9+' : '${cart.itemCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              activeIcon: Consumer<CartProvider>(
                builder: (_, cart, __) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.shopping_bag),
                      if (cart.itemCount > 0)
                        Positioned(
                          right: -8,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              cart.itemCount > 9 ? '9+' : '${cart.itemCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              label: 'Keranjang',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.access_time_outlined),
              activeIcon: Icon(Icons.access_time_filled),
              label: 'Status',
            ),
          ],
        ),
      ),
    );
  }
}
