import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';

class ProductFormPage extends ConsumerStatefulWidget {
  const ProductFormPage({super.key});
  @override
  ConsumerState<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends ConsumerState<ProductFormPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _category = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController();
  final _barcode = TextEditingController();
  String? _error;

  String? _requiredInt(String? v, String label) {
    final n = int.tryParse(v?.trim() ?? '');
    return (n == null || n < 0) ? '$label harus angka bulat, minimal 0.' : null;
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final err = await ref.read(productsProvider.notifier).add(
          name: _name.text,
          price: _price.text,
          stock: _stock.text,
          category: _category.text,
          barcode: _barcode.text,
        );
    if (!mounted) return;
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Produk disimpan')));
  }

  @override
  void dispose() {
    _name.dispose();
    _category.dispose();
    _price.dispose();
    _stock.dispose();
    _barcode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final digits = [FilteringTextInputFormatter.digitsOnly];
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah produk')),
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Nama produk'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Nama produk wajib diisi.' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _category,
            decoration: const InputDecoration(labelText: 'Kategori'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _price,
            keyboardType: TextInputType.number,
            inputFormatters: digits,
            decoration: const InputDecoration(labelText: 'Harga (Rp)'),
            validator: (v) => _requiredInt(v, 'Harga'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _stock,
            keyboardType: TextInputType.number,
            inputFormatters: digits,
            decoration: const InputDecoration(labelText: 'Stok'),
            validator: (v) => _requiredInt(v, 'Stok'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _barcode,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Barcode (opsional)'),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _save, child: const Text('Simpan')),
        ]),
      ),
    );
  }
}
