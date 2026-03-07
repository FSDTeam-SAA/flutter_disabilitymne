import 'package:disabilitymne/features/auth/presentation/widgets/background_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackgroundImage(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 10),

                /// Top AppBar
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        "My Profile",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(Icons.edit_outlined, color: Colors.white),
                  ],
                ),

                const SizedBox(height: 20),

                /// Profile Image
                Stack(
                  children: [
                    const CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(
                        "https://i.pravatar.cc/300",
                      ),
                    ),

                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// Personal Info
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Personal Info",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: ListView(
                    children: const [
                      ProfileField(label: "Name", value: "Evan"),
                      ProfileField(label: "Gender", value: "Female"),
                      ProfileField(label: "Age", value: "26"),
                      ProfileField(label: "Height", value: "182 cm"),
                      ProfileField(label: "Weight", value: "72 kg"),
                      ProfileField(
                        label: "Your Fitness Goals",
                        value: "Improve Mobility, Build Strength",
                      ),
                      ProfileField(
                        label: "Your mobility type",
                        value: "Wheelchair User",
                      ),
                      ProfileField(
                        label: "Your mobility type",
                        value: "Wheelchair User",
                      ),
                      ProfileField(
                        label: "Fitness experience",
                        value: "Beginner",
                      ),

                      SizedBox(height: 20),
                    ],
                  ),
                ),

                /// Save Button
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7FA9C9), Color(0xFF4E79A7)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      "Save",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileField extends StatelessWidget {
  final String label;
  final String value;

  const ProfileField({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF4B7FA8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
