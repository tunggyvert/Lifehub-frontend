import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../components/widgets/custom_text_field.dart';
import '../components/widgets/custom_button.dart';
import '../components/widgets/app_title.dart';

import '../../../api/feat/auth_service.dart';

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
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      await _authService.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      context.go('/home');
    } on AuthException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ไม่สามารถเชื่อมต่อ server ได้: $e'),
          backgroundColor: Colors.red,
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
