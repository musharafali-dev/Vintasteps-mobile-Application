import 'dart:convert';

class ListingLocation {
  final double latitude;
  final double longitude;

  const ListingLocation({required this.latitude, required this.longitude});

  factory ListingLocation.fromMap(Map<String, dynamic> map) {
    return ListingLocation(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}

class Listing {
  final String id;
  final String sellerId;
  final String title;
  final double price;
  final String status;
  final List<String> images;
  final ListingLocation location;
  final double? distanceKm;

  const Listing({
    required this.id,
    required this.sellerId,
    required this.title,
    required this.price,
    required this.status,
    required this.images,
    required this.location,
    this.distanceKm,
  });

  factory Listing.fromMap(Map<String, dynamic> map) {
    return Listing(
      id: map['id'] as String,
      sellerId: map['sellerId'] as String? ?? map['seller_id'] as String? ?? '',
      title: map['title'] as String,
      price: (map['price'] as num).toDouble(),
      status: map['status'] as String? ?? 'ACTIVE',
      images: _parseImages(map['images']),
      location: map['location'] is Map<String, dynamic>
          ? ListingLocation.fromMap(map['location'] as Map<String, dynamic>)
          : ListingLocation(
              latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
              longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
            ),
      distanceKm: _toNullableDouble(
          map['distanceKm'] ?? map['distance_km'] ?? map['distance']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'sellerId': sellerId,
        'title': title,
        'price': price,
        'status': status,
        'images': images,
        'location': location.toMap(),
        if (distanceKm != null) 'distanceKm': distanceKm,
      };

  String toJson() => jsonEncode(toMap());

  static List<String> _parseImages(dynamic raw) {
    if (raw == null) return const [];
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }

    try {
      final parsed = jsonDecode(raw as String);
      if (parsed is List) {
        return parsed.map((e) => e.toString()).toList();
      }
    } catch (_) {
      // ignore parsing errors and fall back to empty
    }
    return const [];
  }

  static double? _toNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
