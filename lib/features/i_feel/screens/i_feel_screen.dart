import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/icons/app_icons.dart';
import 'package:tickdose/features/i_feel/screens/i_feel_chat_screen.dart';
import 'package:tickdose/features/i_feel/screens/i_feel_voice_screen.dart';
import 'package:tickdose/features/i_feel/widgets/emergency_sheet.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';
import 'package:tickdose/features/navigation/routes/route_names.dart';

class IFeelScreen extends ConsumerStatefulWidget {
  final int initialIndex;
  
  const IFeelScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<IFeelScreen> createState() => _IFeelScreenState();
}

class _IFeelScreenState extends ConsumerState<IFeelScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onTogglePressed(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      resizeToAvoidBottomInset: true, // Important for keyboard
      appBar: AppBar(
        centerTitle: true,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceColor(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.borderLight(context),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildToggleOption(l10n.text, 0),
              _buildToggleOption(l10n.voice, 1),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(AppIcons.history()),
            onPressed: () => Navigator.pushNamed(context, Routes.iFeelHistory),
            tooltip: l10n.history,
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: const [
          IFeelChatScreen(isEmbedded: true),
          IFeelVoiceScreen(isEmbedded: true),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70), // Lift above input areas if needed, though they are inside body. 
        // Actually, with resizeToAvoidBottomInset: true, the FAB moves up with keyboard.
        // But the input field is at bottom of pageview.
        // Standard FAB position is fine.
        child: FloatingActionButton.extended(
          onPressed: () => EmergencySheet.show(context, ref),
          backgroundColor: AppColors.errorRed,
          icon: Icon(AppIcons.emergency()),
          label: Text(l10n.emergency),
          heroTag: 'emergency_fab_shared',
        ),
      ),
    );
  }

  Widget _buildToggleOption(String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTogglePressed(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isSelected ? AppColors.darkTextPrimary : AppColors.textSecondary(context),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
