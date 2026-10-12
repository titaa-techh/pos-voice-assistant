import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../cart/providers/cart_provider.dart';
import '../../product/providers/product_provider.dart';
import '../models/transaction_model.dart';

final transactionsProvider =
    NotifierProvider<TransactionsNotifier, List<TransactionModel>>(
        TransactionsNotifier.new);

class TransactionsNotifier extends Notifier<List<TransactionModel>> {
  Box get _box => Hive.box('transactions');

  @override
  List<TransactionModel> build() {
    final list = _box.values
        .map((e) => TransactionModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// Mengembalikan pesan galat, atau null bila transaksi tersimpan.
  Future<String?> checkout({required String method, String paidText = ''}) async {
    final items = ref.read(cartProvider);
    if (items.isEmpty) return 'Keranjang kosong.';
    final total = ref.read(cartTotalProvider);
    final paid = method == 'Tunai' ? int.tryParse(paidText.trim()) : total;
    if (paid == null) return 'Uang diterima harus berupa angka.';
    if (paid < total) return 'Uang diterima kurang dari total.';

    final now = DateTime.now();
    final trx = TransactionModel(
      id: now.microsecondsSinceEpoch.toString(),
      createdAt: now,
      items: List.of(items),
      total: total,
      paymentMethod: method,
      amountPaid: paid,
      change: paid - total,
      cashierUid: FirebaseAuth.instance.currentUser?.uid ?? 'unknown',
    );
    await _box.put(trx.id, trx.toMap());
    state = [trx, ...state];
    await ref
        .read(productsProvider.notifier)
        .decreaseStock({for (final i in items) i.productId: i.quantity});
    await ref.read(cartProvider.notifier).clear();
    await syncPending();
    return null;
  }

  Future<void> syncPending() async {
    final pending = state.where((t) => !t.synced).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    for (final t in pending) {
      try {
        await FirebaseFirestore.instance
            .collection('transactions')
            .doc(t.id)
            .set({...t.toMap(), 'synced': true}).timeout(const Duration(seconds: 5));
        final done = t.markSynced();
        await _box.put(done.id, done.toMap());
        state = [for (final x in state) x.id == done.id ? done : x];
      } catch (_) {
        break; // masih offline; coba lagi nanti
      }
    }
  }
}
