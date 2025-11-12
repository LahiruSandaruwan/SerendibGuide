import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/journal_entry.dart';
import '../services/user_data_service.dart';
import '../utils/constants.dart';

/// Travel journal for recording memories and experiences
class TravelJournalScreen extends StatefulWidget {
  const TravelJournalScreen({super.key});

  @override
  State<TravelJournalScreen> createState() => _TravelJournalScreenState();
}

class _TravelJournalScreenState extends State<TravelJournalScreen> {
  final UserDataService _userDataService = UserDataService();
  List<JournalEntry> _entries = [];
  bool _isLoading = true;
  String _sortOrder = 'newest'; // newest, oldest, rating

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);
    try {
      final entriesData = await _userDataService.getJournalEntries();
      setState(() {
        _entries = entriesData.map((data) => JournalEntry.fromMap(data)).toList();
        _sortEntries();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading journal entries: $e')),
        );
      }
    }
  }

  void _sortEntries() {
    switch (_sortOrder) {
      case 'newest':
        _entries.sort((a, b) => b.visitDate.compareTo(a.visitDate));
        break;
      case 'oldest':
        _entries.sort((a, b) => a.visitDate.compareTo(b.visitDate));
        break;
      case 'rating':
        _entries.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }
  }

  Future<void> _deleteEntry(int id) async {
    try {
      await _userDataService.deleteJournalEntry(id);
      await _loadEntries();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Journal entry deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting entry: $e')),
        );
      }
    }
  }

  void _showAddEditDialog({JournalEntry? entry}) {
    showDialog(
      context: context,
      builder: (context) => _JournalEntryDialog(
        entry: entry,
        onSave: () {
          Navigator.pop(context);
          _loadEntries();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Journal'),
        backgroundColor: AppConstants.sunsetOrange,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortOrder = value;
                _sortEntries();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'newest',
                child: Text('Newest First'),
              ),
              const PopupMenuItem(
                value: 'oldest',
                child: Text('Oldest First'),
              ),
              const PopupMenuItem(
                value: 'rating',
                child: Text('Highest Rated'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _entries.length,
                  itemBuilder: (context, index) {
                    return _buildJournalCard(_entries[index]);
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: AppConstants.sunsetOrange,
        icon: const Icon(Icons.add),
        label: const Text('New Entry'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No journal entries yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to start recording your memories',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildJournalCard(JournalEntry entry) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showAddEditDialog(entry: entry),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with date and rating
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.attractionName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < entry.rating ? Icons.star : Icons.star_border,
                            size: 16,
                            color: AppConstants.sunsetOrange,
                          );
                        }),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(entry.visitDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Content preview
              Text(
                entry.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),

              // Tags
              if (entry.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: entry.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppConstants.tropicalGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppConstants.tropicalGreen.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        '#$tag',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppConstants.tropicalGreen,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 12),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showAddEditDialog(entry: entry),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppConstants.deepOceanBlue,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Entry'),
                          content: const Text('Are you sure you want to delete this journal entry?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _deleteEntry(entry.id!);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog for adding/editing journal entries
class _JournalEntryDialog extends StatefulWidget {
  final JournalEntry? entry;
  final VoidCallback onSave;

  const _JournalEntryDialog({
    this.entry,
    required this.onSave,
  });

  @override
  State<_JournalEntryDialog> createState() => _JournalEntryDialogState();
}

class _JournalEntryDialogState extends State<_JournalEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _attractionController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  late DateTime _visitDate;
  int _rating = 0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _titleController.text = widget.entry!.title;
      _attractionController.text = widget.entry!.attractionName;
      _contentController.text = widget.entry!.content;
      _tagsController.text = widget.entry!.tags.join(', ');
      _visitDate = widget.entry!.visitDate;
      _rating = widget.entry!.rating;
    } else {
      _visitDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _attractionController.dispose();
    _contentController.dispose();
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

      if (widget.entry != null) {
        // Update existing entry
        await userDataService.updateJournalEntry(
          widget.entry!.id!,
          {
            'title': _titleController.text,
            'attraction_name': _attractionController.text,
            'content': _contentController.text,
            'visit_date': _visitDate.toIso8601String(),
            'rating': _rating,
            'tags': tags.join(','),
          },
        );
      } else {
        // Add new entry
        await userDataService.addJournalEntry(
          attractionName: _attractionController.text,
          title: _titleController.text,
          content: _contentController.text,
          visitDate: _visitDate,
          rating: _rating,
          tags: tags,
        );
      }

      widget.onSave();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving entry: $e')),
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
                Text(
                  widget.entry != null ? 'Edit Entry' : 'New Journal Entry',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Attraction name
                TextFormField(
                  controller: _attractionController,
                  decoration: const InputDecoration(
                    labelText: 'Attraction/Place',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.place),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an attraction name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Content
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Your Experience',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please share your experience';
                    }
                    return null;
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

                // Rating
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rating',
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
                            size: 32,
                            color: AppConstants.sunsetOrange,
                          ),
                        );
                      }),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Tags
                TextFormField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (comma-separated)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.tag),
                    hintText: 'e.g., beautiful, historical, must-visit',
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
                        backgroundColor: AppConstants.sunsetOrange,
                        foregroundColor: Colors.white,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Save'),
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
