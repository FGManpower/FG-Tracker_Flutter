import 'package:fgtracker/app/Model/CommonRes.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommonResponse - Safe Status Parsing (Prevent String -> bool error)', () {
    test('parses String "deactivated" as successful status true without throwing', () {
      final json = {
        "status": "deactivated",
        "message": "Group deactivated successfully",
      };
      final res = CommonResponse.fromJson(json);
      expect(res.status, isTrue);
      expect(res.isSuccess, isTrue);
      expect(res.rawStatus, "deactivated");
      expect(res.message, "Group deactivated successfully");
    });

    test('parses String "active" as successful status true without throwing', () {
      final json = {
        "status": "active",
        "message": "Group activated successfully",
      };
      final res = CommonResponse.fromJson(json);
      expect(res.status, isTrue);
      expect(res.isSuccess, isTrue);
      expect(res.rawStatus, "active");
      expect(res.message, "Group activated successfully");
    });

    test('parses String "true" and "false" without type cast exceptions', () {
      final resTrue = CommonResponse.fromJson({"status": "true", "message": "ok"});
      expect(resTrue.status, isTrue);

      final resFalse = CommonResponse.fromJson({"status": "false", "message": "fail"});
      expect(resFalse.status, isFalse);
    });

    test('parses String "success" and "failed" / "error"', () {
      final resSuccess = CommonResponse.fromJson({"status": "success", "message": "all good"});
      expect(resSuccess.status, isTrue);

      final resFailed = CommonResponse.fromJson({"status": "failed", "message": "bad"});
      expect(resFailed.status, isFalse);

      final resError = CommonResponse.fromJson({"status": "error", "message": "fatal"});
      expect(resError.status, isFalse);
    });

    test('parses boolean and numeric status', () {
      expect(CommonResponse.fromJson({"status": true}).status, isTrue);
      expect(CommonResponse.fromJson({"status": false}).status, isFalse);
      expect(CommonResponse.fromJson({"status": 1}).status, isTrue);
      expect(CommonResponse.fromJson({"status": 0}).status, isFalse);
    });

    test('handles fallback to success or ok keys', () {
      expect(CommonResponse.fromJson({"success": true}).status, isTrue);
      expect(CommonResponse.fromJson({"ok": true}).status, isTrue);
    });
  });

  group('GroupRes & GroupsResData - Safe Type Parsing', () {
    test('parses GroupRes with string status "success" or "active"', () {
      final json = {
        "status": "success",
        "message": "Groups retrieved",
        "data": {
          "groups": [
            {
              "id": "12",
              "groupName": "Alpha Team",
              "isActive": "false",
              "isCreator": "true",
              "memberCount": "8"
            }
          ]
        }
      };

      final res = GroupRes.fromJson(json);
      expect(res.status, isTrue);
      expect(res.data?.groupData?.length, 1);

      final group = res.data!.groupData!.first;
      expect(group.id, 12);
      expect(group.groupName, "Alpha Team");
      expect(group.isActive, isFalse);
      expect(group.isCreator, isTrue);
      expect(group.memberCount, 8);
    });

    test('parses isActive from "active" and "deactivated" strings', () {
      final activeGroup = GroupsResData.fromJson({"status": "active"});
      expect(activeGroup.isActive, isTrue);

      final deactGroup = GroupsResData.fromJson({"status": "deactivated"});
      expect(deactGroup.isActive, isFalse);
    });

    test('parses isActive from numeric 1 and 0', () {
      expect(GroupsResData.fromJson({"isActive": 1}).isActive, isTrue);
      expect(GroupsResData.fromJson({"isActive": 0}).isActive, isFalse);
    });
  });
}

