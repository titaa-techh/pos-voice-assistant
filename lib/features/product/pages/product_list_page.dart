import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/formatter.dart';
import '../../cart/providers/cart_provider.dart';
import '../../cart/widgets/voice_sheet.dart';
import '../providers/product_provider.dart';
import 'product_form_page.dart';

class ProductListPage extends ConsumerStatefulWidget {
  const ProductListPage({super.key});
  @override
  ConsumerState<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends ConsumerState<ProductListPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.toLowerCase();
    final list = ref
        .watch(productsProvider)
        .where((p) => q.isEmpty || p.name.toLowerCase().contains(q))
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Produk'), actions: [
        IconButton(
          tooltip: 'Tambah produk',
          icon: const Icon(Icons.add),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ProductFormPage())),
        ),
      ]),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Cari produk',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                tooltip: 'Cari dengan suara',
                icon: const Icon(Icons.mic),
                onPressed: () => showVoiceSheet(context),
              ),
            ),
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? const Center(child: Text('Belum ada produk. Ketuk + untuk menambah.'))
              : ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final p = list[i];
                    return ListTile(
                      title: Text(p.name),
                      subtitle: Text(
                          '${rupiah(p.price)} · ${p.stock == 0 ? 'Habis' : 'stok ${p.stock}'}'),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProductFormPage(product: p)),
                      ),
                      trailing: IconButton(
                        tooltip: 'Tambah ke keranjang',
                        icon: const Icon(Icons.add_shopping_cart),
                        onPressed: p.stock == 0
                            ? null
                            : () {
                                final err = ref.read(cartProvider.notifier).add(p);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                        err ?? '${p.name} ditambahkan ke keranjang')));
                              },
                      ),
                    );
                  },
                ),
        ),
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text('Ketuk nama produk untuk mengubah atau menghapus.',
              style: TextStyle(fontSize: 12)),
        ),
      ]),
    );
  }
}