import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
import 'package:lifehub/features/auth/components/widgets/custom_button.dart';
import 'package:lifehub/features/auth/components/widgets/custom_text_field.dart';

import '../components/widgets/app_title.dart';

class ResetpassScreen extends StatefulWidget {
  const ResetpassScreen({super.key});

  @override
  State<ResetpassScreen> createState() => _ResetpassScreenState();
}

class _ResetpassScreenState extends State<ResetpassScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final Color primaryOrange = const Color(0xFFF07B3F);
  final Color backgroundWhite = const Color(0xFFFAFAFA);

  bool _isPasswordVisible = false;
  // bool _isConfirmPasswordVisible = false;
  // bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                const AppLogo(),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _passwordController,
                  hint: 'ใส่รหัสผ่านที่ต้องการ',
                  icon: Icons.lock_outline,
                  obscureText: !_isPasswordVisible,
                  primaryColor: primaryOrange,
                  suffixIcon: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.black26,
                    ),
                  ),
                ),
                SizedBox(height: 16),

                CustomTextField(
                  controller: _confirmPasswordController,
                  hint: 'ยืนยันรหัสผ่าน',
                  icon: Icons.lock_outline,
                  obscureText: !_isPasswordVisible,
                  primaryColor: primaryOrange,
                  suffixIcon: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.black26,
                    ),
                  ),
                ),
                SizedBox(height: 16),

                CustomButton(text: 'ยืนยัน', onPressed: () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
