/// SAMPLE DATA ONLY — used in debug builds until the backend ships the
/// /packages endpoints (see PackagePricingRepo.useMock).
/// Prices here are placeholders, not real FG Tracker prices.
/// The shape is exactly the API contract in docs/package_pricing_api.md.
class PackagePricingMock {
  PackagePricingMock._();

  static Map<String, dynamic> packages() => {
        'status': true,
        'message': 'Packages fetched (sample data)',
        'data': {
          'packages': [
            {
              'id': 1,
              'moduleKey': 'attendance',
              'title': 'Attendance',
              'tagline': 'Selfie + location check-ins for your whole team',
              'startingPrice': 49,
              'currency': 'INR',
              'priceUnit': '/ member / month',
              'badge': 'Popular',
              'isAvailable': true,
              'isSubscribed': false,
              'highlights': ['Face check-in', 'Geo-fenced', 'Reports'],
              'sortOrder': 1,
            },
            {
              'id': 2,
              'moduleKey': 'walkie_talkie',
              'title': 'Walkie-Talkie',
              'tagline': 'Push-to-talk voice channels for groups',
              'startingPrice': 99,
              'currency': 'INR',
              'priceUnit': '/ member / month',
              'isAvailable': true,
              'isSubscribed': false,
              'highlights': ['Group channels', 'Works in background'],
              'sortOrder': 2,
            },
            {
              'id': 3,
              'moduleKey': 'safe_zone_route',
              'title': 'Safe Zone + Safe Route',
              'tagline': 'Alerts when members leave a zone or route',
              'startingPrice': 79,
              'currency': 'INR',
              'priceUnit': '/ member / month',
              'isAvailable': true,
              'isSubscribed': false,
              'highlights': ['Geofence alerts', 'Route deviation'],
              'sortOrder': 3,
            },
            {
              'id': 4,
              'moduleKey': 'live_tracking',
              'title': 'Live Tracking',
              'tagline': 'Real-time location of every member on one map',
              'startingPrice': 59,
              'currency': 'INR',
              'priceUnit': '/ member / month',
              'isAvailable': true,
              'isSubscribed': true,
              'activeUntil': '2026-12-31',
              'highlights': ['Live map', 'Location history'],
              'sortOrder': 4,
            },
          ],
        },
      };

  static Map<String, dynamic> plansFor(String moduleKey) {
    final plan = _plans[moduleKey];
    if (plan == null) {
      return {
        'status': false,
        'message': 'No plans found for this package',
      };
    }
    return {
      'status': true,
      'message': 'Plans fetched (sample data)',
      'data': plan,
    };
  }

  static List<Map<String, dynamic>> _durations(int base, int planIdStart) => [
        {
          'planId': planIdStart,
          'billingInterval': 'monthly',
          'durationMonths': 1,
          'pricePerMember': base,
        },
        {
          'planId': planIdStart + 1,
          'billingInterval': 'quarterly',
          'durationMonths': 3,
          'pricePerMember': (base * 3 * 0.9).round(),
          'mrpPerMember': base * 3,
        },
        {
          'planId': planIdStart + 2,
          'billingInterval': 'yearly',
          'durationMonths': 12,
          'pricePerMember': (base * 12 * 0.8).round(),
          'mrpPerMember': base * 12,
          'isRecommended': true,
        },
      ];

