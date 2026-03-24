import 'package:disabilitymne/core/theme/app_colors.dart';
import 'package:disabilitymne/core/theme/text_style.dart';
import 'package:disabilitymne/features/auth/presentation/widgets/background_image.dart';
import 'package:disabilitymne/features/calculator/model/calculator_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HistoryScreen extends StatefulWidget {
  final Meal meal;

  const HistoryScreen({
    super.key,
    required this.meal,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackgroundImage(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              if (!_isSearching) ...[
                _buildTabBar(),
                Expanded(child: _buildTabContent()),
                if (_selectedTabIndex == 0) _buildDoneButton(),
              ] else ...[
                Expanded(child: _buildSearchContent()),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// HEADER
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.white,
              size: 20,
            ),
            onPressed: () => Get.back(),
          ),
          Text(
            widget.meal.mealLabel,
            style: AppText.xlSemiBold_20_600.copyWith(color: AppColors.white),
          ),
        ],
      ),
    );
  }

  /// SEARCH BAR
  /// add border color
  Widget _buildSearchBar() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _isSearching = value.isNotEmpty;
        });
      },
      style: const TextStyle(color: AppColors.white),
      decoration: InputDecoration(
        hintText: "Food or meal",
        hintStyle: AppText.smRegular_14_400.copyWith(
          color: AppColors.white,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.white,
        ),
        suffixIcon: _isSearching
            ? IconButton(
                icon: const Icon(Icons.clear, color: AppColors.white),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _isSearching = false;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: const Color(0xFF465061),

        /// DEFAULT BORDER
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF7E8592),
          ),
        ),

        /// WHEN NOT FOCUSED
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF7E8592),
            width: 1,
          ),
        ),

        /// WHEN CLICKED
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF7E8592),
            width: 1.2,
          ),
        ),
      ),
    ),
  );
}

  /// TAB BAR
  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTabItem(0, Icons.history, "History"),
          _buildTabItem(1, Icons.favorite_border, "Favorite"),
          _buildTabItem(2, Icons.track_changes, "Tracked"),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label) {
    bool isSelected = _selectedTabIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Column(
        children: [
          Icon(
            icon,
            color: isSelected
                ? AppColors.profileActiveTab
                : AppColors.profileTextSecondary,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppText.xsMedium_12_500.copyWith(
              color: isSelected
                  ? AppColors.profileActiveTab
                  : AppColors.profileTextSecondary,
            ),
          ),
          const SizedBox(height: 6),
          if (isSelected)
            Container(height: 2, width: 40, color: AppColors.profileActiveTab),
        ],
      ),
    );
  }

  /// TAB CONTENT SWITCH
  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildHistoryList();
      case 1:
        return _buildFavoriteContent();
      case 2:
        return _buildTrackedContent();
      default:
        return _buildHistoryList();
    }
  }

  /// SEARCH CONTENT
  Widget _buildSearchContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Search result",
            style: AppText.lgMedium_18_500.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 3, // Mock search results
              itemBuilder: (context, index) {
                return _buildFoodCard(
                  title: "Search Item ${index + 1}",
                  kcal: "${(index + 1) * 10} kcal",
                  gram: "100g",
                  trailing: Icons.add,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// HISTORY TAB
  Widget _buildHistoryList() {
    final entries = widget.meal.entries;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "All recent",
            style: AppText.lgMedium_18_500.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: entries.isEmpty
                ? const Center(
                    child: Text(
                      "No entries found",
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return _buildFoodCard(
                        title: entry.foodName,
                        kcal: "${entry.calories.toStringAsFixed(0)} kcal",
                        gram: "${entry.quantity.toStringAsFixed(0)} ${entry.servingLabel}",
                        trailing: Icons.close,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// FAVORITE TAB
  Widget _buildFavoriteContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        children: [
          Text(
            "Food",
            style: AppText.lgMedium_18_500.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 12),

          _buildFoodCard(
            title: "Apple",
            kcal: "50 kcal",
            gram: "10g",
            trailing: Icons.favorite,
          ),

          const SizedBox(height: 20),

          Text(
            "Meals",
            style: AppText.lgMedium_18_500.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 12),

          _buildEmptyCard("No favorite Meals yet"),

          const SizedBox(height: 20),

          Text(
            "Recipes",
            style: AppText.lgMedium_18_500.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 12),

          _buildEmptyCard("No favorite Recipes yet"),
        ],
      ),
    );
  }

  /// TRACKED TAB
  Widget _buildTrackedContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "You have tracked",
            style: AppText.lgMedium_18_500.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              itemCount: 2,
              itemBuilder: (context, index) {
                return _buildFoodCard(
                  title: "Apple",
                  kcal: "50 kcal",
                  gram: "25 g",
                  trailing: Icons.close,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// FOOD CARD
  Widget _buildFoodCard({
    required String title,
    required String kcal,
    required String gram,
    required IconData trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF7E8592)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            /// CARD CONTENT
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.transparent,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppText.xl2Medium_22_500.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 4),

                        Text(
                          kcal,
                          style: AppText.smMedium_14_500.copyWith(
                            color: AppColors.white,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(
                              Icons.edit_outlined,
                              size: 24,
                              color: AppColors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              gram,
                              style: AppText.smMedium_14_500.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Color(0xFF818894)),
                    ),
                    child: Icon(
                      trailing,
                      size: 18,
                      color: trailing == Icons.favorite
                          ? AppColors.profileActiveTab
                          : AppColors.white,
                    ),
                  ),
                ],
              ),
            ),

            /// TOP INNER SHADOW
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 50,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color.fromARGB(120, 0, 0, 0), Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            /// BOTTOM INNER SHADOW
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 50,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Color.fromARGB(120, 0, 0, 0)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// EMPTY CARD
  Widget _buildEmptyCard(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.profileCardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.profileBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.favorite_border, color: AppColors.profileActiveTab),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppText.smRegular_14_400.copyWith(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// DONE BUTTON
  Widget _buildDoneButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          gradient: AppColors.buttonGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ElevatedButton(
          onPressed: () => Get.back(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
          ),
          child: Text(
            "Done",
            style: AppText.mdSemiBold_16_700.copyWith(color: Colors.black),
          ),
        ),
      ),
    );
  }
}
