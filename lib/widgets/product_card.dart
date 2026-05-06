import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../utils/constants.dart';
import '../screens/product_details_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        colors: [Color(0xFFE0E7FF), Color(0xFFC7D2FE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Hero(
                      tag: 'product_image_${product.id}',
                      child:
                          product.imageUrl != null &&
                              product.imageUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: _buildImage(product.imageUrl!),
                            )
                          : const Center(
                              child: Icon(
                                Icons.shopping_bag,
                                size: 40,
                                color: Colors.black12,
                              ),
                            ),
                    ),
                  ),

                  // Actions (Edit/Delete)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Row(
                      children: [
                        _ActionButton(
                          icon: Icons.edit,
                          color: AppColors.primary,
                          onTap: onEdit,
                        ),
                        const SizedBox(width: 8),
                        _ActionButton(
                          icon: Icons.delete,
                          color: AppColors.danger,
                          onTap: onDelete,
                        ),
                      ],
                    ),
                  ),

                  // Price Badge
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${product.price.toStringAsFixed(2)} ر.س',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Details Section
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String url) {
    if (url.isEmpty) {
      return const Center(
        child: Icon(Icons.shopping_bag, size: 40, color: Colors.black12),
      );
    }

    try {
      if (url.startsWith('data:image')) {
        // Base64 image
        final base64String = url.split(',').last;
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          gaplessPlayback: true, // Prevents flickering
          errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.broken_image, color: Colors.black26, size: 40),
          ),
        );
      } else {
        // Network image
        return Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Center(
            child: Icon(
              Icons.image_not_supported,
              color: Colors.black26,
              size: 40,
            ),
          ),
        );
      }
    } catch (e) {
      return const Center(
        child: Icon(Icons.broken_image, color: Colors.black26, size: 40),
      );
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
