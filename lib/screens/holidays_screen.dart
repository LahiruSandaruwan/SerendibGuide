import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/holiday.dart';
import '../services/holiday_service.dart';
import '../utils/constants.dart';

/// Screen displaying Sri Lankan public holidays
class HolidaysScreen extends StatefulWidget {
  const HolidaysScreen({super.key});

  @override
  State<HolidaysScreen> createState() => _HolidaysScreenState();
}

class _HolidaysScreenState extends State<HolidaysScreen> with SingleTickerProviderStateMixin {
  final HolidayService _service = HolidayService();

  late TabController _tabController;
  List<Holiday>? _allHolidays;
  List<Holiday>? _upcomingHolidays;
  Holiday? _nextHoliday;
  bool _isLoading = true;
  String? _error;

  int _selectedYear = DateTime.now().year;
  HolidayType? _filterType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadHolidays();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHolidays() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final allHolidays = await _service.getHolidays(year: _selectedYear);
      final upcomingHolidays = await _service.getUpcomingHolidays();
      final nextHoliday = await _service.getNextHoliday();

      if (mounted) {
        setState(() {
          _allHolidays = allHolidays;
          _upcomingHolidays = upcomingHolidays;
          _nextHoliday = nextHoliday;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load holidays';
          _isLoading = false;
        });
      }
    }
  }

  List<Holiday> _getFilteredHolidays() {
    if (_allHolidays == null) return [];
    if (_filterType == null) return _allHolidays!;
    return _allHolidays!.where((h) => h.type == _filterType).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sri Lankan Holidays'),
        backgroundColor: AppConstants.sunsetOrange,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Calendar'),
            Tab(text: 'Poya Info'),
          ],
        ),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _error != null
              ? _buildErrorState()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUpcomingTab(),
                    _buildCalendarTab(),
                    _buildPoyaInfoTab(),
                  ],
                ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading holidays...'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(_error ?? 'Failed to load holidays'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadHolidays,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingTab() {
    final today = DateTime.now();
    final todayHoliday = _allHolidays?.firstWhere(
      (h) => h.isToday,
      orElse: () => Holiday(
        date: today,
        name: '',
        localName: '',
        countryCode: 'LK',
        fixed: true,
        type: HolidayType.publicHoliday,
      ),
    );
    final isTodayHoliday = todayHoliday?.name.isNotEmpty ?? false;

    return RefreshIndicator(
      onRefresh: _loadHolidays,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Today's status
          Card(
            color: isTodayHoliday
                ? AppConstants.successGreen.withOpacity(0.1)
                : AppConstants.deepOceanBlue.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    isTodayHoliday ? Icons.celebration : Icons.calendar_today,
                    size: 40,
                    color: isTodayHoliday
                        ? AppConstants.successGreen
                        : AppConstants.deepOceanBlue,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE, MMMM d, y').format(today),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isTodayHoliday
                              ? '🎉 Today is ${todayHoliday!.name}!'
                              : 'Not a public holiday today',
                          style: TextStyle(
                            fontSize: 14,
                            color: isTodayHoliday
                                ? AppConstants.successGreen
                                : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Next holiday
          if (_nextHoliday != null && !_nextHoliday!.isToday) ...[
            Text(
              'Next Holiday',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildNextHolidayCard(_nextHoliday!),
            const SizedBox(height: 24),
          ],

          // Upcoming holidays
          if (_upcomingHolidays != null && _upcomingHolidays!.isNotEmpty) ...[
            Text(
              'Upcoming (Next 90 Days)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...(_upcomingHolidays!
                .where((h) => !h.isToday)
                .map((holiday) => _buildHolidayCard(holiday))),
          ] else ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No upcoming holidays in the next 90 days'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNextHolidayCard(Holiday holiday) {
    final daysUntil = holiday.daysUntil;

    return Card(
      elevation: 4,
      color: AppConstants.sunsetOrange.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  holiday.icon,
                  style: const TextStyle(fontSize: 36),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        holiday.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (holiday.localName != holiday.name)
                        Text(
                          holiday.localName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEEE, MMMM d, y').format(holiday.date),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppConstants.deepOceanBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppConstants.sunsetOrange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                daysUntil == 0
                    ? 'Today!'
                    : daysUntil == 1
                        ? 'Tomorrow'
                        : 'in $daysUntil days',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            if (holiday.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                holiday.description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHolidayCard(Holiday holiday) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Text(
          holiday.icon,
          style: const TextStyle(fontSize: 32),
        ),
        title: Text(
          holiday.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (holiday.localName != holiday.name)
              Text(
                holiday.localName,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            const SizedBox(height: 4),
            Text(
              DateFormat('EEEE, MMM d').format(holiday.date),
              style: const TextStyle(color: AppConstants.deepOceanBlue),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getTypeColor(holiday.type).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                holiday.type.displayName,
                style: TextStyle(
                  fontSize: 10,
                  color: _getTypeColor(holiday.type),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${holiday.daysUntil}d',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarTab() {
    final filteredHolidays = _getFilteredHolidays();
    final holidaysByMonth = <int, List<Holiday>>{};

    for (final holiday in filteredHolidays) {
      holidaysByMonth.putIfAbsent(holiday.date.month, () => []).add(holiday);
    }

    return Column(
      children: [
        // Year selector and filter
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Row(
            children: [
              // Year selector
              Expanded(
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        setState(() {
                          _selectedYear--;
                          _loadHolidays();
                        });
                      },
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          _selectedYear.toString(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        setState(() {
                          _selectedYear++;
                          _loadHolidays();
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Filter dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButton<HolidayType?>(
                  value: _filterType,
                  underline: const SizedBox(),
                  hint: const Text('Filter', style: TextStyle(fontSize: 14)),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Types', style: TextStyle(fontSize: 14)),
                    ),
                    ...HolidayType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(
                          _getTypeDisplay(type),
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => _filterType = value);
                  },
                ),
              ),
            ],
          ),
        ),

        // Summary
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                '${filteredHolidays.length}',
                'Total Holidays',
                Icons.calendar_month,
              ),
              Container(width: 1, height: 40, color: Colors.grey[300]),
              _buildSummaryItem(
                '${filteredHolidays.where((h) => h.type == HolidayType.publicHoliday).length}',
                'Public',
                Icons.public,
              ),
              Container(width: 1, height: 40, color: Colors.grey[300]),
              _buildSummaryItem(
                '${filteredHolidays.where((h) => h.name.contains('Poya')).length}',
                'Poya Days',
                Icons.brightness_2,
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Holidays by month
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 12,
            itemBuilder: (context, index) {
              final month = index + 1;
              final monthHolidays = holidaysByMonth[month] ?? [];

              if (monthHolidays.isEmpty) return const SizedBox();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      DateFormat('MMMM').format(DateTime(_selectedYear, month)),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.deepOceanBlue,
                      ),
                    ),
                  ),
                  ...monthHolidays.map((holiday) => _buildCalendarHolidayRow(holiday)),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppConstants.deepOceanBlue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppConstants.sunsetOrange,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarHolidayRow(Holiday holiday) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Date box
          Container(
            width: 50,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getTypeColor(holiday.type).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('MMM').format(holiday.date),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _getTypeColor(holiday.type),
                  ),
                ),
                Text(
                  holiday.date.day.toString(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _getTypeColor(holiday.type),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(holiday.icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        holiday.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (holiday.localName != holiday.name) ...[
                  const SizedBox(height: 2),
                  Text(
                    holiday.localName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE').format(holiday.date),
                  style: TextStyle(
                    fontSize: 11,
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

  Widget _buildPoyaInfoTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Info card
        Card(
          color: AppConstants.deepOceanBlue.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🌕', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Poya Days in Sri Lanka',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppConstants.deepOceanBlue,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Poya days are Buddhist full moon observance days, occurring monthly. '
                  'These are public holidays throughout Sri Lanka.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Monthly Poya days
        Text(
          'Monthly Poya Days',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),

        ...SriLankanHolidays.monthlyPoyaDays.map((poya) {
          final parts = poya.split(' - ');
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppConstants.deepOceanBlue,
                child: Text('🌕', style: TextStyle(fontSize: 20)),
              ),
              title: Text(
                parts[1],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(parts[0]),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          );
        }),

        const SizedBox(height: 24),

        // What to expect
        Text(
          'What to Expect on Poya Days',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),

        _buildInfoItem(
          '🏦',
          'Banks & Government Offices',
          'Most banks and government offices are closed.',
        ),
        _buildInfoItem(
          '🍺',
          'Alcohol Sales',
          'Sale of alcohol is prohibited on Poya days.',
        ),
        _buildInfoItem(
          '🎵',
          'Entertainment',
          'Many entertainment venues may be closed or have limited hours.',
        ),
        _buildInfoItem(
          '🛕',
          'Temple Visits',
          'Locals visit temples to observe religious activities.',
        ),
        _buildInfoItem(
          '🏪',
          'Shops & Restaurants',
          'Most shops and tourist restaurants remain open.',
        ),
        _buildInfoItem(
          '🏖️',
          'Tourist Attractions',
          'Tourist sites and attractions are typically open.',
        ),

        const SizedBox(height: 24),

        // Travel tip
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppConstants.warningAmber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppConstants.warningAmber.withOpacity(0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.lightbulb,
                color: AppConstants.warningAmber,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Travel Tip',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.warningAmber,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Plan ahead for Poya days. Stock up on essentials if needed, '
                      'and be respectful of local customs. It\'s a great opportunity '
                      'to experience Sri Lankan Buddhist culture!',
                      style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(HolidayType type) {
    switch (type) {
      case HolidayType.publicHoliday:
        return AppConstants.successGreen;
      case HolidayType.bankHoliday:
        return AppConstants.deepOceanBlue;
      case HolidayType.religious:
        return AppConstants.ancientBrown;
      case HolidayType.observance:
        return AppConstants.warningAmber;
    }
  }

  String _getTypeDisplay(HolidayType type) {
    switch (type) {
      case HolidayType.publicHoliday:
        return 'Public Holiday';
      case HolidayType.bankHoliday:
        return 'Bank Holiday';
      case HolidayType.religious:
        return 'Religious Day';
      case HolidayType.observance:
        return 'Observance';
    }
  }
}
