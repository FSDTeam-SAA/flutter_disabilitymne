import 'package:disabilitymne/core/theme/app_colors.dart';
import 'package:disabilitymne/features/daily_tracker/controller/daily_tracker_controller.dart';
import 'package:disabilitymne/features/daily_tracker/model/daily_tracker_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Daily Tracker screen: Daily Habit Week 1 card + Notes section.
/// MVC: View uses [DailyTrackerController] and [HabitItem] model.
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
  /// Checked: green border + green check icon; Unchecked: light gray border
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
    controller = Get.put(DailyTrackerController());
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHabitCard(),
              const SizedBox(height: 24),
              _buildNotesSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHabitCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor, width: 1),
      ),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                flex: 3,
                child: Text(
                  'Daily Habit Week 1',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (i) => Expanded(
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, thickness: 1, color: _dividerColor),
          const SizedBox(height: 12),
          Obx(() => Column(
            children: List.generate(controller.habits.length, (habitIndex) {
              final habit = controller.habits[habitIndex];
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _habitRow(habitIndex, habit),
              );
            }),
          )),
        ],
      ),
    );
  }

  Widget _habitRow(int habitIndex, HabitItem habit) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            '${habit.label} ${habit.emoji}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        Expanded(
          flex: 4,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (dayIndex) {
              final checked = habit.daysChecked[dayIndex];
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: GestureDetector(
                      onTap: () => controller.toggleDay(habitIndex, dayIndex),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: checked ? _checkboxCheckedGreen : _checkboxUncheckedBorder,
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
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.check,
                                    color: _checkboxCheckedGreen,
                                    size: 14,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
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
            onTap: () {
              controller.addNotes(notesController.text);
              notesController.clear();
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
