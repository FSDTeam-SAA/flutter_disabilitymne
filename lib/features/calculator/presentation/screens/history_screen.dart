import 'dart:async';

import 'package:disabilitymne/core/theme/app_colors.dart';
import 'package:disabilitymne/core/theme/text_style.dart';
import 'package:disabilitymne/features/auth/presentation/widgets/background_image.dart';
import 'package:disabilitymne/features/calculator/controller/calculator_controller.dart';
import 'package:disabilitymne/features/calculator/model/calculator_model.dart';
import 'package:disabilitymne/features/calculator/presentation/screens/search_screen.dart';
import 'package:disabilitymne/features/calculator/services/calculator_interface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/core/helpers/app_snackbar.dart';

enum MealScreenTab { myMeal, recent, saved }

class HistoryScreen extends StatefulWidget {
  final Meal meal;
  final DateTime diaryDate;
  final MealScreenTab initialTab;

  const HistoryScreen({
    super.key,
    required this.meal,
    required this.diaryDate,
    this.initialTab = MealScreenTab.myMeal,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _busyEntryIds = <String>{};

  Timer? _searchDebounce;
  late final CalculatorInterface _api;
  late int _selectedTabIndex;

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
  bool _savingCurrentMeal = false;

  @override
  void initState() {
    super.initState();
    _api = Get.find<CalculatorInterface>();
    _selectedTabIndex = widget.initialTab.index;
    _loadSelectedTab();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  String _apiDate(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }

  MealScreenTab get _selectedTab => MealScreenTab.values[_selectedTabIndex];

  bool get _showsSearchBar => _selectedTab != MealScreenTab.myMeal;

  String get _searchHintText {
    switch (_selectedTab) {
      case MealScreenTab.recent:
        return 'Search recent foods';
      case MealScreenTab.saved:
        return 'Search saved meals';
      case MealScreenTab.myMeal:
        return '';
    }
  }

  void _loadSelectedTab() {
    switch (_selectedTab) {
      case MealScreenTab.myMeal:
        _loadTracked();
        break;
      case MealScreenTab.recent:
        _loadHistory();
        break;
      case MealScreenTab.saved:
        _loadFavorites();
        break;
    }
  }

  Future<void> _handleRefresh() async {
    _searchDebounce?.cancel();
    switch (_selectedTab) {
      case MealScreenTab.myMeal:
        await _loadTracked();
        break;
      case MealScreenTab.recent:
        await _loadHistory();
        break;
      case MealScreenTab.saved:
        await _loadFavorites();
        break;
    }
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

    final result = await _api.getNutritionHistory(
      page: append ? _historyPage + 1 : 1,
      limit: 30,
      mealType: widget.meal.mealType,
      query: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
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
        setState(() {
          if (pageData == null) {
            _historyLoading = false;
            _historyLoadingMore = false;
            return;
          }

          _historyEntries = append
              ? [..._historyEntries, ...pageData.entries]
              : pageData.entries;
          _historyPage = pageData.page;
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
        setState(() {
          _favoriteSections =
              success.data ??
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

    final result = await _api.getNutritionDiary(
      date: _apiDate(widget.diaryDate),
    );
    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _trackedError = failure.uiMessage;
          _trackedLoading = false;
        });
      },
      (success) {
        Meal? mealForType;
        final diary = success.data;
        if (diary != null) {
          for (final meal in diary.meals) {
            if (meal.mealType == widget.meal.mealType) {
              mealForType = meal;
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
    if (_selectedTabIndex == index) return;

    _searchDebounce?.cancel();
    if (_searchController.text.isNotEmpty) {
      _searchController.clear();
    }

    setState(() => _selectedTabIndex = index);
    _loadSelectedTab();
  }

  void _debouncedHistoryReload() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      _loadHistory();
    });
  }

  void _setEntryBusy(String entryId, bool isBusy) {
    if (!mounted || entryId.isEmpty) return;
    setState(() {
      if (isBusy) {
        _busyEntryIds.add(entryId);
      } else {
        _busyEntryIds.remove(entryId);
      }
    });
  }

  void _removeEntryLocally(String entryId) {
    if (!mounted || entryId.isEmpty) return;

    setState(() {
      _historyEntries = _historyEntries.where((e) => e.id != entryId).toList();
      _trackedEntries = _trackedEntries.where((e) => e.id != entryId).toList();

      if (_favoriteSections != null) {
        _favoriteSections = NutritionFavoriteSections(
          foods: _favoriteSections!.foods
              .where((e) => e.id != entryId)
              .toList(),
          meals: _favoriteSections!.meals
              .where((e) => e.id != entryId)
              .toList(),
          recipes: _favoriteSections!.recipes
              .where((e) => e.id != entryId)
              .toList(),
        );
      }
    });
  }

  void _removeFavoriteLocally(String entryId) {
    if (!mounted || entryId.isEmpty || _favoriteSections == null) return;

    setState(() {
      _favoriteSections = NutritionFavoriteSections(
        foods: _favoriteSections!.foods.where((e) => e.id != entryId).toList(),
        meals: _favoriteSections!.meals.where((e) => e.id != entryId).toList(),
        recipes: _favoriteSections!.recipes
            .where((e) => e.id != entryId)
            .toList(),
      );
    });
  }

  void _showMessage(String title, String message) {
    AppSnackbar.show(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
    );
  }

  void _refreshCalculatorDiary() {
    if (!Get.isRegistered<CalculatorController>()) return;
    Get.find<CalculatorController>().fetchDiary();
  }

  Future<void> _openAddFoodSearch() async {
    final tracked = await Get.to<bool>(
      () => BreakfastSearchScreen(
        mealType: widget.meal.mealType,
        date: widget.diaryDate,
      ),
    );

    if (tracked == true) {
      await _loadTracked();
      _refreshCalculatorDiary();
    }
  }

  Future<bool> _confirmDelete(String foodName) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B2940),
        title: const Text(
          'Delete entry?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Remove $foodName from your log?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> _deleteEntry({
    required String entryId,
    required String foodName,
  }) async {
    if (entryId.isEmpty) {
      _showMessage('Error', 'This entry cannot be deleted right now.');
      return;
    }

    final confirmed = await _confirmDelete(foodName);
    if (!confirmed) return;

    _setEntryBusy(entryId, true);
    final result = await _api.deleteNutritionDiaryEntry(entryId: entryId);
    if (!mounted) return;

    result.fold((failure) => _showMessage('Error', failure.uiMessage), (_) {
      _removeEntryLocally(entryId);
      _refreshCalculatorDiary();
      _showMessage('Deleted', '$foodName was removed.');
    });

    _setEntryBusy(entryId, false);
  }

  Future<void> _removeFavoriteEntry(NutritionEntrySummary entry) async {
    if (entry.id.isEmpty) {
      _showMessage('Error', 'This favorite cannot be updated right now.');
      return;
    }

    _setEntryBusy(entry.id, true);
    if (entry.favoriteKind == 'meal') {
      final result = await _api.deleteNutritionFavoriteMeal(
        mealFavoriteId: entry.id,
      );
      if (!mounted) return;

      result.fold((failure) => _showMessage('Error', failure.uiMessage), (_) {
        _removeFavoriteLocally(entry.id);
        _showMessage('Updated', '${entry.foodName} removed from favorites.');
      });
    } else if (entry.favoriteKind == 'recipe') {
      final result = await _api.toggleRecipeFavorite(
        recipeId: entry.id,
        isFavorite: false,
      );
      if (!mounted) return;

      result.fold((failure) => _showMessage('Error', failure.uiMessage), (_) {
        _removeFavoriteLocally(entry.id);
        _showMessage('Updated', '${entry.foodName} removed from favorites.');
      });
    } else {
      final result = await _api.updateNutritionDiaryEntry(
        entryId: entry.id,
        payload: const {'isFavorite': false},
      );
      if (!mounted) return;

      result.fold((failure) => _showMessage('Error', failure.uiMessage), (_) {
        _removeFavoriteLocally(entry.id);
        _showMessage('Updated', '${entry.foodName} removed from favorites.');
      });
    }

    _setEntryBusy(entry.id, false);
  }

  Future<void> _saveCurrentMealAsFavorite() async {
    if (_trackedEntries.isEmpty || _savingCurrentMeal) {
      return;
    }

    setState(() {
      _savingCurrentMeal = true;
    });

    final result = await _api.saveNutritionFavoriteMeal(
      date: _apiDate(widget.diaryDate),
      mealType: widget.meal.mealType,
    );
    if (!mounted) return;

    result.fold(
      (failure) {
        _showMessage('Error', failure.uiMessage);
      },
      (success) async {
        _showMessage(
          'Saved',
          success.message.isNotEmpty
              ? success.message
              : '${widget.meal.mealLabel} saved to favorites.',
        );
        await _loadFavorites();
      },
    );

    if (!mounted) return;
    setState(() {
      _savingCurrentMeal = false;
    });
  }

  List<NutritionEntrySummary> _filterSummaries(
    List<NutritionEntrySummary> list,
    String query,
  ) {
    if (query.isEmpty) return list;
    final lower = query.toLowerCase();

    return list.where((entry) {
      return entry.foodName.toLowerCase().contains(lower) ||
          entry.brandName.toLowerCase().contains(lower) ||
          entry.mealLabel.toLowerCase().contains(lower);
    }).toList();
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
              if (_showsSearchBar) _buildSearchBar(),
              _buildTabBar(),
              Expanded(child: _buildTabContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 16, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.white,
              size: 20,
            ),
            onPressed: () => Get.back(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.meal.mealLabel,
                  style: AppText.xlSemiBold_20_600.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Review logged items, recent foods, and saved meals.',
                  style: AppText.smRegular_14_400.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
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
          if (_selectedTab == MealScreenTab.recent) {
            _debouncedHistoryReload();
          }
        },
        style: const TextStyle(color: AppColors.white),
        decoration: InputDecoration(
          hintText: _searchHintText,
          hintStyle: AppText.smRegular_14_400.copyWith(color: AppColors.white),
          prefixIcon: const Icon(Icons.search, color: AppColors.white),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.white),
                  onPressed: () {
                    _searchController.clear();
                    _searchDebounce?.cancel();
                    if (_selectedTab == MealScreenTab.recent) {
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
            borderSide: const BorderSide(color: Color(0xFF7E8592)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF7E8592), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF7E8592), width: 1.2),
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
          _buildTabItem(0, Icons.restaurant_menu_outlined, 'My Meal'),
          _buildTabItem(1, Icons.history, 'Recent'),
          _buildTabItem(2, Icons.favorite_border, 'Saved'),
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
            Container(height: 2, width: 40, color: AppColors.profileActiveTab),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        late final Widget child;
        switch (_selectedTabIndex) {
          case 0:
            child = _buildTrackedContent(constraints);
            break;
          case 1:
            child = _buildHistoryList(constraints);
            break;
          case 2:
            child = _buildFavoriteContent(constraints);
            break;
          default:
            child = _buildTrackedContent(constraints);
        }

        return RefreshIndicator(
          onRefresh: _handleRefresh,
          color: const Color(0xff6FA8DC),
          backgroundColor: const Color(0xff0E1A2B),
          child: child,
        );
      },
    );
  }

  Widget _buildHistoryList(BoxConstraints constraints) {
    if (_historyLoading && _historyEntries.isEmpty) {
      return _buildScrollableState(
        constraints: constraints,
        child: const CircularProgressIndicator(color: AppColors.white),
      );
    }

    if (_historyError != null && _historyEntries.isEmpty) {
      return _buildScrollableState(
        constraints: constraints,
        child: _buildErrorState(_historyError!, _loadHistory),
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        Text(
          'Recent items',
          style: AppText.lgMedium_18_500.copyWith(color: AppColors.white),
        ),
        const SizedBox(height: 16),
        if (_historyEntries.isEmpty)
          SizedBox(
            height: constraints.maxHeight > 140
                ? constraints.maxHeight - 140
                : 140,
            child: Center(
              child: Text(
                _searchController.text.trim().isEmpty
                    ? 'No recent items yet'
                    : 'No matching recent foods',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          )
        else
          ..._historyEntries.map(
            (entry) => _buildSummaryCard(
              entry,
              trailing: Icons.close,
              trailingBusy: _busyEntryIds.contains(entry.id),
              onTrailingTap: () =>
                  _deleteEntry(entryId: entry.id, foodName: entry.foodName),
            ),
          ),
        if (_historyPage < _historyTotalPages)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: _historyLoadingMore
                  ? const CircularProgressIndicator(color: AppColors.white)
                  : TextButton(
                      onPressed: () => _loadHistory(append: true),
                      child: const Text(
                        'Load more',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ),
          ),
      ],
    );
  }

  Widget _buildFavoriteContent(BoxConstraints constraints) {
    if (_favoriteLoading && _favoriteSections == null) {
      return _buildScrollableState(
        constraints: constraints,
        child: const CircularProgressIndicator(color: AppColors.white),
      );
    }

    if (_favoriteError != null && _favoriteSections == null) {
      return _buildScrollableState(
        constraints: constraints,
        child: _buildErrorState(_favoriteError!, _loadFavorites),
      );
    }

    final sections =
        _favoriteSections ??
        NutritionFavoriteSections(foods: [], meals: [], recipes: []);
    final query = _searchController.text.trim();
    final foods = _filterSummaries(sections.foods, query);
    final meals = _filterSummaries(sections.meals, query);
    final recipes = _filterSummaries(sections.recipes, query);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        _buildFavoriteSection(
          title: 'Food',
          emptyText: query.isEmpty
              ? 'No favorite foods yet'
              : 'No matching foods',
          entries: foods,
        ),
        const SizedBox(height: 20),
        _buildFavoriteSection(
          title: 'Meals',
          emptyText: query.isEmpty
              ? 'No favorite meals yet'
              : 'No matching meals',
          entries: meals,
        ),
        const SizedBox(height: 20),
        _buildFavoriteSection(
          title: 'Recipes',
          emptyText: query.isEmpty
              ? 'No favorite recipes yet'
              : 'No matching recipes',
          entries: recipes,
        ),
      ],
    );
  }

  Widget _buildFavoriteSection({
    required String title,
    required String emptyText,
    required List<NutritionEntrySummary> entries,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppText.lgMedium_18_500.copyWith(color: AppColors.white),
        ),
        const SizedBox(height: 12),
        if (entries.isEmpty)
          _buildEmptyCard(emptyText)
        else
          ...entries.map(
            (entry) => _buildSummaryCard(
              entry,
              trailing: Icons.favorite,
              trailingBusy: _busyEntryIds.contains(entry.id),
              onTrailingTap: () => _removeFavoriteEntry(entry),
            ),
          ),
      ],
    );
  }

