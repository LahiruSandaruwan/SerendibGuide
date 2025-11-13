import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/currency.dart';
import '../services/currency_service.dart';
import '../utils/constants.dart';

/// Currency Converter Screen
class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final CurrencyService _service = CurrencyService();
  final TextEditingController _amountController = TextEditingController(text: '1000');

  Map<String, CurrencyRate>? _rates;
  bool _isLoading = true;
  String? _error;

  String _fromCurrency = 'LKR';
  String _toCurrency = 'USD';
  double _amount = 1000;
  CurrencyConversion? _conversion;

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadRates() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final rates = await _service.getExchangeRates();

      if (mounted) {
        setState(() {
          _rates = rates;
          _isLoading = false;
        });
        _convert();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _convert() async {
    if (_rates == null) return;

    try {
      final conversion = await _service.convert(
        amount: _amount,
        fromCurrency: _fromCurrency,
        toCurrency: _toCurrency,
      );

      if (mounted) {
        setState(() {
          _conversion = conversion;
        });
      }
    } catch (e) {
      print('Error converting: $e');
    }
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
    _convert();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
        backgroundColor: AppConstants.sunsetOrange,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _service.clearCache();
              _loadRates();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildConverterCard(),
                      const SizedBox(height: 24),
                      _buildPopularRatesCard(),
                      const SizedBox(height: 16),
                      _buildDataSource(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
            const SizedBox(height: 16),
            const Text(
              'Error loading rates',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadRates,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.sunsetOrange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConverterCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Amount input
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: PopularCurrencies.getSymbol(_fromCurrency),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.all(16),
              ),
              onChanged: (value) {
                setState(() {
                  _amount = double.tryParse(value) ?? 0;
                });
                _convert();
              },
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),

            const SizedBox(height: 20),

            // From currency selector
            _buildCurrencySelector(
              label: 'From',
              value: _fromCurrency,
              onChanged: (value) {
                setState(() => _fromCurrency = value!);
                _convert();
              },
            ),

            const SizedBox(height: 12),

            // Swap button
            IconButton(
              onPressed: _swapCurrencies,
              icon: const Icon(Icons.swap_vert),
              iconSize: 32,
              style: IconButton.styleFrom(
                backgroundColor: AppConstants.deepOceanBlue.withOpacity(0.1),
              ),
            ),

            const SizedBox(height: 12),

            // To currency selector
            _buildCurrencySelector(
              label: 'To',
              value: _toCurrency,
              onChanged: (value) {
                setState(() => _toCurrency = value!);
                _convert();
              },
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Result
            if (_conversion != null) ...[
              Text(
                _conversion!.displayResult,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.tropicalGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '1 ${_conversion!.fromCurrency} = ${_conversion!.rate.toStringAsFixed(4)} ${_conversion!.toCurrency}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencySelector({
    required String label,
    required String value,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            PopularCurrencies.getFlag(value),
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                DropdownButton<String>(
                  value: value,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: PopularCurrencies.currencies.keys.map((code) {
                    return DropdownMenuItem(
                      value: code,
                      child: Text(
                        '$code - ${PopularCurrencies.getName(code)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularRatesCard() {
    if (_rates == null) return const SizedBox();

    final popularRates = PopularCurrencies.popularCodes
        .where((code) => _rates!.containsKey(code) && code != 'LKR')
        .map((code) => _rates![code]!)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Popular Rates (1 LKR =)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...popularRates.map((rate) => _buildRateRow(rate)),
          ],
        ),
      ),
    );
  }

  Widget _buildRateRow(CurrencyRate rate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            PopularCurrencies.getFlag(rate.code),
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rate.code,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  rate.name,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            rate.format(rate.rate),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppConstants.deepOceanBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSource() {
    return Center(
      child: Column(
        children: [
          Text(
            'Exchange rates from Exchangerate.host',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
          if (_rates != null && _rates!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Last updated: ${_getLastUpdateTime()}',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getLastUpdateTime() {
    if (_rates == null || _rates!.isEmpty) return '';
    final lastUpdate = _rates!.values.first.lastUpdated;
    final now = DateTime.now();
    final diff = now.difference(lastUpdate);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} minutes ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    } else {
      return '${diff.inDays} days ago';
    }
  }
}
