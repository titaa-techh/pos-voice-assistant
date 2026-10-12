import 'package:intl/intl.dart';

String rupiah(num n) =>
    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(n);

String tanggal(DateTime d) => DateFormat('dd/MM/yyyy HH:mm', 'id_ID').format(d);
