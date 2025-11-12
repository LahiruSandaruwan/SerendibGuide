import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

/// Budget calculator to estimate trip costs
class BudgetCalculatorScreen extends StatefulWidget {
  const BudgetCalculatorScreen({super.key});

  @override
  State<BudgetCalculatorScreen> createState() => _BudgetCalculatorScreenState();
}

class _BudgetCalculatorScreenState extends State<BudgetCalculatorScreen> {
  // Input controllers
  final TextEditingController _daysController = TextEditingController(text: '7');
  final TextEditingController _peopleController = TextEditingController(text: '2');

  // Selected options
  String _accommodationType = 'Mid-range';
  String _transportType = 'Mix';
  String _foodStyle = 'Local + Tourist';
  int _attractionsPerDay = 2;
  bool _includeActivities = true;
  bool _includeShopping = false;

  // Prices per day per person in LKR
  final Map<String, double> _accommodationPrices = {
    'Budget': 2000,
    'Mid-range': 5000,
    'Luxury': 15000,
  };

  final Map<String, double> _transportPrices = {
    'Public Transport': 500,
    'Mix': 1500,
    'Private Driver': 5000,
  };

  final Map<String, double> _foodPrices = {
    'Local Only': 1000,
    'Local + Tourist': 2000,
    'Tourist Restaurants': 3500,
  };

  @override
  void dispose() {
    _daysController.dispose();
    _peopleController.dispose();
    super.dispose();
  }

  Map<String, double> _calculateBudget() {
    final int days = int.tryParse(_daysController.text) ?? 7;
    final int people = int.tryParse(_peopleController.text) ?? 2;

    // Calculate per person per day
    final double accommodation = _accommodationPrices[_accommodationType] ?? 5000;
    final double transport = _transportPrices[_transportType] ?? 1500;
    final double food = _foodPrices[_foodStyle] ?? 2000;
    final double attractions = _attractionsPerDay * 2000.0; // Avg 2000 LKR per entry
    final double activities = _includeActivities ? 3000.0 : 0; // Safari, diving, etc.
    final double shopping = _includeShopping ? 2000.0 : 0;

    final double dailyPerPerson = accommodation + transport + food + attractions + activities + shopping;
    final double totalPerPerson = dailyPerPerson * days;
    final double totalTrip = totalPerPerson * people;

    return {
      'accommodation': accommodation * days * people,
      'transport': transport * days * people,
      'food': food * days * people,
      'attractions': attractions * days * people,
      'activities': activities * days * people,
      'shopping': shopping * days * people,
      'dailyPerPerson': dailyPerPerson,
      'totalPerPerson': totalPerPerson,
      'totalTrip': totalTrip,
    };
  }

  @override
  Widget build(BuildContext context) {
    final budget = _calculateBudget();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Calculator'),
        backgroundColor: AppConstants.deepOceanBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Card(
              color: AppConstants.deepOceanBlue.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                child: Row(
                  children: [
                    const Icon(Icons.calculate, size: 40, color: AppConstants.deepOceanBlue),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Trip Budget Estimator',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Get an estimate of your Sri Lanka trip costs',
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

            // Trip Details
            const Text(
              'Trip Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _daysController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Number of Days',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _peopleController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Number of People',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.people),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Accommodation
            _buildSection(
              'Accommodation',
              Icons.hotel,
              DropdownButton<String>(
                value: _accommodationType,
                isExpanded: true,
                items: _accommodationPrices.keys.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text('$value (LKR ${_accommodationPrices[value]}/night/person)'),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() => _accommodationType = newValue!);
                },
              ),
            ),

            const SizedBox(height: 16),

            // Transport
            _buildSection(
              'Transport',
              Icons.directions_car,
              DropdownButton<String>(
                value: _transportType,
                isExpanded: true,
                items: _transportPrices.keys.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text('$value (LKR ${_transportPrices[value]}/day/person)'),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() => _transportType = newValue!);
                },
              ),
            ),

            const SizedBox(height: 16),

            // Food
            _buildSection(
              'Food',
              Icons.restaurant,
              DropdownButton<String>(
                value: _foodStyle,
                isExpanded: true,
                items: _foodPrices.keys.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text('$value (LKR ${_foodPrices[value]}/day/person)'),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() => _foodStyle = newValue!);
                },
              ),
            ),

            const SizedBox(height: 16),

            // Attractions
            _buildSection(
              'Attraction Entries',
              Icons.location_on,
              Row(
                children: [
                  Expanded(
                    child: Text('$_attractionsPerDay sites per day'),
                  ),
                  Slider(
                    value: _attractionsPerDay.toDouble(),
                    min: 0,
                    max: 5,
                    divisions: 5,
                    label: _attractionsPerDay.toString(),
                    onChanged: (double value) {
                      setState(() => _attractionsPerDay = value.toInt());
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Activities
            CheckboxListTile(
              title: const Text('Include Activities'),
              subtitle: const Text('Safari, diving, water sports (LKR 3000/day/person)'),
              value: _includeActivities,
              onChanged: (bool? value) {
                setState(() => _includeActivities = value ?? true);
              },
              secondary: const Icon(Icons.surfing),
            ),

            // Shopping
            CheckboxListTile(
              title: const Text('Include Shopping Budget'),
              subtitle: const Text('Souvenirs, gifts (LKR 2000/day/person)'),
              value: _includeShopping,
              onChanged: (bool? value) {
                setState(() => _includeShopping = value ?? false);
              },
              secondary: const Icon(Icons.shopping_bag),
            ),

            const SizedBox(height: 24),
            const Divider(thickness: 2),
            const SizedBox(height: 16),

            // Budget Summary
            const Text(
              'Budget Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Breakdown
            _buildBudgetItem('Accommodation', budget['accommodation']!, Colors.blue),
            _buildBudgetItem('Transport', budget['transport']!, Colors.orange),
            _buildBudgetItem('Food', budget['food']!, Colors.green),
            _buildBudgetItem('Attractions', budget['attractions']!, Colors.purple),
            if (_includeActivities)
              _buildBudgetItem('Activities', budget['activities']!, Colors.teal),
            if (_includeShopping)
              _buildBudgetItem('Shopping', budget['shopping']!, Colors.pink),

            const SizedBox(height: 16),
            const Divider(thickness: 2),
            const SizedBox(height: 16),

            // Total summary cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Per Person/Day',
                    budget['dailyPerPerson']!,
                    Icons.person,
                    AppConstants.tropicalGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Per Person Total',
                    budget['totalPerPerson']!,
                    Icons.account_circle,
                    AppConstants.sunsetOrange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Grand total
            Card(
              color: AppConstants.deepOceanBlue,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                child: Column(
                  children: [
                    const Text(
                      'TOTAL TRIP COST',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'LKR ${_formatCurrency(budget['totalTrip']!)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '≈ USD ${_formatCurrency(budget['totalTrip']! / 300)}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Disclaimer
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
                        'This is an estimate. Actual costs may vary based on season, preferences, and booking choices.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppConstants.deepOceanBlue),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildBudgetItem(String label, double amount, Color color) {
    final total = _calculateBudget()['totalTrip']!;
    final percentage = (amount / total * 100).toStringAsFixed(0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label),
          ),
          Text(
            'LKR ${_formatCurrency(amount)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(
            '($percentage%)',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, double amount, IconData icon, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'LKR ${_formatCurrency(amount)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
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
