import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Testscren extends StatefulWidget {
  const Testscren({super.key});

  @override
  State<Testscren> createState() => _TestscrenState();
}

class _TestscrenState extends State<Testscren> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("Hello Samad"),));
  }
}
