class Product {
  final String id; // Unique identifier for each product
  final String name;
  final double price;
  final String description;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
  });

  // From JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'], // Assuming the backend provides the '_id' field
      name: json['name'],
      price: json['price'].toDouble(), // Ensure price is treated as a double
      description: json['description'],
      imageUrl: json['imageUrl'],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id, // Assuming your backend uses '_id' for product IDs
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}
