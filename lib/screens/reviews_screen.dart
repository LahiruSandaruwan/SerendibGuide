import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_review.dart';
import '../services/user_data_service.dart';
import '../utils/constants.dart';

/// Screen for viewing and adding user reviews
class ReviewsScreen extends StatefulWidget {
  final int? attractionId;
  final String? attractionName;

  const ReviewsScreen({
    super.key,
    this.attractionId,
    this.attractionName,
  });

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final UserDataService _userDataService = UserDataService();
  List<UserReview> _reviews = [];
  bool _isLoading = true;
  String _sortBy = 'recent'; // recent, rating, helpful
  double _averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);
    try {
      final reviewsData = widget.attractionId != null
          ? await _userDataService.getReviewsByAttraction(widget.attractionId!)
          : await _userDataService.getAllReviews();

      final reviews =
          reviewsData.map((data) => UserReview.fromMap(data)).toList();

      if (widget.attractionId != null) {
        final avgRating =
            await _userDataService.getAverageRating(widget.attractionId!);
        setState(() {
          _averageRating = avgRating;
        });
      }

      setState(() {
        _reviews = reviews;
        _sortReviews();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reviews: $e')),
        );
      }
    }
  }

  void _sortReviews() {
    switch (_sortBy) {
      case 'recent':
        _reviews.sort((a, b) => b.postedDate.compareTo(a.postedDate));
        break;
      case 'rating':
        _reviews.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'helpful':
        _reviews.sort((a, b) => b.helpfulCount.compareTo(a.helpfulCount));
        break;
    }
  }

  void _showAddReviewDialog() {
    if (widget.attractionId == null || widget.attractionName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please open this from an attraction page')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _AddReviewDialog(
        attractionId: widget.attractionId!,
        attractionName: widget.attractionName!,
        onReviewAdded: () {
          Navigator.pop(context);
          _loadReviews();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.attractionName != null ? 'Reviews' : 'All Reviews'),
        backgroundColor: AppConstants.tropicalGreen,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
                _sortReviews();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'recent', child: Text('Most Recent')),
              const PopupMenuItem(
                  value: 'rating', child: Text('Highest Rating')),
              const PopupMenuItem(
                  value: 'helpful', child: Text('Most Helpful')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reviews.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    if (widget.attractionId != null) _buildRatingSummary(),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _reviews.length,
                        itemBuilder: (context, index) {
                          return _buildReviewCard(_reviews[index]);
                        },
                      ),
                    ),
                  ],
                ),
      floatingActionButton: widget.attractionId != null
          ? FloatingActionButton.extended(
              onPressed: _showAddReviewDialog,
              backgroundColor: AppConstants.tropicalGreen,
              icon: const Icon(Icons.rate_review),
              label: const Text('Write Review'),
            )
          : null,
    );
  }

  Widget _buildRatingSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppConstants.tropicalGreen.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                _averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.tropicalGreen,
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < _averageRating.round()
                        ? Icons.star
                        : Icons.star_border,
                    color: AppConstants.sunsetOrange,
                    size: 20,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_reviews.length} ${_reviews.length == 1 ? 'Review' : 'Reviews'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Based on traveler experiences',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rate_review, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No reviews yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            widget.attractionId != null
                ? 'Be the first to share your experience!'
                : 'Reviews from travelers will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(UserReview review) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user info and rating
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppConstants.tropicalGreen,
                  child: Text(
                    review.userName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            review.userName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (review.userCountry != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                review.userCountry!,
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < review.rating
                                    ? Icons.star
                                    : Icons.star_border,
                                size: 14,
                                color: AppConstants.sunsetOrange,
                              );
                            }),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            dateFormat.format(review.postedDate),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Category badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppConstants.deepOceanBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${review.category.emoji} ${review.category.displayName}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppConstants.deepOceanBlue,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Attraction name if viewing all reviews
            if (widget.attractionId == null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppConstants.tropicalGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.place,
                      size: 14,
                      color: AppConstants.tropicalGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      review.attractionName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.tropicalGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Review text
            Text(
              review.reviewText,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),

            const SizedBox(height: 12),

            // Visit date
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Visited: ${dateFormat.format(review.visitDate)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Helpful button
            Row(
              children: [
                TextButton.icon(
                  onPressed: () async {
                    await _userDataService.markReviewHelpful(review.id!);
                    _loadReviews();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Marked as helpful. Thanks!')),
                      );
                    }
                  },
                  icon: const Icon(Icons.thumb_up_outlined, size: 16),
                  label: Text('Helpful (${review.helpfulCount})'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppConstants.deepOceanBlue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog for adding a new review
class _AddReviewDialog extends StatefulWidget {
  final int attractionId;
  final String attractionName;
  final VoidCallback onReviewAdded;

  const _AddReviewDialog({
    required this.attractionId,
    required this.attractionName,
    required this.onReviewAdded,
  });

  @override
  State<_AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<_AddReviewDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _reviewController = TextEditingController();
  final _countryController = TextEditingController();
  late DateTime _visitDate;
  int _rating = 0;
  ReviewCategory _category = ReviewCategory.general;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _visitDate = DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _reviewController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userDataService = UserDataService();
      await userDataService.addReview(
        attractionId: widget.attractionId,
        attractionName: widget.attractionName,
        userName: _nameController.text,
        rating: _rating,
        reviewText: _reviewController.text,
        visitDate: _visitDate,
        userCountry:
            _countryController.text.isNotEmpty ? _countryController.text : null,
        category: _category.name,
      );

      widget.onReviewAdded();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review added successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding review: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _visitDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _visitDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Write a Review',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.attractionName,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),

                // Your name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Your Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Country (optional)
                TextFormField(
                  controller: _countryController,
                  decoration: const InputDecoration(
                    labelText: 'Country (optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.flag),
                  ),
                ),

                const SizedBox(height: 16),

                // Rating
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Rating',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          onPressed: () {
                            setState(() => _rating = index + 1);
                          },
                          icon: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            size: 36,
                            color: AppConstants.sunsetOrange,
                          ),
                        );
                      }),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Category
                DropdownButtonFormField<ReviewCategory>(
                  value: _category,
                  decoration: const InputDecoration(
                    labelText: 'Travel Type',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: ReviewCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(
                          '${category.emoji} ${category.displayName}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _category = value);
                    }
                  },
                ),

                const SizedBox(height: 16),

                // Visit date
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Visit Date',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(dateFormat.format(_visitDate)),
                  ),
                ),

                const SizedBox(height: 16),

                // Review text
                TextFormField(
                  controller: _reviewController,
                  decoration: const InputDecoration(
                    labelText: 'Your Review',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                    hintText: 'Share your experience...',
                  ),
                  maxLines: 6,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please write your review';
                    }
                    if (value.length < 20) {
                      return 'Please write at least 20 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSaving ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.tropicalGreen,
                        foregroundColor: Colors.white,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Submit Review'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
