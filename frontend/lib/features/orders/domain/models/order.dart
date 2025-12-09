class Order {
  const Order({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.thumbnailUrl,
    required this.total,
    required this.status,
    required this.sellerId,
    required this.buyerId,
    required this.placedAt,
    this.shippedAt,
    this.deliveredAt,
  });

  final String id;
  final String listingId;
  final String listingTitle;
  final String thumbnailUrl;
  final double total;
  final String status;
  final String sellerId;
  final String buyerId;
  final DateTime placedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as String,
      listingId: map['listingId'] as String? ?? map['listing_id'] as String,
      listingTitle:
          map['listingTitle'] as String? ?? map['listing_title'] as String,
      thumbnailUrl: map['thumbnailUrl'] as String? ??
          map['thumbnail_url'] as String? ??
          '',
      total: (map['total'] as num? ?? map['price'] as num? ?? 0).toDouble(),
      status: map['status'] as String? ?? 'pending',
      sellerId: map['sellerId'] as String? ?? map['seller_id'] as String,
      buyerId: map['buyerId'] as String? ?? map['buyer_id'] as String,
      placedAt: DateTime.parse(
          map['placedAt'] as String? ?? map['placed_at'] as String),
      shippedAt: _asNullableDate(map['shippedAt'] ?? map['shipped_at']),
      deliveredAt: _asNullableDate(map['deliveredAt'] ?? map['delivered_at']),
    );
  }

  static DateTime? _asNullableDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  bool get needsDeliveryConfirmation => status.toLowerCase() == 'shipped';
}
