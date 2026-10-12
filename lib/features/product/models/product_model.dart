class ProductModel {
  final String id;
  final String name;
  final int price;
  final int stock;
  final String category;
  final String? barcode;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.category = 'Umum',
    this.barcode,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'price': price,
        'stock': stock,
        'category': category,
        'barcode': barcode,
        'imageUrl': imageUrl,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ProductModel.fromMap(Map m) => ProductModel(
        id: m['id'] as String,
        name: m['name'] as String,
        price: (m['price'] as num).toInt(),
        stock: (m['stock'] as num).toInt(),
        category: (m['category'] as String?) ?? 'Umum',
        barcode: m['barcode'] as String?,
        imageUrl: m['imageUrl'] as String?,
        createdAt: DateTime.parse(m['createdAt'] as String),
        updatedAt: DateTime.parse(m['updatedAt'] as String),
      );

  ProductModel copyWith({int? stock}) => ProductModel(
        id: id,
        name: name,
        price: price,
        stock: stock ?? this.stock,
        category: category,
        barcode: barcode,
        imageUrl: imageUrl,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
}
