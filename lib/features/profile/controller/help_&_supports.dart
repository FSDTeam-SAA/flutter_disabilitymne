import 'package:disabilitymne/features/profile/model/help_and_support_model.dart';
import 'package:disabilitymne/features/profile/services/profile_interface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/core/helpers/app_snackbar.dart';

class HelpSupportController extends GetxController {
  HelpSupportController({required this.profileInterface});
  final ProfileInterface profileInterface;

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
      AppSnackbar.error(
        'Error',
        'All fields are required',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    try {
      final data = helpSupportData;

      final response = await profileInterface.submitHelpSupport(data);

      response.fold(
        (failure) {
          AppSnackbar.error(
            'Error',
            failure.uiMessage,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        (success) {
          Get.back();
          clearFields();
          Future.delayed(const Duration(milliseconds: 300), () {
            AppSnackbar.success(
              'Success',
              'Your report has been submitted.',
              snackPosition: SnackPosition.BOTTOM,
            );
          });
        },
      );
    } catch (e) {
      AppSnackbar.show(
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