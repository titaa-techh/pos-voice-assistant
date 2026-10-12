import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product_model.dart';

final productsProvider =
    NotifierProvider<ProductsNotifier, List<ProductModel>>(ProductsNotifier.new);

class ProductsNotifier extends Notifier<List<ProductModel>> {
  Box get _box => Hive.box('products');

  @override
  List<ProductModel> build() {
    final list = _box.values
        .map((e) => ProductModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  /// Mengembalikan pesan galat, atau null bila berhasil disimpan.
  Future<String?> add({
    required String name,
    required String price,
    required String stock,
    String category = '',
    String barcode = '',
  }) async {
    final n = name.trim();
    if (n.isEmpty) return 'Nama produk wajib diisi.';
    if (state.any((p) => p.name.toLowerCase() == n.toLowerCase())) {
      return 'Nama produk sudah ada.';
    }
    final pr = int.tryParse(price.trim());
    if (pr == null || pr < 0) return 'Harga harus angka bulat, minimal 0.';
    final st = int.tryParse(stock.trim());
    if (st == null || st < 0) return 'Stok harus angka bulat, minimal 0.';
    final bc = barcode.trim();
    if (bc.isNotEmpty && state.any((p) => p.barcode == bc)) {
      return 'Barcode sudah dipakai produk lain.';
    }
    final now = DateTime.now();
    final p = ProductModel(
      id: now.microsecondsSinceEpoch.toString(),
      name: n,
      price: pr,
      stock: st,
      category: category.trim().isEmpty ? 'Umum' : category.trim(),
      barcode: bc.isEmpty ? null : bc,
      createdAt: now,
      updatedAt: now,
    );
    await _save(p);
    return null;
  }

  Future<void> decreaseStock(Map<String, int> quantities) async {
    for (final p in state.where((p) => quantities.containsKey(p.id)).toList()) {
      await _save(p.copyWith(stock: p.stock - quantities[p.id]!));
    }
  }

  Future<void> _save(ProductModel p) async {
    await _box.put(p.id, p.toMap());
    state = [...state.where((x) => x.id != p.id), p]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(p.id)
          .set(p.toMap())
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      // Offline: data tetap aman di Hive.
    }
  }
}
