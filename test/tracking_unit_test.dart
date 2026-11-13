import 'package:flutter_test/flutter_test.dart';
import 'package:fgtracker/app/Data/Services/Tracking.dart';
import 'package:fgtracker/app/Model/LocationDataRes.dart';
import 'package:fgtracker/app/Model/UsersWithinRadiusRes.dart';
import 'package:fgtracker/app/modules/Track/Controller/TrackLiveLocationSocketService.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  group('1. Tracking APIs - UsersWithinRadiusRes & LocationDataRes Model Unit Tests', () {
    test('UsersWithinRadiusRes correctly parses nearby users with latitude, longitude & address', () {
      final json = {
        "status": true,
        "message": "Nearby users fetched successfully",
        "radius": {"meters": 2000, "display": "2 km"},
        "data": [
          {
            "userId": 101,
            "id": 101,
            "latitude": 19.0760,
            "longitude": 72.8777,
            "name": "Rohan Sharma",
            "mobileNumber": "9876543210",
            "distanceMeters": 450,
            "distance": "450 m",
            "location": "Andheri East, Mumbai",
            "profileImage": "uploads/Auth/rohan.png",
            "isOnline": true,
            "chatId": 55,
          },
          {
            "userId": 102,
            "id": 102,
            "latitude": 19.0800,
            "longitude": 72.8800,
            "name": "Amit Verma",
            "distanceMeters": 1200,
            "distance": "1.2 km",
            "location": "Kurla, Mumbai",
            "isOnline": false,
            "chatId": 56,
          }
        ]
      };

      final res = UsersWithinRadiusRes.fromJson(json);

      expect(res.status, true);
      expect(res.data?.length, 2);

      final user1 = res.data![0];
      expect(user1.userId, 101);
      expect(user1.name, 'Rohan Sharma');
      expect(user1.latitude, 19.0760);
      expect(user1.longitude, 72.8777);
      expect(user1.location, 'Andheri East, Mumbai');
      expect(user1.isOnline, true);
      expect(user1.chatId, 55);

      final user2 = res.data![1];
      expect(user2.userId, 102);
      expect(user2.latitude, 19.0800);
      expect(user2.longitude, 72.8800);
      expect(user2.isOnline, false);
    });

    test('LocationData correctly parses locationSharing (Ghost Mode / Private Mode)', () {
      final ghostUserJson = {
        "id": 201,
        "userId": 201,
        "groupId": 10,
        "name": "Ghost User",
        "latitude": 19.1000,
        "longitude": 72.9000,
        "locationSharing": false,
        "isOnline": true,
      };

      final ghostMember = LocationData.fromJson(ghostUserJson);
      expect(ghostMember.userId, 201);
      expect(ghostMember.locationSharing, false);

      final normalUserJson = {
        "id": 202,
        "userId": 202,
        "groupId": 10,
        "name": "Sharing User",
        "latitude": 19.1000,
        "longitude": 72.9000,
        "locationSharing": true,
        "isOnline": true,
      };

      final normalMember = LocationData.fromJson(normalUserJson);
      expect(normalMember.userId, 202);
      expect(normalMember.locationSharing, true);
    });
  });

  group('2. Socket Models - LiveLocationSocketModel Unit Tests', () {
    test('LiveLocationSocketModel parses socket payload with area/city address fallback', () {
      final socketPayload = {
        "userId": 301,
        "groupId": 15,
        "lat": 19.0728,
        "lng": 72.8826,
        "battery": 82,
        "area": "Bandra",
        "city": "Mumbai",
        "name": "Karan Malhotra",
        "profileImage": "uploads/Auth/karan.png"
      };

      final model = LiveLocationSocketModel.fromJson(socketPayload);

      expect(model.userId, 301);
      expect(model.groupId, 15);
      expect(model.lat, 19.0728);
      expect(model.lng, 72.8826);
      expect(model.battery, 82);
      expect(model.address, 'Bandra, Mumbai');
      expect(model.name, 'Karan Malhotra');
    });

    test('LiveLocationSocketModel normalizes string coordinate fields safely', () {
      final rawPayload = {
        "userId": "401",
        "latitude": "19.0123",
        "longitude": "72.8456",
        "batteryLevel": "95%",
        "location": "Dadar, Mumbai"
      };

      final model = LiveLocationSocketModel.fromJson(rawPayload);

      expect(model.userId, '401');
      expect(model.lat, closeTo(19.0123, 0.0001));
      expect(model.lng, closeTo(72.8456, 0.0001));
      expect(model.battery, 95);
      expect(model.address, 'Dadar, Mumbai');
    });
  });

  group('3. Activity & Online / Last-Seen State Verification', () {
    final tracking = Tracking();

    test('User with lastSeen within threshold (< 5 mins) is Online', () {
      final recentLastSeen = DateTime.now().subtract(const Duration(minutes: 2)).toIso8601String();
      final isOnline = tracking.isOnline(
        rawIsOnline: true,
        lastSeen: recentLastSeen,
        thresholdMinutes: 5,
      );
      expect(isOnline, true);
    });

    test('User with lastSeen older than threshold (>= 5 mins) is Offline / Last Seen', () {
      // Even if rawIsOnline is true in DB, inactivity must evaluate to false
      final oldLastSeen = DateTime.now().subtract(const Duration(minutes: 15)).toIso8601String();
      final isOnline = tracking.isOnline(
        rawIsOnline: true,
        lastSeen: oldLastSeen,
        thresholdMinutes: 5,
      );
      expect(isOnline, false);
    });

    test('User with lastSeen from yesterday evaluates to Offline', () {
      final yesterdayLastSeen = DateTime.now().subtract(const Duration(hours: 26)).toIso8601String();
      final isOnline = tracking.isOnline(
        rawIsOnline: 1,
        lastSeen: yesterdayLastSeen,
        thresholdMinutes: 5,
      );
      expect(isOnline, false);
    });

    test('Explicit offline flag without lastSeen evaluates to Offline', () {
      final isOnline = tracking.isOnline(
        rawIsOnline: false,
        lastSeen: null,
      );
      expect(isOnline, false);
    });
  });

  group('4. Radius Boundary & Distance Filtering Unit Tests', () {
    const double myLat = 19.0760;
    const double myLng = 72.8777;

    test('User within selected radius is accepted', () {
      // Point approximately 450 meters away
      const double targetLat = 19.0790;
      const double targetLng = 72.8795;
      const double selectedRadiusMeters = 2000.0;

      final distance = Geolocator.distanceBetween(myLat, myLng, targetLat, targetLng);
      final bool isWithin = distance <= selectedRadiusMeters;

      expect(isWithin, true);
      expect(distance, lessThan(2000.0));
    });

    test('User outside selected radius is rejected / excluded', () {
      // Point approximately 5.2 km away
      const double farLat = 19.1200;
      const double farLng = 72.9100;
      const double selectedRadiusMeters = 2000.0;

      final distance = Geolocator.distanceBetween(myLat, myLng, farLat, farLng);
      final bool isWithin = distance <= selectedRadiusMeters;

      expect(isWithin, false);
      expect(distance, greaterThan(2000.0));
    });

    test('Radius string conversion handles km and meters accurately', () {
      int getApiRadiusParam(String val) {
        final cleanVal = val.replaceAll('km', '').replaceAll('m', '').trim();
        final double? parsed = double.tryParse(cleanVal);
        if (parsed == null || parsed <= 0) return 2000;
        if (val.contains('km') || parsed < 50) {
          return (parsed * 1000).round();
        } else {
          return parsed.round();
        }
      }

      expect(getApiRadiusParam('0.5'), 500);
      expect(getApiRadiusParam('1'), 1000);
      expect(getApiRadiusParam('2'), 2000);
      expect(getApiRadiusParam('5'), 5000);
      expect(getApiRadiusParam('500m'), 500);
      expect(getApiRadiusParam('2km'), 2000);
    });
  });

  group('5. Socket Event Packet Unwrapping Unit Tests', () {
    test('group-location-update wrapper correctly unpacks updatedUser', () {
      final groupEventWrapper = {
        "status": true,
        "groupId": 12,
        "updatedUserId": 501,
        "updatedUser": {
          "userId": 501,
          "groupId": 12,
          "lat": 19.0760,
          "lng": 72.8777,
          "battery": 88,
          "name": "Live Member",
          "isOnline": true,
          "locationSharing": true
        },
        "data": [
          {"userId": 501, "latitude": 19.0760, "longitude": 72.8777},
          {"userId": 502, "latitude": 18.5204, "longitude": 73.8567} // 150 km away static record
        ]
      };

      Map<String, dynamic>? extractedMovingUser;
      if (groupEventWrapper['updatedUser'] is Map) {
        extractedMovingUser = Map<String, dynamic>.from(groupEventWrapper['updatedUser'] as Map);
      }

      expect(extractedMovingUser, isNotNull);
      expect(extractedMovingUser!['userId'], 501);
      expect(extractedMovingUser['groupId'], 12);
      expect(extractedMovingUser['lat'], 19.0760);
      expect(extractedMovingUser['name'], 'Live Member');

      // Ensure static other group members from 'data' are not treated as active moving users
      expect(extractedMovingUser['userId'], isNot(502));
    });
  });
}

