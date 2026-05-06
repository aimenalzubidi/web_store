import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../utils/constants.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({Key? key, required this.product})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(child: _buildProductInfo(context)),
        ],
      ),
     );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'product_image_${product.id}',
          child: _buildProductImage(),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    if (product.imageUrl != null &&
        product.imageUrl!.startsWith('data:image')) {
      final base64String = product.imageUrl!.split(',').last;
      return Image.memory(base64Decode(base64String), fit: BoxFit.cover);
    } else if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      return Image.network(
        product.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildErrorImage(),
      );
    }
    return _buildErrorImage();
  }

  Widget _buildErrorImage() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(
        Icons.image_not_supported,
        size: 80,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildProductInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${product.price} ر.س',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 18,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                'المخزون: ${product.stock}',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'الوصف',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            product.description.isNotEmpty
                ? product.description
                : 'لا يوجد وصف متاح لهذا المنتج حالياً.',
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 40),
          _buildDetailTile(
            icon: Icons.local_shipping_outlined,
            title: 'توصيل سريع',
            subtitle: 'يتم التوصيل خلال 24-48 ساعة عمل',
          ),
          _buildDetailTile(
            icon: Icons.verified_user_outlined,
            title: 'ضمان الجودة',
            subtitle: 'منتج أصلي ومضمون 100%',
          ),
          const SizedBox(height: 100), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            // Implementation for ordering can be added here
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('سيتم إضافة ميزة الطلب قريباً')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_bag_outlined),
              SizedBox(width: 12),
              Text(
                'طلب المنتج الآن',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
