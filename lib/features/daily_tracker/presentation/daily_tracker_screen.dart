import 'package:disabilitymne/core/theme/app_colors.dart';
import 'package:disabilitymne/features/daily_tracker/controller/daily_tracker_controller.dart';
import 'package:disabilitymne/features/daily_tracker/model/daily_tracker_model.dart';
import 'package:disabilitymne/features/daily_tracker/repository/daily_tracker_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Daily Tracker screen.
///
/// UI mapping: days[0]=Mon, days[1]=Tue, ..., days[6]=Sun.
/// Highlights today and selected day. Week navigation via arrows.
class DailyTrackerScreen extends StatefulWidget {
  const DailyTrackerScreen({super.key});

  @override
  State<DailyTrackerScreen> createState() => _DailyTrackerScreenState();
}

class _DailyTrackerScreenState extends State<DailyTrackerScreen> {
  late final DailyTrackerController controller;
  final notesController = TextEditingController();

  static const Color _screenBg = Color(0xFF0B1A2A);
  static const Color _cardBg = Color(0xFF2A4360);
  static const Color _checkboxCheckedGreen = Color(0xFF27BE69);
  static const Color _checkboxUncheckedBorder = Color(0xFF696D73);
  static const Color _addNotesBtnStart = Color(0xFF4B7FA8);
  static const Color _addNotesBtnEnd = Color(0xFF3A6390);
  static const Color _inputBg = Color(0xFF1C2533);
  static const Color _hintColor = Color(0xFFA0A8B7);
  static const Color _borderColor = Color(0xFF5B8FB7);
  static const Color _dividerColor = Color(0xFF696D73);

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      DailyTrackerController(Get.find<DailyTrackerRepository>()),
    );
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _screenBg,
      appBar: AppBar(
        backgroundColor: _screenBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 22),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Daily Tracker',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          return RefreshIndicator(
            onRefresh: controller.fetchDailyTracker,
            color: Colors.white,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (controller.errorMessage.value != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Text(
                        controller.errorMessage.value!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  // _buildWeekNavigation(),
                  const SizedBox(height: 16),
                  _buildHabitCard(),
                  const SizedBox(height: 24),
                  _buildNotesSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // Widget _buildWeekNavigation() {
  //   return Obx(() {
  //     final weekDays = controller.weekDays;
  //     return Container(
  //       padding: const EdgeInsets.all(16),
  //       decoration: BoxDecoration(
  //         color: _cardBg,
  //         borderRadius: BorderRadius.circular(16),
  //         border: Border.all(color: _borderColor, width: 1),
  //       ),
  //       child: Column(
  //         children: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               IconButton(
  //                 icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
  //                 onPressed: controller.goToPreviousWeek,
  //               ),
  //               Text(
  //                 'Week ${controller.weekNumber > 0 ? controller.weekNumber : ''}',
  //                 style: const TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.w600,
  //                 ),
  //               ),
  //               IconButton(
  //                 icon: const Icon(Icons.chevron_right, color: Colors.white, size: 28),
  //                 onPressed: controller.goToNextWeek,
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 12),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: weekDays.map((day) {
  //               final isToday = day.isToday;
  //               final isSelected = day.isSelected;
  //               return Expanded(
  //                 child: GestureDetector(
  //                   onTap: () => controller.selectDay(day.date),
  //                   child: Container(
  //                     margin: const EdgeInsets.symmetric(horizontal: 2),
  //                     padding: const EdgeInsets.symmetric(vertical: 8),
  //                     decoration: BoxDecoration(
  //                       color: isSelected
  //                           ? _selectedHighlight.withValues(alpha: 0.3)
  //                           : isToday
  //                               ? _todayHighlight.withValues(alpha: 0.3)
  //                               : null,
  //                       borderRadius: BorderRadius.circular(8),
  //                       border: Border.all(
  //                         color: isSelected
  //                             ? _selectedHighlight
  //                             : isToday
  //                                 ? _todayHighlight
  //                                 : Colors.transparent,
  //                         width: 1.5,
  //                       ),
  //                     ),
  //                     child: Column(
  //                       children: [
  //                         Text(
  //                           day.label,
  //                           style: const TextStyle(
  //                             color: Colors.white70,
  //                             fontSize: 11,
  //                             fontWeight: FontWeight.w500,
  //                           ),
  //                         ),
  //                         const SizedBox(height: 4),
  //                         Text(
  //                           '${day.date.day}',
  //                           style: const TextStyle(
  //                             color: Colors.white,
  //                             fontSize: 14,
  //                             fontWeight: FontWeight.w600,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               );
  //             }).toList(),
  //           ),
  //         ],
  //       ),
  //     );
  //   });
  // }

  Widget _buildHabitCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 380;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(isCompact ? 16 : 20),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _borderColor, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isCompact) ...[
                const Text(
                  'Daily Habits',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDayHeaderRow(fontSize: 11),
              ] else
                Row(
                  children: [
                    const Expanded(
                      flex: 3,
                      child: Text(
                        'Daily Habits',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(flex: 4, child: _buildDayHeaderRow()),
                  ],
                ),
              const SizedBox(height: 12),
              Divider(height: 1, thickness: 1, color: _dividerColor),
              const SizedBox(height: 12),
              Obx(
                () => Column(
                  children: List.generate(controller.habits.length, (
                    habitIndex,
                  ) {
                    final habit = controller.habits[habitIndex];
                    final isLastItem =
                        habitIndex == controller.habits.length - 1;
                    return Padding(
                      padding: EdgeInsets.only(bottom: isLastItem ? 0 : 14),
                      child: _habitRow(habitIndex, habit, isCompact: isCompact),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDayHeaderRow({double fontSize = 12}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ...['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map(
          (day) => Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _habitRow(int habitIndex, Habit habit, {required bool isCompact}) {
    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${habit.title} ${habit.emoji}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          _buildHabitChecksRow(habitIndex, habit, boxSize: 28),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            '${habit.title} ${habit.emoji}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(flex: 4, child: _buildHabitChecksRow(habitIndex, habit)),
      ],
    );
  }

  Widget _buildHabitChecksRow(int habitIndex, Habit habit, {double? boxSize}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (arrayIndex) {
        final checked = habit.days[arrayIndex];
        final checkbox = GestureDetector(
          onTap: () => controller.toggleHabitDay(habitIndex, arrayIndex),
          child: Container(
            width: boxSize,
            height: boxSize,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: checked
                    ? _checkboxCheckedGreen
                    : _checkboxUncheckedBorder,
                width: 1,
              ),
            ),
            child: checked
                ? Center(
                    child: Image.asset(
                      'assets/image/check_icon.png',
                      width: 14,
                      height: 14,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.check,
                        color: _checkboxCheckedGreen,
                        size: 14,
                      ),
                    ),
                  )
                : null,
          ),
        );

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: boxSize == null
                ? AspectRatio(aspectRatio: 1, child: checkbox)
                : Center(child: checkbox),
          ),
        );
      }),
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notes',
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: _inputBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _borderColor, width: 1),
          ),
          child: TextField(
            controller: notesController,
            maxLines: 4,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Type your notes here',
              hintStyle: TextStyle(color: _hintColor, fontSize: 14),
              contentPadding: const EdgeInsets.all(16),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              final text = notesController.text;
              notesController.clear();
              await controller.addNote(text);
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [_addNotesBtnStart, _addNotesBtnEnd],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  const Text(
                    'Add Notes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
