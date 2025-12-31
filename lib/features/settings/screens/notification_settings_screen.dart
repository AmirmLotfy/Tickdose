import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/icons/app_icons.dart';
import 'package:tickdose/features/profile/providers/settings_provider.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  Future<void> _showQuietHoursPicker(BuildContext context, WidgetRef ref) async {
    final settings = ref.read(settingsProvider);
    
    // Parse current times
    final startParts = settings.quietHoursStart.split(':');
    final endParts = settings.quietHoursEnd.split(':');
    
    TimeOfDay? startTime = TimeOfDay(
      hour: int.parse(startParts[0]),
      minute: int.parse(startParts[1]),
    );
    
    TimeOfDay? endTime = TimeOfDay(
      hour: int.parse(endParts[0]),
      minute: int.parse(endParts[1]),
    );

    // Show dialog
    final result = await showDialog<Map<String, TimeOfDay>>(
      context: context,
      builder: (context) => _QuietHoursDialog(startTime: startTime, endTime: endTime),
    );

    if (result != null) {
      final start = result['start']!;
      final end = result['end']!;
      
      final startStr = '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
      final endStr = '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
      
      await ref.read(settingsProvider.notifier).setQuietHours(startStr, endStr);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Settings', style: TextStyle(color: AppColors.textPrimary(context))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Receive medicine reminders'),
            value: settings.notificationsEnabled,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleNotifications(value);
            },
          ),
          SwitchListTile(
            title: const Text('Sound'),
            subtitle: const Text('Play sound with notifications'),
            value: settings.soundEnabled,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleSound(value);
            },
          ),
          SwitchListTile(
            title: const Text('Vibration'),
            subtitle: const Text('Vibrate with notifications'),
            value: settings.vibrationEnabled,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleVibration(value);
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Quiet Hours'),
            subtitle: Text('${settings.quietHoursStart} - ${settings.quietHoursEnd}'),
            trailing: AppIcons.themedIcon(context, AppIcons.chevronRight(), autoMirror: true),
            enabled: settings.notificationsEnabled,
            onTap: () => _showQuietHoursPicker(context, ref),
          ),
        ],
      ),
    );
  }
}

class _QuietHoursDialog extends StatefulWidget {
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const _QuietHoursDialog({required this.startTime, required this.endTime});

  @override
  State<_QuietHoursDialog> createState() => _QuietHoursDialogState();
}

class _QuietHoursDialogState extends State<_QuietHoursDialog> {
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    _startTime = widget.startTime;
    _endTime = widget.endTime;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Quiet Hours'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Start Time'),
            subtitle: Text(_startTime.format(context)),
            trailing: Icon(AppIcons.time()),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _startTime,
              );
              if (time != null) {
                setState(() => _startTime = time);
              }
            },
          ),
          ListTile(
            title: const Text('End Time'),
            subtitle: Text(_endTime.format(context)),
            trailing: Icon(AppIcons.time()),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _endTime,
              );
              if (time != null) {
                setState(() => _endTime = time);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, {'start': _startTime, 'end': _endTime});
          },
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }
}
