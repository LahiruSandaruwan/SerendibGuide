import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

/// Offline currency converter for Sri Lanka travel
class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final TextEditingController _amountController = TextEditingController(text: '1000');

  String _fromCurrency = 'LKR';
  String _toCurrency = 'USD';

  // Exchange rates relative to LKR (as of typical 2024 rates)
  // Note: In production, these would be updated via API or periodic updates
  final Map<String, double> _exchangeRates = {
    'LKR': 1.0,
    'USD': 0.0033, // 1 LKR = 0.0033 USD (approx 300 LKR = 1 USD)
    'EUR': 0.0030, // 1 LKR = 0.0030 EUR
    'GBP': 0.0026, // 1 LKR = 0.0026 GBP
    'AUD': 0.0050, // 1 LKR = 0.0050 AUD
    'CAD': 0.0045, // 1 LKR = 0.0045 CAD
    'INR': 0.28, // 1 LKR = 0.28 INR
    'JPY': 0.48, // 1 LKR = 0.48 JPY
    'CNY': 0.024, // 1 LKR = 0.024 CNY
    'SGD': 0.0044, // 1 LKR = 0.0044 SGD
    'MYR': 0.015, // 1 LKR = 0.015 MYR
    'THB': 0.12, // 1 LKR = 0.12 THB
    'AED': 0.012, // 1 LKR = 0.012 AED
    'SAR': 0.012, // 1 LKR = 0.012 SAR
    'NZD': 0.0054, // 1 LKR = 0.0054 NZD
    'CHF': 0.0029, // 1 LKR = 0.0029 CHF
    'SEK': 0.034, // 1 LKR = 0.034 SEK
    'NOK': 0.035, // 1 LKR = 0.035 NOK
    'DKK': 0.022, // 1 LKR = 0.022 DKK
    'KRW': 4.3, // 1 LKR = 4.3 KRW
  };

  final Map<String, String> _currencyNames = {
    'LKR': 'Sri Lankan Rupee',
    'USD': 'US Dollar',
    'EUR': 'Euro',
    'GBP': 'British Pound',
    'AUD': 'Australian Dollar',
    'CAD': 'Canadian Dollar',
    'INR': 'Indian Rupee',
    'JPY': 'Japanese Yen',
    'CNY': 'Chinese Yuan',
    'SGD': 'Singapore Dollar',
    'MYR': 'Malaysian Ringgit',
    'THB': 'Thai Baht',
    'AED': 'UAE Dirham',
    'SAR': 'Saudi Riyal',
    'NZD': 'New Zealand Dollar',
    'CHF': 'Swiss Franc',
    'SEK': 'Swedish Krona',
    'NOK': 'Norwegian Krone',
    'DKK': 'Danish Krone',
    'KRW': 'South Korean Won',
  };

  final Map<String, String> _currencySymbols = {
    'LKR': 'Rs',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'AUD': 'A\$',
    'CAD': 'C\$',
    'INR': '₹',
    'JPY': '¥',
    'CNY': '¥',
    'SGD': 'S\$',
    'MYR': 'RM',
    'THB': '฿',
    'AED': 'د.إ',
    'SAR': '﷼',
    'NZD': 'NZ\$',
    'CHF': 'CHF',
    'SEK': 'kr',
    'NOK': 'kr',
    'DKK': 'kr',
    'KRW': '₩',
  };

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double _convert() {
    final double? amount = double.tryParse(_amountController.text);
    if (amount == null) return 0.0;

    // Convert from -> LKR -> to
    final double inLKR = amount / _exchangeRates[_fromCurrency]!;
    final double result = inLKR * _exchangeRates[_toCurrency]!;

    return result;
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
  }

  List<Map<String, dynamic>> _getCommonConversions() {
    final double? amount = double.tryParse(_amountController.text);
    if (amount == null) return [];

    final List<String> commonCurrencies = ['USD', 'EUR', 'GBP', 'AUD', 'INR', 'JPY'];
    final List<Map<String, dynamic>> conversions = [];

    for (final currency in commonCurrencies) {
      if (currency != _fromCurrency) {
        final double inLKR = amount / _exchangeRates[_fromCurrency]!;
        final double result = inLKR * _exchangeRates[currency]!;

        conversions.add({
          'currency': currency,
          'amount': result,
          'symbol': _currencySymbols[currency],
          'name': _currencyNames[currency],
        });
      }
    }

    return conversions;
  }

  @override
  Widget build(BuildContext context) {
    final convertedAmount = _convert();
    final commonConversions = _getCommonConversions();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
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
                    const Icon(Icons.currency_exchange, size: 40, color: AppConstants.deepOceanBlue),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Offline Currency Converter',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Convert between 20+ currencies',
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

            // Amount input
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'Amount',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.attach_money, size: 30),
                suffixText: _fromCurrency,
                suffixStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 24),

            // From currency
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Text('From', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _fromCurrency,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: _exchangeRates.keys.map((currency) {
                        return DropdownMenuItem(
                          value: currency,
                          child: Row(
                            children: [
                              Text(
                                _currencySymbols[currency]!,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                currency,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _currencyNames[currency]!,
                                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _fromCurrency = value!);
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Swap button
            Center(
              child: IconButton(
                onPressed: _swapCurrencies,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppConstants.deepOceanBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.swap_vert, color: AppConstants.deepOceanBlue, size: 30),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // To currency
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Text('To', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _toCurrency,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: _exchangeRates.keys.map((currency) {
                        return DropdownMenuItem(
                          value: currency,
                          child: Row(
                            children: [
                              Text(
                                _currencySymbols[currency]!,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                currency,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _currencyNames[currency]!,
                                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _toCurrency = value!);
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Result card
            Card(
              color: AppConstants.deepOceanBlue,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                child: Column(
                  children: [
                    Text(
                      _toCurrency,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_currencySymbols[_toCurrency]} ${_formatCurrency(convertedAmount)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_amountController.text} $_fromCurrency = ${_formatCurrency(convertedAmount)} $_toCurrency',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Quick conversions
            if (commonConversions.isNotEmpty) ...[
              const Text(
                'Quick Conversions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              ...commonConversions.map((conversion) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppConstants.tropicalGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          conversion['symbol'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.tropicalGreen,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      conversion['currency'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      conversion['name'],
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    trailing: Text(
                      '${conversion['symbol']} ${_formatCurrency(conversion['amount'])}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: 16),
            ],

            // Exchange rate info
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
                        'Rates are approximate and for reference only. Check current rates before exchanging money.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Useful tips
            Card(
              color: AppConstants.deepOceanBlue.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.tips_and_updates, color: AppConstants.sunsetOrange),
                        SizedBox(width: 8),
                        Text(
                          'Money Tips for Sri Lanka',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildTip('ATMs are widely available in cities and tourist areas'),
                    _buildTip('Credit cards accepted at hotels and large restaurants'),
                    _buildTip('Carry cash for small shops, tuk-tuks, and rural areas'),
                    _buildTip('Exchange money at banks or authorized dealers for best rates'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    // Format to 2 decimal places for most currencies, 0 for JPY and KRW
    final int decimals = (_toCurrency == 'JPY' || _toCurrency == 'KRW') ? 0 : 2;

    return amount.toStringAsFixed(decimals).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
