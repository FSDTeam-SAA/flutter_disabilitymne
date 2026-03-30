import 'package:disabilitymne/features/auth/presentation/widgets/background_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
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
  bool _favoriteBusy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getRecipeDetail(widget.id);
    });
  }

  Future<void> _refreshRecipe() async {
    await controller.getRecipeDetail(widget.id);
  }

  Widget _buildRefreshableState({required Widget child}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final minHeight = constraints.maxHeight > 48
            ? constraints.maxHeight - 48
            : 0.0;

        return RefreshIndicator(
          onRefresh: _refreshRecipe,
          color: const Color(0xff6FA8DC),
          backgroundColor: const Color(0xff0E1A2B),
          child: ListView(
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
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackgroundImage(
        child: Obx(() {
          if (controller.isDetailLoading.value) {
            return _buildRefreshableState(
              child: const CircularProgressIndicator(color: Colors.white),
            );
          }

          final recipe = controller.recipeDetail.value;
          if (recipe == null) {
            return _buildRefreshableState(
              child: const Text(
                "Recipe not found",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final String title = recipe.recipeName ?? "Recipe Details";
          final String image =
              recipe.recipeImage ??
              "https://images.unsplash.com/photo-1517673132405-a56a62b18caf";
          final bool isFavorite = recipe.isFavorite == true;

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
                                    size: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    "Back",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        GestureDetector(
                          onTap: _favoriteBusy
                              ? null
                              : () async {
                                  setState(() {
                                    _favoriteBusy = true;
                                  });
                                  await controller.toggleFavorite(
                                    recipeId: widget.id,
                                    isFavorite: !isFavorite,
                                  );
                                  if (!mounted) return;
                                  setState(() {
                                    _favoriteBusy = false;
                                  });
                                },
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white,
                            child: _favoriteBusy
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black87,
                                    ),
                                  )
                                : Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFavorite
                                        ? Colors.red
                                        : Colors.black87,
                                    size: 18,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// CONTENT
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshRecipe,
                  color: const Color(0xff6FA8DC),
                  backgroundColor: const Color(0xff0E1A2B),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
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
                                      isLast:
                                          entry.key ==
                                          recipe.ingredients!.length - 1,
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

                          recipe.howToPrepare != null &&
                                  recipe.howToPrepare!.isNotEmpty
                              ? Html(
                                  data: recipe.howToPrepare,
                                  shrinkWrap: true,
                                  style: {
                                    "body": Style(
                                      color: Colors.white70,
                                      margin: Margins.zero,
                                      padding: HtmlPaddings.zero,
                                      lineHeight: LineHeight.number(1.5),
                                      fontSize: FontSize(14.0),
                                    ),
                                    "p": Style(
                                      color: Colors.white70,
                                      margin: Margins.only(bottom: 8.0),
                                      padding: HtmlPaddings.zero,
                                      lineHeight: LineHeight.number(1.5),
                                    ),
                                  },
                                )
                              : const Text(
                                  "No preparation instructions available",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    height: 1.5,
                                  ),
                                ),
                        ],
                      ),
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
  final bool isLast;

  const IngredientItem({
    super.key,
    required this.number,
    required this.text,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Number Circle and Line
          Column(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xff2C5A87),
                child: Text(
                  number.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1,
                    color: Colors.white.withValues(alpha:0.3),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 12),

          /// Ingredient text
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(text, style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
