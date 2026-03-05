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
        // Try to load the image, but show a fallback if it doesn't exist
        Image.asset(
          image,
          height: height,
          width: width,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('[AppLogo] Error loading image: $error');
            debugPrint('[AppLogo] Image path: $image');
            // Fallback to a text logo if image is missing
            return Container(
              height: height,
              width: width,
              decoration: BoxDecoration(
                color: const Color(0xFFF07B3F),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  'LifeHub',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        const Text(
          'LifeHub',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF07B3F),
          ),
        ),
      ],
    );
  }
}
