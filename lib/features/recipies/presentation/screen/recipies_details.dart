import 'package:flutter/material.dart';

class RecipeDetailsScreen extends StatelessWidget {
  const RecipeDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0F223A),
      body: Column(
        children: [

          /// TOP IMAGE SECTION
          Container(
            height: 280,
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
              image: DecorationImage(
                image: NetworkImage(
                  "https://images.unsplash.com/photo-1517673132405-a56a62b18caf",
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.arrow_back, color: Colors.white),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            "Back",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      ],
                    ),

                    /// Favorite Button
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 18,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

          /// CONTENT
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xff1C3557),
                    Color(0xff0F223A),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// Meal info
                    const Center(
                      child: Text(
                        "420 Kcal | 10 min | Breakfast",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Title
                    const Text(
                      "High protein Oat Bowl",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// NUTRITION CARDS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        NutritionCard(title: "420", subtitle: "Kcal"),
                        NutritionCard(title: "28g", subtitle: "Protein"),
                        NutritionCard(title: "52g", subtitle: "Carbs"),
                        NutritionCard(title: "8g", subtitle: "fat"),
                      ],
                    ),

                    const SizedBox(height: 28),

                    /// INGREDIENTS
                    const Text(
                      "Ingredients",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    const IngredientItem(
                        number: 1, text: "High Protein Oat Bowl"),
                    const IngredientItem(
                        number: 2, text: "1 scoop protein powder"),
                    const IngredientItem(number: 3, text: "1 banana, sliced"),
                    const IngredientItem(number: 4, text: "1 tbsp almond"),
                    const IngredientItem(
                        number: 5, text: "1 cup almond milk"),
                    const IngredientItem(number: 6, text: "1 tsp honey"),

                    const SizedBox(height: 24),

                    /// HOW TO PREPARE
                    const Text(
                      "How to prepare a meal",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                      style: TextStyle(color: Colors.white70, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class NutritionCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const NutritionCard({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          )
        ],
      ),
    );
  }
}

class IngredientItem extends StatelessWidget {
  final int number;
  final String text;

  const IngredientItem({
    super.key,
    required this.number,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [

          /// Number Circle
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xff2C5A87),
            child: Text(
              number.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),

          const SizedBox(width: 12),

          /// Ingredient text
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}