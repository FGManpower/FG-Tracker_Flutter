import 'package:cached_network_image/cached_network_image.dart';
import 'package:fgtracker/app/Core/theme/appTheme.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';

class ViewFullImage extends StatelessWidget {
  ViewFullImage({super.key, required this.title, required this.pimgurl});
  String title = "";
  String pimgurl = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // iconTheme: IconThemeData(color: Colors.white),
        title: reausabletext(
          title,
          fontfamily: FontFamily.interMedium,
          fontsize: 15,
        ),
      ),
      body: Center(
        child: CachedNetworkImage(
          width: MediaQuery.sizeOf(context).width,
          imageUrl: pimgurl == null ? MyAppTheme.notFoundImg : pimgurl,
          fit: BoxFit.cover,
          placeholder: (context, string) => const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
