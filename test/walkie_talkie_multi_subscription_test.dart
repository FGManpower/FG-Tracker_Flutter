import 'package:flutter_test/flutter_test.dart';
import 'package:fgtracker/app/Model/walkie_talkie_trial_details_model.dart';

void main() {
  group('WalkieTalkie Multi Team Plan Parsing Tests', () {
    test('Parses multiple team subscriptions array correctly', () {
      final json = {
        'status': true,
        'message': 'Overview fetched successfully',
        'data': {
          'access': {
            'canUseWalkie': true,
            'accessType': 'team',
          },
          'subscriptions': {
            'individual': {
              'hasPurchasedBefore': false,
              'hasActiveSubscription': false,
              'currentSubscription': null,
            },
            'team': {
              'hasPurchasedBefore': true,
              'hasActiveSubscription': true,
              'currentSubscription': {
                'subscriptionId': 101,
                'planId': 1,
                'planName': 'Monthly Plan 1',
                'planType': 'team',
                'billingInterval': 'monthly',
                'purchasedSeats': 1,
                'assignedSeats': 1,
                'availableSeats': 0,
                'status': 'active',
                'isOwner': true,
              },
              'subscriptions': [
                {
                  'subscriptionId': 101,
                  'planId': 1,
                  'planName': 'Monthly Plan 1',
                  'planType': 'team',
                  'billingInterval': 'monthly',
                  'purchasedSeats': 1,
                  'assignedSeats': 1,
                  'availableSeats': 0,
                  'status': 'active',
                  'isOwner': true,
                },
                {
                  'subscriptionId': 102,
                  'planId': 1,
                  'planName': 'Monthly Plan 2',
                  'planType': 'team',
                  'billingInterval': 'monthly',
                  'purchasedSeats': 1,
                  'assignedSeats': 0,
                  'availableSeats': 1,
                  'status': 'active',
                  'isOwner': true,
                },
              ],
            },
          },
        },
      };

      final model = WalkieTalkieTrialDetailsModel.fromJson(json);
      expect(model.isSuccessful, isTrue);
      expect(model.data, isNotNull);
      final team = model.data?.subscriptions?.team;
      expect(team, isNotNull);
      expect(team!.hasActiveSubscription, isTrue);
      expect(team.subscriptions.length, 2);
      expect(team.subscriptions[0].subscriptionId, 101);
      expect(team.subscriptions[1].subscriptionId, 102);
      expect(team.subscriptions[0].planName, 'Monthly Plan 1');
      expect(team.subscriptions[1].planName, 'Monthly Plan 2');
    });

    test('Parses activeSubscriptions array variant', () {
      final json = {
        'status': true,
        'data': {
          'subscriptions': {
            'team': {
              'hasPurchasedBefore': true,
              'hasActiveSubscription': true,
              'activeSubscriptions': [
                {
                  'subscriptionId': 201,
                  'planName': 'Team Plan A',
                  'status': 'active',
                  'purchasedSeats': 1,
                },
                {
                  'subscriptionId': 202,
                  'planName': 'Team Plan B',
                  'status': 'active',
                  'purchasedSeats': 1,
                },
              ],
            },
          },
        },
      };

      final model = WalkieTalkieTrialDetailsModel.fromJson(json);
      final team = model.data?.subscriptions?.team;
      expect(team, isNotNull);
      expect(team!.subscriptions.length, 2);
      expect(team.currentSubscription?.subscriptionId, 201);
    });

    test('Parses accumulated 2 seats single plan variant', () {
      final json = {
        'status': true,
        'data': {
          'subscriptions': {
            'team': {
              'hasPurchasedBefore': true,
              'hasActiveSubscription': true,
              'currentSubscription': {
                'subscriptionId': 301,
                'planName': 'Monthly Plan',
                'purchasedSeats': 2,
                'assignedSeats': 1,
                'availableSeats': 1,
                'status': 'active',
              },
            },
          },
        },
      };

      final model = WalkieTalkieTrialDetailsModel.fromJson(json);
      final team = model.data?.subscriptions?.team;
      expect(team, isNotNull);
      expect(team!.subscriptions.length, 1);
      expect(team.subscriptions.first.purchasedSeats, 2);
      expect(team.subscriptions.first.availableSeats, 1);
    });
  });
}
