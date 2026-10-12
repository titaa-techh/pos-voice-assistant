import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/formatter.dart';
import '../product/providers/product_provider.dart';
import '../transaction/providers/transaction_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  bool _same(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final trx = ref.watch(transactionsProvider);
    final now = DateTime.now();
    final today = trx.where((t) => _same(t.createdAt, now)).toList();
    final sales = today.fold<int>(0, (s, t) => s + t.total);
    final low = products.where((p) => p.stock < 10).length;

    final days = [
      for (var i = 6; i >= 0; i--) DateTime(now.year, now.month, now.day - i)
    ];
    final totals = [
      for (final d in days)
        trx.where((t) => _same(t.createdAt, d)).fold<int>(0, (s, t) => s + t.total)
    ];
    final maxV = totals.fold<int>(1, (m, v) => v > m ? v : m);
    final weekTotal = totals.fold<int>(0, (s, v) => s + v);
    const names = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final scheme = Theme.of(context).colorScheme;

    Widget stat(String label, String value, {Color? color}) => Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(value,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold, color: color)),
              ]),
            ),
          ),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard'), actions: [
        IconButton(
          tooltip: 'Keluar',
          icon: const Icon(Icons.logout),
          onPressed: () => FirebaseAuth.instance.signOut(),
        ),
      ]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Row(children: [
          stat('Penjualan hari ini', rupiah(sales)),
          stat('Transaksi', '${today.length}'),
        ]),
        Row(children: [
          stat('Total produk', '${products.length}'),
          stat('Stok menipis', '$low', color: low > 0 ? scheme.error : null),
        ]),
        const SizedBox(height: 16),
        Text('Penjualan 7 hari terakhir',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Container(
                      height: (totals[i] / maxV * 100).clamp(2.0, 100.0),
                      decoration: BoxDecoration(
                        color: i == 6 ? scheme.primary : scheme.primaryContainer,
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(names[days[i].weekday - 1],
                        style: Theme.of(context).textTheme.bodySmall),
                  ]),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 8),
        Text('Total 7 hari: ${rupiah(weekTotal)}',
            style: Theme.of(context).textTheme.bodySmall),
      ]),
    );
  }
}