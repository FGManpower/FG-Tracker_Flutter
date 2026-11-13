

import 'package:fgtracker/l10n/l10n.dart';

class Tracking {
  /// Display text for the fixed English location values the tracking code
  /// uses as logic ids ("Location unavailable", "Locating...", ...). Any
  /// other value (address from geocoding / API) is returned as-is.
  static String displayLocation(String value) {
    final l = appL10n;
    switch (value.trim()) {
      case 'Location unavailable':
        return l.track_locationUnavailable;
      case 'Locating...':
        return l.track_locating;
      case 'Current Location':
        return l.track_currentLocation;
      case 'Nearby you':
        return l.track_nearbyYou;
    }
    return value;
  }

  /// Display text for a distance value such as "1.2 km away" (the English
  /// value is kept for parsing). Number and unit stay; "away" is translated.
  static String displayDistance(String value) {
    final t = value.trim();
    if (t.endsWith(' away')) {
      return appL10n.track_distanceAway(t.substring(0, t.length - 5).trim());
    }
    return displayLocation(t);
  }

  /// Display text for the fixed English errors set by TrackingController
  /// (kept in English: the screen checks them for "internet"/"network").
  /// Server messages are returned as-is.
  static String displayError(String value) {
    final l = appL10n;
    switch (value) {
      case 'Failed to load groups':
        return l.track_errorFailedLoadGroups;
      case 'Unable to connect to server. Please try again.':
        return l.track_errorServer;
      case 'Unable to load groups. Please try again.':
        return l.track_errorLoadGroups;
      case 'Unable to load nearby members. Please try again.':
        return l.track_errorLoadMembers;
      case 'No internet connection. Please check your network.':
        return l.track_errorNoInternet;
    }
    return value;
  }

  /// Safely parse a date-time string, automatically handling UTC timestamps without trailing 'Z'.
  static DateTime? parseDateTime(dynamic raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw.isUtc ? raw.toLocal() : raw;
    final str = raw.toString().trim();
    if (str.isEmpty || str == 'null') return null;

    final epoch = int.tryParse(str);
    if (epoch != null && epoch > 1000000000) {
      final ms = str.length == 10 ? epoch * 1000 : epoch;
      return DateTime.fromMillisecondsSinceEpoch(ms).toLocal();
    }

    try {
      final normalizedStr = str.replaceAll('/', '-');
      DateTime dt = DateTime.parse(normalizedStr);
      // If the string does not specify a timezone offset or Z, backend might have stored in UTC
      if (!normalizedStr.endsWith('Z') && !normalizedStr.contains('+')) {
        final utcDt = DateTime.tryParse('${normalizedStr.replaceAll(' ', 'T')}Z');
        if (utcDt != null) {
          final now = DateTime.now();
          final diffNormal = now.difference(dt).abs();
          final diffUtc = now.difference(utcDt.toLocal()).abs();
          if (diffUtc < diffNormal) {
            return utcDt.toLocal();
          }
        }
      }
      return dt.isUtc ? dt.toLocal() : dt;
    } catch (_) {
      return null;
    }
  }

  /// Check if a user is considered online/live based on explicit status or recency of lastSeen.
  bool isOnline({dynamic rawIsOnline, dynamic lastSeen, int thresholdMinutes = 5}) {
    if (lastSeen != null) {
      final dt = parseDateTime(lastSeen);
      if (dt != null) {
        final now = DateTime.now();
        final diff = now.difference(dt);
        if (!diff.isNegative && diff.inMinutes >= thresholdMinutes) {
          return false;
        }
        return true;
      }
    }

    if (rawIsOnline != null) {
      if (rawIsOnline == false ||
          rawIsOnline == 0 ||
          rawIsOnline == '0' ||
          rawIsOnline == 'false' ||
          rawIsOnline == 'offline') {
        return false;
      }
      if (rawIsOnline == true ||
          rawIsOnline == 1 ||
          rawIsOnline == '1' ||
          rawIsOnline == 'online') {
        return true;
      }
    }

    return false;
  }

  String getTimeAgo(DateTime lastSeen) {
    final now = DateTime.now();
    final dt = lastSeen.isUtc ? lastSeen.toLocal() : lastSeen;
    final diff = now.difference(dt);

    final l = appL10n;
    if (diff.isNegative || diff.inSeconds < 180) return l.common_justNow;
    if (diff.inMinutes < 60) return l.common_minutesAgo(diff.inMinutes);
    if (diff.inHours < 24) {
      return l.common_hoursAgo(diff.inHours);
    }
    return l.common_daysAgo(diff.inDays);
  }
}

