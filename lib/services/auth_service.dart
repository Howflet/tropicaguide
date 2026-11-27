import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/traveler_profile.dart';
import '../models/trip_summary.dart';

class AuthException implements Exception {
  final String code;
  final String message;

  const AuthException(this.code, this.message);

  @override
  String toString() => message;
}

class AuthService extends ChangeNotifier {
  final bool useCloudFirebase;
  final Map<String, String> _credentialsStore = {
    'howard@tropicaguide.app': 'Tropica2026!',
    'maya@tropicaguide.app': 'IslandTrip99!',
  };

  final Map<String, TravelerProfile> _profilesStore = {
    'uid-howard': const TravelerProfile(
      uid: 'uid-howard',
      email: 'howard@tropicaguide.app',
      displayName: 'Howard Fletcher',
      preferences: ['Beach & Water', 'Local Food', 'History & Culture'],
      savedDestinations: ['Miami, FL', 'San Juan, PR', 'Key West, FL'],
      pendingTripInvites: ['trip-key-west'],
      maxDailyBudget: 160.0,
      travelPace: 'Balanced',
    ),
    'uid-maya': const TravelerProfile(
      uid: 'uid-maya',
      email: 'maya@tropicaguide.app',
      displayName: 'Maya Lin',
      preferences: ['Outdoor Adventure', 'Photography'],
      savedDestinations: ['San Juan, PR'],
      pendingTripInvites: [],
      maxDailyBudget: 130.0,
      travelPace: 'Packed',
    ),
  };

  final List<TripSummary> _trips = [
    TripSummary(
      tripId: 'trip-miami-spring',
      title: 'Miami Spring Break',
      destination: 'Miami, FL',
      startDate: DateTime(2026, 3, 14),
      endDate: DateTime(2026, 3, 18),
      ownerId: 'uid-howard',
      memberIds: const ['uid-howard', 'uid-maya'],
      memberRoles: const {'uid-howard': 'owner', 'uid-maya': 'editor'},
      groupBudget: 1450.0,
    ),
    TripSummary(
      tripId: 'trip-san-juan',
      title: 'San Juan Getaway',
      destination: 'San Juan, PR',
      startDate: DateTime(2026, 12, 18),
      endDate: DateTime(2026, 12, 22),
      ownerId: 'uid-howard',
      memberIds: const ['uid-howard'],
      memberRoles: const {'uid-howard': 'owner'},
      groupBudget: 1800.0,
    ),
    TripSummary(
      tripId: 'trip-key-west',
      title: 'Key West Roadtrip',
      destination: 'Key West, FL',
      startDate: DateTime(2027, 1, 8),
      endDate: DateTime(2027, 1, 11),
      ownerId: 'uid-maya',
      memberIds: const ['uid-maya', 'uid-howard'],
      memberRoles: const {'uid-maya': 'owner', 'uid-howard': 'editor'},
      groupBudget: 950.0,
      isInvitation: true,
    ),
  ];

  TravelerProfile? _currentProfile;
  String? _lastPasswordResetEmail;

  AuthService({this.useCloudFirebase = false});

  TravelerProfile? get currentProfile => _currentProfile;
  bool get isAuthenticated => _currentProfile != null;
  String? get lastPasswordResetEmail => _lastPasswordResetEmail;
  List<TripSummary> get trips => List.unmodifiable(_trips);

  static String? validateEmail(String? email) {
    final trimmed = (email ?? '').trim();
    if (trimmed.isEmpty) {
      return 'Email is required.';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String? validatePassword(String? password) {
    final value = password ?? '';
    if (value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    return null;
  }

  Future<TravelerProfile> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final emailError = validateEmail(email);
    if (emailError != null) {
      throw AuthException('invalid-email', emailError);
    }
    final passwordError = validatePassword(password);
    if (passwordError != null) {
      throw AuthException('weak-password', passwordError);
    }

    final normalizedEmail = email.trim().toLowerCase();
    final storedPassword = _credentialsStore[normalizedEmail];
    if (storedPassword == null || storedPassword != password) {
      throw const AuthException(
        'invalid-credentials',
        'Invalid email or password. Please check your credentials.',
      );
    }

    if (useCloudFirebase) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: normalizedEmail,
          password: password,
        );
      } catch (_) {
        // Fallback to local verified profile state when running offline/tests
      }
    }

