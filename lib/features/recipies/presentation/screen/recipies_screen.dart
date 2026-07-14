import 'package:disabilitymne/features/auth/presentation/widgets/background_image.dart';
import 'package:disabilitymne/features/recipies/controller/recipe_conreoller.dart';
import 'package:disabilitymne/features/recipies/model/recipes_model.dart';
import 'package:disabilitymne/features/recipies/presentation/screen/recipies_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  static const List<String> _mealTypes = [
    'breakfast',
    'lunch',
    'dinner',
    'snack',
  ];

  final RecipeController controller = Get.isRegistered<RecipeController>()
      ? Get.find<RecipeController>()
      : Get.put(RecipeController());

  String _selectedMealType = _mealTypes.first;

  @override
  void initState() {
    super.initState();
    controller.ensureMealLoaded(_selectedMealType);
  }

  String _tabLabel(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundImage(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Recipes",
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Personalized plans & recipes",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _mealTypes.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final mealType = _mealTypes[index];
                    final selected = mealType == _selectedMealType;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedMealType = mealType;
                        });
                        controller.ensureMealLoaded(mealType);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF6FA8DC)
                              : Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF8EC4F1)
                                : Colors.white24,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _tabLabel(mealType),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  final mealState = controller.stateForMealType(
                    _selectedMealType,
                  );
                  final recipes = mealState.items;

                  return RefreshIndicator(
                    onRefresh: () =>
                        controller.refreshMealType(_selectedMealType),
                    color: Colors.white,
                    child:
                        ((mealState.isInitialLoading || !mealState.hasLoaded) &&
                            recipes.isEmpty)
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 180),
                              Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : recipes.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              vertical: 180,
                              horizontal: 24,
                            ),
                            children: [
                              Center(
                                child: Text(
                                  'No ${_selectedMealType.toLowerCase()} recipes found',
                                  style: const TextStyle(color: Colors.white70),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          )
                        : NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              if (notification.metrics.pixels >=
                                  notification.metrics.maxScrollExtent - 200) {
                                controller.loadMoreMealType(_selectedMealType);
                              }
                              return false;
                            },
                            child: ListView.builder(
                              key: PageStorageKey<String>(
                                'recipes-$_selectedMealType',
                              ),
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount:
                                  recipes.length +
                                  (mealState.isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index >= recipes.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                }

                                final recipe = recipes[index];
                                return RecipeCard(recipe: recipe);
                              },
                            ),
                          ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final RecipeModel recipe;

  const RecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final imageUrl = recipe.recipeImage ?? '';

    return InkWell(
      onTap: () {
        Get.to(() => RecipeDetailsScreen(id: recipe.id ?? ""));
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xffE6EEF6),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: const Color(0xFFD5E2EF),
              backgroundImage: imageUrl.isNotEmpty
                  ? CachedNetworkImageProvider(imageUrl)
                  : null,
              child: imageUrl.isEmpty
                  ? const Icon(
                      Icons.restaurant,
                      color: Color(0xFF59748F),
                      size: 28,
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.recipeName ?? "",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "${formatRecipeNutritionValue(recipe.caloriesKcal)} kcal",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          "|",
                          style: TextStyle(color: Colors.black, fontSize: 14),
                        ),
                      ),
                      Text(
                        recipe.recipeDuration ?? "",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          "|",
                          style: TextStyle(color: Colors.black, fontSize: 14),
                        ),
                      ),
                      Text(
                        recipe.recipeType ?? "",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ],
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
