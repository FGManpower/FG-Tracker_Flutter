import 'package:fgtracker/app/Core/values/responsive.dart';
import 'package:fgtracker/app/modules/Application/Controller/InitiateController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fgtracker/gen/assets.gen.dart';

class Splashscreen extends StatelessWidget  {
  const Splashscreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InitiateController());

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Assets.images.splashBg.path),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: controller.animationController,
                builder: (context, child) {
                  double size = MediaQueryHelper.width(200) +
                      (controller.animationController.value *
                          MediaQueryHelper.width(80));
                  double opacity = (1 - controller.animationController.value) * 0.2;
                  return Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(opacity),
                    ),
                  );
                },
              ),
              FadeTransition(
                opacity: controller.fadeAnimation,
                child: ScaleTransition(
                  scale: controller.scaleAnimation,
                  child: Image.asset(
                    Assets.icons.appIcon.path,
                    height: MediaQueryHelper.height(180),
                    width: MediaQueryHelper.width(180),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
