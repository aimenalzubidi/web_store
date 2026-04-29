import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import '../models/product_model.dart';
import '../widgets/product_card.dart';
import '../utils/constants.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _searchQuery = '';

  // ================= EXCEL =================
  Future<void> _importFromExcel() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        var bytes = result.files.single.bytes!;
        var excel = Excel.decodeBytes(bytes);
        var table = excel.tables[excel.tables.keys.first];

        if (table != null) {
          final batch = FirebaseFirestore.instance.batch();
          final collection = FirebaseFirestore.instance.collection('products');

          for (int i = 1; i < table.rows.length; i++) {
            var row = table.rows[i];
            if (row.isEmpty || row[0]?.value == null) continue;

            String name = row[0]?.value?.toString() ?? '';
            double price =
                double.tryParse(
                  row.length > 1 ? row[1]?.value.toString() ?? '0' : '0',
                ) ??
                0;

            if (name.isNotEmpty) {
              batch.set(collection.doc(), {
                'name': name,
                'price': price,
                'imageUrl': null,
                'stock': 0,
              });
            }
          }

          await batch.commit();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم استيراد المنتجات بنجاح')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ: $e')));
    }
  }

  // ================= IMAGE =================
  Future<String?> _imageToBase64(Uint8List? bytes) async {
    if (bytes == null) return null;

    final codec = await ui.instantiateImageCodec(bytes, targetWidth: 600);
    final frame = await codec.getNextFrame();
    final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);

    return base64Encode(data!.buffer.asUint8List());
  }

  // ================= ADD =================
  void _showAddDialog(BuildContext context) {
    final nameC = TextEditingController();
    final priceC = TextEditingController();
    Uint8List? _pickedImage;
    bool _isProcessing = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('إضافة منتج'),

          // 🔥 FIX بدون تغيير التصميم
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameC,
                    decoration: const InputDecoration(labelText: 'الاسم'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceC,
                    decoration: const InputDecoration(labelText: 'السعر'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  Container(
                    height: 150,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _pickedImage != null
                        ? Image.memory(_pickedImage!, fit: BoxFit.cover)
                        : InkWell(
                            onTap: () async {
                              final result = await FilePicker.platform
                                  .pickFiles(
                                    type: FileType.image,
                                    withData: true,
                                  );
                              if (result != null) {
                                setDialogState(() {
                                  _pickedImage = result.files.first.bytes;
                                });
                              }
                            },
                            child: const Center(
                              child: Icon(Icons.add_photo_alternate),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameC.text.isEmpty) return;

                final doc = await FirebaseFirestore.instance
                    .collection('products')
                    .add({
                      'name': nameC.text,
                      'price': double.tryParse(priceC.text) ?? 0,
                      'imageUrl': null,
                      'stock': 0,
                    });

                if (_pickedImage != null) {
                  String? base64 = await _imageToBase64(_pickedImage);
                  await doc.update({
                    'imageUrl': 'data:image/png;base64,$base64',
                  });
                }

                Navigator.pop(ctx);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  // ================= EDIT =================
  void _showEditDialog(BuildContext context, Product product) {
    final nameC = TextEditingController(text: product.name);
    final priceC = TextEditingController(text: product.price.toString());
    Uint8List? _pickedImage;
    String _currentImageUrl = product.imageUrl ?? '';
    bool _isProcessing = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('تعديل المنتج'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameC,
                    decoration: const InputDecoration(
                      labelText: 'الاسم',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceC,
                    decoration: const InputDecoration(
                      labelText: 'السعر',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // منطقة معاينة واختيار الصورة
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: (_pickedImage != null || _currentImageUrl.isNotEmpty)
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: _pickedImage != null
                                    ? Image.memory(
                                        _pickedImage!,
                                        width: double.infinity,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      )
                                    : _buildEditPreview(_currentImageUrl),
                              ),
                              Positioned(
                                top: 5,
                                right: 5,
                                child: CircleAvatar(
                                  backgroundColor: Colors.red,
                                  radius: 15,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setDialogState(() {
                                        _pickedImage = null;
                                        _currentImageUrl = '';
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 5,
                                right: 5,
                                child: CircleAvatar(
                                  backgroundColor: AppColors.primary,
                                  radius: 15,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.edit,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    onPressed: () async {
                                      final result = await FilePicker.platform
                                          .pickFiles(
                                            type: FileType.image,
                                            withData: true,
                                          );
                                      if (result != null) {
                                        setDialogState(() {
                                          _pickedImage =
                                              result.files.first.bytes;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          )
                        : InkWell(
                            onTap: () async {
                              final result = await FilePicker.platform
                                  .pickFiles(
                                    type: FileType.image,
                                    withData: true,
                                  );
                              if (result != null) {
                                setDialogState(() {
                                  _pickedImage = result.files.first.bytes;
                                });
                              }
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 40,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(height: 8),
                                const Text('اختر صورة جديدة'),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isProcessing ? null : () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: Colors.grey,
              ),
              onPressed: _isProcessing
                  ? null
                  : () async {
                      if (nameC.text.isEmpty) return;

                      setDialogState(() => _isProcessing = true);

                      // تحديث البيانات الأساسية
                      await FirebaseFirestore.instance
                          .collection('products')
                          .doc(product.id)
                          .update({
                            'name': nameC.text,
                            'price': double.tryParse(priceC.text) ?? 0,
                          });

                      // تحديث الصورة إذا تم اختيار صورة جديدة
                      if (_pickedImage != null) {
                        String? base64 = await _imageToBase64(_pickedImage);
                        if (base64 != null) {
                          await FirebaseFirestore.instance
                              .collection('products')
                              .doc(product.id)
                              .update({
                                'imageUrl': 'data:image/png;base64,$base64',
                              });
                        }
                      } else if (_currentImageUrl.isEmpty) {
                        // إذا تم حذف الصورة نهائياً
                        await FirebaseFirestore.instance
                            .collection('products')
                            .doc(product.id)
                            .update({'imageUrl': null});
                      }

                      Navigator.pop(ctx);
                    },
              child: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('تحديث', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditPreview(String url) {
    if (url.startsWith('data:image')) {
      return Image.memory(
        base64Decode(url.split(',').last),
        width: double.infinity,
        height: 150,
        fit: BoxFit.cover,
      );
    } else {
      return Image.network(
        url,
        width: double.infinity,
        height: 150,
        fit: BoxFit.cover,
        errorBuilder: (ctx, _, __) =>
            const Center(child: Icon(Icons.broken_image)),
      );
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text(
          'المنتجات',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file, color: AppColors.success),
            onPressed: _importFromExcel,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('إضافة', style: TextStyle(color: Colors.white)),
              onPressed: () => _showAddDialog(context),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // 🔍 Search
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: 'بحث...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var products = snapshot.data!.docs
                    .map(
                      (e) => Product.fromMap(
                        e.data() as Map<String, dynamic>,
                        e.id,
                      ),
                    )
                    .toList();

                if (_searchQuery.isNotEmpty) {
                  products = products
                      .where(
                        (p) => p.name.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ),
                      )
                      .toList();
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 250,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];

                    return ProductCard(
                      product: product,
                      onEdit: () => _showEditDialog(context, product),
                      onDelete: () => FirebaseFirestore.instance
                          .collection('products')
                          .doc(product.id)
                          .delete(),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
