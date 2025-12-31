import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/services/timezone_monitor_service.dart';
import 'package:tickdose/core/utils/logger.dart';
import 'package:tickdose/features/profile/providers/profile_provider.dart';

class TimezoneSettingsScreen extends ConsumerStatefulWidget {
  const TimezoneSettingsScreen({super.key});

  @override
  ConsumerState<TimezoneSettingsScreen> createState() => _TimezoneSettingsScreenState();
}

class _TimezoneSettingsScreenState extends ConsumerState<TimezoneSettingsScreen> {
  String? _selectedTimezone;
  bool _autoDetect = true;
  List<String> _popularTimezones = [];
  List<String> _allTimezones = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUserTimezone();
    _loadTimezones();
    
    // Listen to timezone changes
    TimezoneMonitorService().timezoneChanges.listen((newTimezone) {
      if (mounted) {
        setState(() {
          _selectedTimezone = newTimezone;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Timezone changed to $newTimezone. Reminders will be updated.'),
            backgroundColor: AppColors.infoBlue,
          ),
        );
      }
    });
  }

  void _loadUserTimezone() {
    final userAsync = ref.read(userProfileProvider);
    userAsync.whenData((user) {
      if (user != null) {
        setState(() {
          _selectedTimezone = user.timezone;
          _autoDetect = user.timezoneAutoDetect;
        });
      }
    });
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
      
      return '$timezone (UTC$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')})';
    } catch (e) {
      return timezone;
    }
  }

  Future<void> _saveTimezone() async {
    final userAsync = ref.read(userProfileProvider);
    userAsync.whenData((user) async {
      if (user != null && _selectedTimezone != null) {
        try {
          await ref.read(profileControllerProvider.notifier).updateProfile(
            user.copyWith(
              timezone: _selectedTimezone!,
              timezoneAutoDetect: _autoDetect,
            ),
          );
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Timezone settings saved'),
                backgroundColor: AppColors.successGreen,
              ),
            );
          }
        } catch (e) {
          Logger.error('Error saving timezone: $e', tag: 'TimezoneSettings');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error saving timezone: $e'),
                backgroundColor: AppColors.errorRed,
              ),
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timezone Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('No user data'));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Timezone Configuration',
                style: AppTextStyles.h2(context),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your timezone settings for accurate reminder scheduling.',
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Current timezone display
              Card(
                child: ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Current Timezone'),
                  subtitle: Text(_formatTimezone(user.timezone)),
                ),
              ),
              const SizedBox(height: 16),

              // Auto-detect toggle
              Card(
                child: SwitchListTile(
                  title: const Text('Use device timezone automatically'),
                  subtitle: Text(
                    _autoDetect
                        ? 'Timezone will update automatically when you travel'
                        : 'Manual timezone selection',
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 12,
                    ),
                  ),
                  value: _autoDetect,
                  onChanged: (value) {
                    setState(() {
                      _autoDetect = value;
                      if (value) {
                        _selectedTimezone = TimezoneMonitorService().getCurrentTimezone();
                        _saveTimezone();
                      }
                    });
                  },
                  activeThumbColor: AppColors.primaryBlue,
                ),
              ),

              if (!_autoDetect) ...[
                const SizedBox(height: 16),
                Text(
                  'Select Timezone',
                  style: AppTextStyles.h3(context),
                ),
                const SizedBox(height: 12),
                
                // Search field
                TextField(
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
                const SizedBox(height: 16),
                
                // Timezone list
                Container(
                  constraints: const BoxConstraints(maxHeight: 400),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.borderLight(context),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                        selectedTileColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle,
                                color: AppColors.primaryBlue,
                              )
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedTimezone = timezone;
                          });
                          _saveTimezone();
                        },
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Test timezone change button
              Card(
                child: ListTile(
                  leading: const Icon(Icons.bug_report),
                  title: const Text('Test Timezone Change'),
                  subtitle: const Text('Simulate a timezone change for testing'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Simulate timezone change (for testing)
                    final testTimezones = ['Africa/Cairo', 'Europe/London', 'America/New_York'];
                    final currentIndex = testTimezones.indexOf(_selectedTimezone ?? '');
                    final nextIndex = (currentIndex + 1) % testTimezones.length;
                    
                    setState(() {
                      _selectedTimezone = testTimezones[nextIndex];
                    });
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Test: Timezone changed to ${testTimezones[nextIndex]}'),
                        backgroundColor: AppColors.infoBlue,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
