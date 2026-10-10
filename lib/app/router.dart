import 'package:flutter/material.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/home/screens/main_screen.dart';
import '../features/orders/screens/order_detail_screen.dart';
import '../features/orders/screens/checkout_screen.dart';
import '../features/products/screens/product_detail_screen.dart';
import '../features/admin/screens/admin_main_screen.dart';
import '../core/models/product_model.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String adminHome = '/admin-home';
  static const String productDetail = '/product-detail';
  static const String checkout = '/checkout';
  static const String orderDetail = '/order-detail';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(const SplashScreen(), settings);

      case login:
        return _buildRoute(const LoginScreen(), settings);

      case register:
        return _buildRoute(const RegisterScreen(), settings);

      case home:
        return _buildRoute(const MainScreen(), settings);

      case adminHome:
        return _buildRoute(const AdminMainScreen(), settings);

      case productDetail:
        final product = settings.arguments as ProductModel;
        return _buildRoute(ProductDetailScreen(product: product), settings);

      case checkout:
        return _buildRoute(const CheckoutScreen(), settings);

      case orderDetail:
        final orderId = settings.arguments as int;
        return _buildRoute(OrderDetailScreen(orderId: orderId), settings);

      default:
        return _buildRoute(
          Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
          settings,
        );
    }
  }

  static PageRoute _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}
