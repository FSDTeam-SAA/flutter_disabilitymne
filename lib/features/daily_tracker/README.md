# Daily Tracker – Implementation Plan & Architecture

## Overview

Production-ready Flutter frontend for the Daily Tracker feature. The frontend owns all date logic; the backend contract is unchanged.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│  UI (daily_tracker_screen.dart)                                  │
│  - Week navigation (prev/next)                                    │
│  - Day selection, today/selected highlighting                    │
│  - Habit rows with 7 cells (Mon-Sun)                             │
│  - Notes section                                                  │
└────────────────────────────┬────────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────────┐
│  Controller (daily_tracker_controller.dart)                      │
│  - selectedDate = source of truth                               │
│  - weekDays, habits, notes (derived)                             │
│  - goToPreviousWeek, goToNextWeek, selectDay                     │
│  - toggleHabitDay(habitIndex, arrayIndex)                        │
│  - addNote(text)                                                  │
└────────────────────────────┬────────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────────┐
│  Repository (daily_tracker_repository.dart)                      │
│  - fetchDailyTracker(selectedDate)                              │
│  - toggleHabit(selectedDate, habitKey, dayIndex, completed)     │
│  - addNote(selectedDate, text)                                    │
│  Derives weekStartDate & dayIndex from selectedDate internally  │
└────────────────────────────┬────────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────────┐
│  Date Utils (daily_tracker_date_utils.dart)                      │
│  - getMondayOfWeek, formatDateOnly                              │
│  - weekStartDateFromSelected, dayIndexFromSelected              │
│  - getWeekDaysForUi, arrayIndexFromDayIndex                     │
└─────────────────────────────────────────────────────────────────┘
```

**State management:** GetX (existing in project). Reactive `selectedDate`, `trackerData`, `isLoading`, `errorMessage`.

## Backend Contract (unchanged)

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/v1/users/me/daily-tracker?weekStartDate=YYYY-MM-DD` | GET | Fetch tracker for week |
| `/api/v1/users/me/daily-tracker` | PATCH | Toggle habit cell |
| `/api/v1/users/me/daily-tracker/notes` | POST | Add note |

**Rules:**
- Monday = day 1. dayIndex: 1=Mon, 2=Tue, …, 7=Sun.
- days[0]=Mon, days[1]=Tue, …, days[6]=Sun.
- weekStartDate: YYYY-MM-DD (Monday).
- Backend may return weekStartDate as ISO (e.g. `2026-02-22T18:00:00.000Z`). Do not use for UI state.

## Date Logic (Frontend Owns)

1. **selectedDate** – User’s current date (source of truth).
2. **weekStartDate** – Monday of that week as `YYYY-MM-DD`.
3. **dayIndex** – 1–7 for Mon–Sun (`DateTime.weekday` in Dart).
4. **arrayIndex** – 0–6 for `days[]` (`dayIndex - 1`).

## UI Mapping

| Column | Label | arrayIndex | dayIndex |
|--------|-------|------------|----------|
| 0 | Mon | 0 | 1 |
| 1 | Tue | 1 | 2 |
| … | … | … | … |
| 6 | Sun | 6 | 7 |

## Examples

**User opens app on Wednesday 2026-02-25:**
- `selectedDate` = 2026-02-25
- `weekStartDate` = 2026-02-23
- `dayIndex` = 3
- GET: `?weekStartDate=2026-02-23`

**Toggle Thursday of that week:**
- PATCH body: `{ weekStartDate: "2026-02-23", habitKey: "follow_diet", dayIndex: 4, completed: true }`

**Navigate to next week:**
- `selectedDate` += 7 days → 2026-03-04 (Wed)
- Refetch with new weekStartDate.

## Edge Cases

| Case | Handling |
|------|----------|
| Timezone drift | Use local date only. Never use backend ISO for UI state. |
| Backend returns `2026-02-22T18:00:00.000Z` | Ignore for state. Use our computed weekStartDate. |
| Near midnight | Use `DateTime(year, month, day)` for date-only comparisons. |
| Sunday selected | dayIndex=7, arrayIndex=6. |
| No tracker for week | Backend creates default. Frontend shows loading then data. |
| Optimistic toggle fails | Rollback via `_fetchForSelectedDate()`. |

## Testing Strategy

1. **Unit tests** – `daily_tracker_date_utils_test.dart`:
   - getMondayOfWeek (Mon, Wed, Sun)
   - formatDateOnly
   - weekStartDateFromSelected
   - dayIndexFromSelected (1, 3, 7)
   - arrayIndex ↔ dayIndex roundtrip
   - getWeekDaysForUi (7 days, today/selected)
   - parseBackendWeekStartToDateOnly

2. **Repository tests** – Mock AuthorizedPigeon, assert:
   - GET URL includes correct weekStartDate
   - PATCH body has weekStartDate, habitKey, dayIndex, completed
   - POST body has weekStartDate, dayIndex, text

3. **Widget tests** – Tracker screen:
   - Week nav buttons trigger controller
   - Day cells call toggleHabitDay with correct arrayIndex
   - Today/selected highlighting

4. **Integration** – Manual:
   - Open on Wed, verify GET URL
   - Toggle Thu, verify PATCH body
   - Add note, verify POST body
   - Navigate weeks, verify refetch
