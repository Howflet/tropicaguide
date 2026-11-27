import 'package:flutter/foundation.dart';

class TravelerProfile {
  final String uid;
  final String email;
  final String displayName;
  final List<String> preferences;
  final List<String> savedDestinations;
  final List<String> pendingTripInvites;
  final double maxDailyBudget;
  final String travelPace;

  const TravelerProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.preferences = const [],
    this.savedDestinations = const [],
    this.pendingTripInvites = const [],
    this.maxDailyBudget = 150.0,
    this.travelPace = 'Balanced',
  });

  TravelerProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    List<String>? preferences,
    List<String>? savedDestinations,
    List<String>? pendingTripInvites,
    double? maxDailyBudget,
    String? travelPace,
  }) {
    return TravelerProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      preferences: preferences ?? this.preferences,
      savedDestinations: savedDestinations ?? this.savedDestinations,
      pendingTripInvites: pendingTripInvites ?? this.pendingTripInvites,
      maxDailyBudget: maxDailyBudget ?? this.maxDailyBudget,
      travelPace: travelPace ?? this.travelPace,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email.trim(),
      'displayName': displayName.trim(),
      'preferences': preferences,
      'savedDestinations': savedDestinations,
      'pendingTripInvites': pendingTripInvites,
      'maxDailyBudget': maxDailyBudget,
      'travelPace': travelPace,
    };
  }

  factory TravelerProfile.fromMap(Map<String, dynamic> map) {
    return TravelerProfile(
      uid: (map['uid'] ?? '') as String,
      email: (map['email'] ?? '') as String,
      displayName: (map['displayName'] ?? 'Traveler') as String,
      preferences: List<String>.from(map['preferences'] ?? const <String>[]),
      savedDestinations: List<String>.from(
        map['savedDestinations'] ?? const <String>[],
      ),
      pendingTripInvites: List<String>.from(
        map['pendingTripInvites'] ?? const <String>[],
      ),
      maxDailyBudget: ((map['maxDailyBudget'] ?? 150.0) as num).toDouble(),
      travelPace: (map['travelPace'] ?? 'Balanced') as String,
    );
  }

  bool canBeEditedBy(String actorUid) => actorUid.isNotEmpty && actorUid == uid;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TravelerProfile &&
        other.uid == uid &&
        other.email == email &&
        other.displayName == displayName &&
        listEquals(other.preferences, preferences) &&
        listEquals(other.savedDestinations, savedDestinations) &&
        listEquals(other.pendingTripInvites, pendingTripInvites) &&
        other.maxDailyBudget == maxDailyBudget &&
        other.travelPace == travelPace;
  }

  @override
  int get hashCode => Object.hash(
        uid,
        email,
        displayName,
        Object.hashAll(preferences),
        Object.hashAll(savedDestinations),
        Object.hashAll(pendingTripInvites),
        maxDailyBudget,
        travelPace,
      );
}
