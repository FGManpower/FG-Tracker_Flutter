import 'package:flutter/cupertino.dart';

class IntroCurvedDiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.25);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.05,
      size.width * 0.5,
      size.height * 0.08,
    );
    path.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.12,
      size.width,
      0,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}