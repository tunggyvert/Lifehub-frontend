import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../components/widgets/custom_text_field.dart';
import '../components/widgets/custom_button.dart';
import '../components/widgets/app_title.dart';
import '../../../api/feat/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  final Color primaryOrange = const Color(0xFFF07B3F);
  final Color backgroundWhite = const Color(0xFFFAFAFA);

  final _authService = AuthService();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      await _authService.register(
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
        _confirmPasswordController.text,
      );
      if (!mounted) return;

      context.go('/');
    } on AuthException {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ข้อมูลไม่ถูกต้อง')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถเชื่อมต่อกับ server ได้: $e')),
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

                CustomTextField(
                  controller: _usernameController,
                  hint: 'username',
                  icon: Icons.person_outline,
                  primaryColor: primaryOrange,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _emailController,
                  hint: 'อีเมล',
                  icon: Icons.email_outlined,
                  primaryColor: primaryOrange,
                ),
                const SizedBox(height: 16),

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
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _confirmPasswordController,
                  hint: 'ยืนยันรหัสผ่าน',
                  icon: Icons.lock_outline,
                  obscureText: !_isConfirmPasswordVisible,
                  primaryColor: primaryOrange,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.black26,
                    ),
                    onPressed: () {
                      setState(
                        () => _isConfirmPasswordVisible =
                            !_isConfirmPasswordVisible,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),

                CustomButton(
                  text: 'สมัครสมาชิก',
                  onPressed: _handleRegister,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: () {
                    context.go('/');
                  },
                  child: Text(
                    'มีบัญชีอยู่แล้ว? เข้าสู่ระบบ',
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
