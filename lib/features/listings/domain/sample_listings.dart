import 'models/listing.dart';

/// Static fallback inventory used when the API has no data yet.
final List<Listing> sampleListings = [
  const Listing(
    id: 'sample-jacket',
    sellerId: 'demo-seller',
    title: 'Indigo Selvedge Jacket',
    price: 128,
    status: 'ACTIVE',
    images: [
      'https://images.unsplash.com/photo-1483985988355-763728e1935b',
    ],
    location: ListingLocation(latitude: 34.0522, longitude: -118.2437),
    distanceKm: 2.5,
  ),
  const Listing(
    id: 'sample-boots',
    sellerId: 'demo-seller',
    title: 'Heritage Leather Boots',
    price: 185,
    status: 'ACTIVE',
    images: [
      'https://images.unsplash.com/photo-1500904156668-758cff89dcff',
    ],
    location: ListingLocation(latitude: 40.73061, longitude: -73.935242),
    distanceKm: 5.2,
  ),
  const Listing(
    id: 'sample-runners',
    sellerId: 'demo-seller',
    title: 'Retro Runner 95s',
    price: 90,
    status: 'ACTIVE',
    images: [
      'https://images.unsplash.com/photo-1475180098004-ca77a66827be',
    ],
    location: ListingLocation(latitude: 51.5072, longitude: -0.1276),
    distanceKm: 8.1,
  ),
  const Listing(
    id: 'sample-loafers',
    sellerId: 'demo-seller',
    title: 'Sunset Suede Loafers',
    price: 110,
    status: 'ACTIVE',
    images: [
      'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab',
    ],
    location: ListingLocation(latitude: 37.7749, longitude: -122.4194),
    distanceKm: 3.4,
  ),
  const Listing(
    id: 'sample-hikers',
    sellerId: 'demo-seller',
    title: 'Nordic Trail Hikers',
    price: 150,
    status: 'ACTIVE',
    images: [
      'https://images.unsplash.com/photo-1441986300917-64674bd600d8',
    ],
    location: ListingLocation(latitude: 59.9139, longitude: 10.7522),
    distanceKm: 12.6,
  ),
  const Listing(
    id: 'sample-heels',
    sellerId: 'demo-seller',
    title: 'Celeste Studio Heels',
    price: 135,
    status: 'ACTIVE',
    images: [
      'https://images.unsplash.com/photo-1503341455253-b2e723bb3dbb',
    ],
    location: ListingLocation(latitude: 48.8566, longitude: 2.3522),
    distanceKm: 6.7,
  ),
];
