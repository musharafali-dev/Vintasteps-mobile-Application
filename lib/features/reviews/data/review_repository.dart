import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/review.dart';

/// Mocked repository that simulates persisting and retrieving reviews.
/// Swap with a network-backed implementation when the backend is ready.
class ReviewRepository {
  ReviewRepository() {
    _seedMockReviews();
  }

  final List<Review> _reviews = [];

  void _seedMockReviews() {
    final now = DateTime.now();
    _reviews.addAll([
      Review(
        id: 'rev-1',
        orderId: 'order-1',
        reviewerId: 'user-1',
        revieweeId: 'user-2',
        rating: 4.5,
        comment: 'Great packaging and quick shipping!',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Review(
        id: 'rev-2',
        orderId: 'order-2',
        reviewerId: 'user-3',
        revieweeId: 'user-1',
        rating: 5,
        comment: 'Exactly as described. Would buy again.',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
    ]);
  }

  Future<List<Review>> fetchReviewsForUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _reviews.where((review) => review.revieweeId == userId).toList();
  }

  Future<bool> hasReviewForOrder(String orderId, String reviewerId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _reviews.any(
      (review) => review.orderId == orderId && review.reviewerId == reviewerId,
    );
  }

  Future<Review> submitReview({
    required String orderId,
    required String reviewerId,
    required String revieweeId,
    required double rating,
    required String comment,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));

    final review = Review(
      id: 'rev-${DateTime.now().millisecondsSinceEpoch}',
      orderId: orderId,
      reviewerId: reviewerId,
      revieweeId: revieweeId,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );

    _reviews.add(review);
    return review;
  }
}

final reviewRepositoryProvider = Provider.autoDispose<ReviewRepository>((ref) {
  return ReviewRepository();
});
