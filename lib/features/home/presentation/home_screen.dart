import 'package:disabilitymne/app/controller/app_ground_controller.dart';
import 'package:disabilitymne/core/theme/app_colors.dart';
import 'package:disabilitymne/features/auth/presentation/widgets/background_image.dart';
import 'package:disabilitymne/features/chat/presentation/chat_with_admin_screen.dart';
import 'package:disabilitymne/features/daily_tracker/presentation/daily_tracker_screen.dart';
import 'package:disabilitymne/features/progress/presentation/progress_screen.dart';
import 'package:disabilitymne/features/recipies/controller/recipe_conreoller.dart';
import 'package:disabilitymne/features/recipies/model/recipes_model.dart';
import 'package:disabilitymne/features/recipies/presentation/screen/recipies_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Home screen matching the design: header, hero card, My Programs, My Recipes, Quick Action.
class HomeScreen extends StatefulWidget {
  final bool? isPremiumUser;
  const HomeScreen({super.key, this.isPremiumUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _cardBlue = Color(0xFF1A233A);
  static const Color _accentLightBlue = Color(0xFF89C9E6);
  static const Color _seeAllBlue = Color(0xFF85C4E2);
  /// Selected tab background color (#4B7FA8); icon and text stay white
  static const Color _recipeTabSelectedBg = Color(0xFF4B7FA8);
  static const List<String> _recipeTabAssetPaths = [
    'assets/image/recipe_icon_breakfast.png',
    'assets/image/recipe_icon_lunch.png',
    'assets/image/recipe_icon_dinner.png',
  ];
  int _recipeTabIndex = 0;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<RecipeController>()) {
      Get.put(RecipeController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackgroundImage(
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(child: _buildHeroCard()),
              SliverToBoxAdapter(child: _buildSectionSpacer()),
              _buildMyProgramsSection(),
              SliverToBoxAdapter(child: _buildSectionSpacer()),
              _buildMyRecipesSection(),
              SliverToBoxAdapter(child: _buildSectionSpacer()),
              _buildQuickActionSection(),
              // Extra bottom space so content doesn't hide behind bottom nav
              const SliverToBoxAdapter(child: SizedBox(height: 140)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: _cardBlue,
              child: const Icon(Icons.person, color: Colors.white70, size: 32),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Evan 👋',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Good morning!',
                    style: TextStyle(
                      color: AppColors.primaryText.withValues( alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _accentLightBlue.withValues( alpha: .25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    // Card gradient: dark navy top-left to muted blue bottom-right (match design)
    const Color heroCardStart = Color(0xFF1A2B43);
    const Color heroCardEnd = Color(0xFF2B476F);
 
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [heroCardStart, heroCardEnd],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x66000000), // #000000 at 40% opacity (66 = 40% alpha)
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ready for your Fitness',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  
                  Text(
                    'Journey?',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              // buttonGradientStart,
                              // buttonGradientEnd,
                              Color(0xff4D7EA9),
                              Color(0xff89C9E6)
                            ],
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Get Started',
                              style: TextStyle(
                                color: AppColors.primaryText,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.chevron_right,
                              size: 22,
                              color: AppColors.primaryText,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 100,
              height: 100,
              child: Image.asset(
                'assets/image/fitness_journey_icon.png',
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Icon(
                  Icons.accessible_forward_rounded,
                  size: 72,
                  color: _accentLightBlue.withValues(alpha:  0.9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionSpacer() {
    return const SizedBox(height: 24);
  }

  Widget _buildMyProgramsSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Programs',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'See all',
                    style: TextStyle(
                      color: _seeAllBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildProgramCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramCard() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x66000000),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Image.asset(
              'assets/image/my_programs_card.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, _, _) => _buildProgramCardFallback(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgramCardFallback() {
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBlue,
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFF1A204C),
            const Color(0xFF2E3A7E),
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '3 Days | 12 Weeks | 60 Min',
                  style: TextStyle(
                    color: AppColors.primaryText.withValues(alpha:  0.85),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "BEGINNER'S\nBLUEPRINT",
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.fitness_center, color: Colors.white54, size: 40),
        ],
      ),
    );
  }

  Widget _buildMyRecipesSection() {
    const tabs = ['Breakfast', 'Lunch', 'Dinner'];
    final recipeController = Get.find<RecipeController>();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Recipes',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.find<AppGroundController>().changeIndex(2);
                  },
                  child: Text(
                    'See all',
                    style: TextStyle(
                      color: _seeAllBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(3, (index) {
                  final selected = _recipeTabIndex == index;
                  return Padding(
                    padding: EdgeInsets.only(right: index < 2 ? 10 : 0),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () =>
                            setState(() => _recipeTabIndex = index),
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? _recipeTabSelectedBg
                                : _cardBlue,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white24,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: ColorFiltered(
                                  colorFilter: const ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                  child: Image.asset(
                                    _recipeTabAssetPaths[index],
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, _, _) => Icon(
                                      [
                                        Icons.breakfast_dining_outlined,
                                        Icons.restaurant_outlined,
                                        Icons.dinner_dining_outlined,
                                      ][index],
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                tabs[index],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final all = recipeController.recipeList;
              if (all.isEmpty) {
                return SizedBox(
                  height: 160,
                  child: Center(
                    child: Text(
                      'No recipes yet',
                      style: TextStyle(
                        color: AppColors.primaryText.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }
              return SizedBox(
                height: 168,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: all.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: 140,
                      child: _buildRecipeCard(all[index], index),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeCard(RecipeModel recipe, int index) {
    final title = recipe.recipeName ?? 'Recipe';
    final kcal = '${recipe.caloriesKcal ?? 0} Kcal';
    final gradients = [
      [const Color(0xFF1A233A), const Color(0xFF2A4A3A)],
      [const Color(0xFF1A233A), const Color(0xFF4A3A2A)],
      [const Color(0xFF1A233A), const Color(0xFF3A3A4A)],
    ];
    final colors = gradients[index % gradients.length];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Get.to(() => RecipeDetailsScreen(id: recipe.id ?? '')),
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 168,
          child: Card(
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.zero,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _cardBlue,
                    _cardBlue,
                    colors[1].withValues(alpha: 0.6),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: recipe.recipeImage != null &&
                                recipe.recipeImage!.isNotEmpty
                            ? Image.network(
                                recipe.recipeImage!,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _recipePlaceholder(),
                              )
                            : _recipePlaceholder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    kcal,
                    style: TextStyle(
                      color: AppColors.primaryText.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _recipePlaceholder() {
    return Container(
      width: 70,
      height: 70,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white12,
      ),
      child: Icon(
        Icons.restaurant,
        color: Colors.white54,
        size: 32,
      ),
    );
  }

  Widget _buildQuickActionSection() {
    final showChat = widget.isPremiumUser == true;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Action',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    imagePath: 'assets/image/quick_action_progress.png',
                    label: 'Progress',
                    fallbackIcon: Icons.show_chart_rounded,
                    onTap: () => Get.to(() => const ProgressScreen()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(
                    imagePath: 'assets/image/quick_action_daily_tracker.png',
                    label: 'Daily Tracker',
                    fallbackIcon: Icons.checklist_rounded,
                    onTap: () => Get.to(() => const DailyTrackerScreen()),
                  ),
                ),
              ],
            ),
            if (showChat) ...[
              const SizedBox(height: 12),
              _buildChatWithCoachCta(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChatWithCoachCta() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
             Get.to(() => const ChatWithAdminScreen());
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28),
          decoration: BoxDecoration(
            color: _cardBlue,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: Image.asset(
                  'assets/image/chat_icon.png',
                  fit: BoxFit.contain,
                  // If asset missing, fall back to icon
                  errorBuilder: (_, _, _) => Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: AppColors.primaryText,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Chat with the Coach',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required String imagePath,
    required String label,
    required IconData fallbackIcon,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: _cardBlue,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color:Color(0xffFFFFFF)),
          ),
          child: Column(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => Icon(
                      fallbackIcon,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
