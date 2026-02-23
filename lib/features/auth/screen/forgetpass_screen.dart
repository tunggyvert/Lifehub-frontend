import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
import 'package:lifehub/features/auth/components/widgets/app_title.dart';
import 'package:lifehub/features/auth/components/widgets/custom_button.dart';
import 'package:lifehub/features/auth/components/widgets/custom_text_field.dart';

class ForgetpassScreen extends StatefulWidget {
  const ForgetpassScreen({super.key});

  @override
  State<ForgetpassScreen> createState() => _ForgetpassScreenState();
}

class _ForgetpassScreenState extends State<ForgetpassScreen> {

  final _emailController = TextEditingController();
  final Color primaryOrange = const Color(0xFFF07B3F);
  final Color backgroundWhite = const Color(0xFFFAFAFA);

  @override
  void dispose() {
    _emailController.dispose();
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
                const SizedBox(height: 48),

                CustomTextField(
                controller: _emailController, 
                hint: 'อีเมล', 
                icon: Icons.email_outlined,
                primaryColor: primaryOrange,
                ),
                const SizedBox(height: 16),

                CustomButton(text: 'ตกลง', onPressed: () {}),
                const SizedBox(height: 16,),
              ]
            ),
          ),
        ),
      )
    );
  }
}