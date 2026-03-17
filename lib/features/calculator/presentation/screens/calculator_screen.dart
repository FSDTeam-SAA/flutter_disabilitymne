import 'package:app_pigeon/app_pigeon.dart';
import 'package:disabilitymne/core/constants/api_endpoints.dart';
import 'package:disabilitymne/features/calculator/presentation/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({
    super.key,
    this.goal,
    this.weightKg,
    this.proteinPerKg,
    this.carbsPerKg,
    this.fatPerKg,
    this.caloriesPerKg,
  });

  final String? goal;
  final double? weightKg;
  final double? proteinPerKg;
  final double? carbsPerKg;
  final double? fatPerKg;
  final double? caloriesPerKg;

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  late DateTime _selectedDate;
  late Future<Map<String, dynamic>> _diaryFuture;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _diaryFuture = _fetchDiary();
  }

  Future<Map<String, dynamic>> _fetchDiary() async {
    final query = <String, String>{
      'date': _toApiDate(_selectedDate),
      if (widget.goal != null && widget.goal!.isNotEmpty) 'goal': widget.goal!,
      if (widget.weightKg != null) 'weightKg': widget.weightKg.toString(),
      if (widget.proteinPerKg != null)
        'proteinPerKg': widget.proteinPerKg.toString(),
      if (widget.carbsPerKg != null) 'carbsPerKg': widget.carbsPerKg.toString(),
      if (widget.fatPerKg != null) 'fatPerKg': widget.fatPerKg.toString(),
      if (widget.caloriesPerKg != null)
        'caloriesPerKg': widget.caloriesPerKg.toString(),
    };

    final uri = Uri.parse(
      ApiEndpoints.nutritionDiary,
    ).replace(queryParameters: query);
    final response = await Get.find<AuthorizedPigeon>().get(uri.toString());
    final body = response.data;
    final data = body is Map<String, dynamic> ? body['data'] : null;
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid nutrition diary response');
    }
    return data;
  }

  void _changeDay(int delta) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: delta));
      _diaryFuture = _fetchDiary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6FA8D1),
              Color(0xFF5592BE),
              Color(0xFF355F83),
              Color(0xFF1B2940),
              Color(0xFF151F32),
              Color(0xFF0D1B2A),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<Map<String, dynamic>>(
            future: _diaryFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Failed to load nutrition diary',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _diaryFuture = _fetchDiary();
                            });
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return _buildLoadedState(snapshot.data!);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadedState(Map<String, dynamic> data) {
    final diaryDate = _tryParseDate(data['date']) ?? _selectedDate;
    final energy = _asMap(data['energy']);
    final macroProgress = _asMap(data['macroProgress']);
    final carbs = _asMap(macroProgress['carbs']);
    final protein = _asMap(macroProgress['protein']);
    final fat = _asMap(macroProgress['fat']);
    final meals = _asMapList(data['meals']);

    final eatenKcal = _toDouble(energy['eatenKcal']);
    final remainingKcal = _toDouble(energy['remainingKcal']);
    final burnedKcal = _toDouble(energy['burnedKcal']);
    final goalKcal = _toDouble(energy['goalKcal']);

    final gaugeMax = goalKcal <= 0 ? 1.0 : goalKcal;
    final gaugeValue = eatenKcal.clamp(0, gaugeMax).toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => _changeDay(-1),
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    _formatHeaderDate(diaryDate),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => _changeDay(1),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildEnergyLabel('Eaten', eatenKcal),
                      SizedBox(
                        height: 220,
                        width: 220,
                        child: SfRadialGauge(
                          axes: [
                            RadialAxis(
                              minimum: 0,
                              maximum: gaugeMax,
                              showLabels: false,
                              showTicks: false,
                              axisLineStyle: const AxisLineStyle(
                                thickness: 0.18,
                                thicknessUnit: GaugeSizeUnit.factor,
                                color: Colors.white24,
                              ),
                              pointers: [
                                RangePointer(
                                  value: gaugeValue,
                                  width: 0.18,
                                  sizeUnit: GaugeSizeUnit.factor,
                                  color: Colors.white,
                                  cornerStyle: CornerStyle.bothCurve,
                                  enableAnimation: true,
                                ),
                              ],
                              annotations: [
                                GaugeAnnotation(
                                  angle: 90,
                                  positionFactor: 0.1,
                                  widget: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Remaining',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        remainingKcal.toStringAsFixed(0),
                                        style: const TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Goal ${goalKcal.toStringAsFixed(0)} Kcal',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _buildEnergyLabel('Burned', burnedKcal),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MacroCard(
                        title: 'Carbs',
                        value:
                            '${_toDouble(carbs['consumedG']).toStringAsFixed(0)} / ${_toDouble(carbs['targetG']).toStringAsFixed(0)}g',
                        progress: _progress01(carbs['progressPercent']),
                      ),
                      MacroCard(
                        title: 'Protein',
                        value:
                            '${_toDouble(protein['consumedG']).toStringAsFixed(0)} / ${_toDouble(protein['targetG']).toStringAsFixed(0)}g',
                        progress: _progress01(protein['progressPercent']),
                      ),
                      MacroCard(
                        title: 'Fat',
                        value:
                            '${_toDouble(fat['consumedG']).toStringAsFixed(0)} / ${_toDouble(fat['targetG']).toStringAsFixed(0)}g',
                        progress: _progress01(fat['progressPercent']),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Meals Logged',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...meals.map((meal) {
                    final recommendation = _asMap(meal['recommendation']);
                    final recommendedCalories = _asMap(
                      recommendation['recommendedCalories'],
                    );
                    final mealType = (meal['mealType'] as String?) ?? 'breakfast';
                    final title = (meal['mealLabel'] as String?) ?? mealType;
                    final eaten = _toDouble(_asMap(meal['totals'])['caloriesKcal'])
                        .toStringAsFixed(0);
                    final minKcal = _toDouble(recommendedCalories['minKcal'])
                        .toStringAsFixed(0);
                    final maxKcal = _toDouble(recommendedCalories['maxKcal'])
                        .toStringAsFixed(0);
                    final entries = _toInt(meal['totalEntries']);
                    return MealTile(
                      title: title,
                      subtitle:
                          'Recommended: $minKcal - $maxKcal kcal  |  Eaten: $eaten kcal  |  Entries: $entries',
                      onTap: () {},
                      onAddTap: () {
                        Get.to(
                          () => BreakfastSearchScreen(
                            mealType: mealType,
                            date: diaryDate,
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyLabel(String title, double value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 4),
        Text(
          value.toStringAsFixed(0),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _toApiDate(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }

  DateTime? _tryParseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  String _formatHeaderDate(DateTime date) {
    final now = DateTime.now();
    final isToday =
        now.year == date.year && now.month == date.month && now.day == date.day;
    final day = date.day.toString().padLeft(2, '0');
    final month = _monthShort(date.month);
    if (isToday) return 'TODAY, $day $month';
    return '${_weekdayShort(date.weekday)}, $day $month';
  }

  String _monthShort(int month) {
    const m = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return m[(month.clamp(1, 12)) - 1];
  }

  String _weekdayShort(int weekday) {
    const d = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return d[(weekday.clamp(1, 7)) - 1];
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    return {};
  }

  List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is List) {
      return value.whereType<Map<String, dynamic>>().toList();
    }
    return const [];
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

  double _progress01(dynamic percent) {
    final p = _toDouble(percent);
    return (p / 100).clamp(0, 1);
  }
}

class MacroCard extends StatelessWidget {
  final String title;
  final String value;
  final double progress;

  const MacroCard({
    super.key,
    required this.title,
    required this.value,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 48) / 3,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2940),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            
            backgroundColor: Color(0xFFE5EEFF),
            valueColor: const AlwaysStoppedAnimation(Colors.lightBlue),
          ),
        ],
      ),
    );
  }
}

class MealTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onAddTap;

  const MealTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white30),
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF16263B),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: onAddTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
