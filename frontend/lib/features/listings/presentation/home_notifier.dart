import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/listing_repository.dart';
import '../domain/models/listing.dart';
import '../domain/sample_listings.dart';

final homeNotifierProvider =
    AsyncNotifierProvider<HomeNotifier, List<Listing>>(HomeNotifier.new);

const _fallbackLatitude =
    34.0522; // Los Angeles fallback while location is disabled
const _fallbackLongitude = -118.2437;
const _fallbackRadiusKm = 25.0;

class HomeNotifier extends AsyncNotifier<List<Listing>> {
  ListingRepository get _repository => ref.read(listingRepositoryProvider);

  @override
  FutureOr<List<Listing>> build() async {
    return _loadNearbyListings();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadNearbyListings);
  }

  Future<List<Listing>> _loadNearbyListings() async {
    try {
      final listings = await _repository.fetchNearbyListings(
        latitude: _fallbackLatitude,
        longitude: _fallbackLongitude,
        radiusKm: _fallbackRadiusKm,
      );

      if (listings.isEmpty) {
        return sampleListings;
      }
      return listings;
    } catch (_) {
      return sampleListings;
    }
  }
}
