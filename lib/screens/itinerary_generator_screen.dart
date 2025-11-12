import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/itinerary.dart';
import '../services/itinerary_generator_service.dart';
import '../utils/constants.dart';

/// AI Itinerary Generator screen
class ItineraryGeneratorScreen extends StatefulWidget {
  const ItineraryGeneratorScreen({super.key});

  @override
  State<ItineraryGeneratorScreen> createState() => _ItineraryGeneratorScreenState();
}

class _ItineraryGeneratorScreenState extends State<ItineraryGeneratorScreen> {
  final ItineraryGeneratorService _generatorService = ItineraryGeneratorService();

  int _numberOfDays = 7;
  BudgetLevel _budgetLevel = BudgetLevel.moderate;
  PaceLevel _paceLevel = PaceLevel.moderate;
  Set<String> _selectedInterests = {'Cultural', 'Nature'};
  bool _isGenerating = false;
  GeneratedItinerary? _generatedItinerary;

  final List<String> _availableInterests = [
    'Cultural',
    'Nature',
    'Beach',
    'Wildlife',
    'Adventure',
    'Historical',
  ];

  Future<void> _generateItinerary() async {
    setState(() => _isGenerating = true);

    try {
      final prefs = ItineraryPreferences(
        numberOfDays: _numberOfDays,
        budgetLevel: _budgetLevel,
        interests: _selectedInterests.toList(),
        pace: _paceLevel,
      );

      final itinerary = await _generatorService.generateItinerary(prefs);

      setState(() {
        _generatedItinerary = itinerary;
        _isGenerating = false;
      });
    } catch (e) {
      print('Error generating itinerary: $e');
      setState(() => _isGenerating = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating itinerary: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Itinerary Generator'),
        backgroundColor: AppConstants.deepOceanBlue,
      ),
      body: _generatedItinerary == null
          ? _buildInputForm()
          : _buildGeneratedItinerary(),
    );
  }

  Widget _buildInputForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Card(
            color: AppConstants.deepOceanBlue.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: const [
                  Icon(Icons.auto_awesome, size: 40, color: AppConstants.deepOceanBlue),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Trip Planner',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Create a personalized itinerary in seconds',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Number of days
          const Text(
            'Trip Duration',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Number of Days', style: TextStyle(fontSize: 16)),
                      Text(
                        '$_numberOfDays days',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.deepOceanBlue,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _numberOfDays.toDouble(),
                    min: 3,
                    max: 14,
                    divisions: 11,
                    label: '$_numberOfDays days',
                    onChanged: (value) {
                      setState(() => _numberOfDays = value.toInt());
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Budget level
          const Text(
            'Budget Level',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SegmentedButton<BudgetLevel>(
            segments: const [
              ButtonSegment(
                value: BudgetLevel.budget,
                label: Text('Budget'),
                icon: Icon(Icons.savings),
              ),
              ButtonSegment(
                value: BudgetLevel.moderate,
                label: Text('Moderate'),
                icon: Icon(Icons.account_balance_wallet),
              ),
              ButtonSegment(
                value: BudgetLevel.luxury,
                label: Text('Luxury'),
                icon: Icon(Icons.diamond),
              ),
            ],
            selected: {_budgetLevel},
            onSelectionChanged: (Set<BudgetLevel> selection) {
              setState(() => _budgetLevel = selection.first);
            },
          ),

          const SizedBox(height: 24),

          // Pace level
          const Text(
            'Trip Pace',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SegmentedButton<PaceLevel>(
            segments: const [
              ButtonSegment(
                value: PaceLevel.relaxed,
                label: Text('Relaxed'),
                icon: Icon(Icons.self_improvement),
              ),
              ButtonSegment(
                value: PaceLevel.moderate,
                label: Text('Moderate'),
                icon: Icon(Icons.directions_walk),
              ),
              ButtonSegment(
                value: PaceLevel.packed,
                label: Text('Packed'),
                icon: Icon(Icons.directions_run),
              ),
            ],
            selected: {_paceLevel},
            onSelectionChanged: (Set<PaceLevel> selection) {
              setState(() => _paceLevel = selection.first);
            },
          ),

          const SizedBox(height: 24),

          // Interests
          const Text(
            'Your Interests',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableInterests.map((interest) {
              final isSelected = _selectedInterests.contains(interest);
              return FilterChip(
                label: Text(interest),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedInterests.add(interest);
                    } else {
                      _selectedInterests.remove(interest);
                    }
                  });
                },
                selectedColor: AppConstants.tropicalGreen.withOpacity(0.3),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // Generate button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isGenerating ? null : _generateItinerary,
              icon: _isGenerating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_isGenerating ? 'Generating...' : 'Generate Itinerary'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.deepOceanBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Info
          Card(
            color: Colors.amber.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'The itinerary is generated based on your preferences and available attractions. You can customize it further after generation.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratedItinerary() {
    final itinerary = _generatedItinerary!;

    return Column(
      children: [
        // Header with summary
        Container(
          color: AppConstants.deepOceanBlue,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      itinerary.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      setState(() => _generatedItinerary = null);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStat(Icons.calendar_today, '${itinerary.numberOfDays} days'),
                  const SizedBox(width: 16),
                  _buildStat(Icons.location_on, '${itinerary.getTotalAttractions()} stops'),
                  const SizedBox(width: 16),
                  _buildStat(Icons.attach_money, 'LKR ${_formatCurrency(itinerary.getTotalEstimatedCost())}'),
                ],
              ),
            ],
          ),
        ),

        // Day plans
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: itinerary.dayPlans.length,
            itemBuilder: (context, index) {
              return _buildDayPlanCard(itinerary.dayPlans[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildDayPlanCard(DayPlan day) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppConstants.deepOceanBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Day ${day.dayNumber}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppConstants.deepOceanBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    day.region,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'LKR ${_formatCurrency(day.estimatedCost)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Attractions
            const Text(
              'Attractions',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...day.attractions.asMap().entries.map((entry) {
              final index = entry.key;
              final attraction = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppConstants.tropicalGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        attraction.name,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            if (day.travelTips.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConstants.sunsetOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppConstants.sunsetOrange.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline, color: AppConstants.sunsetOrange, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        day.travelTips,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
