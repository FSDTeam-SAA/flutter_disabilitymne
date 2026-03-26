import 'package:disabilitymne/features/programs/presentation/widgets/explore_program_widget.dart';
import 'package:disabilitymne/features/programs/presentation/widgets/library_widget.dart';
import 'package:disabilitymne/features/programs/presentation/widgets/my_program_widget.dart';
import 'package:flutter/material.dart';

class ProgramsScreen extends StatefulWidget {
  const ProgramsScreen({super.key});

  @override
  State<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends State<ProgramsScreen> {
  int selectedTab = 0;

  final tabs = ["Your Program", "Explore", "Library"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0E1A2B),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Programs",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Adaptive exercises for your ability",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),

            const SizedBox(height: 20),

            /// Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: List.generate(
                    tabs.length,
                    (index) => Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTab = index;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selectedTab == index
                                ? const Color(0xff6FA8DC)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            tabs[index],
                            style: TextStyle(
                              color: selectedTab == index
                                  ? Colors.white
                                  : Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Tab Content
            Expanded(
              child: IndexedStack(
                index: selectedTab,
                children: [MyProgramWidget(), ExploreWidget(), LibraryWidget()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
