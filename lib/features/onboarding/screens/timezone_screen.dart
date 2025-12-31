import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/services/timezone_monitor_service.dart';
import 'package:tickdose/core/utils/logger.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';

class TimezoneScreen extends ConsumerStatefulWidget {
  final int currentStep;
  final int totalSteps;
  
  const TimezoneScreen({
    super.key,
    this.currentStep = 3,
    this.totalSteps = 5,
  });

  @override
  ConsumerState<TimezoneScreen> createState() => _TimezoneScreenState();
}

class _TimezoneScreenState extends ConsumerState<TimezoneScreen> {
  String? _selectedTimezone;
  bool _isLoading = true;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initializeTimezone();
    // Update time every second
    _updateTime();
  }

  void _updateTime() {
    if (mounted) {
      setState(() {
        _currentTime = DateTime.now();
      });
      Future.delayed(const Duration(seconds: 1), _updateTime);
    }
  }

  Future<void> _initializeTimezone() async {
    setState(() => _isLoading = true);
    
    try {
      final currentTimezone = TimezoneMonitorService().getCurrentTimezone();
      setState(() {
        _selectedTimezone = currentTimezone;
        _isLoading = false;
      });
    } catch (e) {
      Logger.error('Error initializing timezone: $e', tag: 'TimezoneScreen');
      setState(() {
        _selectedTimezone = 'UTC';
        _isLoading = false;
      });
    }
  }

  String _formatTimezone(String timezone) {
    try {
      final location = tz.getLocation(timezone);
      final now = tz.TZDateTime.now(location);
      final offset = now.timeZoneOffset;
      final hours = offset.inHours;
      final minutes = (offset.inMinutes % 60).abs();
      final sign = offset.isNegative ? '-' : '+';
      
      // Get timezone abbreviation if available
      final abbreviation = _getTimezoneAbbreviation(timezone);
      
      return 'GMT$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}${abbreviation != null ? ' ($abbreviation)' : ''}';
    } catch (e) {
      return timezone;
    }
  }

  String? _getTimezoneAbbreviation(String timezone) {
    // Common timezone abbreviations
    final abbreviations = {
      'America/Los_Angeles': 'PDT',
      'America/New_York': 'EDT',
      'Europe/London': 'GMT',
      'Europe/Paris': 'CET',
      'Asia/Tokyo': 'JST',
      'Asia/Dubai': 'GST',
      'Australia/Sydney': 'AEDT',
    };
    return abbreviations[timezone];
  }

  String _getTimezoneDisplayName(String timezone) {
    // Extract city and country from timezone string
    final parts = timezone.split('/');
    if (parts.length >= 2) {
      final city = parts.last.replaceAll('_', ' ');
      final region = parts[0];
      
      // Map regions to country names
      final countryMap = {
        'America': 'USA',
        'Europe': 'Europe',
        'Asia': 'Asia',
        'Africa': 'Africa',
        'Australia': 'Australia',
      };
      
      final country = countryMap[region] ?? region;
      return '$city, $country';
    }
    return timezone;
  }

  Future<void> _showTimezonePicker() async {
    final timezone = await showDialog<String>(
      context: context,
      builder: (context) => _TimezonePickerDialog(
        currentTimezone: _selectedTimezone ?? 'UTC',
      ),
    );
    
    if (timezone != null) {
      setState(() {
        _selectedTimezone = timezone;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundColor(context),
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryGreen,
          ),
        ),
      );
    }

    final timeFormat = DateFormat('hh:mm');
    final periodFormat = DateFormat('a');
    final currentTimeStr = timeFormat.format(_currentTime);
    final periodStr = periodFormat.format(_currentTime);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    // Hero Illustration
                    _buildHeroIllustration(context),
                    const SizedBox(height: 32),
                    // Headline
                    Text(
                      'Where are you based?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Body Text
                    Text(
                      'We use your local time to ensure your reminders arrive exactly when you need them.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Current Time Display
                    _buildCurrentTimeDisplay(context, currentTimeStr, periodStr),
                    const SizedBox(height: 32),
                    // Timezone Selector Card
                    _buildTimezoneSelectorCard(context),
                    const SizedBox(height: 16),
                    // Map Preview
                    _buildMapPreview(context),
                    const SizedBox(height: 100), // Space for bottom button
                  ],
                ),
              ),
            ),
            // Sticky Footer
            _buildFooterButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
            color: AppColors.textPrimary(context),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.shadowColorLight(context),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.totalSteps, (index) {
                final isActive = index == widget.currentStep - 1;
                return Container(
                  width: isActive ? 32 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primaryGreen
                        : AppColors.borderLight(context),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.primaryGreen.withValues(alpha: 0.5),
                              blurRadius: 10,
                            ),
                          ]
                        : null,
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 48), // Spacer for balance
        ],
      ),
    );
  }

  Widget _buildHeroIllustration(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow effect
        Container(
          width: 192,
          height: 192,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
        ),
        // Globe container
        Container(
          width: 192,
          height: 192,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.borderLight(context),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor(context),
                blurRadius: 20,
              ),
            ],
          ),
          child: ClipOval(
            child: Container(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              child: Icon(
                Icons.public,
                size: 96,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentTimeDisplay(BuildContext context, String time, String period) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.currentTimeDetected,
          style: TextStyle(
            color: AppColors.primaryGreen,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              time,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 64,
                fontWeight: FontWeight.w800,
                height: 1,
                fontFeatures: [const FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 4),
            Text(
              period,
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimezoneSelectorCard(BuildContext context) {
    if (_selectedTimezone == null) return const SizedBox();
    
    return GestureDetector(
      onTap: _showTimezonePicker,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.borderLight(context)
                : AppColors.borderLight(context),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColorLight(context),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.public,
                color: AppColors.primaryGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Region',
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getTimezoneDisplayName(_selectedTimezone!),
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTimezone(_selectedTimezone!),
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.edit,
              color: AppColors.textSecondary(context),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPreview(BuildContext context) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderLight(context),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Container(
              color: AppColors.surfaceColor(context),
              child: Center(
                child: Icon(
                  Icons.map,
                  size: 48,
                  color: AppColors.textSecondary(context).withValues(alpha: 0.3),
                ),
              ),
            ),
            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.backgroundColor(context).withValues(alpha: 0.9),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            AppColors.backgroundColor(context),
            AppColors.backgroundColor(context).withValues(alpha: 0.0),
          ],
          stops: const [0.8, 1.0],
        ),
      ),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _selectedTimezone != null
              ? () {
                  Navigator.pop(context, {
                    'timezone': _selectedTimezone,
                    'autoDetect': false,
                  });
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: AppColors.backgroundColor(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Confirm & Continue',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.check,
                size: 20,
                color: AppColors.backgroundColor(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimezonePickerDialog extends StatefulWidget {
  final String currentTimezone;

  const _TimezonePickerDialog({required this.currentTimezone});

  @override
  State<_TimezonePickerDialog> createState() => _TimezonePickerDialogState();
}

class _TimezonePickerDialogState extends State<_TimezonePickerDialog> {
  String _searchQuery = '';
  String? _selectedTimezone;
  List<String> _popularTimezones = [];
  List<String> _allTimezones = [];

  @override
  void initState() {
    super.initState();
    _selectedTimezone = widget.currentTimezone;
    _loadTimezones();
  }

  void _loadTimezones() {
    _popularTimezones = [
      'Africa/Cairo',
      'America/New_York',
      'America/Los_Angeles',
      'Europe/London',
      'Europe/Paris',
      'Asia/Dubai',
      'Asia/Tokyo',
      'Asia/Shanghai',
      'Australia/Sydney',
      'UTC',
    ];

    _allTimezones = tz.timeZoneDatabase.locations.keys.toList()..sort();
  }

  List<String> get _filteredTimezones {
    if (_searchQuery.isEmpty) {
      return _popularTimezones;
    }
    return _allTimezones
        .where((tz) => tz.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  String _formatTimezone(String timezone) {
    try {
      final location = tz.getLocation(timezone);
      final now = tz.TZDateTime.now(location);
      final offset = now.timeZoneOffset;
      final hours = offset.inHours;
      final minutes = (offset.inMinutes % 60).abs();
      final sign = offset.isNegative ? '-' : '+';
      return 'GMT$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    } catch (e) {
      return timezone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.backgroundColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.selectTimezone,
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    color: AppColors.textSecondary(context),
                  ),
                ],
              ),
            ),
            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search timezones...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            // List
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredTimezones.length,
                itemBuilder: (context, index) {
                  final timezone = _filteredTimezones[index];
                  final isSelected = _selectedTimezone == timezone;
                  
                  return ListTile(
                    title: Text(timezone),
                    subtitle: Text(_formatTimezone(timezone)),
                    selected: isSelected,
                    selectedTileColor: AppColors.primaryGreen.withValues(alpha: 0.1),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: AppColors.primaryGreen,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedTimezone = timezone;
                      });
                      Navigator.pop(context, timezone);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
