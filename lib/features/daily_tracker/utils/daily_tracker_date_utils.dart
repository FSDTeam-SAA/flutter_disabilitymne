/// Date utilities for Daily Tracker.
///
/// **Critical rules:**
/// - Backend uses Monday as day 1. dayIndex: 1=Mon..7=Sun.
/// - days[0..6] maps to Mon..Sun (arrayIndex = dayIndex - 1).
/// - Frontend owns all date logic. Never use backend ISO weekStartDate for UI state.
/// - All calculations use [DateTime] in local time (no UTC conversion for display).
library;

/// Represents a single day in the week for UI display.
class TrackerDay {
  final DateTime date;
  final int dayIndex; // 1=Mon..7=Sun (backend convention)
  final String label; // "Mon", "Tue", etc.
  final bool isToday;
  final bool isSelected;

  const TrackerDay({
    required this.date,
    required this.dayIndex,
    required this.label,
    required this.isToday,
    required this.isSelected,
  });
}

/// Returns Monday of the week containing [date], at local midnight.
///
/// Dart [DateTime.weekday]: 1=Monday, 7=Sunday.
/// Example: Wed 2026-02-25 -> Mon 2026-02-23.
DateTime getMondayOfWeek(DateTime date) {
  final local = DateTime(date.year, date.month, date.day);
  return local.subtract(Duration(days: local.weekday - 1));
}

/// Formats [date] as YYYY-MM-DD (date-only, no timezone).
///
/// Used for API requests. Backend expects this format.
String formatDateOnly(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

/// Returns weekStartDate (Monday) as YYYY-MM-DD for the week containing [selectedDate].
///
/// This is the value to send in GET/PATCH/POST requests.
String weekStartDateFromSelected(DateTime selectedDate) {
  return formatDateOnly(getMondayOfWeek(selectedDate));
}

/// Returns dayIndex (1=Mon..7=Sun) for [selectedDate].
///
/// [selectedDate.weekday] already gives 1=Mon..7=Sun in Dart.
int dayIndexFromSelected(DateTime selectedDate) {
  return selectedDate.weekday;
}

/// Returns array index (0..6) for a given dayIndex (1..7).
/// days[arrayIndex] = dayIndex - 1.
int arrayIndexFromDayIndex(int dayIndex) {
  assert(dayIndex >= 1 && dayIndex <= 7);
  return dayIndex - 1;
}

/// Returns dayIndex (1..7) from array index (0..6).
int dayIndexFromArrayIndex(int arrayIndex) {
  assert(arrayIndex >= 0 && arrayIndex <= 6);
  return arrayIndex + 1;
}

/// Generates the 7 UI days for the week containing [selectedDate].
///
/// [selectedDate] is used to highlight which day is selected.
/// [today] is used to highlight today (defaults to DateTime.now()).
///
/// Returns Mon..Sun in order. days[0]=Mon, days[6]=Sun.
List<TrackerDay> getWeekDaysForUi({
  required DateTime selectedDate,
  DateTime? today,
}) {
  final now = today ?? DateTime.now();
  final monday = getMondayOfWeek(selectedDate);
  final selectedLocal = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
  final todayLocal = DateTime(now.year, now.month, now.day);

  const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  return List.generate(7, (i) {
    final dayDate = monday.add(Duration(days: i));
    final dayIndex = i + 1; // 1=Mon..7=Sun
    final isToday = dayDate == todayLocal;
    final isSelected = dayDate == selectedLocal;

    return TrackerDay(
      date: dayDate,
      dayIndex: dayIndex,
      label: labels[i],
      isToday: isToday,
      isSelected: isSelected,
    );
  });
}

/// Parses backend ISO weekStartDate to YYYY-MM-DD for display/logging only.
///
/// **Do not use for UI state or API requests.** The backend may return
/// ISO like "2026-02-22T18:00:00.000Z" (UTC) which can shift the calendar
/// day in other timezones. Frontend must compute weekStartDate from
/// selectedDate for all API calls.
String parseBackendWeekStartToDateOnly(dynamic value) {
  if (value == null) return '';
  if (value is String) {
    final dt = DateTime.tryParse(value);
    if (dt != null) return formatDateOnly(dt);
    if (value.length >= 10) return value.substring(0, 10);
  }
  return '';
}
