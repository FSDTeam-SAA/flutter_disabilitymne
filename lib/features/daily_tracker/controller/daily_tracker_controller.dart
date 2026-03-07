import 'package:disabilitymne/features/daily_tracker/model/daily_tracker_model.dart';
import 'package:get/get.dart';

class DailyTrackerController extends GetxController {
  final RxList<HabitItem> habits = <HabitItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadDefaultHabits();
  }

  void _loadDefaultHabits() {
    habits.assignAll([
      HabitItem(label: 'Follow a Diet', emoji: '🍎'),
      HabitItem(label: 'No Alcohol or Cheat Meals', emoji: '🚫'),
      HabitItem(label: 'Follow the workout', emoji: '🏋️‍♀'),
      HabitItem(label: 'Drink 2L Water', emoji: '💧'),
      HabitItem(label: 'Take progres picture', emoji: '📸'),
      HabitItem(label: 'Read 10 Page', emoji: '📚'),
    ]);
    // Day 1 all checked (as in design)
    for (var i = 0; i < habits.length; i++) {
      habits[i] = habits[i].copyWithToggledDay(0);
    }
  }

  void toggleDay(int habitIndex, int dayIndex) {
    if (habitIndex < 0 || habitIndex >= habits.length) return;
    habits[habitIndex] = habits[habitIndex].copyWithToggledDay(dayIndex);
  }

  void addNotes(String text) {
    // Persist or handle add notes action
  }
}
