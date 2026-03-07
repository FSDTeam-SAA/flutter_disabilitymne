/// Model for a single habit row: label, emoji, and 7-day checkbox state.
class HabitItem {
  final String label;
  final String emoji;
  final List<bool> daysChecked;

  HabitItem({
    required this.label,
    required this.emoji,
    List<bool>? daysChecked,
  }) : daysChecked = daysChecked ?? List.filled(7, false);

  HabitItem copyWithToggledDay(int dayIndex) {
    if (dayIndex < 0 || dayIndex >= 7) return this;
    final updated = List<bool>.from(daysChecked);
    updated[dayIndex] = !updated[dayIndex];
    return HabitItem(
      label: label,
      emoji: emoji,
      daysChecked: updated,
    );
  }
}
