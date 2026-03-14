import 'package:disabilitymne/features/calculator/presentation/screens/choose_screen.dart';
import 'package:disabilitymne/features/calculator/presentation/screens/history_screen.dart';
import 'package:disabilitymne/features/calculator/presentation/screens/meals_logged_screen.dart';
import 'package:disabilitymne/features/calculator/presentation/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  final double eatenCalories = 1500;
  final double goalCalories = 1792;

  double get remainingCalories => 1792 - 1500;

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 10),

                /// FIXED DATE HEADER (NOT SCROLLABLE)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "TODAY, 23 FEB",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// SCROLLABLE CONTENT
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        /// CALORIE GAUGE
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,

                          children: [
                            Column(
                              children: [
                                Text(
                                  "Eaten",
                                  style: TextStyle(color: Colors.white70),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "1500",
                                  style: TextStyle(
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
                                    maximum: goalCalories,
                                    showLabels: false,
                                    showTicks: false,
                                    axisLineStyle: const AxisLineStyle(
                                      thickness: 0.18,
                                      thicknessUnit: GaugeSizeUnit.factor,
                                      color: Colors.white24,
                                    ),
                                    pointers: [
                                      RangePointer(
                                        value: eatenCalories,
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
                                              "Remaining",
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              remainingCalories.toStringAsFixed(
                                                0,
                                              ),
                                              style: const TextStyle(
                                                fontSize: 30,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Goal ${goalCalories.toInt()} Kcal",
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
                                  style: TextStyle(color: Colors.white70),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "0",
                                  style: TextStyle(
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

                        /// MACRO CARDS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            MacroCard(
                              title: "Carbs",
                              value: "17 / 328g",
                              progress: 0.1,
                            ),
                            MacroCard(
                              title: "Protein",
                              value: "1 / 131g",
                              progress: 0.05,
                            ),
                            MacroCard(
                              title: "Fat",
                              value: "0 / 87g",
                              progress: 0.02,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        /// MEALS LOGGED
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Meals Logged",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        MealTile(
                          title: "Breakfast",
                          subtitle: "Recommended: 656 - 918 kcal",
                          onTap: () {
                            Get.to(() => HistoryScreen());
                          },
                        ),
                        MealTile(
                          title: "Lunch",
                          subtitle: "Recommended: 787 - 1049 kcal",
                          onTap: () {
                            Get.to(() => MealDetailScreen());
                          },
                        ),
                        MealTile(
                          title: "Dinner",
                          subtitle: "Recommended: 1023 - 1338 kcal",
                          onTap: () {
                            Get.to(() => FoodDetailScreen());
                          },
                        ),
                        MealTile(
                          title: "Snack",
                          subtitle: "Recommended: 656 - 918 kcal",
                          onTap: () {
                            Get.to(() => BreakfastSearchScreen());
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

  const MealTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.onTap,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
            Container(
              height: 34,
              width: 34,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white30),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
