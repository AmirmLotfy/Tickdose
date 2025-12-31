import 'package:flutter/material.dart';
import '../../navigation/widgets/bottom_nav_bar.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'today_screen.dart';
import 'package:tickdose/features/reminders/screens/reminders_screen.dart';
import 'package:tickdose/features/tracking/screens/tracking_screen.dart';
import 'package:tickdose/features/pharmacy/screens/pharmacy_finder_screen.dart';
import 'package:tickdose/features/profile/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tickdose/core/services/remote_command_service.dart';
import 'package:tickdose/features/navigation/routes/route_names.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  User? _currentUser;
  final RemoteCommandService _remoteCommandService = RemoteCommandService();

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      _remoteCommandService.listenForCommands(_currentUser!.uid);
    }
  }

  @override
  void dispose() {
    _remoteCommandService.dispose();
    super.dispose();
  }

  final List<Widget> _screens = [
    const TodayScreen(),
    const RemindersScreen(),
    const TrackingScreen(),
    const PharmacyFinderScreen(),
    const ProfileScreen(),
  ];



  void _onQuickAdd() {
    // Show quick add modal or navigate directly to add medicine
    // For now, let's navigate to Add Medicine as priority
    Navigator.pushNamed(context, Routes.addMedicine);
  }

  @override
  Widget build(BuildContext context) {
    // final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      extendBody: true, // Allows content to scroll behind the floating nav bar
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100.0), // Adjusted for new floating nav bar
        child: FloatingActionButton(
          onPressed: _onQuickAdd,
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: const CircleBorder(),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.add_rounded,
              color: AppColors.textPrimary(context),
              size: 30,
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
