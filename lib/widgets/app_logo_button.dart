import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppLogoButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool compact;

  const AppLogoButton({
    super.key,
    required this.onTap,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final size = compact ? 44.0 : 50.0;

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(compact ? 5 : 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFF7F7F7).withOpacity(0.85),
              width: 2.2,
            ),
          ),
          child: SvgPicture.asset(
            'assets/images/CUBO0white.svg',
            fit: BoxFit.contain,
            colorFilter: const ColorFilter.mode(
              Color(0xFFF7F7F7),
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}