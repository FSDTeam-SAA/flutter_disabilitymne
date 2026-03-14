import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';


class FoodDetailScreen extends StatefulWidget {
  const FoodDetailScreen({super.key});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  String selectedQuantity = '1';
  String selectedUnit = 'Whole (125g)';
  String selectedMeal = 'Breakfast';

  final quantities = ['1', '2', '3', '0.5', 'Custom'];
  final units = ['Whole (125g)', 'Medium (182g)', 'Small (149g)'];
  final meals = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151A24), // matching dark bg
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Custom AppBar equivalent
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {},
                          child: const Icon(Icons.close, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {},
                          child: const Icon(Icons.favorite_border, color: Colors.white, size: 22),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Title
              const Padding(
                padding: EdgeInsets.only(top: 8, bottom: 20),
                child: Text(
                  'Apple',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),

              // Quantity & Unit row
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: selectedQuantity,
                      dropdownColor: const Color(0xFF1D222F),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      items: quantities
                          .map((q) => DropdownMenuItem(
                                value: q,
                                child: Text(q),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => selectedQuantity = v!),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: selectedUnit,
                      dropdownColor: const Color(0xFF1D222F),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      items: units
                          .map((u) => DropdownMenuItem(
                                value: u,
                                child: Text(u),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => selectedUnit = v!),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Meal dropdown
              DropdownButtonFormField<String>(
                value: selectedMeal,
                dropdownColor: const Color(0xFF1D222F),
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                style: const TextStyle(color: Colors.white, fontSize: 15),
                items: meals
                    .map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(m),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => selectedMeal = v!),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 24),

              // Nutrition Container
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1D222F),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department_outlined, color: Colors.grey, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          '73 Kcal',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Macro circles row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildMacroCircle(
                          percent: 0.94,
                          color: const Color(0xFF6DA7D3), // light blue
                          label: 'Carbs',
                          value: '10g',
                          percentText: '94%',
                        ),
                        _buildMacroCircle(
                          percent: 0.02,
                          color: const Color(0xFF8CE172), // light green
                          label: 'protein',
                          value: '0,2 g',
                          percentText: '2%',
                        ),
                        _buildMacroCircle(
                          percent: 0.03,
                          color: const Color(0xFF53A1FB), // blue
                          label: 'protein', // Using exact text from mockup
                          value: '0,2 g',
                          percentText: '3%',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Track button
              GestureDetector(
                onTap: () {},
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
                  child: const Center(
                    child: Text(
                      "Track",
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
          backgroundColor: Colors.white.withOpacity(0.08),
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