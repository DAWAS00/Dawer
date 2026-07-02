class InvoiceItem {
  final String name;
  final int quantity;
  final double price;

  const InvoiceItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  double get total => quantity * price;

  Map<String, dynamic> toJson() => {
    'name': name,
    'quantity': quantity,
    'price': price,
  };

  factory InvoiceItem.fromJson(Map<String, dynamic> json) => InvoiceItem(
    name: json['name'] as String,
    quantity: (json['quantity'] as num).toInt(),
    price: (json['price'] as num).toDouble(),
  );
}
