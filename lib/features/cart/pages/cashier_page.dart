
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatter.dart';
import '../../product/models/product_model.dart';
import '../../product/providers/product_provider.dart';
import '../../transaction/pages/payment_page.dart';
import '../providers/cart_provider.dart';
import '../widgets/voice_sheet.dart';
import 'barcode_scanner_page.dart';

class CashierPage extends ConsumerWidget {
  const CashierPage({super.key});

  Future<void> _scanBarcode(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const BarcodeScannerPage(),
      ),
    );

    if (!context.mounted || code == null) return;

    final products = ref.read(productsProvider);

    ProductModel? product;

    for (final p in products) {
      if (p.barcode?.trim() == code.trim()) {
        product = p;
        break;
      }
    }

    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Produk dengan barcode $code tidak ditemukan.',
          ),
        ),
      );
      return;
    }

    final error = ref.read(cartProvider.notifier).add(product);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${product.name} berhasil ditambahkan ke keranjang.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);
    final products = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasir'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: FilledButton.icon(
                    onPressed: () => showVoiceSheet(context),
                    icon: const Icon(Icons.mic),
                    label: const Text('Mikrofon'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    onPressed: () => _scanBarcode(context, ref),
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Barcode'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: cart.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Keranjang kosong. Ketuk Mikrofon dan ucapkan nama produk, atau pindai barcode produk.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView(
                    children: [
                      for (final item in cart)
                        ListTile(
                          title: Text(item.name),
                          subtitle: Text(
                            '${rupiah(item.price)} × ${item.quantity} = ${rupiah(item.price * item.quantity)}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Kurangi',
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                ),
                                onPressed: () {
                                  ref
                                      .read(cartProvider.notifier)
                                      .decrease(item.productId);
                                },
                              ),
                              Text('${item.quantity}'),
                              IconButton(
                                tooltip: 'Tambah',
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                ),
                                onPressed: () {
                                  final matches = products.where(
                                    (p) => p.id == item.productId,
                                  );

                                  if (matches.isEmpty) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Produk tidak ditemukan.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  final error = ref
                                      .read(cartProvider.notifier)
                                      .add(matches.first);

                                  if (error != null) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(error),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total'),
                      Text(
                        rupiah(total),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: cart.isEmpty
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PaymentPage(),
                                ),
                              );
                            },
                      child: const Text('Bayar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}