import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/auth/Auth_Widget/policy_texts.dart';
import 'package:fgtracker/app/modules/auth/Controller/PrivacyTermsController.dart';
import 'package:fgtracker/app/modules/auth/Controller/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class PrivacyTermsBottomSheet extends StatefulWidget {
  final String userPhone;

  const PrivacyTermsBottomSheet({Key? key, required this.userPhone}) : super(key: key);


  static Future<bool> show(BuildContext context, String userPhone) async {
    PrivacyTermsController termsController;
    if (!Get.isRegistered<PrivacyTermsController>()) {
      termsController = Get.put(PrivacyTermsController());
    } else {
      termsController = Get.find<PrivacyTermsController>();
    }

    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController());
    }
    termsController.showTerms.value = false;
    termsController.isAtBottom.value = false;

    final bool? result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PrivacyTermsBottomSheet(userPhone: userPhone),
    );

    return result ?? false;
  }

  @override
  _PrivacyTermsBottomSheetState createState() => _PrivacyTermsBottomSheetState();
}

class _PrivacyTermsBottomSheetState extends State<PrivacyTermsBottomSheet> {
  final ScrollController _scrollController = ScrollController();
  final PrivacyTermsController termsController = Get.find();
  final AuthController authController = Get.find();
  bool _showScrollToBottom = true;
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange) {
        termsController.setIsAtBottom(true);
      }
      // else {
      //   termsController.setIsAtBottom(false);
      // }
    });

  }


  Widget _scrollToBottomButton() {
    return Positioned(
      top: 10,
      right: 10,
      child: AnimatedOpacity(
        opacity: _showScrollToBottom ? 1.0 : 0.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: IgnorePointer(
          ignoring: !_showScrollToBottom,
          child: GestureDetector(
            onTap: _scrollToBottom,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: Icon(Icons.arrow_downward, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }
  void _handleNext() {
    termsController.setShowTerms(true);
    termsController.setIsAtBottom(false);
    _scrollController.jumpTo(0);
  }

  void _handleAccept() async {
    await Global.storageServices.setString("${PrefConst.AcceptPolicy}_${widget.userPhone}", "true");
    authController.setAcceptance(widget.userPhone, true);
    Navigator.pop(context,true); // ✅ Return true
  }

  void _handleDecline() {
    Global.storageServices.setString("${PrefConst.AcceptPolicy}_${widget.userPhone}", "false");
    authController.setAcceptance(widget.userPhone, false);
    Navigator.pop(context,false); // ✅ Return false
  }

  @override
  Widget build(BuildContext context) {

      return AnimatedPadding(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.4,
          builder: (_, sheetController) => Padding(
            padding: EdgeInsets.only(right: 15.w, left: 15.w),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // ✅ Keeps buttons visible
                children: [
                  Obx(() => _buildHeader(termsController.showTerms.value)),

                  Expanded(
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      thickness: 6,
                      radius: Radius.circular(10),
                      child: Obx(() => _buildContent(termsController.showTerms.value)),
                    ),
                  ),
                  _scrollToBottomButton(),
                  SafeArea( // ✅ Ensures buttons are not hidden behind keyboard or notch
                    child: Obx(() => _buildBottomButtons(
                      termsController.isAtBottom.value,
                      termsController.showTerms.value,
                    )),
                  ),
                ],
              ),

            ),
          ),
        ),
      );

  }

  Widget _buildHeader(bool showTerms) => Container(
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10))),
        SizedBox(height: 10),
        reausabletext(showTerms ? "Terms & Conditions" : "Privacy Policy", fontsize: 20, fontweight: FontWeight.bold),
      ],
    ),
  );

  Widget _buildContent(bool showTerms) {
    final String content = showTerms ? PolicyTexts.termsAndConditions : PolicyTexts.privacyPolicy;
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.all(16),
      child: Text(content, style: TextStyle(fontSize: 16, height: 1.5)),
    );
  }

  Widget _buildBottomButtons(bool isAtBottom, bool showTerms) {
    if (!isAtBottom) {
      return SizedBox(
        height: 40,
        child: Center(child: reausabletext("Scroll to the bottom to proceed", color: Colors.black, fontsize: 12)),
      );
    }

    return Padding(
      padding: EdgeInsets.all(16.0),
      child: showTerms
          ? Row(
        children: [
          Expanded(child: reausablebuttons(
            title: "Decline",
            ontap: _handleDecline,
            buttonfontsize: 14,
            colors: [Colors.red, Colors.red, Colors.red],
            height: 40,
            textcolor: Colors.white,
          )),
          SizedBox(width: 10),
          Expanded(child: reausablebuttons(
            title: "Accept",
            ontap: _handleAccept,
            buttonfontsize: 14,
            colors: [Colors.green, Colors.green, Colors.green],
            height: 40,
            textcolor: Colors.white,
          )),
        ],
      )
          : reausablebuttons(
        title: "Next",
        ontap: _handleNext,
        buttonfontsize: 14,
        width: 150,
        height: 40,
        textcolor: Colors.white,
      ),
    );
  }

}
