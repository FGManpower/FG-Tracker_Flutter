import 'package:fgtracker/app/Core/theme/AppText.dart';

class OnboardingContents {
  final String title;
  final String image;
  final String desc;

  OnboardingContents({
    required this.title,
    required this.image,
    required this.desc,
  });
}

List<OnboardingContents> contents = [
  OnboardingContents(
    title: "trackYourWork",
    image: "assets/images/image1.png",
    desc: "rememberToKeepTrack",
  ),
  OnboardingContents(
    title: "stayOrganizedWithUs",
    image: "assets/images/image2.png",
    desc: "butUnderstandingCntribution",
  ),
  OnboardingContents(
    title: "getNotifiedWhenWorkHappens",
    image: "assets/images/image3.png",
    desc:
    "takeControlOfNotification",
  ),
];