import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/travel_tip.dart';
import '../services/user_data_service.dart';
import '../utils/constants.dart';

/// Screen for browsing and sharing travel tips
class TravelTipsExchangeScreen extends StatefulWidget {
  final int? attractionId;
  final String? attractionName;

  const TravelTipsExchangeScreen({
    super.key,
    this.attractionId,
    this.attractionName,
  });

  @override
  State<TravelTipsExchangeScreen> createState() =>
      _TravelTipsExchangeScreenState();
}

class _TravelTipsExchangeScreenState extends State<TravelTipsExchangeScreen> {
  final UserDataService _userDataService = UserDataService();
  List<TravelTip> _tips = [];
  bool _isLoading = true;
  TipCategory? _filterCategory;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTips();
  }

  Future<void> _loadTips() async {
    setState(() => _isLoading = true);
    try {
      final tipsData = widget.attractionId != null
          ? await _userDataService.getTipsByAttraction(widget.attractionId!)
          : await _userDataService.getAllTravelTips();

      final tips = tipsData.map((data) => TravelTip.fromMap(data)).toList();

      setState(() {
        _tips = tips;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tips: $e')),
        );
      }
    }
  }

  List<TravelTip> _getFilteredTips() {
    var filtered = _tips;

    // Filter by category
    if (_filterCategory != null) {
      filtered =
          filtered.where((tip) => tip.category == _filterCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((tip) {
        return tip.title.toLowerCase().contains(query) ||
            tip.tipText.toLowerCase().contains(query) ||
            tip.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    }

    return filtered;
  }

  void _showAddTipDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddTipDialog(
        attractionId: widget.attractionId,
        attractionName: widget.attractionName,
        onTipAdded: () {
          Navigator.pop(context);
          _loadTips();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTips = _getFilteredTips();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.attractionName != null
            ? 'Travel Tips'
            : 'Travel Tips Exchange'),
        backgroundColor: AppConstants.deepOceanBlue,
      ),
      body: Column(
        children: [
          // Search and filter
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                // Search bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search tips...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
                const SizedBox(height: 12),

                // Category filters
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFilterChip('All', null),
                      ...TipCategory.values.map((category) {
                        return _buildFilterChip(
                            category.displayName, category);
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tips list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredTips.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredTips.length,
                        itemBuilder: (context, index) {
                          return _buildTipCard(filteredTips[index]);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTipDialog,
        backgroundColor: AppConstants.deepOceanBlue,
        icon: const Icon(Icons.lightbulb),
        label: const Text('Share a Tip'),
      ),
    );
  }

  Widget _buildFilterChip(String label, TipCategory? category) {
    final isSelected = _filterCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _filterCategory = selected ? category : null;
          });
        },
        selectedColor: AppConstants.deepOceanBlue.withOpacity(0.2),
        checkmarkColor: AppConstants.deepOceanBlue,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lightbulb_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No tips yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share a helpful tip!',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(TravelTip tip) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with category and user
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppConstants.deepOceanBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${tip.category.icon} ${tip.category.displayName}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.deepOceanBlue,
                    ),
                  ),
                ),
                const Spacer(),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppConstants.deepOceanBlue,
                  child: Text(
                    tip.userName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      tip.userName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      dateFormat.format(tip.postedDate),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Attraction name if viewing all tips
            if (widget.attractionId == null && tip.attractionName != null) ...[
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
                      tip.attractionName!,
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

            // Title
            Row(
              children: [
                const Icon(
                  Icons.lightbulb,
                  size: 20,
                  color: AppConstants.sunsetOrange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tip.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Tip text
            Text(
              tip.tipText,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),

            // Tags
            if (tip.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: tip.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppConstants.tropicalGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppConstants.tropicalGreen.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      '#$tag',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppConstants.tropicalGreen,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 12),

            // Helpful button
            TextButton.icon(
              onPressed: () async {
                await _userDataService.markTipHelpful(tip.id!);
                _loadTips();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Marked as helpful. Thanks!')),
                  );
                }
              },
              icon: const Icon(Icons.thumb_up_outlined, size: 16),
              label: Text('Helpful (${tip.helpfulCount})'),
              style: TextButton.styleFrom(
                foregroundColor: AppConstants.deepOceanBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog for adding a new travel tip
class _AddTipDialog extends StatefulWidget {
  final int? attractionId;
  final String? attractionName;
  final VoidCallback onTipAdded;

  const _AddTipDialog({
    this.attractionId,
    this.attractionName,
    required this.onTipAdded,
  });

  @override
  State<_AddTipDialog> createState() => _AddTipDialogState();
}

class _AddTipDialogState extends State<_AddTipDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _titleController = TextEditingController();
  final _tipController = TextEditingController();
  final _tagsController = TextEditingController();
  TipCategory _category = TipCategory.general;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _tipController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final userDataService = UserDataService();
      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      await userDataService.addTravelTip(
        attractionId: widget.attractionId,
        attractionName: widget.attractionName,
        userName: _nameController.text,
        title: _titleController.text,
        tipText: _tipController.text,
        category: _category.name,
        tags: tags,
      );

      widget.onTipAdded();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tip added successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding tip: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  'Share a Travel Tip',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                if (widget.attractionName != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.attractionName!,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
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

                // Category
                DropdownButtonFormField<TipCategory>(
                  value: _category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: TipCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text('${category.icon} ${category.displayName}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _category = value);
                    }
                  },
                ),

                const SizedBox(height: 16),

                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Tip Title',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                    hintText: 'e.g., Best time to visit',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Tip text
                TextFormField(
                  controller: _tipController,
                  decoration: const InputDecoration(
                    labelText: 'Your Tip',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                    hintText: 'Share your helpful advice...',
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please share your tip';
                    }
                    if (value.length < 20) {
                      return 'Please write at least 20 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Tags
                TextFormField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (comma-separated)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.tag),
                    hintText: 'e.g., budget, family, morning',
                  ),
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
                        backgroundColor: AppConstants.deepOceanBlue,
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
                          : const Text('Share Tip'),
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
