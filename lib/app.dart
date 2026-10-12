import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/login_page.dart';
import 'features/cart/pages/cashier_page.dart';
import 'features/cart/providers/cart_provider.dart';
import 'features/dashboard/dashboard_page.dart';
import 'features/product/pages/product_list_page.dart';
import 'features/profile/profile_page.dart';
import 'features/transaction/pages/history_page.dart';
import 'features/transaction/providers/transaction_provider.dart';

class PosApp extends StatelessWidget {
  const PosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS Voice Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return snap.data == null ? const LoginPage() : const MainShell();
        },
      ),
    );
  }
}

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});
  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // Kirim transaksi yang tertunda saat aplikasi dibuka.
    Future.microtask(() => ref.read(transactionsProvider.notifier).syncPending());
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartProvider).fold<int>(0, (s, e) => s + e.quantity);
    return Scaffold(
      body: IndexedStack(index: _index, children: const [
        DashboardPage(),
        ProductListPage(),
        CashierPage(),
        HistoryPage(),
        ProfilePage(),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          const NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: 'Produk'),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            label: 'Kasir',
          ),
          const NavigationDestination(icon: Icon(Icons.history), label: 'Riwayat'),
          const NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}