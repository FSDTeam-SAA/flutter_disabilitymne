import 'package:disabilitymne/features/profile/model/help_and_support_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HelpSupportController extends GetxController {

  final emailController = TextEditingController();
  final subjectController = TextEditingController();
  final descriptionController = TextEditingController();

  RxInt descriptionLength = 0.obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    descriptionController.addListener(() {
      descriptionLength.value = descriptionController.text.length;
    });
  }

  HelpAndSupportModel get helpSupportData => HelpAndSupportModel(
        email: emailController.text.trim(),
        subject: subjectController.text.trim(),
        description: descriptionController.text.trim(),
      );

  void submitHelpRequest() async {
    if (emailController.text.isEmpty ||
        subjectController.text.isEmpty ||
        descriptionController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "All fields are required",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final data = helpSupportData;

      /// TODO: Send to API
      print("Help Request: ${data.toJson()}");

      Get.snackbar(
        "Success",
        "Your report has been submitted.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      clearFields();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Something went wrong",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void clearFields() {
    emailController.clear();
    subjectController.clear();
    descriptionController.clear();
    descriptionLength.value = 0;
  }

  @override
  void onClose() {
    emailController.dispose();
    subjectController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}