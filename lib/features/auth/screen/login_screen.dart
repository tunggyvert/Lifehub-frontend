import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../components/widgets/custom_text_field.dart';
import '../components/widgets/custom_button.dart';
import '../components/widgets/app_title.dart';

import '../../../api/feat/auth_service.dart';
import '../../../core/storage/token_storage_test.dart';
import 'package:flutter/foundation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final Color primaryOrange = const Color(0xFFF07B3F);
  final Color backgroundWhite = const Color(0xFFFAFAFA);

  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Run token storage test in debug mode
    if (kDebugMode) {
      TokenStorageTest.runTests();
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    debugPrint('[LoginScreen] Attempting login for user: $username');

    try {
      await _authService.login(username, password);

      if (!mounted) return;

      debugPrint('[LoginScreen] Login successful, navigating to home');
      context.go('/home');
    } on AuthException catch (e) {
      if (!mounted) return;
      debugPrint('[LoginScreen] AuthException: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e, stackTrace) {
      if (!mounted) return;
      debugPrint('[LoginScreen] Unexpected error: $e');
      debugPrint('[LoginScreen] Stack trace: $stackTrace');

      String errorMessage = 'ไม่สามารถเชื่อมต่อ server ได้: $e';

      // Check for common issues
      if (e.toString().contains('MissingPluginException')) {
        errorMessage = 'พบปัญหากับ secure storage กรุณา restart แอปพลิเคชัน';
      } else if (e.toString().contains('Network') ||
          e.toString().contains('Connection')) {
        errorMessage =
            'ไม่สามารถเชื่อมต่ออินเทอร์เน็ต กรุณาตรวจสอบการเชื่อมต่อ';
      } else if (e.toString().contains('Timeout')) {
        errorMessage = 'การเชื่อมต่อหมดเวลา กรุณาลองใหม่';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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

                // Email Input
                CustomTextField(
                  controller: _usernameController,
                  hint: 'ชื่อผู้ใช้',
                  icon: Icons.email_outlined,
                  primaryColor: primaryOrange,
                ),
                const SizedBox(height: 16),

                // Password Input (ใช้ State เข้ามาช่วย)
                CustomTextField(
                  controller: _passwordController,
                  hint: 'รหัสผ่าน',
                  icon: Icons.lock_outline,
                  obscureText: !_isPasswordVisible,
                  primaryColor: primaryOrange,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.black26,
                    ),
                    onPressed: () {
                      setState(() => _isPasswordVisible = !_isPasswordVisible);
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // Login Button พร้อมสถานะ Loading
                CustomButton(
                  text: 'เข้าสู่ระบบ',
                  onPressed: _handleLogin,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: () {
                    context.go('/register');
                  },
                  child: Text(
                    'ยังไม่มีบัญชี? สมัครสมาชิก',
                    style: TextStyle(color: primaryOrange),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.go('/forgetpass');
                  },
                  child: Text(
                    'ลืมรหัสผ่าน',
                    style: TextStyle(color: primaryOrange),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
