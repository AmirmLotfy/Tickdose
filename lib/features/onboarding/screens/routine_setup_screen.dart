import 'package:flutter/material.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';

class RoutineSetupScreen extends StatefulWidget {
  final int currentStep;
  final int totalSteps;
  
  const RoutineSetupScreen({
    super.key,
    this.currentStep = 3,
    this.totalSteps = 5,
  });

  @override
  State<RoutineSetupScreen> createState() => _RoutineSetupScreenState();
}

class _RoutineSetupScreenState extends State<RoutineSetupScreen> {
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _bedtime = const TimeOfDay(hour: 22, minute: 30);
  bool _isEditingBedtime = false;

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  // Format time as HH:mm for UserModel (24-hour format)
  String _formatTime24Hour(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatTimeShort(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Duration _calculateSleepDuration() {
    var wake = _wakeTime.hour * 60 + _wakeTime.minute;
    var bed = _bedtime.hour * 60 + _bedtime.minute;
    
    if (bed < wake) {
      bed += 24 * 60; // Next day
    }
    
    final duration = bed - wake;
    return Duration(minutes: duration);
  }

  String _formatSleepDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  Future<void> _selectTime(BuildContext context, TimeOfDay currentTime, Function(TimeOfDay) onTimeSelected) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryGreen,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onTimeSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (widget.currentStep / widget.totalSteps) * 100;
    final sleepDuration = _calculateSleepDuration();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            // Progress Bar
            _buildProgressBar(context, progress),
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Headline
                    Text(
                      AppLocalizations.of(context)!.defineActiveHours,
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Body Text
                    Text(
                      AppLocalizations.of(context)!.wakeWindowReminders,
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Sleep Goal Visualization
                    _buildSleepGoalVisualization(context, sleepDuration),
                    const SizedBox(height: 32),
                    // Wake Up Card
                    _buildWakeUpCard(context),
                    const SizedBox(height: 16),
                    // Bedtime Card
                    _buildBedtimeCard(context),
                    const SizedBox(height: 100), // Space for bottom button
                  ],
                ),
              ),
            ),
            // Sticky Bottom Button
            _buildContinueButton(context),
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
            icon: const Icon(Icons.arrow_back, size: 24),
            onPressed: () => Navigator.pop(context),
            color: AppColors.textSecondary(context),
          ),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.routineSetup,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, null);
            },
            child: Text(
              AppLocalizations.of(context)!.skip,
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${widget.currentStep} of ${widget.totalSteps}',
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${progress.toInt()}% Completed',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.borderLight(context),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepGoalVisualization(BuildContext context, Duration sleepDuration) {
    return Center(
      child: Container(
        width: 192,
        height: 192,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.borderLight(context)
                : AppColors.surfaceColor(context),
            width: 4,
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryGreen.withValues(alpha: 0.1),
              Colors.transparent,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative border arc
            Positioned.fill(
              child: CustomPaint(
                painter: _ArcPainter(),
              ),
            ),
            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bedtime,
                    color: AppColors.primaryGreen,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'SLEEP GOAL',
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatSleepDuration(sleepDuration),
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWakeUpCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectTime(
        context,
        _wakeTime,
        (time) => setState(() => _wakeTime = time),
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.cardColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.transparent,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.warningOrange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.wb_sunny,
                  color: AppColors.warningOrange,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.wakeUp,
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(text: _formatTimeShort(_wakeTime)),
                          TextSpan(
                            text: ' ${_wakeTime.period == DayPeriod.am ? 'AM' : 'PM'}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: AppColors.textSecondary(context),
                ),
                onPressed: () => _selectTime(
                  context,
                  _wakeTime,
                  (time) => setState(() => _wakeTime = time),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBedtimeCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _isEditingBedtime = true);
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.cardColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryGreen,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryPurple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.dark_mode,
                      color: AppColors.secondaryPurple,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.bedtime,
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: AppColors.textPrimary(context),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(text: _formatTimeShort(_bedtime)),
                              TextSpan(
                                text: ' ${_bedtime.period == DayPeriod.am ? 'AM' : 'PM'}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.check_circle,
                    color: AppColors.primaryGreen,
                    size: 24,
                  ),
                ],
              ),
            ),
            // Inline Time Picker Visualization
            if (_isEditingBedtime)
              Container(
                height: 128,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkBackground.withValues(alpha: 0.2)
                      : AppColors.borderLight(context).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTimePickerColumn(context, _bedtime.hourOfPeriod, 1, 12, (value) {
                      setState(() {
                        _bedtime = TimeOfDay(
                          hour: _bedtime.period == DayPeriod.am
                              ? (value == 12 ? 0 : value)
                              : (value == 12 ? 12 : value + 12),
                          minute: _bedtime.minute,
                        );
                      });
                    }),
                    const SizedBox(width: 8),
                    Text(
                      ':',
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildTimePickerColumn(context, _bedtime.minute, 0, 59, (value) {
                      setState(() {
                        _bedtime = TimeOfDay(
                          hour: _bedtime.hour,
                          minute: value,
                        );
                      });
                    }),
                    const SizedBox(width: 8),
                    _buildTimePickerColumn(context, _bedtime.period == DayPeriod.am ? 0 : 1, 0, 1, (value) {
                      setState(() {
                        final newPeriod = value == 0 ? DayPeriod.am : DayPeriod.pm;
                        _bedtime = TimeOfDay(
                          hour: _bedtime.hour,
                          minute: _bedtime.minute,
                        );
                        // Adjust hour for AM/PM
                        if (newPeriod != _bedtime.period) {
                          if (newPeriod == DayPeriod.pm && _bedtime.hour < 12) {
                            _bedtime = TimeOfDay(hour: _bedtime.hour + 12, minute: _bedtime.minute);
                          } else if (newPeriod == DayPeriod.am && _bedtime.hour >= 12) {
                            _bedtime = TimeOfDay(hour: _bedtime.hour - 12, minute: _bedtime.minute);
                          }
                        }
                      });
                    }, labels: ['AM', 'PM']),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickerColumn(
    BuildContext context,
    int currentValue,
    int min,
    int max,
    Function(int) onChanged, {
    List<String>? labels,
  }) {
    return Expanded(
      child: ListWheelScrollView.useDelegate(
        itemExtent: 40,
        diameterRatio: 1.5,
        physics: const FixedExtentScrollPhysics(),
        controller: FixedExtentScrollController(initialItem: currentValue - min),
        onSelectedItemChanged: (index) {
          onChanged(min + index);
        },
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            if (index < 0 || index > max - min) return const SizedBox();
            final value = min + index;
            final isSelected = value == currentValue;
            final displayText = labels != null && index < labels.length
                ? labels[index]
                : value.toString().padLeft(2, '0');
            
            return Center(
              child: Text(
                displayText,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.textPrimary(context)
                      : AppColors.textSecondary(context).withValues(alpha: 0.4),
                  fontSize: isSelected ? 24 : 20,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            );
          },
          childCount: max - min + 1,
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
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
              color: AppColors.primaryGreen.withValues(alpha: 0.25),
              blurRadius: 14,
              spreadRadius: 0,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'wakeTime': _formatTime24Hour(_wakeTime),
              'bedtime': _formatTime24Hour(_bedtime),
            });
          },
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
              Text(
                AppLocalizations.of(context)!.continueButton,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward,
                size: 18,
                color: AppColors.backgroundColor(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryGreen.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawArc(
      rect,
      -0.785, // -45 degrees in radians
      1.57, // 90 degrees in radians
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
