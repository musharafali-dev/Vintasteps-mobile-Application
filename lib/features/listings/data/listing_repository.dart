import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../domain/models/listing.dart';

class ListingRepository {
  final DioClient _dioClient;

  ListingRepository(this._dioClient);

  Future<List<Listing>> fetchNearbyListings({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
  }) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      '/api/v1/listings/nearby',
      queryParameters: {
        'lat': latitude,
        'lon': longitude,
        'radiusKm': radiusKm,
      },
    );

    final data = response.data;
    final items = data?['data'] as List<dynamic>? ?? const [];

    return items
        .map((item) => Listing.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<Listing> createListing({
    required Map<String, dynamic> data,
    List<String> imagePaths = const [],
  }) async {
    final formData = FormData();

    data.forEach((key, value) {
      if (value == null) return;
      formData.fields.add(MapEntry(key, value.toString()));
    });

    if (imagePaths.isNotEmpty) {
      for (final path in imagePaths) {
        formData.files.add(
          MapEntry(
            'images',
            await MultipartFile.fromFile(path, filename: path.split('/').last),
          ),
        );
      }
    }

    final response = await _dioClient.dio.post<Map<String, dynamic>>(
      '/api/v1/listings',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    final body = response.data;
    if (body == null || body['data'] == null) {
      throw const FormatException('Invalid response from server');
    }

    return Listing.fromMap(body['data'] as Map<String, dynamic>);
  }
}

final listingRepositoryProvider = Provider<ListingRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ListingRepository(dioClient);
});