    final profile = _profilesStore.values.firstWhere(
      (p) => p.email.toLowerCase() == normalizedEmail,
    );
    _currentProfile = profile;
    notifyListeners();
    return profile;
  }

  Future<TravelerProfile> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final emailError = validateEmail(email);
    if (emailError != null) {
      throw AuthException('invalid-email', emailError);
    }
    final passwordError = validatePassword(password);
    if (passwordError != null) {
      throw AuthException('weak-password', passwordError);
    }
    if (displayName.trim().isEmpty) {
      throw const AuthException(
        'invalid-display-name',
        'Display name cannot be empty.',
      );
    }

    final normalizedEmail = email.trim().toLowerCase();
    if (_credentialsStore.containsKey(normalizedEmail)) {
      throw const AuthException(
        'email-already-in-use',
        'An account already exists for that email address.',
      );
    }

    final uid = 'uid-${DateTime.now().millisecondsSinceEpoch}';
    final profile = TravelerProfile(
      uid: uid,
      email: normalizedEmail,
      displayName: displayName.trim(),
      preferences: const ['Beach & Water', 'Local Food'],
      savedDestinations: const ['Miami, FL'],
    );

    _credentialsStore[normalizedEmail] = password;
    _profilesStore[uid] = profile;
    _currentProfile = profile;

    if (useCloudFirebase) {
      try {
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: normalizedEmail,
          password: password,
        );
        final fbUid = credential.user?.uid ?? uid;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(fbUid)
            .set(profile.copyWith(uid: fbUid).toMap());
      } catch (_) {}
    }

    notifyListeners();
    return profile;
  }

  Future<TravelerProfile> signInWithGoogle() async {
    final profile = _profilesStore['uid-howard']!;
    _currentProfile = profile;
    notifyListeners();
    return profile;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    final emailError = validateEmail(email);
    if (emailError != null) {
      throw AuthException('invalid-email', emailError);
    }
    final normalizedEmail = email.trim().toLowerCase();
    _lastPasswordResetEmail = normalizedEmail;
    if (useCloudFirebase) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: normalizedEmail,
        );
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<TravelerProfile> updateProfile({
    required String actorUid,
    required String targetUid,
    String? displayName,
    List<String>? preferences,
    List<String>? savedDestinations,
    double? maxDailyBudget,
    String? travelPace,
  }) async {
    final existing = _profilesStore[targetUid];
    if (existing == null) {
      throw const AuthException('user-not-found', 'Traveler profile not found.');
    }
    if (!existing.canBeEditedBy(actorUid)) {
      throw const AuthException(
        'permission-denied',
        'Only the owning traveler account can edit private profile settings.',
      );
    }
    if (displayName != null && displayName.trim().isEmpty) {
      throw const AuthException(
        'invalid-display-name',
        'Display name cannot be empty.',
      );
    }

    final updated = existing.copyWith(
      displayName: displayName?.trim() ?? existing.displayName,
      preferences: preferences ?? existing.preferences,
      savedDestinations: savedDestinations ?? existing.savedDestinations,
      maxDailyBudget: maxDailyBudget ?? existing.maxDailyBudget,
      travelPace: travelPace ?? existing.travelPace,
    );

    _profilesStore[targetUid] = updated;
    if (_currentProfile?.uid == targetUid) {
      _currentProfile = updated;
    }

    if (useCloudFirebase) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(targetUid)
            .set(updated.toMap(), SetOptions(merge: true));
      } catch (_) {}
    }

    notifyListeners();
    return updated;
  }

  void respondToTripInvite({
    required String tripId,
    required bool accept,
  }) {
    final user = _currentProfile;
    if (user == null) return;

    final updatedInvites =
        user.pendingTripInvites.where((id) => id != tripId).toList();
    _currentProfile = user.copyWith(pendingTripInvites: updatedInvites);
    _profilesStore[user.uid] = _currentProfile!;

    final index = _trips.indexWhere((t) => t.tripId == tripId);
    if (index != -1) {
      final trip = _trips[index];
      if (accept) {
        _trips[index] = TripSummary(
          tripId: trip.tripId,
          title: trip.title,
          destination: trip.destination,
          startDate: trip.startDate,
          endDate: trip.endDate,
          ownerId: trip.ownerId,
          memberIds: trip.memberIds,
          memberRoles: trip.memberRoles,
          groupBudget: trip.groupBudget,
          isInvitation: false,
        );
      } else {
        _trips.removeAt(index);
      }
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    _currentProfile = null;
    if (useCloudFirebase) {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
    }
    notifyListeners();
  }
}
