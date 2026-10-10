import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';

class BakeryImage extends StatelessWidget {
  final String? imageKey;
  final String? productName;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const BakeryImage({
    super.key,
    this.imageKey,
    this.productName,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  static String resolveAssetPath(String? key, String? name) {
    final cleanKey = (key ?? '').trim().toLowerCase();
    final cleanName = (name ?? '').trim().toLowerCase();

    // Direct asset paths
    if (cleanKey.startsWith('assets/images/')) {
      return cleanKey;
    }

    // Direct key matches
    final keyMap = {
      'almond_croissant': 'assets/images/almond_croissant.jpg',
      'roti_sisir': 'assets/images/roti_sisir.jpg',
      'kue_lumpur': 'assets/images/kue_lumpur.jpg',
      'kopi_susu': 'assets/images/kopi_susu.jpg',
      'cinnamon_roll': 'assets/images/cinnamon_roll.jpg',
      'sourdough': 'assets/images/sourdough.jpg',
      'brownies': 'assets/images/brownies.jpg',
      'matcha_latte': 'assets/images/matcha_latte.jpg',
      'bread_default': 'assets/images/bread_default.jpg',
      'roti': 'assets/images/roti_sisir.jpg',
      'kue': 'assets/images/brownies.jpg',
      'pastry': 'assets/images/almond_croissant.jpg',
      'minuman': 'assets/images/kopi_susu.jpg',
    };

    if (keyMap.containsKey(cleanKey)) {
      return keyMap[cleanKey]!;
    }

    // Name-based smart matching
    if (cleanName.contains('croissant') || cleanName.contains('pastry')) {
      return 'assets/images/almond_croissant.jpg';
    }
    if (cleanName.contains('sisir') || cleanName.contains('mentega')) {
      return 'assets/images/roti_sisir.jpg';
    }
    if (cleanName.contains('lumpur') || cleanName.contains('pandan')) {
      return 'assets/images/kue_lumpur.jpg';
    }
    if (cleanName.contains('kopi') || cleanName.contains('coffee') || cleanName.contains('aren')) {
      return 'assets/images/kopi_susu.jpg';
    }
    if (cleanName.contains('cinnamon') || cleanName.contains('roll')) {
      return 'assets/images/cinnamon_roll.jpg';
    }
    if (cleanName.contains('sourdough')) {
      return 'assets/images/sourdough.jpg';
    }
    if (cleanName.contains('brownies') || cleanName.contains('cokelat') || cleanName.contains('chocolate')) {
      return 'assets/images/brownies.jpg';
    }
    if (cleanName.contains('matcha') || cleanName.contains('latte') || cleanName.contains('tea')) {
      return 'assets/images/matcha_latte.jpg';
    }
    if (cleanName.contains('roti') || cleanName.contains('bread') || cleanName.contains('toast')) {
      return 'assets/images/roti_sisir.jpg';
    }
    if (cleanName.contains('kue') || cleanName.contains('cake') || cleanName.contains('tart')) {
      return 'assets/images/brownies.jpg';
    }

    // Default bakery bread
    return 'assets/images/bread_default.jpg';
  }

  @override
  Widget build(BuildContext context) {
    final key = imageKey?.trim() ?? '';
    final isNetworkUrl = key.startsWith('http://') || key.startsWith('https://');

    Widget imageWidget;

    if (isNetworkUrl) {
      imageWidget = CachedNetworkImage(
        imageUrl: key,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          color: AppColors.surfaceVariant,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) {
          final fallbackAsset = resolveAssetPath(null, productName);
          return Image.asset(
            fallbackAsset,
            width: width,
            height: height,
            fit: fit,
          );
        },
      );
    } else {
      final assetPath = resolveAssetPath(key, productName);
      imageWidget = Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/bread_default.jpg',
            width: width,
            height: height,
            fit: fit,
          );
        },
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
