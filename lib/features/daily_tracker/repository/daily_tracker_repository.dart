import 'package:app_pigeon/app_pigeon.dart';
import 'package:disabilitymne/core/api_handler/base_repository.dart';
import 'package:disabilitymne/core/constants/api_endpoints.dart';
import 'package:disabilitymne/core/helpers/typedefs.dart';
import 'package:disabilitymne/features/daily_tracker/model/daily_tracker_model.dart';
import 'package:disabilitymne/features/daily_tracker/model/daily_tracker_notes_list_model.dart';
import 'package:disabilitymne/features/daily_tracker/utils/daily_tracker_date_utils.dart';

/// Repository for Daily Tracker API.
///
/// All methods accept [DateTime selectedDate] as the source of truth.
/// weekStartDate and dayIndex are derived internally - UI never builds payloads.
base class DailyTrackerRepository extends BaseRepository {
  DailyTrackerRepository(this._pigeon);

  final AuthorizedPigeon _pigeon;

  /// GET daily tracker for the week containing [selectedDate].
  ///
  /// Sends weekStartDate=YYYY-MM-DD (Monday of that week).
  FutureRequest<DailyTrackerData> fetchDailyTracker(DateTime selectedDate) async {
    return asyncTryCatch(
      tryFunc: () async {
        final weekStartDate = weekStartDateFromSelected(selectedDate);
        final uri = '${ApiEndpoints.dailyTracker}?weekStartDate=$weekStartDate';
        final response = await _pigeon.get(uri);
        final data = extractBodyData(response) as Map<String, dynamic>?;
        if (data == null) throw Exception('Invalid daily tracker response');
        return DailyTrackerData.fromJson(data);
      },
    );
  }

  /// PATCH to toggle a habit cell.
  ///
  /// [selectedDate] determines the week. [dayIndex] (1=Mon..7=Sun) is the cell.
  /// [completed] is the new value.
  FutureRequest<DailyTrackerData> toggleHabit({
    required DateTime selectedDate,
    required String habitKey,
    required int dayIndex,
    required bool completed,
  }) async {
    return asyncTryCatch(
      tryFunc: () async {
        final weekStartDate = weekStartDateFromSelected(selectedDate);
        final payload = ToggleHabitPayload(
          weekStartDate: weekStartDate,
          habitKey: habitKey,
          dayIndex: dayIndex,
          completed: completed,
        );
        final response = await _pigeon.patch(
          ApiEndpoints.dailyTracker,
          data: payload.toJson(),
        );
        final data = extractBodyData(response) as Map<String, dynamic>?;
        if (data == null) throw Exception('Invalid toggle response');
        return DailyTrackerData.fromJson(data);
      },
    );
  }

  /// POST to add a note for [selectedDate]'s day.
  ///
  /// dayIndex is derived from selectedDate (1=Mon..7=Sun).
  FutureRequest<void> addNote({
    required DateTime selectedDate,
    required String text,
  }) async {
    return asyncTryCatch(
      tryFunc: () async {
        final weekStartDate = weekStartDateFromSelected(selectedDate);
        final dayIndex = dayIndexFromSelected(selectedDate);
        final payload = AddNotePayload(
          weekStartDate: weekStartDate,
          dayIndex: dayIndex,
          text: text,
        );
        await _pigeon.post(ApiEndpoints.dailyTrackerNotes, data: payload.toJson());
      },
    );
  }

  /// GET my daily tracker notes with pagination.
  ///
  /// [page] and [limit] for pagination. Optional [weekStartDate] (YYYY-MM-DD)
  /// to filter by week.
  FutureRequest<DailyTrackerNotesListResponse> getMyDailyTrackerNotes({
    int page = 1,
    int limit = 20,
    String? weekStartDate,
  }) async {
    return asyncTryCatch(
      tryFunc: () async {
        final query = <String>['page=$page', 'limit=$limit'];
        if (weekStartDate != null && weekStartDate.isNotEmpty) {
          query.add('weekStartDate=$weekStartDate');
        }
        final uri = '${ApiEndpoints.dailyTrackerNotes}?${query.join('&')}';
        final response = await _pigeon.get(uri);
        final body = response.data as Map<String, dynamic>?;
        if (body == null) throw Exception('Invalid notes response');
        return DailyTrackerNotesListResponse.fromJson(body);
      },
    );
  }
}
