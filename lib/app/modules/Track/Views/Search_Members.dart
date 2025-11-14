import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/themes_data.dart';

class SearchMembers extends StatefulWidget {
  const SearchMembers({super.key});

  @override
  State<SearchMembers> createState() => _SearchMembersState();
}

class _SearchMembersState extends State<SearchMembers> {
  final TextEditingController searchValues = TextEditingController();

  @override
  void dispose() {
    searchValues.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ToggleThemeData.darkPurple,
        elevation: 4,
        titleSpacing: 0,
        toolbarHeight: 65.h,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.zero,
          icon: Container(
            height: 33.w,
            width: 33.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: ToggleThemeData.white,
                width: 2.w,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.arrow_back_outlined,
                color: Colors.white,
                size: 24.sp,
              ),
            ),
          ),
        ),

        // 🔥 Search Bar inside AppBar
        title: Padding(
          padding: EdgeInsets.only(right: 10.w),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50.r),

            ),
            child: TextField(
              controller: searchValues,
              keyboardType: TextInputType.text,
              onChanged: (value) {},
              decoration: InputDecoration(
                hintText: "Search Members",
                contentPadding: EdgeInsets.symmetric(horizontal: 15.w),
                suffixIcon: searchValues.text.isNotEmpty
                    ? InkWell(
                  onTap: () {
                    setState(() {
                      searchValues.clear();
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.all(6.r),
                    child: CircleAvatar(
                      backgroundColor: ToggleThemeData.darkPurple,
                      child: Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                )
                    : null,
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),

      body: Center(
        child: Text(
          "Type to search...",
          style: TextStyle(fontSize: 18.sp),
        ),
      ),
    );
  }
}
