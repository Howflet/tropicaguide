import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tropicaguide/main.dart';
import 'package:tropicaguide/services/auth_service.dart';

void main() {
  group('Week 1 Foundation — Authentication & Traveler Profile', () {
    test('Authorized sign-in succeeds and loads private preferences', () async {
      final authService = AuthService();
      final profile = await authService.signInWithEmailAndPassword(
        email: 'howard@tropicaguide.app',
        password: 'Tropica2026!',
      );

      expect(authService.isAuthenticated, isTrue);
      expect(profile.uid, equals('uid-howard'));
      expect(profile.preferences, contains('Beach & Water'));
      expect(profile.savedDestinations, contains('Miami, FL'));
    });

    test('Invalid credentials and malformed emails are rejected', () async {
      final authService = AuthService();

      await expectLater(
        () => authService.signInWithEmailAndPassword(
          email: 'not-an-email',
          password: 'Tropica2026!',
        ),
        throwsA(
          isA<AuthException>().having((e) => e.code, 'code', 'invalid-email'),
        ),
      );

      await expectLater(
        () => authService.signInWithEmailAndPassword(
          email: 'howard@tropicaguide.app',
          password: 'WrongPassword123!',
        ),
        throwsA(
          isA<AuthException>()
              .having((e) => e.code, 'code', 'invalid-credentials'),
        ),
      );
    });

    test('Profile updates enforce owner-only access and reject non-owners',
        () async {
      final authService = AuthService();
      await authService.signInWithEmailAndPassword(
        email: 'howard@tropicaguide.app',
        password: 'Tropica2026!',
      );

      // Owner edit succeeds
      final updated = await authService.updateProfile(
        actorUid: 'uid-howard',
        targetUid: 'uid-howard',
        displayName: 'Howard F.',
        preferences: const ['Beach & Water', 'Photography'],
      );
      expect(updated.displayName, equals('Howard F.'));
      expect(updated.preferences, contains('Photography'));

      // Unauthorized edit by another user is rejected
      await expectLater(
        () => authService.updateProfile(
          actorUid: 'uid-maya',
          targetUid: 'uid-howard',
          displayName: 'Tampered Name',
        ),
        throwsA(
          isA<AuthException>()
              .having((e) => e.code, 'code', 'permission-denied'),
        ),
      );
    });

    testWidgets(
        'Welcome sign-in flow transitions to Home Trips and opens Trip Workspace tabs',
        (WidgetTester tester) async {
      final authService = AuthService();
      await tester.pumpWidget(TropicaGuideApp(authService: authService));

      expect(find.text('TropicaGuide'), findsOneWidget);
      expect(find.byKey(const Key('primary_auth_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('primary_auth_button')));
      await tester.pumpAndSettle();

      // Verifies navigation to Home — Upcoming Trips
      expect(find.text('Miami Spring Break'), findsOneWidget);
      expect(find.text('Trip Invite: Key West Roadtrip'), findsOneWidget);

      // Accept the pending trip invitation
      final acceptButton = find.byKey(const Key('accept_invite_trip-key-west'));
      await tester.ensureVisible(acceptButton);
      await tester.pumpAndSettle();
      await tester.tap(acceptButton);
      await tester.pumpAndSettle();
      expect(find.text('Key West Roadtrip'), findsOneWidget);

      // Open Miami Spring Break workspace and verify all 5 trip tabs exist
      await tester.tap(find.text('Miami Spring Break'));
      await tester.pumpAndSettle();

      expect(find.text('Itinerary'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Checklist'), findsOneWidget);
      expect(find.text('Packing'), findsOneWidget);
      expect(find.text('Members'), findsOneWidget);
    });
  });
}
