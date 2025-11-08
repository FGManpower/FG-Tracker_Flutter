import 'dart:convert';
import 'dart:developer';

import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Tracking {
  Future<Map<String, dynamic>?> getWalkingRoute(
      LatLng origin, LatLng destination,{String mode="walking"}) async {
    final String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=$mode&key=${ConstRes.gMapApiKey}";

    try {
      final response = await ConstRes().sendRequest.get(url);

      if (response.statusCode == 200) {
        final data =
        response.data is String ? jsonDecode(response.data) : response.data;

        if ((data['routes'] as List).isNotEmpty) {
          final route = data['routes'][0];
          final leg = route['legs'][0];
          return {
            "distance": leg["distance"]["text"],
            "duration": leg["duration"]["text"],
            "polyline": route["overview_polyline"]["points"],
          };
        } else {
          log("❌ No routes found in response");
        }
      } else {
        log("❌ Google Directions API error: ${response.statusCode}");
      }
    } catch (e) {
      log("❌ Dio error while fetching route: $e");
    }

    return null;
  }

  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> polylineCoords = [];
    int index = 0, lat = 0, lng = 0;

    while (index < encoded.length) {
      int shift = 0, result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      polylineCoords.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return polylineCoords;
  }

  String getTimeAgo(DateTime lastSeen) {
    final now = DateTime.now();
    final diff = now.difference(lastSeen);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24)
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    return '${diff.inDays} day${diff.inDays > 1 ? 's' :''} ago';
    }
}

