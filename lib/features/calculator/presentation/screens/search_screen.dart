import 'dart:async';

import 'package:app_pigeon/app_pigeon.dart';
import 'package:disabilitymne/core/constants/api_endpoints.dart';
import 'package:disabilitymne/features/calculator/controller/calculator_controller.dart';
import 'package:disabilitymne/features/calculator/presentation/screens/choose_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BreakfastSearchScreen extends StatefulWidget {
  const BreakfastSearchScreen({
    super.key,
    this.mealType = 'breakfast',
    this.date,
  });

  final String mealType;
  final DateTime? date;

  @override
  State<BreakfastSearchScreen> createState() => _BreakfastSearchScreenState();
}

class _BreakfastSearchScreenState extends State<BreakfastSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<_FoodSearchItem> _foods = [];
  final List<String> _suggestions = [];

  Timer? _debounce;
  bool _loading = false;
  bool _didTrackFood = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.text = _query;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchNow(String query) async {
    setState(() {
      _loading = true;
      _query = query;
    });

    try {
      await Future.wait([_fetchSuggestions(query), _fetchFoods(query)]);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _fetchSuggestions(String query) async {
    if (query.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _suggestions.clear();
        });
      }
      return;
    }

    final uri = Uri.parse(
      ApiEndpoints.nutritionFoodSuggestions,
    ).replace(queryParameters: {'q': query.trim(), 'limit': '10'});
    final response = await Get.find<AuthorizedPigeon>().get(uri.toString());
    final root = response.data;
    final data = root is Map<String, dynamic> ? root['data'] : null;
    final list = data is List
        ? data.whereType<Map<String, dynamic>>().toList()
        : <Map<String, dynamic>>[];
    final labels = list
        .map((e) => (e['label'] as String?) ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
    if (!mounted) return;
    setState(() {
      _suggestions
        ..clear()
        ..addAll(labels);
    });
  }

  Future<void> _fetchFoods(String query) async {
    if (query.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _foods.clear();
        });
      }
      return;
    }

    final uri = Uri.parse(ApiEndpoints.nutritionFoodSearch).replace(
      queryParameters: {'query': query.trim(), 'page': '1', 'pageSize': '20'},
    );
    final response = await Get.find<AuthorizedPigeon>().get(uri.toString());
    final root = response.data;
    final data = root is Map<String, dynamic> ? root['data'] : null;
    final foods = data is Map<String, dynamic> ? data['foods'] : null;
    final list = foods is List
        ? foods.whereType<Map<String, dynamic>>().toList()
        : const <Map<String, dynamic>>[];

    if (!mounted) return;
    setState(() {
      _foods
        ..clear()
        ..addAll(list.map(_FoodSearchItem.fromJson));
    });
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _searchNow(value);
    });
  }

  void _closeScreen() {
    Get.back(result: _didTrackFood);
  }

  Future<void> _handleRefresh() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      return;
    }
    await _searchNow(query);
  }

  @override
  Widget build(BuildContext context) {
    final mealLabel = _titleCase(widget.mealType);
    return WillPopScope(
      onWillPop: () async {
        _closeScreen();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF151A24),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _closeScreen,
                      child: const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Food to $mealLabel',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Search foods from the database and add them to this meal.',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Search foods from database',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey[400],
                        size: 22,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _searchNow('');
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              if (_suggestions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _suggestions
                          .take(6)
                          .map(
                            (suggestion) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ActionChip(
                                backgroundColor: const Color(0xFF2A3040),
                                side: BorderSide(color: Colors.white.withOpacity(0.12)),
                                label: Text(
                                  suggestion,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  _searchController.value = TextEditingValue(
                                    text: suggestion,
                                    selection: TextSelection.collapsed(
                                      offset: suggestion.length,
                                    ),
                                  );
                                  _searchNow(suggestion);
                                },
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Search Results',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(child: _buildResultsSection(mealLabel)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSection(String mealLabel) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          onRefresh: _handleRefresh,
          color: const Color(0xff6FA8DC),
          backgroundColor: const Color(0xff0E1A2B),
          child: _buildResultsContent(
            constraints: constraints,
            mealLabel: mealLabel,
          ),
        );
      },
    );
  }

  Widget _buildResultsContent({
    required BoxConstraints constraints,
    required String mealLabel,
  }) {
    if (_loading) {
      return _buildRefreshableState(
        constraints: constraints,
        child: const CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_query.trim().isEmpty) {
      return _buildRefreshableState(
        constraints: constraints,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search, size: 40, color: Colors.grey[500]),
              const SizedBox(height: 14),
              const Text(
                'Search foods from the database',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Type a food name to find items you can add to $mealLabel.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    if (_foods.isEmpty) {
      return _buildRefreshableState(
        constraints: constraints,
        child: const Text(
          'No foods found',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _foods.length,
      itemBuilder: (context, index) {
        final food = _foods[index];
        return FoodTile(
          title: food.description,
          calories: '${food.caloriesKcal.toStringAsFixed(0)} kcal',
          subtitle: food.portionSubtitle,
          onAddTap: () async {
            final tracked = await Get.to<bool>(
              () => FoodDetailScreen(
                fdcId: food.fdcId,
                mealType: widget.mealType,
                entryDate: _toApiDate(widget.date ?? DateTime.now()),
              ),
            );

            if (tracked == true) {
              _didTrackFood = true;
            }

            if (tracked == true && Get.isRegistered<CalculatorController>()) {
              await Get.find<CalculatorController>().fetchDiary();
            }
          },
        );
      },
    );
  }

  Widget _buildRefreshableState({
    required BoxConstraints constraints,
    required Widget child,
  }) {
    final minHeight = constraints.maxHeight > 48
        ? constraints.maxHeight - 48
        : 0.0;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.all(24),
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight),
          child: Center(child: child),
        ),
      ],
    );
  }
}

class FoodTile extends StatelessWidget {
  final String title;
  final String calories;
  final String? subtitle;
  final bool showKcal;
  final VoidCallback? onAddTap;

  const FoodTile({
    super.key,
    required this.title,
    required this.calories,
    this.subtitle,
    this.showKcal = true,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1D222F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    if (showKcal) ...[
                      const SizedBox(height: 4),
                      Text(
                        calories,
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      ),
                    ],
                    if (subtitle != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 14,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              subtitle!,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              InkWell(
                onTap: onAddTap,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white30),
                    color: Colors.transparent,
                  ),
                  child: const Icon(Icons.add, size: 20, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _toApiDate(DateTime date) {
  final mm = date.month.toString().padLeft(2, '0');
  final dd = date.day.toString().padLeft(2, '0');
  return '${date.year}-$mm-$dd';
}

String _titleCase(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1).toLowerCase();
}

class _FoodSearchItem {
  _FoodSearchItem({
    required this.fdcId,
    required this.description,
    required this.caloriesKcal,
    required this.portionLabel,
    required this.portionGramWeight,
    required this.nutrientsPer100g,
    required this.portionOptions,
  });

  final int fdcId;
  final String description;
  final double caloriesKcal;
  final String portionLabel;
  final double portionGramWeight;
  final Map<String, dynamic> nutrientsPer100g;
  final List<Map<String, dynamic>> portionOptions;

  String get portionSubtitle =>
      '1 $portionLabel (${portionGramWeight.toStringAsFixed(0)} g)';

  factory _FoodSearchItem.fromJson(Map<String, dynamic> json) {
    final display = _asMap(json['display']);
    final defaultPortionOption = _asMap(json['defaultPortionOption']);
    final optionsRaw = json['portionOptions'];
    final options = optionsRaw is List
        ? optionsRaw.whereType<Map<String, dynamic>>().toList()
        : <Map<String, dynamic>>[];
    final nutrientsPer100g = _asMap(json['nutrientsPer100g']);

    return _FoodSearchItem(
      fdcId: _toInt(json['fdcId']),
      description: (json['description'] as String?) ?? 'Unknown food',
      caloriesKcal: _toDouble(display['caloriesKcal']),
      portionLabel: (defaultPortionOption['label'] as String?) ?? 'Serving',
      portionGramWeight: _toDouble(defaultPortionOption['gramWeight']),
      nutrientsPer100g: nutrientsPer100g,
      portionOptions: options,
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  return {};
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

int _toInt(dynamic value) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
