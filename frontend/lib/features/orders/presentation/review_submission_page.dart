import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../reviews/data/review_repository.dart';

class ReviewSubmissionArgs {
  const ReviewSubmissionArgs({
    required this.orderId,
    required this.reviewerId,
    required this.revieweeId,
    required this.listingTitle,
  });

  final String orderId;
  final String reviewerId;
  final String revieweeId;
  final String listingTitle;
}

class ReviewSubmissionPage extends ConsumerStatefulWidget {
  const ReviewSubmissionPage({super.key, required this.args});

  final ReviewSubmissionArgs args;

  @override
  ConsumerState<ReviewSubmissionPage> createState() =>
      _ReviewSubmissionPageState();
}

class _ReviewSubmissionPageState extends ConsumerState<ReviewSubmissionPage> {
  double _rating = 5;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave a Review'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How was your experience with ${widget.args.listingTitle}?',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Text('Rating',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(5, (index) {
                          final value = (index + 1).toDouble();
                          final filled = value <= _rating;
                          return IconButton(
                            onPressed: () => setState(() => _rating = value),
                            icon: Icon(
                              filled ? Icons.star : Icons.star_border,
                              color: filled ? Colors.amber : Colors.grey,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _commentController,
                        minLines: 3,
                        maxLines: 5,
                        maxLength: 280,
                        decoration: const InputDecoration(
                          labelText: 'Comments',
                          hintText: 'Share details about the transaction...'
                              ' (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReview,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit Review'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
    if (_rating <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a star rating.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final repository = ref.read(reviewRepositoryProvider);

    try {
      await repository.submitReview(
        orderId: widget.args.orderId,
        reviewerId: widget.args.reviewerId,
        revieweeId: widget.args.revieweeId,
        rating: _rating,
        comment: _commentController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted. Thank you!')),
      );
      context.pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to submit review: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
