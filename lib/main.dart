import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('id_ID');
  await Hive.initFlutter();
  await Future.wait([
    Hive.openBox('products'),
    Hive.openBox('transactions'),
    Hive.openBox('cart'),
    Hive.openBox('settings'),
  ]);
  runApp(const ProviderScope(child: PosApp()));
}
