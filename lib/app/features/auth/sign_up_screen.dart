import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:disabilitymne/core/image_path.dart';
import 'package:disabilitymne/core/common/widget/app_text_field.dart';
import 'package:disabilitymne/app/features/welcome/welcome_screen.dart';
import 'package:disabilitymne/app/features/auth/sign_in_screen.dart';

/// Sign up screen - name, email, phone, password, confirm password.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  static const Color _darkNavy = Color(0xFF1A2C46);
  static const Color _linkBlue = Color(0xFF89C9E6);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signUp() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement sign up
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkNavy,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => Get.offAll(() => const WelcomeScreen()),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                          size: 28,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Image.asset(
                      ImagePath.appLogo,
                      height: 70,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Let's Get Started!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create an account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 32),
                  AppTextField(
                    label: 'User Name',
                    hint: 'Enter your First Name',
                    prefixIcon: Icons.person_outline,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    controller: _nameController,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter your name' : null,
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: 'Your Email',
                    hint: 'Enter your Email',
                    prefixIcon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    controller: _emailController,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter your email' : null,
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: 'Phone Number',
                    hint: 'Enter your phone number',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    controller: _phoneController,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter your phone' : null,
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: 'Password',
                    hint: 'Enter your Password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    controller: _passwordController,
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter your password' : null,
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: _linkBlue,
                        size: 22,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: 'Confirm Password',
                    hint: 'Enter Confirm Password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscureConfirmPassword,
                    controller: _confirmPasswordController,
                    textInputAction: TextInputAction.done,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Confirm your password';
                      if (v != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    suffix: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: _linkBlue,
                        size: 22,
                      ),
                      onPressed: () => setState(
                        () => _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _SignUpButton(onPressed: _signUp),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.offAll(() => const SignInScreen()),
                        child: const Text(
                          'Sign In Here',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _linkBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SignUpButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SignUpButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF89C9E6), Color(0xFF4D7EA9)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: const Text(
          'SIGN UP',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
