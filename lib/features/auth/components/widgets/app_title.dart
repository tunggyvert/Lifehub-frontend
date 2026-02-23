import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
 
  final String image;
  final double? height;
  final double? width;

  const AppLogo({
    super.key,
    this.image = 'assets/images/lifehub-removebg.png',
    this.height = 160,
    this.width = 160,
  });

  @override
  Widget build(BuildContext context) {
  return Column(
    mainAxisSize: MainAxisSize.min, 
    children: [
      Image.asset(
        image,
        height: height,
        width: width,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, size: 50, color: Colors.red);
        },
      ),
    ],
  );
}
}