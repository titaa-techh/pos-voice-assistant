import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/formatter.dart';
import '../providers/transaction_provider.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(transactionsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat')),
      body: list.isEmpty
          ? const Center(child: Text('Belum ada transaksi.'))
          : ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final t = list[i];
                return ListTile(
                  title: Text('Transaksi #${t.id.substring(t.id.length - 6)}'),
                  subtitle: Text(
                      '${tanggal(t.createdAt)} · ${t.synced ? 'tersinkron' : 'belum sinkron'}'),
                  trailing: Text(rupiah(t.total)),
                  onTap: () => showDialog<void>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Detail transaksi'),
                      content: Column(mainAxisSize: MainAxisSize.min, children: [
                        for (final it in t.items)
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text('${it.name} x${it.quantity}'),
                            Text(rupiah(it.price * it.quantity)),
                          ]),
                        const Divider(),
                        Text('Total ${rupiah(t.total)} (${t.paymentMethod})'),
                        Text('Kembali ${rupiah(t.change)}'),
                      ]),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Tutup'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
