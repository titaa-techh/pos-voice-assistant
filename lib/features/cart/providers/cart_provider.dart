import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../product/models/product_model.dart';
import '../models/cart_item.dart';

final thresholdProvider = Provider<int>(
  (ref) => Hive.box('settings').get('threshold', defaultValue: 3) as int,
);

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

final cartTotalProvider = Provider<int>(
  (ref) => ref.watch(cartProvider).fold(0, (s, e) => s + e.price * e.quantity),
);

class CartNotifier extends Notifier<List<CartItem>> {
  Box get _box => Hive.box('cart');

  @override
  List<CartItem> build() => _box.values
      .map((e) => CartItem.fromMap(Map<String, dynamic>.from(e as Map)))
      .toList();

  /// Mengembalikan pesan galat, atau null bila berhasil.
  String? add(ProductModel p) {
    final i = state.indexWhere((e) => e.productId == p.id);
    final q = i < 0 ? 1 : state[i].quantity + 1;
    if (q > p.stock) return '${p.name}: stok tidak cukup';
    final item = i < 0
        ? CartItem(productId: p.id, name: p.name, price: p.price, quantity: q)
        : state[i].withQuantity(q);
    _set(i < 0 ? [...state, item] : ([...state]..[i] = item));
    return null;
  }

  void decrease(String productId) {
    final next = <CartItem>[];
    for (final e in state) {
      if (e.productId != productId) {
        next.add(e);
      } else if (e.quantity > 1) {
        next.add(e.withQuantity(e.quantity - 1));
      }
    }
    _set(next);
  }

  Future<void> clear() async {
    state = [];
    await _box.clear();
  }

  Future<void> _set(List<CartItem> items) async {
    state = items;
    await _box.clear();
    await _box.addAll(items.map((e) => e.toMap()));
  }
}
