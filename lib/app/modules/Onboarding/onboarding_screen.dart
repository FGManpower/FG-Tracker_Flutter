
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/auth/Views/login_Page.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'onboarding_contents.dart';

class OnboardingController extends GetxController {
  var currentPage = 0.obs;
  PageController pageController = PageController();

  void updatePage(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value < contents.length - 1) {
      pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  void jumpToPage(int index) {
    pageController.jumpToPage(index);
  }
}

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final OnboardingController controller = Get.put(OnboardingController());

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.updatePage,
                itemCount: contents.length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.asset(contents[i].image),
                        ),
                        SizedBox(height: (height >= 840) ? 60 : 30),
                        reausabletext(
                          contents[i].title,
                          align: TextAlign.center,

                            fontfamily: "Mulish",
                            fontweight: FontWeight.w600,
                            fontsize: (width <= 550) ? 30 : 35,
                        ),
                        SizedBox(height: 15),
                        reausabletext(
                          contents[i].desc,
                          align: TextAlign.center,

                            fontfamily: "Mulish",
                            fontweight: FontWeight.w300,
                            fontsize: (width <= 550) ? 17 : 25,

                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(
                        () => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        contents.length,
                            (int index) => AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: controller.currentPage.value != index
                                ? Colors.black.withOpacity(0.3)
                                : Colors.black,
                          ),
                          margin: EdgeInsets.only(right: 5),
                          height: 10,
                          width: controller.currentPage.value == index ? 20 : 10,
                        ),
                      ),
                    ),
                  ),
                  Obx(
                        () => controller.currentPage.value + 1 == contents.length
                        ? Padding(
                      padding: EdgeInsets.all(30),
                      child: ElevatedButton(
                        onPressed: () => Get.off(LoginPage()),
                        child: reausabletext("START", color: Colors.white),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          padding: (width <= 550)
                              ? EdgeInsets.symmetric(horizontal: 100, vertical: 20)
                              : EdgeInsets.symmetric(horizontal: width * 0.2, vertical: 25),
                          textStyle: TextStyle(fontSize: (width <= 550) ? 13 : 17),
                        ),
                      ),
                    )
                        : Padding(
                      padding: EdgeInsets.all(30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => controller.jumpToPage(2),
                            child: reausabletext("SKIP", color: Colors.black),
                          ),
                          ElevatedButton(
                            onPressed: controller.nextPage,
                            child: reausabletext("NEXT", color: Colors.white),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
