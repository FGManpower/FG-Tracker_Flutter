import 'package:flutter/material.dart';

class CurvedDiagonalClipper extends CustomClipper<Path> {
  final double cutHeightFactor;

  CurvedDiagonalClipper({this.cutHeightFactor = 0.5});

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0.0, size.height);



    double controlPointX = size.width / 4;
    double controlPointY = size.height * cutHeightFactor + 40;

    double curveEndPointX = size.width;
    double curveEndPointY = size.height * cutHeightFactor - 80;

    path.quadraticBezierTo(
      controlPointX,
      controlPointY,
      curveEndPointX,
      curveEndPointY,
    );

    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}