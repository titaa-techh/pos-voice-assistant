import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../transaction/providers/transaction_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final pending = ref.watch(transactionsProvider).where((t) => !t.synced).length;
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        ListTile(
          leading: const Icon(Icons.person),
          title: Text(user?.email ?? '-'),
        ),
        ListTile(
          leading: const Icon(Icons.sync),
          title: Text(pending == 0
              ? 'Semua transaksi sudah tersinkron'
              : '$pending transaksi menunggu sinkronisasi'),
          trailing: TextButton(
            onPressed: () => ref.read(transactionsProvider.notifier).syncPending(),
            child: const Text('Sinkronkan'),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => FirebaseAuth.instance.signOut(),
          child: const Text('Keluar'),
        ),
      ]),
    );
  }
}
