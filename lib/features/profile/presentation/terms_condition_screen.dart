import 'package:disabilitymne/features/auth/presentation/widgets/background_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TermsConditionScreen extends StatelessWidget {
  const TermsConditionScreen({super.key});

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
          "Terms & Condition",
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
                "1. Acceptance of Terms\nBy using this App, you agree to these Terms & Conditions.\nIf you do not agree, please do not use the App.\n\n2. Medical Disclaimer\nThe content provided in this App is for fitness and educational purposes only.\nIt does not replace professional medical advice.\nUsers must consult a licensed physician before starting any exercise program.\nParents/guardians are responsible for ensuring medical clearance for minors.\nParticipation in exercises is at your own risk.\n\n3. Eligibility\nUsers under 18 must have parental/guardian consent.\nParents/guardians are responsible for supervising minors using the App.\n\n4. User Responsibilities\nYou agree to:\nProvide accurate information\nFollow exercise instructions carefully\nNot misuse the platform\nNot share login credentials\n\n5. Payments & Subscriptions\nFees for training programs are clearly stated in the App.\nSubscription fees are billed as described at purchase.",
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