  Widget _buildTrackedContent(BoxConstraints constraints) {
    if (_trackedLoading && _trackedEntries.isEmpty) {
      return _buildScrollableState(
        constraints: constraints,
        child: const CircularProgressIndicator(color: AppColors.white),
      );
    }

    if (_trackedError != null && _trackedEntries.isEmpty) {
      return _buildScrollableState(
        constraints: constraints,
        child: _buildErrorState(_trackedError!, _loadTracked),
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        Text(
          'My Meal',
          style: AppText.lgMedium_18_500.copyWith(color: AppColors.white),
        ),
        const SizedBox(height: 8),
        Text(
          '${widget.meal.mealLabel} on ${_formatShortDate(widget.diaryDate)}',
          style: AppText.smRegular_14_400.copyWith(color: Colors.white70),
        ),
        if (_trackedEntries.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: _openAddFoodSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.profileActiveTab,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Food'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: _savingCurrentMeal
                        ? null
                        : _saveCurrentMealAsFavorite,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.white,
                      side: BorderSide(
                        color: _savingCurrentMeal
                            ? Colors.white24
                            : AppColors.profileActiveTab,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: _savingCurrentMeal
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : const Icon(Icons.favorite_border, size: 18),
                    label: Text(_savingCurrentMeal ? 'Saving...' : 'Save Meal'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ] else
          const SizedBox(height: 4),
        if (_trackedEntries.isEmpty)
          SizedBox(
            height: constraints.maxHeight > 220
                ? constraints.maxHeight - 220
                : 220,
            child: _buildMyMealEmptyState(),
          )
        else
          ..._trackedEntries.map(
            (entry) => _buildFoodCard(
              title: entry.displayTitle,
              kcal: '${entry.calories.toStringAsFixed(0)} kcal',
              gram: entry.quantityLine,
              trailing: Icons.close,
              trailingBusy: _busyEntryIds.contains(entry.id ?? ''),
              onTrailingTap: () => _deleteEntry(
                entryId: entry.id ?? '',
                foodName: entry.foodName,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildScrollableState({
    required BoxConstraints constraints,
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(24),
  }) {
    final minHeight = constraints.maxHeight > padding.vertical
        ? constraints.maxHeight - padding.vertical
        : 0.0;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: padding,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight),
          child: Center(child: child),
        ),
      ],
    );
  }

  Widget _buildMyMealEmptyState() {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.profileCardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.profileBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.restaurant_menu_outlined,
              color: AppColors.profileActiveTab,
              size: 34,
            ),
            const SizedBox(height: 12),
            Text(
              'Nothing logged for this meal yet.',
              textAlign: TextAlign.center,
              style: AppText.mdSemiBold_16_700.copyWith(color: AppColors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Use Add Food to search the food database and log an item.',
              textAlign: TextAlign.center,
              style: AppText.smRegular_14_400.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openAddFoodSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.profileActiveTab,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Food'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  String _formatShortDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildSummaryCard(
    NutritionEntrySummary entry, {
    required IconData trailing,
    bool trailingBusy = false,
    VoidCallback? onTrailingTap,
  }) {
    return _buildFoodCard(
      title: entry.displayTitle,
      kcal: '${entry.caloriesKcal.toStringAsFixed(0)} kcal',
      gram: entry.quantityLine,
      subtitle: '${entry.mealLabel} | ${_shortDate(entry.entryDate)}',
      trailing: trailing,
      trailingBusy: trailingBusy,
      onTrailingTap: onTrailingTap,
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
    bool trailingBusy = false,
    VoidCallback? onTrailingTap,
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
                  InkWell(
                    onTap: trailingBusy ? null : onTrailingTap,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF818894)),
                      ),
                      child: trailingBusy
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : Icon(
                              trailing,
                              size: 18,
                              color: trailing == Icons.favorite
                                  ? AppColors.profileActiveTab
                                  : AppColors.white,
                            ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
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
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
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
}
