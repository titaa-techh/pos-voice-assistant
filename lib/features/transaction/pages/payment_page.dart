import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/formatter.dart';
import '../../cart/providers/cart_provider.dart';
import '../providers/transaction_provider.dart';

class PaymentPage extends ConsumerStatefulWidget {
  const PaymentPage({super.key});
  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  final _paid = TextEditingController();
  String _method = 'Tunai';
  String? _error;
  bool _busy = false;

  Future<void> _done() async {
    setState(() => _busy = true);
    final err = await ref
        .read(transactionsProvider.notifier)
        .checkout(method: _method, paidText: _paid.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = err;
    });
    if (err == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Transaksi tersimpan')));
    }
  }

  @override
  void dispose() {
    _paid.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);
    final paid = int.tryParse(_paid.text) ?? 0;
    final change = (_method == 'Tunai' && paid > total) ? paid - total : 0;
    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        for (final i in cart)
          ListTile(
            dense: true,
            title: Text('${i.name} x${i.quantity}'),
            trailing: Text(rupiah(i.price * i.quantity)),
          ),
        const Divider(),
        ListTile(
          title: const Text('Total'),
          trailing: Text(rupiah(total), style: Theme.of(context).textTheme.titleLarge),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'Tunai', label: Text('Tunai')),
            ButtonSegment(value: 'QRIS', label: Text('QRIS')),
            ButtonSegment(value: 'Transfer', label: Text('Transfer')),
          ],
          selected: {_method},
          onSelectionChanged: (s) => setState(() => _method = s.first),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _paid,
          enabled: _method == 'Tunai',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => setState(() => _error = null),
          decoration: const InputDecoration(labelText: 'Uang diterima (Rp)'),
        ),
        ListTile(
          title: const Text('Kembalian'),
          trailing: Text(rupiah(change)),
        ),
        if (_error != null)
          Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _busy ? null : _done,
          child: const Text('Selesai'),
        ),
      ]),
    );
  }
}
