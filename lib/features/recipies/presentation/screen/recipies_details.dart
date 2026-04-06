import 'package:disabilitymne/features/auth/presentation/widgets/background_image.dart';
import 'package:app_pigeon/app_pigeon.dart';
import 'package:disabilitymne/core/constants/api_endpoints.dart';
import 'package:disabilitymne/features/calculator/controller/calculator_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/features/recipies/controller/recipe_conreoller.dart';
import 'package:disabilitymne/features/recipies/model/recipes_model.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final String id;
  const RecipeDetailsScreen({super.key, required this.id});

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  final RecipeController controller = Get.find<RecipeController>();
  bool _quickAddBusy = false;

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

  String _normalizeMealType(String? value) {
    final normalized = (value ?? '').trim().toLowerCase();
    if (normalized == 'breakfast' ||
        normalized == 'lunch' ||
        normalized == 'dinner' ||
        normalized == 'snack') {
      return normalized;
    }
    return 'other';
  }

  String _titleCase(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  String _todayApiDate() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  Future<String?> _selectMealType(String defaultMealType) async {
    const mealTypes = ['breakfast', 'lunch', 'dinner', 'snack', 'other'];
    String selectedMealType = defaultMealType;

    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF1F2B42),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add to meal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...mealTypes.map(
                      (mealType) => RadioListTile<String>(
                        value: mealType,
                        groupValue: selectedMealType,
                        onChanged: (value) {
                          if (value == null) return;
                          setSheetState(() {
                            selectedMealType = value;
                          });
                        },

                        fillColor: MaterialStateProperty.resolveWith<Color>((
                          states,
                        ) {
                          if (states.contains(MaterialState.selected)) {
                            return const Color(0xff6FA8DC); // selected color
                          }
                          return Colors.white; // inactive color ✅
                        }),
                        title: Text(
                          _titleCase(mealType),
                          style: const TextStyle(color: Colors.white),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff6FA8DC),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.of(
                          bottomSheetContext,
                        ).pop(selectedMealType),
                        child: const Text('Add to Meal'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _quickAddRecipeToDiary() async {
    final recipe = controller.recipeDetail.value;
    if (recipe == null || _quickAddBusy) return;

    final defaultMealType = _normalizeMealType(recipe.recipeType);
    final selectedMealType = await _selectMealType(defaultMealType);
    if (selectedMealType == null || !mounted) return;

    setState(() {
      _quickAddBusy = true;
    });

    try {
      final imageUrl =
          recipe.recipeImage ??
          ((recipe.recipeImages != null && recipe.recipeImages!.isNotEmpty)
              ? recipe.recipeImages!.first
              : '');

      await Get.find<AuthorizedPigeon>().post(
        ApiEndpoints.nutritionDiaryEntries,
        data: {
          'date': _todayApiDate(),
          'mealType': selectedMealType,
          'foodName': recipe.recipeName ?? 'Recipe',
          'source': 'manual',
          'quantity': 1,
          'servingLabel': 'recipe',
          'caloriesKcal': recipe.caloriesKcal ?? 0,
          'proteinG': recipe.proteinG ?? 0,
          'carbsG': recipe.carbsG ?? 0,
          'fatG': recipe.fatG ?? 0,
          'fiberG': 0,
          'sugarG': 0,
          'imageUrl': imageUrl,
          'notes': '',
        },
      );

      if (Get.isRegistered<CalculatorController>()) {
        await Get.find<CalculatorController>().fetchDiary();
      }

      if (!mounted) return;
      Get.snackbar(
        'Added',
        'Recipe added to ${_titleCase(selectedMealType)}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      if (!mounted) return;
      Get.snackbar(
        'Error',
        'Failed to add recipe to meal',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() {
          _quickAddBusy = false;
        });
      }
    }
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

                        // GestureDetector(
                        //   onTap: _favoriteBusy
                        //       ? null
                        //       : () async {
                        //           setState(() {
                        //             _favoriteBusy = true;
                        //           });
                        //           await controller.toggleFavorite(
                        //             recipeId: widget.id,
                        //             isFavorite: !isFavorite,
                        //           );
                        //           if (!mounted) return;
                        //           setState(() {
                        //             _favoriteBusy = false;
                        //           });
                        //         },
                        //   child: CircleAvatar(
                        //     radius: 16,
                        //     backgroundColor: Colors.white,
                        //     child: _favoriteBusy
                        //         ? const SizedBox(
                        //             width: 14,
                        //             height: 14,
                        //             child: CircularProgressIndicator(
                        //               strokeWidth: 2,
                        //               color: Colors.black87,
                        //             ),
                        //           )
                        //         : Icon(
                        //             isFavorite
                        //                 ? Icons.favorite
                        //                 : Icons.favorite_border,
                        //             color: isFavorite
                        //                 ? Colors.red
                        //                 : Colors.black87,
                        //             size: 18,
                        //           ),
                        //   ),
                        // ),
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
                                title: formatRecipeNutritionValue(
                                  recipe.caloriesKcal,
                                ),
                                subtitle: "Kcal",
                              ),
                              NutritionCard(
                                title:
                                    "${formatRecipeNutritionValue(recipe.proteinG)}g",
                                subtitle: "Protein",
                              ),
                              NutritionCard(
                                title:
                                    "${formatRecipeNutritionValue(recipe.carbsG)}g",
                                subtitle: "Carbs",
                              ),
                              NutritionCard(
                                title:
                                    "${formatRecipeNutritionValue(recipe.fatG)}g",
                                subtitle: "fat",
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff6FA8DC),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _quickAddBusy
                                  ? null
                                  : _quickAddRecipeToDiary,
                              child: _quickAddBusy
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Add to Meal',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                            ),
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
                                  .map(
                                    (ingredient) =>
                                        IngredientItem(text: ingredient),
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
  final String text;

  const IngredientItem({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF6FA8DC),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
