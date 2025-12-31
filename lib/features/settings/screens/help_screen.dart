import 'package:flutter/material.dart';
import '../../../core/icons/app_icons.dart';
import '../../../core/theme/app_theme.dart';
import 'help_detail_screen.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildHelpSection(
            context,
            'Getting Started',
            [
              'How to add your first medicine',
              'Setting up reminders',
              'Understanding notifications',
            ],
          ),
          _buildHelpSection(
            context,
            'Medications',
            [
              'Adding medicine details',
              'Setting dosage and frequency',
              'Refill reminders',
            ],
          ),
          _buildHelpSection(
            context,
            'Tracking',
            [
              'Viewing adherence statistics',
              'Understanding your reports',
              'Export data',
            ],
          ),
          _buildHelpSection(
            context,
            'Account & Privacy',
            [
              'Managing your account',
              'Privacy settings',
              'Data backup',
            ],
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Need more help?'),
                SizedBox(height: 8),
                Text(
                  'Contact us at support@tickdose.app',
                  style: TextStyle(color: AppColors.primaryBlue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(BuildContext context, String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...items.map((item) => ListTile(
              leading: Icon(AppIcons.help()),
              title: Text(item),
              trailing: AppIcons.themedIcon(context, AppIcons.chevronRight(), autoMirror: true),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HelpDetailScreen(
                      title: item,
                      content: 'Detailed information about "$item" will be available here soon.\n\nFor immediate assistance, please contact support.',
                    ),
                  ),
                );
              },
            )),
        const Divider(),
      ],
    );
  }
}

