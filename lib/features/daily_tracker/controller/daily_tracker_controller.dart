import 'package:disabilitymne/features/daily_tracker/model/daily_tracker_model.dart';
import 'package:disabilitymne/features/daily_tracker/repository/daily_tracker_repository.dart';
import 'package:disabilitymne/features/daily_tracker/utils/daily_tracker_date_utils.dart';
import 'package:get/get.dart';

/// Controller for Daily Tracker.
///
/// **Source of truth:** [selectedDate]. All API calls derive weekStartDate and
/// dayIndex from it. Never overwrite with backend response.
class DailyTrackerController extends GetxController {
  DailyTrackerController(this._repo);

  final DailyTrackerRepository _repo;

  /// The date the user is viewing/selecting. Source of truth for all date logic.
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  /// Tracker data for the current week. Null when loading or error.
  final Rxn<DailyTrackerData> trackerData = Rxn<DailyTrackerData>();

  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();

  /// The 7 days (Mon..Sun) for the current week, for UI rendering.
  List<TrackerDay> get weekDays => getWeekDaysForUi(
        selectedDate: selectedDate.value,
        today: DateTime.now(),
      );

  /// Week number from backend (for display). 0 if not loaded.
  int get weekNumber => trackerData.value?.weekNumber ?? 0;

  /// Habits from tracker. Empty list if not loaded.
  List<Habit> get habits => trackerData.value?.habits ?? [];

  /// Notes from tracker.
  List<TrackerNote> get notes => trackerData.value?.notes ?? [];

  @override
  void onInit() {
    super.onInit();
    _fetchForSelectedDate();
  }

  /// Fetch tracker for the week containing [selectedDate].
  Future<void> _fetchForSelectedDate() async {
    isLoading.value = true;
    errorMessage.value = null;
    final result = await _repo.fetchDailyTracker(selectedDate.value);
    result.fold(
      (failure) {
        errorMessage.value = failure.uiMessage;
        trackerData.value = null;
      },
      (data) {
        trackerData.value = data;
      },
    );
    isLoading.value = false;
  }

  /// Public refetch (e.g. pull-to-refresh).
  Future<void> fetchDailyTracker() => _fetchForSelectedDate();

  /// Navigate to previous week (same weekday).
  void goToPreviousWeek() {
    selectedDate.value = selectedDate.value.subtract(const Duration(days: 7));
    _fetchForSelectedDate();
  }

  /// Navigate to next week (same weekday).
  void goToNextWeek() {
    selectedDate.value = selectedDate.value.add(const Duration(days: 7));
    _fetchForSelectedDate();
  }

  /// Select a specific day (updates selectedDate to that day).
  void selectDay(DateTime date) {
    selectedDate.value = DateTime(date.year, date.month, date.day);
    // No refetch - we're viewing the same week
  }

  /// Toggle habit at [arrayIndex] (0=Mon..6=Sun).
  ///
  /// The cell corresponds to the day at that index in the current week.
  Future<void> toggleHabitDay(int habitIndex, int arrayIndex) async {
    if (habitIndex < 0 || habitIndex >= habits.length) return;
    if (arrayIndex < 0 || arrayIndex >= 7) return;

    final habit = habits[habitIndex];
    final dayIndex = dayIndexFromArrayIndex(arrayIndex);
    final newCompleted = !habit.days[arrayIndex];

    // Optimistic update
    final updatedHabits = List<Habit>.from(habits);
    updatedHabits[habitIndex] = habit.copyWithToggledDay(arrayIndex);
    trackerData.value = trackerData.value != null
        ? DailyTrackerData(
            id: trackerData.value!.id,
            weekStartDateRaw: trackerData.value!.weekStartDateRaw,
            weekNumber: trackerData.value!.weekNumber,
            completionRate: trackerData.value!.completionRate,
            habits: updatedHabits,
            notes: trackerData.value!.notes,
          )
        : null;

    final result = await _repo.toggleHabit(
      selectedDate: selectedDate.value,
      habitKey: habit.key,
      dayIndex: dayIndex,
      completed: newCompleted,
    );

    result.fold(
      (failure) {
        // Rollback
        _fetchForSelectedDate();
        errorMessage.value = failure.uiMessage;
      },
      (data) {
        trackerData.value = data;
      },
    );
  }

  /// Add a note for the currently selected day.
  Future<void> addNote(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    errorMessage.value = null;

    final result = await _repo.addNote(
      selectedDate: selectedDate.value,
      text: trimmed,
    );

    result.fold(
      (failure) => errorMessage.value = failure.uiMessage,
      (_) => _fetchForSelectedDate(),
    );
  }
}
