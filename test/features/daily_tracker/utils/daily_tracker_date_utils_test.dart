import 'package:disabilitymne/features/daily_tracker/utils/daily_tracker_date_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('getMondayOfWeek', () {
    test('Wednesday 2026-02-25 returns Monday 2026-02-23', () {
      final wed = DateTime(2026, 2, 25);
      final monday = getMondayOfWeek(wed);
      expect(monday.year, 2026);
      expect(monday.month, 2);
      expect(monday.day, 23);
    });

    test('Monday returns same Monday', () {
      final mon = DateTime(2026, 2, 23);
      final result = getMondayOfWeek(mon);
      expect(result.year, 2026);
      expect(result.month, 2);
      expect(result.day, 23);
    });

    test('Sunday 2026-02-22 returns Monday 2026-02-16', () {
      final sun = DateTime(2026, 2, 22);
      final monday = getMondayOfWeek(sun);
      expect(monday.year, 2026);
      expect(monday.month, 2);
      expect(monday.day, 16);
    });
  });

  group('formatDateOnly', () {
    test('formats as YYYY-MM-DD', () {
      final date = DateTime(2026, 2, 23);
      expect(formatDateOnly(date), '2026-02-23');
    });

    test('pads single digit month and day', () {
      final date = DateTime(2026, 1, 5);
      expect(formatDateOnly(date), '2026-01-05');
    });
  });

  group('weekStartDateFromSelected', () {
    test('Wednesday 2026-02-25 returns 2026-02-23', () {
      final wed = DateTime(2026, 2, 25);
      expect(weekStartDateFromSelected(wed), '2026-02-23');
    });
  });

  group('dayIndexFromSelected', () {
    test('Monday = 1', () {
      expect(dayIndexFromSelected(DateTime(2026, 2, 23)), 1);
    });
    test('Wednesday = 3', () {
      expect(dayIndexFromSelected(DateTime(2026, 2, 25)), 3);
    });
    test('Sunday = 7', () {
      expect(dayIndexFromSelected(DateTime(2026, 3, 1)), 7);
    });
  });

  group('arrayIndexFromDayIndex / dayIndexFromArrayIndex', () {
    test('dayIndex 1 -> arrayIndex 0', () {
      expect(arrayIndexFromDayIndex(1), 0);
    });
    test('dayIndex 7 -> arrayIndex 6', () {
      expect(arrayIndexFromDayIndex(7), 6);
    });
    test('roundtrip', () {
      for (var i = 1; i <= 7; i++) {
        expect(dayIndexFromArrayIndex(arrayIndexFromDayIndex(i)), i);
      }
    });
  });

  group('getWeekDaysForUi', () {
    test('returns 7 days Mon-Sun', () {
      final days = getWeekDaysForUi(
        selectedDate: DateTime(2026, 2, 25),
        today: DateTime(2026, 2, 25),
      );
      expect(days.length, 7);
      expect(days[0].label, 'Mon');
      expect(days[6].label, 'Sun');
      expect(days[0].dayIndex, 1);
      expect(days[6].dayIndex, 7);
    });

    test('Wednesday selected and today - isToday and isSelected on same day', () {
      final wed = DateTime(2026, 2, 25);
      final days = getWeekDaysForUi(selectedDate: wed, today: wed);
      final wedIndex = 2; // 0=Mon, 1=Tue, 2=Wed
      expect(days[wedIndex].isToday, true);
      expect(days[wedIndex].isSelected, true);
    });

    test('Monday of week is correct date', () {
      final wed = DateTime(2026, 2, 25);
      final days = getWeekDaysForUi(selectedDate: wed, today: wed);
      expect(days[0].date.day, 23);
      expect(days[0].date.month, 2);
      expect(days[0].date.year, 2026);
    });
  });

  group('parseBackendWeekStartToDateOnly', () {
    test('ISO string 2026-02-22T18:00:00.000Z extracts 2026-02-22', () {
      expect(
        parseBackendWeekStartToDateOnly('2026-02-22T18:00:00.000Z'),
        '2026-02-22',
      );
    });

    test('date-only string passes through', () {
      expect(parseBackendWeekStartToDateOnly('2026-02-23'), '2026-02-23');
    });

    test('null returns empty', () {
      expect(parseBackendWeekStartToDateOnly(null), '');
    });
  });
}
