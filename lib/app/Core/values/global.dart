
import 'package:fgtracker/app/Core/values/storage_services.dart';
import 'package:flutter/services.dart';

import 'colors.dart';


class Global {
  static late StorageServices storageServices;


  static Future init() async {

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);


    // SizeConfig.init(ContextUtility.context!);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: AppColors.darkBlue
    ));


    storageServices = await StorageServices().init();
  }
}
