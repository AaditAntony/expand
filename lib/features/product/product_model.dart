class Product {
  final String id;
  final String name;
  final double price;
  final List<String> sizes;
  final String color;
  final String material;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.sizes,
    required this.color,
    required this.material,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? "",
      name: map["name"] ?? "",
      price: (map['price'] as num).toDouble(),
      sizes: List<String>.from(map['size'] ?? []),
      color: map['color'] ?? "",
      material: map["material"] ?? "",
    );
  }

  // map this is the
}
