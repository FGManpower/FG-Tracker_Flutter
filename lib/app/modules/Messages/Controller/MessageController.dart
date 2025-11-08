import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Model/ProfileRes.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/loading.dart';
import 'package:fgtracker/app/Data/Repositories/GetMessageRepo.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Socket_Message_Services.dart';

class MessageController extends GetxController {

  final SocketMessageService socketService = SocketMessageService.instance;
  final ScrollController _scrollController = ScrollController();

  var messageData = <MessageData>[].obs;
  var imagePath = "".obs;
  final joinedUsersData = <Map<String, dynamic>>[].obs;
  var isSending = false.obs;
  var messageText = ''.obs;


  String getBgColorKey(String userId) => 'chat_background_color_$userId';
  String getBgImagePathKey(String userId) => 'chat_background_image_path_$userId';


  var chatBackgroundColor = Colors.white.obs;
  var chatBackgroundImagePath = RxnString(); // path to file image


  late final UserData userData; // User data for the current chat
  final TextEditingController textController = TextEditingController();
  final RxBool _isSending = false.obs; // Observable to track sending status

  String get currentImagePath => imagePath.value;
  TextEditingController get messageTextController => textController;

  final TextEditingController inputController = TextEditingController();



  Future<void> saveThemePreferences(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('chat_background_color_$userId', chatBackgroundColor.value.value);

    if (chatBackgroundImagePath.value != null) {
      prefs.setString('chat_background_image_path_$userId', chatBackgroundImagePath.value!);
    } else {
      prefs.remove('chat_background_image_path_$userId');
    }
  }

  Future<void> loadThemePreferences(String userId) async {
    final prefs = await SharedPreferences.getInstance();

    final colorValue = prefs.getInt('chat_background_color_$userId');
    if (colorValue != null) {
      chatBackgroundColor.value = Color(colorValue);
    }

    final imagePath = prefs.getString('chat_background_image_path_$userId');
    if (imagePath != null && File(imagePath).existsSync()) {
      chatBackgroundImagePath.value = imagePath;
    } else {
      chatBackgroundImagePath.value = null;
    }
  }



  Future<void> pickBackgroundImageFromGallery(String userId) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = path.basename(pickedFile.path);
      final savedImage = await File(pickedFile.path).copy('${directory.path}/$fileName');
      chatBackgroundImagePath.value = savedImage.path;
      saveThemePreferences(userId); // 👈 pass the specific userId here

    }
  }



  void initSocket(String recieverId,{required int groupId}

      ) {
    log("----------------InitChatDetail----groupId:${groupId}-----recieverId--${recieverId}");
    socketService.init(groupId: groupId,userId: recieverId,ConstRes.socketUrl);

    socketService.socket?.off('receive_message');
    socketService.RecievedMessage(

      senderId: Global.storageServices.get(PrefConst.userId).toString(),
      recieverId: recieverId,
      groupId: groupId,
        callback: (message) {
          messageData.add(MessageData.fromJson(message));

          Future.delayed(const Duration(milliseconds: 50), () {
            scrollToBottom(_scrollController, animated: true);
          });
        }
      // callback: (message) {
      //   messageData.add(MessageData.fromJson(message));
      //   scrollToBottom(_scrollController, animated: true);
      // },
    );
  }


  Future<void> getMessageHistory(BuildContext context,String recieverId,int groupId) async {
   try{
     Loading().showloading(context: context);
    var result = await MessageRepo.MessageHistory(recieverId: recieverId,groupId: groupId);
    if(result.status==true){
      Loading().dismissloading(context: context);
      messageData.value=result.messageData!;
    }else{
      Loading().dismissloading(context: context);
      CommonDialog.errorMessage(result.message);
    }
   }catch(e){
     Loading().dismissloading(context: context);
     log("message-Exception:$e");
   }
  }
}


class ChatThemeController extends GetxController {
  static const String _bgColorKey = 'chat_background_color';
  static const String _bgImageKey = 'chat_background_image';

  var chatBackgroundColor = Colors.white.obs;
  var chatBackgroundImage = RxnString();

  Future<void> loadThemePreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final colorValue = prefs.getInt(_bgColorKey);
    if (colorValue != null) {
      chatBackgroundColor.value = Color(colorValue);
    }

    final imagePath = prefs.getString(_bgImageKey);
    chatBackgroundImage.value = imagePath;
  }
}


void scrollToBottom(ScrollController controller, {bool animated = false}) {
  void tryScroll([int attempt = 0]) {
    if (!controller.hasClients) return;

    final maxScroll = controller.position.maxScrollExtent;

    if (animated) {
      controller.animateTo(
        maxScroll,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      controller.jumpTo(maxScroll);
    }

    // ✅ Retry a few times until list fully renders
    if (attempt < 3) {
      Future.delayed(const Duration(milliseconds: 100), () => tryScroll(attempt + 1));
    }
  }

  // Wait a little before first scroll
  Future.delayed(const Duration(milliseconds: 50), tryScroll);
}



String formatTime(String timestamp) {
  final dateTime = DateTime.parse(timestamp).toLocal();
  return DateFormat('hh:mm a').format(dateTime);
}

String formatDateHeader(String timestamp) {
  final dateTime = DateTime.parse(timestamp).toLocal();
  final now = DateTime.now();

  final today = DateTime(now.year, now.month, now.day);
  final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

  if (messageDate == today) {
    return "Today";
  } else if (messageDate == today.subtract(Duration(days: 1))) {
    return "Yesterday";
  } else {
    return DateFormat('dd MMM yyyy').format(dateTime); // like "05 Jun 2025"
  }
}

final RxString imagePath = ''.obs;
final TextEditingController inputController = TextEditingController();


