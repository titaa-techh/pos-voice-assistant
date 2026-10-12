class CartItem {
  final String productId;
  final String name;
  final int price;
  final int quantity;
  const CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  CartItem withQuantity(int q) =>
      CartItem(productId: productId, name: name, price: price, quantity: q);

  Map<String, dynamic> toMap() =>
      {'productId': productId, 'name': name, 'price': price, 'quantity': quantity};

  factory CartItem.fromMap(Map m) => CartItem(
        productId: m['productId'] as String,
        name: m['name'] as String,
        price: (m['price'] as num).toInt(),
        quantity: (m['quantity'] as num).toInt(),
      );
}
