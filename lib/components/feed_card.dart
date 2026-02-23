import 'package:flutter/material.dart';

class FeedCard extends StatelessWidget {
  final double height;
  final Color backgroundColor;
  final BorderRadius borderRadius;
  final Widget? child;

  const FeedCard({
    super.key,
    this.height = 180,
    required this.backgroundColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
          ),
          child: child,
        ),
        Positioned(
          left: 16,
          bottom: 16,
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.person_outline, color: Colors.black54),
            ),
          ),
        ),
      ],
    );
  }
}
