import 'package:disabilitymne/features/auth/presentation/widgets/background_image.dart';
import 'package:disabilitymne/features/recipies/controller/recipe_conreoller.dart';
import 'package:disabilitymne/features/recipies/model/recipes_model.dart';
import 'package:disabilitymne/features/recipies/presentation/screen/recipies_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RecipesScreen extends StatelessWidget {
  RecipesScreen({super.key});

  final RecipeController controller = Get.put(RecipeController());

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

              const SizedBox(height: 20),

              /// Exercise List
              Expanded(
                child: Obx(
                  () => ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.recipeList.length,
                    itemBuilder: (context, index) {
                      RecipeModel recipe = controller.recipeList[index];

                      return RecipeCard(recipe: recipe);
                    },
                  ),
                ),
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
              backgroundImage: NetworkImage(recipe.recipeImage ?? ""),
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
                  Row(
                    children: [
                      Text(
                        recipe.caloriesKcal?.toString() ?? "",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(6.0, 0, 6.0, 0),
                        child: Text(
                          "|",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        recipe.recipeDuration ?? "",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(6.0, 0, 6.0, 0),
                        child: Text(
                          "|",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
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

            // const CircleAvatar(
            //   radius: 14,
            //   backgroundColor: Colors.white,
            //   child: Icon(Icons.favorite, color: Colors.red, size: 16),
            // ),
          ],
        ),
      ),
    );
  }
}
