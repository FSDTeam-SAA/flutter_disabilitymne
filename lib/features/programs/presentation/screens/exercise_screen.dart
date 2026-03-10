import 'package:flutter/material.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  List<Map<String, TextEditingController>> sets = [
    {"kg": TextEditingController(text: "06"), "reps": TextEditingController()},
    {"kg": TextEditingController(text: "06"), "reps": TextEditingController()},
    {"kg": TextEditingController(text: "08"), "reps": TextEditingController()},
  ];

  void addSet() {
    setState(() {
      sets.add({
        "kg": TextEditingController(),
        "reps": TextEditingController(),
      });
    });
  }

  void removeSet(int index) {
    setState(() {
      sets.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0F1C2E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              /// TOP BAR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text("Back", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  Text(
                    "Exercise 1 of 12",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              /// PROGRESS BAR
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: 0.1,
                  minHeight: 6,
                  backgroundColor: Colors.white24,
                  color: Colors.lightBlueAccent,
                ),
              ),

              const SizedBox(height: 20),

              /// VIDEO CARD
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: AssetImage("assets/images/exercise.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: const Center(
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white70,
                    child: Icon(
                      Icons.play_arrow,
                      size: 35,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// SET CARD
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFF263D57),
                  ),
                  child: Column(
                    children: [
                      /// SAVE BUTTON
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4B7FA8),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Color(0xFF70AACD)),
                          ),
                          child: const Text(
                            "Save",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// SET LIST
                      Expanded(
                        child: ListView.builder(
                          itemCount: sets.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  /// SET TITLE
                                  Text(
                                    "Set ${index + 1}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 20),

                                  /// KG FIELD
                                  SizedBox(
                                    width: 100,
                                    child: TextField(
                                      controller: sets[index]["kg"],
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      decoration: inputDecoration("kg"),
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  /// REPS FIELD
                                  SizedBox(
                                    width: 100,
                                    child: TextField(
                                      controller: sets[index]["reps"],
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      decoration: inputDecoration("reps"),
                                    ),
                                  ),

                                  SizedBox(width: 12),

                                  /// DELETE BUTTON
                                  GestureDetector(
                                    onTap: () => removeSet(index),
                                    child: Icon(
                                      Icons.cancel_outlined,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// ADD SET BUTTON
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 51),
                          side: const BorderSide(color: Color(0xFF70AACD)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: addSet,
                        child: Text(
                          "Add New Set",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// NEXT BUTTON
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff9BD3FF), Color(0xff5CA9D6)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    "Next Exercise",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: const Color(0xff1E334B),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Color(0xFF1A263D)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Color(0xFF1A263D)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Color(0xFF1A263D)),
      ),
    );
  }
}
