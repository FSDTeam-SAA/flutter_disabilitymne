import 'package:disabilitymne/features/auth/presentation/widgets/background_image.dart';
import 'package:disabilitymne/features/daily_tracker/model/daily_tracker_notes_list_model.dart';
import 'package:disabilitymne/features/daily_tracker/repository/daily_tracker_repository.dart';
import 'package:disabilitymne/features/daily_tracker/utils/daily_tracker_date_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Filter options for daily tracker notes.
enum NotesFilter { all, week, daily }

class DailyNotesScreen extends StatefulWidget {
  const DailyNotesScreen({super.key});

  @override
  State<DailyNotesScreen> createState() => _DailyNotesScreenState();
}

class _DailyNotesScreenState extends State<DailyNotesScreen> {
  NotesFilter _selectedFilter = NotesFilter.all;
  List<DailyTrackerNoteItem> _notes = [];
  DailyTrackerNotesMeta? _meta;
  bool _loading = false;
  String? _error;

  static const int _pageSize = 20;

  DailyTrackerRepository get _repo => Get.find<DailyTrackerRepository>();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  String? _weekStartDateForFilter() {
    // Week and Daily both narrow to current week; Daily then filters to today only.
    if (_selectedFilter == NotesFilter.week ||
        _selectedFilter == NotesFilter.daily) {
      return weekStartDateFromSelected(DateTime.now());
    }
    return null;
  }

  Future<void> _loadNotes() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final weekStart = _weekStartDateForFilter();
    final result = await _repo.getMyDailyTrackerNotes(
      page: 1,
      limit: _pageSize,
      weekStartDate: weekStart,
    );

    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() {
          _loading = false;
          _error = failure.uiMessage;
          _notes = [];
          _meta = null;
        });
        Get.snackbar('Error', failure.uiMessage);
      },
      (response) {
        List<DailyTrackerNoteItem> list = response.data;
        if (_selectedFilter == NotesFilter.daily) {
          final todayStr = formatDateOnly(DateTime.now());
          list = list.where((n) => n.date == todayStr).toList();
        }
        setState(() {
          _notes = list;
          _meta = response.meta;
          _loading = false;
          _error = null;
        });
      },
    );
  }

  void _onFilterChanged(NotesFilter filter) {
    if (_selectedFilter == filter) return;
    setState(() => _selectedFilter = filter);
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Daily Notes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BackgroundImage(
        child: Column(
          children: [
            _buildCategoryFilter(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildFilterChip('All', NotesFilter.all),
          _buildFilterChip('Week', NotesFilter.week),
          _buildFilterChip('Daily', NotesFilter.daily),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, NotesFilter filter) {
    final isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () => _onFilterChanged(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4B7FA8) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF4B7FA8)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _loadNotes,
                child: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (_notes.isEmpty) {
      return Center(
        child: Text(
          _selectedFilter == NotesFilter.daily
              ? 'No notes for today'
              : _selectedFilter == NotesFilter.week
              ? 'No notes this week'
              : 'No notes yet',
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_meta != null && _meta!.total > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              '${_notes.length} of ${_meta!.total} note${_meta!.total == 1 ? '' : 's'}',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _notes.length,
            itemBuilder: (context, index) => _buildNoteCard(_notes[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteCard(DailyTrackerNoteItem note) {
    final dateLabel = note.date != null && note.date!.isNotEmpty
        ? _formatDateFromString(note.date!)
        : (note.createdAt != null
              ? _formatDateFromString(formatDateOnly(note.createdAt!))
              : '--');
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4B7FA8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 340;
              final titleSection = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.edit_note_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Flexible(
                    child: Text(
                      'Daily tracker',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );

              final dateSection = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.white54,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      dateLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              );

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleSection,
                    const SizedBox(height: 8),
                    dateSection,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: titleSection),
                  const SizedBox(width: 12),
                  Flexible(child: dateSection),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            note.text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          if (note.weekNumber > 0) ...[
            const SizedBox(height: 8),
            Text(
              'Week ${note.weekNumber}',
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDateFromString(String dateStr) {
    if (dateStr.isEmpty) return '--';
    if (dateStr.length >= 10) {
      final parts = dateStr.substring(0, 10).split('-');
      if (parts.length == 3) {
        return '${parts[2]} - ${parts[1]} - ${parts[0]}';
      }
    }
    return dateStr;
  }
}
