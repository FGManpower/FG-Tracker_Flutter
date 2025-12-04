import 'package:flutter/cupertino.dart';

class BottomFullArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.moveTo(0, size.height);

    path.lineTo(0, size.height * 0.35);

    path.quadraticBezierTo(
      size.width * 0.5,
      -size.height * 0.30,
      size.width,
      size.height * 0.35,
    );

    path.lineTo(size.width, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}