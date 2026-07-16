import 'package:disabilitymne/core/helpers/premium_access.dart';
import 'package:disabilitymne/features/auth/presentation/widgets/background_image.dart';
import 'package:disabilitymne/features/nutrition_plans/controller/nutrition_plans_controller.dart';
import 'package:disabilitymne/features/nutrition_plans/model/nutrition_plan_model.dart';
import 'package:disabilitymne/features/nutrition_plans/services/nutrition_plans_repository.dart';
import 'package:disabilitymne/features/profile/controller/profile_controller.dart';
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

  static const List<Map<String, dynamic>> _weekDays = [
    {'index': 1, 'label': 'Mon'},
    {'index': 2, 'label': 'Tue'},
    {'index': 3, 'label': 'Wed'},
    {'index': 4, 'label': 'Thu'},
    {'index': 5, 'label': 'Fri'},
    {'index': 6, 'label': 'Sat'},
    {'index': 7, 'label': 'Sun'},
  ];

  final RecipeController controller = Get.isRegistered<RecipeController>()
      ? Get.find<RecipeController>()
      : Get.put(RecipeController());

  String _selectedMealType = _mealTypes.first;

  String _dayLabel(NutritionDayModel day) {
    if (day.label.trim().isNotEmpty) return day.label.trim();
    final match = _weekDays.firstWhere(
      (d) => d['index'] == day.dayIndex,
      orElse: () => const {},
    );
    final label = match['label'] as String?;
    if (label != null && label.isNotEmpty) return label;
    return 'Day ${day.dayIndex}';
  }

  NutritionPlansController get _nutritionController {
    if (Get.isRegistered<NutritionPlansController>()) {
      return Get.find<NutritionPlansController>();
    }
    return Get.put(
      NutritionPlansController(repository: Get.find<NutritionPlansRepository>()),
    );
  }

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
    return Obx(() {
      final isPremium = Get.isRegistered<ProfileController>() &&
          isPremiumActiveUser(Get.find<ProfileController>().user.value);
      if (isPremium) {
        return _buildPremiumMealPlans();
      }
      return _buildCatalogRecipes();
    });
  }

  Widget _buildCatalogRecipes() {
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

  Widget _buildPremiumMealPlans() {
    final nutrition = _nutritionController;

    return Scaffold(
      body: BackgroundImage(
        child: SafeArea(
          child: Obx(() {
            if (nutrition.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            final plans = nutrition.plans;
            if (plans.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meal Plans',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      premiumAwaitingCoachMessage,
                      style: TextStyle(color: Colors.white70, height: 1.4),
                    ),
                  ],
                ),
              );
            }

            final plan = plans.first;
            final planDays = plan.nutritionDays;
            if (planDays.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meal Plans',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      premiumAwaitingCoachMessage,
                      style: TextStyle(color: Colors.white70, height: 1.4),
                    ),
                  ],
                ),
              );
            }

            final hasSelected =
                planDays.any((d) => d.dayIndex == nutrition.selectedDayIndex.value);
            final selectedDay = hasSelected
                ? nutrition.selectedDayIndex.value
                : planDays.first.dayIndex;
            final day = planDays.firstWhere(
              (d) => d.dayIndex == selectedDay,
              orElse: () => planDays.first,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Meal Plans',
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plan.title,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: planDays.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final planDay = planDays[index];
                      final dayIndex = planDay.dayIndex;
                      final selected = dayIndex == selectedDay;
                      return InkWell(
                        onTap: () => nutrition.selectedDayIndex.value = dayIndex,
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
                              _dayLabel(planDay),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight:
                                    selected ? FontWeight.w700 : FontWeight.w500,
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
                  child: day.meals.isEmpty
                      ? const Center(
                          child: Text(
                            'No meals for this day yet.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: day.meals.length,
                          itemBuilder: (context, index) {
                            final meal = day.meals[index];
                            final recipe = meal.recipe;
                            if (recipe == null) return const SizedBox.shrink();
                            return RecipeCard(
                              recipe: RecipeModel(
                                id: recipe.id,
                                recipeName: recipe.recipeName,
                                recipeType: recipe.recipeType,
                                caloriesKcal: recipe.caloriesKcal?.toDouble(),
                                recipeImage: recipe.recipeImage,
                                durationMinutes: recipe.durationMinutes,
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }),
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
