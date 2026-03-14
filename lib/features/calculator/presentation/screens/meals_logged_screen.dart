import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class MealDetailScreen extends StatelessWidget {
  const MealDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: [

                const SizedBox(height: 10),

                /// CLOSE BUTTON
                Row(
                  children: [
                    Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white54),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          size: 18, color: Colors.white),
                    )
                  ],
                ),

                const SizedBox(height: 20),

                /// GAUGE
                SizedBox(
                  height: 220,
                  width: 220,
                  child: SfRadialGauge(
                    axes: [
                      RadialAxis(
                        minimum: 0,
                        maximum: 100,
                        showTicks: false,
                        showLabels: false,
                        axisLineStyle: const AxisLineStyle(
                          thickness: 0.18,
                          thicknessUnit: GaugeSizeUnit.factor,
                          color: Colors.white24,
                        ),
                        pointers: const [
                          RangePointer(
                            value: 5,
                            width: 0.18,
                            sizeUnit: GaugeSizeUnit.factor,
                            color: Color(0xFF7EB6D8),
                            cornerStyle: CornerStyle.bothCurve,
                          )
                        ],
                        annotations: const [
                          GaugeAnnotation(
                            angle: 90,
                            positionFactor: 0.1,
                            widget: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "5",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Kcal",
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 14),
                                )
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// BREAKFAST TITLE
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Breakfast",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600),
                  ),
                ),

                const SizedBox(height: 4),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "24 February, 2026",
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                ),

                const SizedBox(height: 20),

                /// FOOD CARD
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white30),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white.withOpacity(0.05),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Apple",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "50 kcal",
                            style: TextStyle(color: Colors.white60),
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: const [
                              Icon(Icons.edit_outlined, size: 14, color: Colors.white60),
                              SizedBox(width: 6),
                              Text(
                                "10g",
                                style: TextStyle(color: Colors.white60),
                              )
                            ],
                          )
                        ],
                      ),

                      Container(
                        height: 34,
                        width: 34,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white30),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            size: 18, color: Colors.white),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                /// KCAL CARD
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white30),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white.withOpacity(0.05),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Text(
                        "5 Kcal",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600),
                      ),

                      const SizedBox(height: 12),

                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Recommended",
                              style: TextStyle(color: Colors.white60)),
                          Text("312 - 468 kcal",
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),

                      const SizedBox(height: 6),

                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Eaten",
                              style: TextStyle(color: Colors.white60)),
                          Text("5 Kcal",
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),

                      const SizedBox(height: 16),

                      const Divider(color: Colors.white24),

                      const SizedBox(height: 12),

                      const Text(
                        "KCAL UNDER",
                        style: TextStyle(color: Colors.white70),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [

                          /// MACRO CIRCLE
                          SizedBox(
                            height: 80,
                            width: 80,
                            child: SfRadialGauge(
                              axes: [
                                RadialAxis(
                                  minimum: 0,
                                  maximum: 100,
                                  showLabels: false,
                                  showTicks: false,
                                  axisLineStyle: const AxisLineStyle(
                                    thickness: 0.2,
                                    thicknessUnit: GaugeSizeUnit.factor,
                                    color: Colors.white24,
                                  ),
                                  pointers: const [
                                    RangePointer(
                                      value: 100,
                                      width: 0.2,
                                      sizeUnit: GaugeSizeUnit.factor,
                                      color: Color(0xFF6DA7D3),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),

                          const SizedBox(width: 24),

                          /// MACRO TEXT
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                MacroRow("Carbs", "100%", Color(0xFF6DA7D3)),
                                MacroRow("Protein", "0%", Color(0xFF8CE172)),
                                MacroRow("Fat", "0%", Color(0xFF53A1FB)),
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// BUTTON
                Container(
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
                  child: const Center(
                    child: Text(
                      "Adjust My Meal",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                const SizedBox(height: 20)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MacroRow extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const MacroRow(this.title, this.value, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(radius: 4, backgroundColor: color),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}