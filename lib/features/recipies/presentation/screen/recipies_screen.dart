import 'package:disabilitymne/features/auth/presentation/widgets/background_image.dart';
import 'package:flutter/material.dart';

class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundImage(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
        
              const SizedBox(height: 20),
        
              /// Category Buttons
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: const [
                    CategoryChip(title: "All", selected: true),
                    CategoryChip(title: "Breakfast"),
                    CategoryChip(title: "Launch"),
                    CategoryChip(title: "Dinner"),
                    CategoryChip(title: "Snacks"),
                  ],
                ),
              ),
        
              const SizedBox(height: 20),
        
              /// Recipe List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: const [
                    RecipeCard(
                      title: "High Protein Oat Bowl",
                      subtitle: "420 Kcal | 10 min | Breakfast",
                      image:
                          "https://images.unsplash.com/photo-1517673132405-a56a62b18caf",
                    ),
                    RecipeCard(
                      title: "Grilled Chicken Salad",
                      subtitle: "380 Kcal | 20 min | Lunch",
                      image:
                          "https://images.unsplash.com/photo-1546069901-ba9599a7e63c",
                    ),
                    RecipeCard(
                      title: "Salmon & Quinoa Bowl",
                      subtitle: "520 Kcal | 25 min | Dinner",
                      image:
                          "https://images.unsplash.com/photo-1467003909585-2f8a72700288",
                    ),
                    RecipeCard(
                      title: "Greek yogurt Parfait",
                      subtitle: "290 Kcal | 5 min | Snack",
                      image:
                          "https://images.unsplash.com/photo-1488477181946-6428a0291777",
                    ),
                    RecipeCard(
                      title: "High Protein Oat Bowl",
                      subtitle: "420 Kcal | 10 min | Breakfast",
                      image:
                          "https://images.unsplash.com/photo-1517673132405-a56a62b18caf",
                    ),
                    RecipeCard(
                      title: "Grilled Chicken Salad",
                      subtitle: "380 Kcal | 20 min | Lunch",
                      image:
                          "https://images.unsplash.com/photo-1546069901-ba9599a7e63c",
                    ),
                    RecipeCard(
                      title: "Salmon & Quinoa Bowl",
                      subtitle: "520 Kcal | 25 min | Dinner",
                      image:
                          "https://images.unsplash.com/photo-1467003909585-2f8a72700288",
                    ),
                    RecipeCard(
                      title: "Greek yogurt Parfait",
                      subtitle: "290 Kcal | 5 min | Snack",
                      image:
                          "https://images.unsplash.com/photo-1488477181946-6428a0291777",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String title;
  final bool selected;

  const CategoryChip({
    super.key,
    required this.title,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: selected ? const Color(0xff1B365D) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;

  const RecipeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xffE6EEF6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          /// Image
          CircleAvatar(
            radius: 35,
            backgroundImage: NetworkImage(image),
          ),

          const SizedBox(width: 14),

          /// Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          /// Favorite Icon
          const CircleAvatar(
            radius: 14,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.favorite,
              color: Colors.red,
              size: 16,
            ),
          )
        ],
      ),
    );
  }
}