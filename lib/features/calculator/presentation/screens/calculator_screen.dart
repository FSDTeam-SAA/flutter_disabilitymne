import 'package:disabilitymne/features/calculator/controller/calculator_controller.dart';
import 'package:disabilitymne/features/calculator/model/calculator_model.dart';
import 'package:disabilitymne/features/calculator/presentation/screens/history_screen.dart';
import 'package:disabilitymne/features/calculator/presentation/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class CalculatorScreen extends GetView<CalculatorController> {
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
          child: Obx(() {
            if (controller.isLoading.value &&
                controller.nutritionData.value == null) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            if (controller.errorMessage.isNotEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        controller.errorMessage.value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => controller.retry(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (controller.nutritionData.value == null) {
              return const Center(
                child: Text(
                  'No data available',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return _buildLoadedState(controller.nutritionData.value!);
          }),
        ),
      ),
    );
  }

  Widget _buildLoadedState(NutritionData data) {
    final diaryDate = data.date;
    final eatenKcal = data.energy.eatenKcal;
    final remainingKcal = data.energy.remainingKcal;
    final burnedKcal = data.energy.burnedKcal;
    final goalKcal = data.energy.goalKcal;

    final gaugeMax = goalKcal <= 0 ? 1.0 : goalKcal;
    final gaugeValue = eatenKcal.clamp(0, gaugeMax).toDouble();

    final carbs = data.macroProgress.carbs;
    final protein = data.macroProgress.protein;
    final fat = data.macroProgress.fat;
    final meals = data.meals;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => controller.changeDay(-1),
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 16,
                  ),
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
                onTap: () => controller.changeDay(1),
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
                      Column(
                        children: [
                          Text(
                            "Eaten",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${eatenKcal.toStringAsFixed(0)} kcal",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
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
                      Column(
                        children: [
                          Text(
                            "Burned",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${burnedKcal.toStringAsFixed(0)} kcal",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MacroCard(
                        title: 'Carbs',
                        value:
                            '${carbs.consumedG} / ${carbs.targetG}g',
                        progress: (carbs.progressPercent / 100).clamp(0, 1),
                      ),
                      MacroCard(
                        title: 'Protein',
                        value:
                            '${protein.consumedG.toStringAsFixed(0)} / ${protein.targetG.toStringAsFixed(0)}g',
                        progress: (protein.progressPercent / 100).clamp(0, 1),
                      ),
                      MacroCard(
                        title: 'Fat',
                        value:
                            '${fat.consumedG.toStringAsFixed(0)} / ${fat.targetG.toStringAsFixed(0)}g',
                        progress: (fat.progressPercent / 100).clamp(0, 1),
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
                    final mealType = meal.mealType;
                    final title = meal.mealLabel.isEmpty
                        ? mealType
                        : meal.mealLabel;
                    final eaten = meal.totals.caloriesKcal.toStringAsFixed(0);
                    final minKcal = meal
                        .recommendation
                        .recommendedCalories
                        .minKcal
                        .toStringAsFixed(0);
                    final maxKcal = meal
                        .recommendation
                        .recommendedCalories
                        .maxKcal
                        .toStringAsFixed(0);
                    final entries = meal.totalEntries;
                    return MealTile(
                      title: title,
                      subtitle:
                          'Recommended: $minKcal - $maxKcal kcal  |  Eaten: $eaten kcal  |  Entries: $entries',
                      onTap: () {
                        Get.to(
                          () => HistoryScreen(
                            meal: meal,
                          ),
                        );
                      },
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
