import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/trip_summary.dart';
import '../services/auth_service.dart';
import '../theme/tropica_theme.dart';
import 'profile_preferences_screen.dart';
import 'trip_workspace_screen.dart';

class HomeTripsScreen extends StatefulWidget {
  final AuthService authService;

  const HomeTripsScreen({
    super.key,
    required this.authService,
  });

  @override
  State<HomeTripsScreen> createState() => _HomeTripsScreenState();
}

class _HomeTripsScreenState extends State<HomeTripsScreen> {
  int _bottomTabIndex = 0;
  String _searchQuery = '';

  void _openTripDetail(TripSummary trip) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TripWorkspaceScreen(
          trip: trip,
          authService: widget.authService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.authService,
      builder: (context, _) {
        final trips = widget.authService.trips.where((trip) {
          if (_searchQuery.trim().isEmpty) return true;
          final q = _searchQuery.toLowerCase();
          return trip.title.toLowerCase().contains(q) ||
              trip.destination.toLowerCase().contains(q);
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(
              _bottomTabIndex == 0
                  ? 'TropicaGuide · Upcoming Trips'
                  : _bottomTabIndex == 1
                      ? 'Explore Destinations'
                      : 'Traveler Profile & Preferences',
            ),
          ),
          body: IndexedStack(
            index: _bottomTabIndex,
            children: [
              _buildTripsTab(context, trips),
              _buildExploreOverviewTab(context),
              ProfilePreferencesScreen(authService: widget.authService),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _bottomTabIndex,
            onDestinationSelected: (index) {
              setState(() {
                _bottomTabIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.luggage_outlined),
                selectedIcon: Icon(Icons.luggage),
                label: 'Trips',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search),
                label: 'Explore',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTripsTab(BuildContext context, List<TripSummary> trips) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final activeTrips = trips.where((t) => !t.isInvitation).toList();
    final invites = trips.where((t) => t.isInvitation).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          key: const Key('trip_search_input'),
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: const InputDecoration(
            hintText: 'Search upcoming trips or destinations...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 16),
        ...activeTrips.map((trip) {
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              leading: CircleAvatar(
                backgroundColor: TropicaTheme.oceanTeal.withValues(alpha: 0.14),
                child: const Icon(
                  Icons.flight_takeoff,
                  color: TropicaTheme.oceanTeal,
                ),
              ),
              title: Text(
                trip.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${trip.destination}\n${dateFormat.format(trip.startDate)} – ${dateFormat.format(trip.endDate)}',
              ),
              isThreeLine: true,
              trailing: Chip(
                label: Text(
                  trip.roleFor(widget.authService.currentProfile!.uid).toUpperCase(),
                ),
              ),
              onTap: () => _openTripDetail(trip),
            ),
          );
        }),
        if (invites.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Pending Group Invitations',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ...invites.map((invite) {
            return Card(
              color: TropicaTheme.sunsetAmber.withValues(alpha: 0.45),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trip Invite: ${invite.title}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${invite.destination} · Budget \$${invite.groupBudget.toStringAsFixed(0)}',
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        ElevatedButton(
                          key: Key('accept_invite_${invite.tripId}'),
                          onPressed: () {
                            widget.authService.respondToTripInvite(
                              tripId: invite.tripId,
                              accept: true,
                            );
                          },
                          child: const Text('Accept Invite'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          key: Key('decline_invite_${invite.tripId}'),
                          onPressed: () {
                            widget.authService.respondToTripInvite(
                              tripId: invite.tripId,
                              accept: false,
                            );
                          },
                          child: const Text('Decline'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildExploreOverviewTab(BuildContext context) {
    final profile = widget.authService.currentProfile!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saved Destination Shortlist',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                ...profile.savedDestinations.map(
                  (dest) => ListTile(
                    leading: const Icon(
                      Icons.place_outlined,
                      color: TropicaTheme.oceanTeal,
                    ),
                    title: Text(dest),
                    subtitle: Text(
                      'Matched to preferences: ${profile.preferences.join(", ")}',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
