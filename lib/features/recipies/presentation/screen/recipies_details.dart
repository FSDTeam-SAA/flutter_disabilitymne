import 'package:disabilitymne/features/auth/presentation/widgets/background_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/features/recipies/controller/recipe_conreoller.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final String id;
  const RecipeDetailsScreen({super.key, required this.id});

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  final RecipeController controller = Get.find<RecipeController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getRecipeDetail(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackgroundImage(
        child: Obx(() {
          if (controller.isDetailLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          final recipe = controller.recipeDetail.value;
          if (recipe == null) {
            return const Center(
              child: Text(
                "Recipe not found",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final String title = recipe.recipeName ?? "Recipe Details";
          final String image =
              recipe.recipeImage ??
              "https://images.unsplash.com/photo-1517673132405-a56a62b18caf";

          return Column(
            children: [
              /// TOP IMAGE SECTION
              Container(
                height: 280,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(image),
                    fit: BoxFit.cover,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.arrow_back_ios,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    "Back",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
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
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// CONTENT
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1C2A42), Color(0xFF121A2C)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Title
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// NUTRITION CARDS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            NutritionCard(
                              title: "${recipe.caloriesKcal ?? 0}",
                              subtitle: "Kcal",
                            ),
                            NutritionCard(
                              title: "${recipe.proteinG ?? 0}g",
                              subtitle: "Protein",
                            ),
                            NutritionCard(
                              title: "${recipe.carbsG ?? 0}g",
                              subtitle: "Carbs",
                            ),
                            NutritionCard(
                              title: "${recipe.fatG ?? 0}g",
                              subtitle: "fat",
                            ),
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
                        if (recipe.ingredients != null &&
                            recipe.ingredients!.isNotEmpty)
                          Column(
                            children: recipe.ingredients!
                                .asMap()
                                .entries
                                .map(
                                  (entry) => IngredientItem(
                                    number: entry.key + 1,
                                    text: entry.value,
                                  ),
                                )
                                .toList(),
                          )
                        else
                          const Text(
                            "No ingredients listed",
                            style: TextStyle(color: Colors.white70),
                          ),

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

                        Text(
                          recipe.howToPrepare ??
                              "No preparation instructions available",
                          style: const TextStyle(
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class NutritionCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const NutritionCard({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF253A55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF4B7FA8)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class IngredientItem extends StatelessWidget {
  final int number;
  final String text;

  const IngredientItem({super.key, required this.number, required this.text});

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
            child: Text(text, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
