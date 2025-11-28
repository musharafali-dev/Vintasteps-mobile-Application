import '../../listings/domain/models/listing.dart';

class CartItem {
  const CartItem({required this.listing, this.quantity = 1});

  final Listing listing;
  final int quantity;

  double get total => listing.price * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      listing: listing,
      quantity: quantity ?? this.quantity,
    );
  }
}
