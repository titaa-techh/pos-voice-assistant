import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';

/// Form tambah produk. Bila [product] diisi, form menjadi mode ubah.
class ProductFormPage extends ConsumerStatefulWidget {
  final ProductModel? product;
  const ProductFormPage({super.key, this.product});
  @override
  ConsumerState<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends ConsumerState<ProductFormPage> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _category;
  late final TextEditingController _price;
  late final TextEditingController _stock;
  late final TextEditingController _barcode;
  String? _error;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name ?? '');
    _category = TextEditingController(text: p?.category ?? '');
    _price = TextEditingController(text: p?.price.toString() ?? '');
    _stock = TextEditingController(text: p?.stock.toString() ?? '');
    _barcode = TextEditingController(text: p?.barcode ?? '');
  }

  String? _requiredInt(String? v, String label) {
    final n = int.tryParse(v?.trim() ?? '');
    return (n == null || n < 0) ? '$label harus angka bulat, minimal 0.' : null;
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final notifier = ref.read(productsProvider.notifier);
    final err = _isEdit
        ? await notifier.update(
            widget.product!.id,
            name: _name.text,
            price: _price.text,
            stock: _stock.text,
            category: _category.text,
            barcode: _barcode.text,
          )
        : await notifier.add(
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
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEdit ? 'Perubahan disimpan' : 'Produk disimpan')));
  }

  Future<void> _delete() async {
    final p = widget.product!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus produk?'),
        content: Text(
            'Produk "${p.name}" akan dihapus dari daftar dan keranjang. Riwayat transaksi lama tidak berubah.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              minimumSize: const Size(0, 40),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(productsProvider.notifier).delete(p.id);
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Produk dihapus')));
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
      appBar: AppBar(title: Text(_isEdit ? 'Ubah produk' : 'Tambah produk')),
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
          FilledButton(
            onPressed: _save,
            child: Text(_isEdit ? 'Simpan perubahan' : 'Simpan'),
          ),
          if (_isEdit) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Hapus produk'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}