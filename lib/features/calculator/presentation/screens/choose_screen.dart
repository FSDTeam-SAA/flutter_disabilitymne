import 'package:app_pigeon/app_pigeon.dart';
import 'package:disabilitymne/core/constants/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/core/helpers/app_snackbar.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class FoodDetailScreen extends StatefulWidget {
  const FoodDetailScreen({
    super.key,
    required this.fdcId,
    this.mealType = 'breakfast',
    required this.entryDate,
  });

  final int fdcId;
  final String mealType;
  final String entryDate;

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  final TextEditingController _quantityController = TextEditingController(
    text: '1',
  );
  final List<String> _mealTypes = const [
    'breakfast',
    'lunch',
    'dinner',
    'snack',
    'other',
  ];

  bool _loading = true;
  bool _tracking = false;
  bool _isFavorite = false;

  String _selectedMeal = 'breakfast';
  _FoodDetails? _food;
  _PortionOption? _selectedPortion;

  @override
  void initState() {
    super.initState();
    _selectedMeal = widget.mealType.toLowerCase();
    _loadFoodDetails();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadFoodDetails() async {
    setState(() {
      _loading = true;
    });
    try {
      final response = await Get.find<AuthorizedPigeon>().get(
        ApiEndpoints.nutritionFoodDetails(widget.fdcId),
      );
      final root = response.data;
      final data = root is Map<String, dynamic> ? root['data'] : null;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid food details response');
      }
      final food = _FoodDetails.fromJson(data);
      setState(() {
        _food = food;
        _selectedPortion = _resolveInitialPortion(food);
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  _PortionOption _resolveInitialPortion(_FoodDetails food) {
    final defaultOption = food.defaultPortionOption;
    if (defaultOption == null) return food.portionOptions.first;

    for (final option in food.portionOptions) {
      if (_isSamePortion(option, defaultOption)) {
        return option;
      }
    }
    return food.portionOptions.first;
  }

  bool _isSamePortion(_PortionOption a, _PortionOption b) {
    return a.label.trim().toLowerCase() == b.label.trim().toLowerCase() &&
        (a.gramWeight - b.gramWeight).abs() < 0.0001;
  }

  double get _quantity {
    final qty = double.tryParse(_quantityController.text.trim()) ?? 0;
    return qty <= 0 ? 0 : qty;
  }

  double get _totalGrams => _quantity * (_selectedPortion?.gramWeight ?? 0);

  _Nutrients get _totals {
    final base = _food?.nutrientsPer100g ?? const _Nutrients();
    final ratio = _totalGrams / 100;
    return _Nutrients(
      caloriesKcal: base.caloriesKcal * ratio,
      proteinG: base.proteinG * ratio,
      carbsG: base.carbsG * ratio,
      fatG: base.fatG * ratio,
      fiberG: base.fiberG * ratio,
      sugarG: base.sugarG * ratio,
    );
  }

  Future<void> _trackFood() async {
    if (_food == null || _selectedPortion == null || _quantity <= 0) return;
    setState(() {
      _tracking = true;
    });
    final payload = {
      'date': widget.entryDate,
      'mealType': _selectedMeal,
      'foodName': _food!.description,
      'fdcId': _food!.fdcId,
      'source': 'usda',
      'quantity': _quantity,
      'servingLabel': _selectedPortion!.label,
      'servingGrams': _selectedPortion!.gramWeight,
      'nutrientsPer100g': _food!.nutrientsPer100g.toJson(),
      'isFavorite': _isFavorite,
    };
    try {
      await Get.find<AuthorizedPigeon>().post(
        ApiEndpoints.nutritionDiaryEntries,
        data: payload,
      );
      if (!mounted) return;
      Get.back(result: true);
      AppSnackbar.show(
        'Tracked',
        'Food added to ${_titleCase(_selectedMeal)}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.show(
        'Error',
        'Failed to track food',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() {
          _tracking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151A24),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : _food == null
                ? Center(
                    child: TextButton(
                      onPressed: _loadFoodDetails,
                      child: const Text('Retry loading food'),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => Navigator.pop(context),
                                child: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => Get.back(),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      setState(() {
                                        _isFavorite = !_isFavorite;
                                      });
                                    },
                                    child: Icon(
                                      _isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 20),
                          child: Text(
                            _food!.description,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: _quantityController,
                                keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                onChanged: (_) => setState(() {}),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Quantity',
                                  labelStyle: const TextStyle(color: Colors.white70),
                                  filled: true,
                                  fillColor: Colors.white.withValues(alpha:  0.05),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Colors.white12),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Colors.white12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 4,
                              child: DropdownButtonFormField<_PortionOption>(
                                isExpanded: true,
                                initialValue: _selectedPortion,
                                dropdownColor: const Color(0xFF1D222F),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.white70,
                                ),
                                style: const TextStyle(color: Colors.white, fontSize: 15),
                                items: _food!.portionOptions
                                    .map(
                                      (u) => DropdownMenuItem(
                                        value: u,
                                        child: Text(
                                          u.estimated
                                              ? '${u.label} (estimated)'
                                              : u.label,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) => setState(() => _selectedPortion = v),
                                decoration: InputDecoration(
                                  labelText: 'How much',
                                  labelStyle: const TextStyle(color: Colors.white70),
                                  filled: true,
                                  fillColor: Colors.white.withValues(alpha:  0.05),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Colors.white12),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Colors.white12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedMeal,
                          dropdownColor: const Color(0xFF1D222F),
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white70,
                          ),
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          items: _mealTypes
                              .map(
                                (m) => DropdownMenuItem(
                                  value: m,
                                  child: Text(_titleCase(m)),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _selectedMeal = v ?? _selectedMeal),
                          decoration: InputDecoration(
                            labelText: 'Meal type',
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha:  0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.white12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.white12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1D222F),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.local_fire_department_outlined,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_totals.caloriesKcal.toStringAsFixed(1)} Kcal',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Total grams: ${_totalGrams.toStringAsFixed(1)} g',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildMacroCircle(
                                    percent: _macroPercent(
                                      _totals.carbsG,
                                      _totals.proteinG,
                                      _totals.fatG,
                                    ),
                                    color: const Color(0xFF6DA7D3),
                                    label: 'Carbs',
                                    value: '${_totals.carbsG.toStringAsFixed(1)} g',
                                    percentText:
                                        '${(_macroPercent(_totals.carbsG, _totals.proteinG, _totals.fatG) * 100).toStringAsFixed(0)}%',
                                  ),
                                  _buildMacroCircle(
                                    percent: _proteinPercent(
                                      _totals.carbsG,
                                      _totals.proteinG,
                                      _totals.fatG,
                                    ),
                                    color: const Color(0xFF8CE172),
                                    label: 'Protein',
                                    value: '${_totals.proteinG.toStringAsFixed(1)} g',
                                    percentText:
                                        '${(_proteinPercent(_totals.carbsG, _totals.proteinG, _totals.fatG) * 100).toStringAsFixed(0)}%',
                                  ),
                                  _buildMacroCircle(
                                    percent: _fatPercent(
                                      _totals.carbsG,
                                      _totals.proteinG,
                                      _totals.fatG,
                                    ),
                                    color: const Color(0xFF53A1FB),
                                    label: 'Fat',
                                    value: '${_totals.fatG.toStringAsFixed(1)} g',
                                    percentText:
                                        '${(_fatPercent(_totals.carbsG, _totals.proteinG, _totals.fatG) * 100).toStringAsFixed(0)}%',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),
                        GestureDetector(
                          onTap: _tracking ? null : _trackFood,
                          child: Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF8FC1DD),
                                  Color(0xFF5F9EC4),
                                ],
                              ),
                            ),
                            child: Center(
                              child: _tracking
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      'Track',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
      ),
    );
  }

  double _macroPercent(double carbs, double protein, double fat) {
    final total = carbs + protein + fat;
    if (total <= 0) return 0;
    return (carbs / total).clamp(0, 1);
  }

  double _proteinPercent(double carbs, double protein, double fat) {
    final total = carbs + protein + fat;
    if (total <= 0) return 0;
    return (protein / total).clamp(0, 1);
  }

  double _fatPercent(double carbs, double protein, double fat) {
    final total = carbs + protein + fat;
    if (total <= 0) return 0;
    return (fat / total).clamp(0, 1);
  }

  Widget _buildMacroCircle({
    required double percent,
    required Color color,
    required String label,
    required String value,
    required String percentText,
  }) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 36.0,
          lineWidth: 6.0,
          percent: percent.clamp(0.0, 1.0),
          center: Text(
            percentText,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          progressColor: color,
          backgroundColor: Colors.white.withValues(alpha:0.08),
          circularStrokeCap: CircularStrokeCap.round,
          animation: true,
          animateFromLastPercent: true,
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }
}

class _FoodDetails {
  _FoodDetails({
    required this.fdcId,
    required this.description,
    required this.nutrientsPer100g,
    required this.portionOptions,
    this.defaultPortionOption,
  });

  final int fdcId;
  final String description;
  final _Nutrients nutrientsPer100g;
  final _PortionOption? defaultPortionOption;
  final List<_PortionOption> portionOptions;

  factory _FoodDetails.fromJson(Map<String, dynamic> json) {
    final nutrientsPer100g = _Nutrients.fromJson(
      _asMap(json['nutrientsPer100g']),
    );
    final portionsRaw = json['portionOptions'];
    final portions = portionsRaw is List
        ? portionsRaw.whereType<Map<String, dynamic>>().map(_PortionOption.fromJson).toList()
        : <_PortionOption>[];
    if (portions.isEmpty) {
      portions.add(
        _PortionOption(
          label: 'Gram',
          gramWeight: 1,
          estimated: true,
        ),
      );
    }
    final defaultPortionMap = _asMap(json['defaultPortionOption']);
    final defaultPortion = defaultPortionMap.isEmpty
        ? null
        : _PortionOption.fromJson(defaultPortionMap);
    return _FoodDetails(
      fdcId: _toInt(json['fdcId']),
      description: (json['description'] as String?) ?? 'Food',
      nutrientsPer100g: nutrientsPer100g,
      defaultPortionOption: defaultPortion,
      portionOptions: portions,
    );
  }
}

class _PortionOption {
  _PortionOption({
    required this.label,
    required this.gramWeight,
    required this.estimated,
  });

  final String label;
  final double gramWeight;
  final bool estimated;

  factory _PortionOption.fromJson(Map<String, dynamic> json) {
    return _PortionOption(
      label: (json['label'] as String?) ?? 'Gram',
      gramWeight: _toDouble(json['gramWeight']),
      estimated: json['estimated'] == true,
    );
  }
}

class _Nutrients {
  const _Nutrients({
    this.caloriesKcal = 0,
    this.proteinG = 0,
    this.carbsG = 0,
    this.fatG = 0,
    this.fiberG = 0,
    this.sugarG = 0,
  });

  final double caloriesKcal;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fiberG;
  final double sugarG;

  factory _Nutrients.fromJson(Map<String, dynamic> json) {
    return _Nutrients(
      caloriesKcal: _toDouble(json['caloriesKcal']),
      proteinG: _toDouble(json['proteinG']),
      carbsG: _toDouble(json['carbsG']),
      fatG: _toDouble(json['fatG']),
      fiberG: _toDouble(json['fiberG']),
      sugarG: _toDouble(json['sugarG']),
    );
  }

  Map<String, dynamic> toJson() => {
        'caloriesKcal': caloriesKcal,
        'proteinG': proteinG,
        'carbsG': carbsG,
        'fatG': fatG,
        'fiberG': fiberG,
        'sugarG': sugarG,
      };
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

String _titleCase(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1).toLowerCase();
}