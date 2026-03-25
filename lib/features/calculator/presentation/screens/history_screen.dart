import 'dart:async';

import 'package:disabilitymne/core/theme/app_colors.dart';
import 'package:disabilitymne/core/theme/text_style.dart';
import 'package:disabilitymne/features/auth/presentation/widgets/background_image.dart';
import 'package:disabilitymne/features/calculator/model/calculator_model.dart';
import 'package:disabilitymne/features/calculator/services/calculator_interface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HistoryScreen extends StatefulWidget {
  final Meal meal;
  final DateTime diaryDate;

  const HistoryScreen({
    super.key,
    required this.meal,
    required this.diaryDate,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  late final CalculatorInterface _api;

  bool _historyLoading = false;
  String? _historyError;
  List<NutritionEntrySummary> _historyEntries = [];
  int _historyPage = 1;
  int _historyTotalPages = 0;
  bool _historyLoadingMore = false;

  bool _favoriteLoading = false;
  String? _favoriteError;
  NutritionFavoriteSections? _favoriteSections;

  bool _trackedLoading = false;
  String? _trackedError;
  List<DiaryEntry> _trackedEntries = [];

  @override
  void initState() {
    super.initState();
    _api = Get.find<CalculatorInterface>();
    _loadHistory();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  String _apiDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  Future<void> _loadHistory({bool append = false}) async {
    if (!append) {
      setState(() {
        _historyLoading = true;
        _historyError = null;
      });
    } else {
      setState(() => _historyLoadingMore = true);
    }

    final page = append ? _historyPage + 1 : 1;
    final q = _searchController.text.trim();
    final queryParam = q.isNotEmpty ? q : null;

    final result = await _api.getNutritionHistory(
      page: page,
      limit: 30,
      mealType: widget.meal.mealType,
      query: queryParam,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _historyError = failure.uiMessage;
          _historyLoading = false;
          _historyLoadingMore = false;
        });
      },
      (success) {
        final pageData = success.data;
        if (pageData == null) {
          setState(() {
            _historyLoading = false;
            _historyLoadingMore = false;
          });
          return;
        }
        setState(() {
          if (append) {
            _historyEntries = [..._historyEntries, ...pageData.entries];
            _historyPage = pageData.page;
          } else {
            _historyEntries = pageData.entries;
            _historyPage = pageData.page;
          }
          _historyTotalPages = pageData.totalPages;
          _historyLoading = false;
          _historyLoadingMore = false;
          _historyError = null;
        });
      },
    );
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _favoriteLoading = true;
      _favoriteError = null;
    });

    final result = await _api.getNutritionFavoriteSections(limit: 50);

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _favoriteError = failure.uiMessage;
          _favoriteLoading = false;
        });
      },
      (success) {
        final data = success.data;
        setState(() {
          _favoriteSections = data ??
              NutritionFavoriteSections(foods: [], meals: [], recipes: []);
          _favoriteLoading = false;
          _favoriteError = null;
        });
      },
    );
  }

  Future<void> _loadTracked() async {
    setState(() {
      _trackedLoading = true;
      _trackedError = null;
    });

    final result = await _api.getNutritionDiary(date: _apiDate(widget.diaryDate));

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _trackedError = failure.uiMessage;
          _trackedLoading = false;
        });
      },
      (success) {
        final diary = success.data;
        Meal? mealForType;
        if (diary != null) {
          for (final m in diary.meals) {
            if (m.mealType == widget.meal.mealType) {
              mealForType = m;
              break;
            }
          }
        }
        setState(() {
          _trackedEntries = mealForType?.entries ?? [];
          _trackedLoading = false;
          _trackedError = null;
        });
      },
    );
  }

  void _onTabSelected(int index) {
    setState(() => _selectedTabIndex = index);
    if (index == 0) {
      _loadHistory();
    } else if (index == 1 && _favoriteSections == null && !_favoriteLoading) {
      _loadFavorites();
    } else if (index == 2) {
      _loadTracked();
    }
  }

  void _debouncedHistoryReload() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      _loadHistory();
    });
  }

  List<NutritionEntrySummary> _filterSummaries(
    List<NutritionEntrySummary> list,
    String q,
  ) {
    if (q.isEmpty) return list;
    final lower = q.toLowerCase();
    return list.where((e) {
      return e.foodName.toLowerCase().contains(lower) ||
          e.brandName.toLowerCase().contains(lower) ||
          e.mealLabel.toLowerCase().contains(lower);
    }).toList();
  }

  List<DiaryEntry> _filterDiary(List<DiaryEntry> list, String q) {
    if (q.isEmpty) return list;
    final lower = q.toLowerCase();
    return list
        .where((e) => e.foodName.toLowerCase().contains(lower))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackgroundImage(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildTabBar(),
              Expanded(child: _buildTabContent()),
              if (_selectedTabIndex == 0) _buildDoneButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.white,
              size: 20,
            ),
            onPressed: () => Get.back(),
          ),
          Text(
            widget.meal.mealLabel,
            style: AppText.xlSemiBold_20_600.copyWith(color: AppColors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: TextField(
        controller: _searchController,
        onChanged: (_) {
          setState(() {});
          if (_selectedTabIndex == 0) {
            _debouncedHistoryReload();
          }
        },
        style: const TextStyle(color: AppColors.white),
        decoration: InputDecoration(
          hintText: 'Food or meal',
          hintStyle: AppText.smRegular_14_400.copyWith(
            color: AppColors.white,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.white,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.white),
                  onPressed: () {
                    _searchController.clear();
                    _searchDebounce?.cancel();
                    if (_selectedTabIndex == 0) {
                      _loadHistory();
                    } else {
                      setState(() {});
                    }
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF465061),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF7E8592),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF7E8592),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF7E8592),
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTabItem(0, Icons.history, 'History'),
          _buildTabItem(1, Icons.favorite_border, 'Favorite'),
          _buildTabItem(2, Icons.track_changes, 'Tracked'),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label) {
    final isSelected = _selectedTabIndex == index;

    return GestureDetector(
      onTap: () => _onTabSelected(index),
      child: Column(
        children: [
          Icon(
            icon,
            color: isSelected
                ? AppColors.profileActiveTab
                : AppColors.profileTextSecondary,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppText.xsMedium_12_500.copyWith(
              color: isSelected
                  ? AppColors.profileActiveTab
                  : AppColors.profileTextSecondary,
            ),
          ),
          const SizedBox(height: 6),
          if (isSelected)
            Container(
                height: 2, width: 40, color: AppColors.profileActiveTab),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildHistoryList();
      case 1:
        return _buildFavoriteContent();
      case 2:
        return _buildTrackedContent();
      default:
        return _buildHistoryList();
    }
  }

  Widget _buildHistoryList() {
    if (_historyLoading && _historyEntries.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.white),
      );
    }

    if (_historyError != null && _historyEntries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _historyError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _loadHistory,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All recent',
            style: AppText.lgMedium_18_500.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _historyEntries.isEmpty
                ? const Center(
                    child: Text(
                      'No entries in history',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    itemCount: _historyEntries.length +
                        (_historyPage < _historyTotalPages ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _historyEntries.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: _historyLoadingMore
                                ? const CircularProgressIndicator(
                                    color: AppColors.white)
                                : TextButton(
                                    onPressed: () => _loadHistory(append: true),
                                    child: const Text(
                                      'Load more',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                          ),
                        );
                      }
                      final e = _historyEntries[index];
                      return _buildSummaryCard(
                        e,
                        trailing: Icons.close,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteContent() {
    if (_favoriteLoading && _favoriteSections == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.white),
      );
    }

    if (_favoriteError != null && _favoriteSections == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _favoriteError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _loadFavorites,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final sections = _favoriteSections!;
    final q = _searchController.text.trim();
    final foods = _filterSummaries(sections.foods, q);
    final meals = _filterSummaries(sections.meals, q);
    final recipes = _filterSummaries(sections.recipes, q);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        children: [
          Text(
            'Food',
            style: AppText.lgMedium_18_500.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 12),
          if (foods.isEmpty)
            _buildEmptyCard(
                q.isEmpty ? 'No favorite foods yet' : 'No matching foods')
          else
            ...foods.map(
              (e) => _buildSummaryCard(e, trailing: Icons.favorite),
            ),
          const SizedBox(height: 20),
          Text(
            'Meals',
            style: AppText.lgMedium_18_500.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 12),
          if (meals.isEmpty)
            _buildEmptyCard(
                q.isEmpty ? 'No favorite meals yet' : 'No matching meals')
          else
            ...meals.map(
              (e) => _buildSummaryCard(e, trailing: Icons.favorite),
            ),
          const SizedBox(height: 20),
          Text(
            'Recipes',
            style: AppText.lgMedium_18_500.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 12),
          if (recipes.isEmpty)
            _buildEmptyCard(
                q.isEmpty ? 'No favorite recipes yet' : 'No matching recipes')
          else
            ...recipes.map(
              (e) => _buildSummaryCard(e, trailing: Icons.favorite),
            ),
        ],
      ),
    );
  }

  Widget _buildTrackedContent() {
    if (_trackedLoading && _trackedEntries.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.white),
      );
    }

    if (_trackedError != null && _trackedEntries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _trackedError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _loadTracked,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final q = _searchController.text.trim();
    final entries = _filterDiary(_trackedEntries, q);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Logged on ${_formatShortDate(widget.diaryDate)}',
            style: AppText.lgMedium_18_500.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Items in ${widget.meal.mealLabel}',
            style: AppText.smRegular_14_400.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Text(
                      q.isEmpty
                          ? 'Nothing logged for this meal yet'
                          : 'No matching items',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return _buildFoodCard(
                        title: entry.foodName,
                        kcal: '${entry.calories.toStringAsFixed(0)} kcal',
                        gram:
                            '${entry.quantity.toStringAsFixed(entry.quantity == entry.quantity.roundToDouble() ? 0 : 1)} ${entry.servingLabel}',
                        subtitle: entry.date.isNotEmpty ? entry.date : null,
                        trailing: Icons.close,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatShortDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Widget _buildSummaryCard(
    NutritionEntrySummary e, {
    required IconData trailing,
  }) {
    return _buildFoodCard(
      title: e.displayTitle,
      kcal: '${e.caloriesKcal.toStringAsFixed(0)} kcal',
      gram: e.quantityLine,
      subtitle: '${e.mealLabel} · ${_shortDate(e.entryDate)}',
      trailing: trailing,
    );
  }

  String _shortDate(String raw) {
    if (raw.length >= 10) return raw.substring(0, 10);
    return raw;
  }

  Widget _buildFoodCard({
    required String title,
    required String kcal,
    required String gram,
    String? subtitle,
    required IconData trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF7E8592)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.transparent,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppText.xl2Medium_22_500.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: AppText.smRegular_14_400.copyWith(
                              color: Colors.white60,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          kcal,
                          style: AppText.smMedium_14_500.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.edit_outlined,
                              size: 24,
                              color: AppColors.white,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                gram,
                                style: AppText.smMedium_14_500.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF818894)),
                    ),
                    child: Icon(
                      trailing,
                      size: 18,
                      color: trailing == Icons.favorite
                          ? AppColors.profileActiveTab
                          : AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 50,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(120, 0, 0, 0),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 50,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Color.fromARGB(120, 0, 0, 0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.profileCardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.profileBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.favorite_border, color: AppColors.profileActiveTab),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppText.smRegular_14_400.copyWith(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoneButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          gradient: AppColors.buttonGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ElevatedButton(
          onPressed: () => Get.back(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
          ),
          child: Text(
            'Done',
            style: AppText.mdSemiBold_16_700.copyWith(color: Colors.black),
          ),
        ),
      ),
    );
  }
}
