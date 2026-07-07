// import 'package:disabilitymne/features/auth/presentation/widgets/background_image.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class HelpSupportScreen extends StatefulWidget {
//   const HelpSupportScreen({super.key});

//   @override
//   State<HelpSupportScreen> createState() => _HelpSupportScreenState();
// }

// class _HelpSupportScreenState extends State<HelpSupportScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _subjectController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _subjectController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Get.back(),
//         ),
//         title: const Text(
//           "Help and support",
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: BackgroundImage(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildLabel("User Email"),
//               const SizedBox(height: 8),
//               _buildTextField(
//                 controller: _emailController,
//                 hint: "Enter your Email",
//                 icon: Icons.person_outline,
//               ),
//               const SizedBox(height: 20),
//               _buildLabel("Subject"),
//               const SizedBox(height: 8),
//               _buildTextField(
//                 controller: _subjectController,
//                 hint: "Problem Heading",
//               ),
//               const SizedBox(height: 20),
//               _buildLabel("Description"),
//               const SizedBox(height: 8),
//               _buildTextField(
//                 controller: _descriptionController,
//                 hint: "Description",
//                 maxLines: 5,
//               ),
//               const SizedBox(height: 8),
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: Text(
//                   "${_descriptionController.text.length}/300",
//                   style: const TextStyle(color: Colors.white54, fontSize: 12),
//                 ),
//               ),
//               const SizedBox(height: 40),
//               _buildSubmitButton(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildLabel(String label) {
//     return Text(
//       label,
//       style: const TextStyle(
//         color: Colors.white,
//         fontSize: 16,
//         fontWeight: FontWeight.w600,
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String hint,
//     IconData? icon,
//     int maxLines = 1,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.transparent,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Color(0xFF575757)),
//       ),
//       child: TextField(
//         controller: controller,
//         maxLines: maxLines,
//         style: const TextStyle(color: Colors.white),
//         onChanged: (value) {
//           if (maxLines > 1) setState(() {});
//         },
//         decoration: InputDecoration(
//           hintText: hint,
//           hintStyle: const TextStyle(color: Colors.white38),
//           prefixIcon: icon != null ? Icon(icon, color: Colors.white54) : null,
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 12,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSubmitButton() {
//     return Container(
//       width: double.infinity,
//       height: 56,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         gradient: const LinearGradient(
//           colors: [Color(0xFF6FBEE5), Color(0xFF314E94)],
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//         ),
//       ),
//       child: ElevatedButton(
//         onPressed: () {
//           // Handle submission logic
//           AppSnackbar.show(
//             "Success",
//             "Your report has been submitted.",
//             snackPosition: SnackPosition.BOTTOM,
//             backgroundColor: Colors.green,
//             colorText: Colors.white,
//           );
//         },
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.transparent,
//           shadowColor: Colors.transparent,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//         child: const Text(
//           "Save & Submit",
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:disabilitymne/features/auth/presentation/widgets/background_image.dart';
import 'package:disabilitymne/features/profile/controller/help_&_supports.dart';
import 'package:disabilitymne/features/profile/services/profile_interface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HelpSupportScreen extends StatelessWidget {
  HelpSupportScreen({super.key});

  final HelpSupportController controller = Get.put(HelpSupportController(profileInterface: Get.find<ProfileInterface>()));

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
          "Help and support",
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
            children: [
              _buildLabel("User Email"),
              const SizedBox(height: 8),
              _buildTextField(
                controller: controller.emailController,
                hint: "Enter your Email",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),

              _buildLabel("Subject"),
              const SizedBox(height: 8),
              _buildTextField(
                controller: controller.subjectController,
                hint: "Problem Heading",
              ),
              const SizedBox(height: 20),

              _buildLabel("Description"),
              const SizedBox(height: 8),
              _buildTextField(
                controller: controller.descriptionController,
                hint: "Description",
                maxLines: 5,
              ),

              const SizedBox(height: 8),

              /// Character Counter
              Align(
                alignment: Alignment.centerRight,
                child: Obx(
                  () => Text(
                    "${controller.descriptionLength.value}/300",
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF575757)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: icon != null ? Icon(icon, color: Colors.white54) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF6FBEE5), Color(0xFF314E94)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: ElevatedButton(
        onPressed: () {
          controller.submitHelpRequest();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Obx(
          () => controller.isLoading.value
              ? const CircularProgressIndicator(
                  color: Colors.white,
                )
              : const Text(
                  "Save & Submit",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}