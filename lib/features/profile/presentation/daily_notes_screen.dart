import 'package:disabilitymne/features/auth/presentation/widgets/background_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DailyNotesScreen extends StatefulWidget {
  const DailyNotesScreen({super.key});

  @override
  State<DailyNotesScreen> createState() => _DailyNotesScreenState();
}

class _DailyNotesScreenState extends State<DailyNotesScreen> {
  String _selectedCategory = 'All';

  final List<Map<String, dynamic>> _notes = [
    {
      "title": "Exercise Note",
      "category": "Exercise",
      "date": "02 - 02 - 2026",
      "desc":
          "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
      "icon": Icons.edit_note_outlined,
    },
    {
      "title": "Tracker Note",
      "category": "Daily tracker",
      "date": "02 - 02 - 2026",
      "desc":
          "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
      "icon": Icons.edit_note_outlined,
    },
    {
      "title": "Tracker Note",
      "category": "Daily tracker",
      "date": "02 - 02 - 2026",
      "desc":
          "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
      "icon": Icons.edit_note_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredNotes = _selectedCategory == 'All'
        ? _notes
        : _notes
              .where((note) => note['category'] == _selectedCategory)
              .toList();

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
          "Daily Notes",
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
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredNotes.length,
                itemBuilder: (context, index) {
                  return _buildNoteCard(filteredNotes[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          _buildFilterChip("All"),
          const SizedBox(width: 8),
          _buildFilterChip("Exercise"),
          const SizedBox(width: 8),
          _buildFilterChip("Daily tracker"),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
      },
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

  Widget _buildNoteCard(Map<String, dynamic> note) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(note['icon'] as IconData, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    note['title'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.white54,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    note['date'] as String,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            note['desc'] as String,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
