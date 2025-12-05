class OrderItem {
  final int productId;
  final String productName;
  final int quantity;
  final double price;
  final String image;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.image,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'],
      productName: json['product_name'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
      image: json['image'] ?? 'no_image.png',
    );
  }

  Map<String, dynamic> toJson() {
    return {'product_id': productId, 'quantity': quantity};
  }
}

class Order {
  final String orderId;
  final String username;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final DateTime timestamp;

  Order({
    required this.orderId,
    required this.username,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.timestamp,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['order_id'],
      username: json['username'] ?? '',
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: json['status'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
