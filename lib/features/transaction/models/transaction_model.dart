import '../../cart/models/cart_item.dart';

class TransactionModel {
  final String id;
  final DateTime createdAt;
  final List<CartItem> items;
  final int total;
  final String paymentMethod;
  final int amountPaid;
  final int change;
  final String cashierUid;
  final bool synced;

  const TransactionModel({
    required this.id,
    required this.createdAt,
    required this.items,
    required this.total,
    required this.paymentMethod,
    required this.amountPaid,
    required this.change,
    required this.cashierUid,
    this.synced = false,
  });

  TransactionModel markSynced() => TransactionModel(
        id: id,
        createdAt: createdAt,
        items: items,
        total: total,
        paymentMethod: paymentMethod,
        amountPaid: amountPaid,
        change: change,
        cashierUid: cashierUid,
        synced: true,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'items': items.map((e) => e.toMap()).toList(),
        'total': total,
        'paymentMethod': paymentMethod,
        'amountPaid': amountPaid,
        'change': change,
        'cashierUid': cashierUid,
        'synced': synced,
      };

  factory TransactionModel.fromMap(Map m) => TransactionModel(
        id: m['id'] as String,
        createdAt: DateTime.parse(m['createdAt'] as String),
        items: (m['items'] as List)
            .map((e) => CartItem.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
        total: (m['total'] as num).toInt(),
        paymentMethod: m['paymentMethod'] as String,
        amountPaid: (m['amountPaid'] as num).toInt(),
        change: (m['change'] as num).toInt(),
        cashierUid: m['cashierUid'] as String,
        synced: m['synced'] as bool? ?? false,
      );
}
