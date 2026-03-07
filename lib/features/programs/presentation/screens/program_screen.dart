// import 'package:flutter/material.dart';

// class ProgramsScreen extends StatefulWidget {
//   const ProgramsScreen({super.key});

//   @override
//   State<ProgramsScreen> createState() => _ProgramsScreenState();
// }

// class _ProgramsScreenState extends State<ProgramsScreen> {

//   int selectedTab = 1;

//   final tabs = [
//     "Your Program",
//     "Explore",
//     "Library",
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xff0E1A2B),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [

//               const SizedBox(height: 10),

//               /// Title
//               const Text(
//                 "Programs",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),

//               const SizedBox(height: 4),

//               const Text(
//                 "Adaptive exercises for your ability",
//                 style: TextStyle(
//                   color: Colors.white70,
//                   fontSize: 14,
//                 ),
//               ),

//               const SizedBox(height: 20),

//               /// Tabs
//               Container(
//                 padding: const EdgeInsets.all(4),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.white24),
//                 ),
//                 child: Row(
//                   children: List.generate(
//                     tabs.length,
//                     (index) => Expanded(
//                       child: GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             selectedTab = index;
//                           });
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(vertical: 10),
//                           decoration: BoxDecoration(
//                             color: selectedTab == index
//                                 ? const Color(0xff6FA8DC)
//                                 : Colors.transparent,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           alignment: Alignment.center,
//                           child: Text(
//                             tabs[index],
//                             style: TextStyle(
//                               color: selectedTab == index
//                                   ? Colors.white
//                                   : Colors.white70,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 20),

//               /// Programs List
//               Expanded(
//                 child: ListView(
//                   children: const [
//                     ProgramCard(),
//                     SizedBox(height: 16),
//                     ProgramCard(),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class ProgramCard extends StatelessWidget {
//   const ProgramCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 160,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         gradient: const LinearGradient(
//           colors: [
//             Color(0xff132A4A),
//             Color(0xff3A2DA8),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//       child: Stack(
//         children: [

//           /// Content
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [

//                 /// Program info
//                 Row(
//                   children: const [
//                     Icon(Icons.accessibility_new,
//                         color: Colors.white, size: 18),
//                     SizedBox(width: 6),
//                     Text(
//                       "3 Days | 12 Weeks | 60 Min",
//                       style: TextStyle(
//                         color: Colors.white70,
//                         fontSize: 12,
//                       ),
//                     )
//                   ],
//                 ),

//                 const Spacer(),

//                 /// Title
//                 const Text(
//                   "BEGINNER'S\nBLUEPRINT",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 26,
//                     fontWeight: FontWeight.bold,
//                     height: 1.1,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           /// Right Image
//           Positioned(
//             right: 0,
//             bottom: 0,
//             top: 0,
//             child: ClipRRect(
//               borderRadius: const BorderRadius.only(
//                 topRight: Radius.circular(16),
//                 bottomRight: Radius.circular(16),
//               ),
//               child: Image.network(
//                 "https://i.imgur.com/8Km9tLL.png",
//                 width: 120,
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:disabilitymne/features/programs/presentation/widgets/library_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/program_detail_screen.dart';

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
                children: const [
                  YourProgramWidget(),
                  ExploreWidget(),
                  LibraryWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class YourProgramWidget extends StatelessWidget {
  const YourProgramWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        ProgramCard(
          title: "BEGINNER'S\nBLUEPRINT",
          onTap: () {
            Get.to(
              () => const ProgramDetailScreen(title: "Beginner Blueprint"),
            );
          },
        ),
        const SizedBox(height: 16),
        ProgramCard(
          title: "BEGINNER'S\nBLUEPRINT",
          onTap: () {
            Get.to(
              () => const ProgramDetailScreen(title: "Beginner Blueprint"),
            );
          },
        ),
      ],
    );
  }
}

class ExploreWidget extends StatelessWidget {
  const ExploreWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        ProgramCard(
          title: "BEGINNER'S\nBLUEPRINT",
          onTap: () {
            Get.to(
              () => const ProgramDetailScreen(title: "Beginner Blueprint"),
            );
          },
        ),
        const SizedBox(height: 16),
        ProgramCard(
          title: "BEGINNER'S\nBLUEPRINT",
          onTap: () {
            Get.to(
              () => const ProgramDetailScreen(title: "Beginner Blueprint"),
            );
          },
        ),
        const SizedBox(height: 16),
        ProgramCard(
          title: "BEGINNER'S\nBLUEPRINT",
          onTap: () {
            Get.to(
              () => const ProgramDetailScreen(title: "Beginner Blueprint"),
            );
          },
        ),
      ],
    );
  }
}

class ProgramCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const ProgramCard({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xff132A4A), Color(0xff3A2DA8)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
