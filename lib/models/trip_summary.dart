class TripSummary {
  final String tripId;
  final String title;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final String ownerId;
  final List<String> memberIds;
  final Map<String, String> memberRoles;
  final double groupBudget;
  final bool isInvitation;

  const TripSummary({
    required this.tripId,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.ownerId,
    required this.memberIds,
    required this.memberRoles,
    this.groupBudget = 1200.0,
    this.isInvitation = false,
  });

  String roleFor(String uid) {
    if (uid == ownerId) return 'owner';
    return memberRoles[uid] ?? 'viewer';
  }

  bool canEdit(String uid) {
    final role = roleFor(uid);
    return role == 'owner' || role == 'editor';
  }

  Map<String, dynamic> toMap() {
    return {
      'tripId': tripId,
      'title': title,
      'destination': destination,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'ownerId': ownerId,
      'memberIds': memberIds,
      'memberRoles': memberRoles,
      'groupBudget': groupBudget,
      'isInvitation': isInvitation,
    };
  }

  factory TripSummary.fromMap(Map<String, dynamic> map) {
    return TripSummary(
      tripId: (map['tripId'] ?? '') as String,
      title: (map['title'] ?? '') as String,
      destination: (map['destination'] ?? '') as String,
      startDate: DateTime.parse(
        (map['startDate'] ?? DateTime.now().toIso8601String()) as String,
      ),
      endDate: DateTime.parse(
        (map['endDate'] ?? DateTime.now().toIso8601String()) as String,
      ),
      ownerId: (map['ownerId'] ?? '') as String,
      memberIds: List<String>.from(map['memberIds'] ?? const <String>[]),
      memberRoles: Map<String, String>.from(
        map['memberRoles'] ?? const <String, String>{},
      ),
      groupBudget: ((map['groupBudget'] ?? 1200.0) as num).toDouble(),
      isInvitation: (map['isInvitation'] ?? false) as bool,
    );
  }
}
