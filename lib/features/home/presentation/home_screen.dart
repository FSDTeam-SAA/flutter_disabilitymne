import 'dart:async';
import 'dart:io';

import 'package:disabilitymne/app/controller/app_ground_controller.dart';
import 'package:disabilitymne/core/theme/app_colors.dart';
import 'package:disabilitymne/features/auth/model/user_model.dart';
import 'package:disabilitymne/features/auth/presentation/widgets/background_image.dart';
import 'package:disabilitymne/features/chat/presentation/chat_thread_screen.dart';
import 'package:disabilitymne/features/chat/repository/chat_repository.dart';
import 'package:disabilitymne/features/daily_tracker/presentation/daily_tracker_screen.dart';
import 'package:disabilitymne/features/programs/controller/explore_program%20controller.dart';
import 'package:disabilitymne/features/programs/presentation/screens/program_detail_screen.dart';
import 'package:disabilitymne/features/programs/presentation/widgets/explore_program_widget.dart';
import 'package:disabilitymne/features/programs/services/program_interface.dart';
import 'package:disabilitymne/features/home/widgets/upgrade_plan_dialog.dart';
import 'package:disabilitymne/features/profile/controller/profile_controller.dart';
import 'package:disabilitymne/features/profile/presentation/notification_screen.dart';
import 'package:disabilitymne/features/progress/presentation/progress_screen.dart';
import 'package:disabilitymne/features/recipies/controller/recipe_conreoller.dart';
import 'package:disabilitymne/features/recipies/model/recipes_model.dart';
import 'package:disabilitymne/features/recipies/presentation/screen/recipies_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Home screen matching the design: header, hero card, My Programs, My Recipes, Quick Action.
class HomeScreen extends StatefulWidget {
  final bool? isPremiumUser;
  const HomeScreen({super.key, this.isPremiumUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _cardBlue = Color(0xFF1A233A);
  static const Color _seeAllBlue = Color(0xFF85C4E2);

  /// Selected tab background color (#4B7FA8); icon and text stay white
  static const Color _recipeTabSelectedBg = Color(0xFF4B7FA8);
  static const List<String> _recipeTabAssetPaths = [
    'assets/image/recipe_icon_breakfast.png',
    'assets/image/recipe_icon_lunch.png',
    'assets/image/recipe_icon_dinner.png',
  ];
  int _recipeTabIndex = 0;
  Timer? _greetingTimer;
  bool _hasCheckedUpgradePopup = false;

  /// Returns one of 4 greetings by device hour: morning, afternoon, evening, night.
  static String _greetingByTime() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good morning!';
    if (hour >= 12 && hour < 17) return 'Good afternoon!';
    if (hour >= 17 && hour < 21) return 'Good evening!';
    return 'Good night!';
  }

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<RecipeController>()) {
      Get.put(RecipeController());
    }
    _greetingTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
    _listenProfileAndShowUpgradePopup();
  }

  /// When profile user is loaded, show upgrade popup when subscription ends within 6 days.
  void _listenProfileAndShowUpgradePopup() {
    if (!Get.isRegistered<ProfileController>()) return;
    final profileController = Get.find<ProfileController>();
    ever(profileController.user, (UserModel? user) {
      if (user == null || !mounted || _hasCheckedUpgradePopup) return;
      _hasCheckedUpgradePopup = true;
      maybeShowUpgradePopup(user);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _hasCheckedUpgradePopup) return;
      final user = profileController.user.value;
      if (user != null) {
        _hasCheckedUpgradePopup = true;
        maybeShowUpgradePopup(user);
      }
    });
  }

  @override
  void dispose() {
    _greetingTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    final futures = <Future<void>>[];

    if (Get.isRegistered<ProfileController>()) {
      futures.add(Get.find<ProfileController>().getProfile());
    }
    if (Get.isRegistered<ProgramController>()) {
      futures.add(Get.find<ProgramController>().getPrograms());
    }
    if (Get.isRegistered<RecipeController>()) {
      futures.add(Get.find<RecipeController>().getRecipes());
    }

    if (futures.isEmpty) {
      return;
    }

    await Future.wait(futures);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackgroundImage(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: Colors.white,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                _buildAppBar(),
                // SliverToBoxAdapter(child: _buildHeroCard()),
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
      ),
    );
  }

  Widget _buildAppBar() {
    final controller = Get.find<ProfileController>();
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Obx(() {
          final user = controller.user.value;
          final profileImageUrl = user?.profileImage;
          final hasProfileImage =
              profileImageUrl != null && profileImageUrl.isNotEmpty;
          final pickedPath = controller.pickedImagePath.value;

          ImageProvider<Object>? avatarImage;
          if (pickedPath != null && File(pickedPath).existsSync()) {
            avatarImage = FileImage(File(pickedPath));
          } else if (hasProfileImage) {
            avatarImage = CachedNetworkImageProvider(profileImageUrl);
          }

          final name = [
            user?.firstName,
            user?.lastName,
          ].whereType<String>().join(' ').trim();
          final displayName = name.isNotEmpty ? name : 'User';

          return Row(
            children: [
              GestureDetector(
                onTap: () => Get.find<AppGroundController>().changeIndex(4),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: _cardBlue,
                  backgroundImage: avatarImage,
                  child: avatarImage == null
                      ? const Icon(
                          Icons.person,
                          color: Colors.white70,
                          size: 32,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome $displayName',
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _greetingByTime(),
                      style: TextStyle(
                        color: AppColors.primaryText.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Get.to(() => NotificationScreen()),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 24,
                    ), // Uses Material icon only; do not use notification.png asset
                    // Positioned(
                    //   top: 4,
                    //   right: 4,
                    //   child: Container(
                    //     width: 8,
                    //     height: 8,
                    //     decoration: const BoxDecoration(
                    //       color: Colors.red,
                    //       shape: BoxShape.circle,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // Widget _buildHeroCard() {
  //   // Card gradient: dark navy top-left to muted blue bottom-right (match design)
  //   const Color heroCardStart = Color(0xFF1A2B43);
  //   const Color heroCardEnd = Color(0xFF2B476F);

  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 20),
  //     child: Container(
  //       padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(24),
  //         gradient: const LinearGradient(
  //           begin: Alignment.topLeft,
  //           end: Alignment.bottomRight,
  //           colors: [heroCardStart, heroCardEnd],
  //         ),
  //         boxShadow: [
  //           BoxShadow(
  //             color: const Color(
  //               0x66000000,
  //             ), // #000000 at 40% opacity (66 = 40% alpha)
  //             blurRadius: 12,
  //             offset: const Offset(0, 4),
  //           ),
  //         ],
  //       ),
  //       child: Row(
  //         children: [
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Text(
  //                   'Ready for your Fitness',
  //                   style: TextStyle(
  //                     color: AppColors.primaryText,
  //                     fontSize: 16,
  //                     fontWeight: FontWeight.w600,
  //                     height: 1.3,
  //                   ),
  //                 ),

  //                 Text(
  //                   'Journey?',
  //                   style: TextStyle(
  //                     color: AppColors.primaryText,
  //                     fontSize: 18,
  //                     fontWeight: FontWeight.bold,
  //                     height: 1.25,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 16),
  //                 Material(
  //                   color: Colors.transparent,
  //                   child: InkWell(
  //                     onTap: () {},
  //                     borderRadius: BorderRadius.circular(12),
  //                     child: Container(
  //                       padding: const EdgeInsets.symmetric(
  //                         horizontal: 40,
  //                         vertical: 12,
  //                       ),
  //                       decoration: BoxDecoration(
  //                         borderRadius: BorderRadius.circular(12),
  //                         gradient: const LinearGradient(
  //                           begin: Alignment.topCenter,
  //                           end: Alignment.bottomCenter,
  //                           colors: [
  //                             // buttonGradientStart,
  //                             // buttonGradientEnd,
  //                             Color(0xff4D7EA9),
  //                             Color(0xff89C9E6),
  //                           ],
  //                         ),
  //                       ),
  //                       child: Row(
  //                         mainAxisSize: MainAxisSize.min,
  //                         children: [
  //                           Text(
  //                             'Get Started',
  //                             style: TextStyle(
  //                               color: AppColors.primaryText,
  //                               fontWeight: FontWeight.w600,
  //                               fontSize: 14,
  //                             ),
  //                           ),
  //                           const SizedBox(width: 8),
  //                           Icon(
  //                             Icons.chevron_right,
  //                             size: 22,
  //                             color: AppColors.primaryText,
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           const SizedBox(width: 12),
  //           SizedBox(
  //             width: 100,
  //             height: 100,
  //             child: Image.asset(
  //               'assets/image/fitness_journey_icon.png',
  //               fit: BoxFit.contain,
  //               errorBuilder: (_, _, _) => Icon(
  //                 Icons.accessible_forward_rounded,
  //                 size: 72,
  //                 color: _accentLightBlue.withValues(alpha: 0.9),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildSectionSpacer() {
    return const SizedBox(height: 24);
  }

  Widget _buildMyProgramsSection() {
    if (!Get.isRegistered<ProgramController>()) {
      Get.put(
        ProgramController(programInterface: Get.find<ProgramInterface>()),
      );
    }
    final programController = Get.find<ProgramController>();

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
                  onTap: () {
                    Get.find<AppGroundController>().changeIndex(1);
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
            Obx(() {
              if (programController.isLoading.value) {
                return SizedBox(
                  height: 160,
                  child: Center(
                    child: CircularProgressIndicator(color: _seeAllBlue),
                  ),
                );
              }
              final list = programController.programList;
              if (list.isEmpty) {
                return _buildProgramCard();
              }
              final showList = list.take(3).toList();
              return SizedBox(
                height: 168,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: showList.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final program = showList[index];
                    return SizedBox(
                      width: 280,
                      child: ProgramCard(
                        title: program.programName,
                        image: program.programThumbnail,
                        onTap: () {
                          Get.to(() => ProgramDetailScreen(program: program));
                        },
                      ),
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
          colors: [const Color(0xFF1A204C), const Color(0xFF2E3A7E)],
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
                    color: AppColors.primaryText.withValues(alpha: 0.85),
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
            Row(
              children: List.generate(3, (index) {
                final selected = _recipeTabIndex == index;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: index == 0 ? 0 : 8),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => setState(() => _recipeTabIndex = index),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: selected ? _recipeTabSelectedBg : _cardBlue,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24, width: 1),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
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
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  tabs[index],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final all = recipeController.recipeList;
              final selectedType = tabs[_recipeTabIndex].trim().toLowerCase();
              final filtered = all
                  .where(
                    (r) =>
                        (r.recipeType ?? '').trim().toLowerCase() ==
                        selectedType,
                  )
                  .toList(growable: false);

              if (filtered.isEmpty) {
                return SizedBox(
                  height: 160,
                  child: Center(
                    child: Text(
                      'No $selectedType recipes yet',
                      style: TextStyle(
                        color: AppColors.primaryText.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }
              return SizedBox(
                height: 240,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: 200,
                      child: _buildRecipeCard(filtered[index], index),
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
    final kcal = '${formatRecipeNutritionValue(recipe.caloriesKcal)} Kcal';
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
        child: Card(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.zero,
          child: Container(
            // padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child:
                      recipe.recipeImage != null &&
                          recipe.recipeImage!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: recipe.recipeImage!,
                          width: double.infinity,
                          height: 140,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _recipePlaceholder(),
                        )
                      : _recipePlaceholder()
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0, bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: AppColors.primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          kcal,
                          style: TextStyle(
                            color: AppColors.primaryText.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _recipePlaceholder() {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withValues(alpha: 0.12),
      ),
      child: const Icon(Icons.restaurant, color: Colors.white54, size: 32),
    );
  }

  Widget _buildQuickActionSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Obx(() {
          final user = Get.find<ProfileController>().user.value;
          final showChat = user?.selectedPlan == 'premium';
          return Column(
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
          );
        }),
      ),
    );
  }

  Widget _buildChatWithCoachCta() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final repo = Get.find<ChatRepository>();
          final result = await repo.createOrGetThread();
          result.fold(
            (failure) {
              Get.snackbar(
                'Chat',
                failure.uiMessage,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            (info) {
              Get.to(
                () => ChatThreadScreen(
                  threadId: info.threadId,
                  counterpartName: info.counterpartName,
                ),
              );
            },
          );
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
            border: Border.all(color: Color(0xffFFFFFF)),
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
                    errorBuilder: (_, _, _) =>
                        Icon(fallbackIcon, color: Colors.white, size: 36),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
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