  static final Map<String, Map<String, dynamic>> _plans = {
    'attendance': {
      'moduleKey': 'attendance',
      'title': 'Attendance',
      'description':
          'Members mark attendance with a selfie and live location. Admins see who is in, late or absent.',
      'currency': 'INR',
      'gstPercent': 18,
      'priceIncludesGst': false,
      'features': [
        'Selfie + face check-in',
        'Location captured with every check-in',
      ],
      'tiers': [
        {
          'id': 11,
          'code': 'basic',
          'name': 'Basic',
          'description': 'For small teams getting started',
          'minMembers': 1,
          'maxMembers': 25,
          'features': [
            {'title': 'Daily check-in / check-out', 'included': true},
            {'title': 'Attendance history (30 days)', 'included': true},
            {'title': 'Excel / PDF reports', 'included': false},
            {'title': 'Geo-fenced office locations', 'included': false},
          ],
          'durations': _durations(49, 101),
        },
        {
          'id': 12,
          'code': 'pro',
          'name': 'Pro',
          'badge': 'Best value',
          'isRecommended': true,
          'description': 'For growing teams that need reports',
          'minMembers': 5,
          'maxMembers': 200,
          'features': [
            {'title': 'Daily check-in / check-out', 'included': true},
            {'title': 'Unlimited attendance history', 'included': true},
            {'title': 'Excel / PDF reports', 'included': true},
            {'title': 'Geo-fenced office locations', 'included': true},
          ],
          'durations': _durations(89, 111),
        },
      ],
      'termsNote':
          'Plans renew manually. Members can be added any time from the group.',
    },
    'safe_zone_route': {
      'moduleKey': 'safe_zone_route',
      'title': 'Safe Zone + Safe Route',
      'description':
          'Draw safe zones and routes on the map. Get alerted the moment someone leaves them.',
      'currency': 'INR',
      'gstPercent': 18,
      'priceIncludesGst': false,
      'features': ['Instant push alerts', 'Works with Live Tracking'],
      'tiers': [
        {
          'id': 21,
          'code': 'individual',
          'name': 'Individual',
          'description': 'Protect yourself or one family member',
          'minMembers': 1,
          'maxMembers': 1,
          'features': [
            {'title': 'Up to 3 safe zones', 'included': true},
            {'title': 'Up to 2 safe routes', 'included': true},
            {'title': 'Route deviation alerts', 'included': true},
          ],
          'durations': _durations(79, 201),
        },
        {
          'id': 22,
          'code': 'team',
          'name': 'Team',
          'badge': 'Popular',
          'isRecommended': true,
          'description': 'For families and field teams',
          'minMembers': 2,
          'maxMembers': 100,
          'features': [
            {'title': 'Unlimited safe zones', 'included': true},
            {'title': 'Unlimited safe routes', 'included': true},
            {'title': 'Route deviation alerts', 'included': true},
          ],
          'durations': _durations(69, 211),
        },
      ],
    },
    'live_tracking': {
      'moduleKey': 'live_tracking',
      'title': 'Live Tracking',
      'description':
          'See every member move on the map in real time, with history playback.',
      'currency': 'INR',
      'gstPercent': 18,
      'priceIncludesGst': true,
      'features': ['Battery-friendly tracking', 'Private / ghost mode'],
      'tiers': [
        {
          'id': 31,
          'code': 'individual',
          'name': 'Individual',
          'minMembers': 1,
          'maxMembers': 1,
          'features': [
            {'title': 'Live location', 'included': true},
            {'title': '7-day location history', 'included': true},
            {'title': 'Group live map', 'included': false},
          ],
          'durations': _durations(59, 301),
        },
        {
          'id': 32,
          'code': 'team',
          'name': 'Team',
          'isRecommended': true,
          'minMembers': 2,
          'maxMembers': 500,
          'features': [
            {'title': 'Live location', 'included': true},
            {'title': '90-day location history', 'included': true},
            {'title': 'Group live map', 'included': true},
          ],
          'durations': _durations(49, 311),
        },
        {
          'id': 33,
          'code': 'enterprise',
          'name': 'Enterprise',
          'minMembers': 50,
          'maxMembers': 5000,
          'features': [
            {'title': 'Live location', 'included': true},
            {'title': 'Unlimited location history', 'included': true},
            {'title': 'Group live map', 'included': true},
            {'title': 'Priority support', 'included': true},
          ],
          'durations': _durations(39, 321),
        },
      ],
    },
  };
}
