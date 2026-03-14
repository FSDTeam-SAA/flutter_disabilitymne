import 'package:flutter/material.dart';

class BreakfastSearchScreen extends StatelessWidget {
  const BreakfastSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151A24),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header / Title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Breakfast",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Search field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: TextField(
                  autofocus: true,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: "Apple",
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 22),
                    suffixIcon: const Icon(Icons.close, color: Colors.white, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // "Results" label
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                "Results",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // List of results
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: const [
                  FoodTile(
                    title: "Apple",
                    calories: "73 kcal",
                    subtitle: "1 Whole (125 g)",
                  ),
                  FoodTile(
                    title: "Apple - Pink Lady",
                    calories: "65 kcal",
                    subtitle: "1 Whole (125 g)",
                  ),
                  FoodTile(
                    title: "Apple pie",
                    calories: "296 kcal",
                    subtitle: "1 Piece (125 g)",
                  ),
                  FoodTile(
                    title: "Apple Juice",
                    calories: "113 kcal",
                    subtitle: "1 regular glass (240 ml)",
                  ),
                  FoodTile(
                    title: "Apple pie, one crust",
                    calories: "286 kcal",
                    subtitle: "1 Standard serving (145 g)",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FoodTile extends StatelessWidget {
  final String title;
  final String calories;
  final String? subtitle;
  final bool showKcal;

  const FoodTile({
    super.key,
    required this.title,
    required this.calories,
    this.subtitle,
    this.showKcal = true,
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
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 13,
                        ),
                      ),
                    ],
                    if (subtitle != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 14, color: Colors.grey[400]),
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
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white30),
                  color: Colors.transparent,
                ),
                child: const Icon(
                  Icons.add,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}