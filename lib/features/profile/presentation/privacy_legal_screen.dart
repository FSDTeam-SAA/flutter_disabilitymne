import 'package:disabilitymne/features/auth/presentation/widgets/background_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrivacyLegalScreen extends StatelessWidget {
  const PrivacyLegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Privacy & Legal",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BackgroundImage(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Introduction",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                "Welcome to Disability Fitness Center App, operated by Disability Fitness Center. Your privacy is important to us. This Privacy Policy explains how we collect, use, and protect your personal information when you use our mobile application.\n\nBy using the App, you agree to the practices described in this policy.\n\nInformation We Collect\nWe may collect the following categories of data:\n\nA. Personal Information\nFull name\nEmail address\nPhone number\nParent/guardian information (if user is under 18)\nProfile photo (optional)\n\nB. Health & Fitness Information\nHeight, weight\nMedical conditions (if voluntarily provided)\nDisability-related information (for customized programs)\nProgress tracking data\nWorkout performance data\n\nC. Payment Information\nIf payments are processed through third-party providers (e.g., Stripe, Apple Pay, Google Pay), we do not store full payment details. Payment providers handle secure processing.\n\nD. Device Information\nDevice type\nOperating system",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
