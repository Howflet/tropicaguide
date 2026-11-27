import 'package:flutter/material.dart';

import '../models/trip_summary.dart';
import '../services/auth_service.dart';
import '../theme/tropica_theme.dart';

class TripWorkspaceScreen extends StatefulWidget {
  final TripSummary trip;
  final AuthService authService;

  const TripWorkspaceScreen({
    super.key,
    required this.trip,
    required this.authService,
  });

  @override
  State<TripWorkspaceScreen> createState() => _TripWorkspaceScreenState();
}

class _TripWorkspaceScreenState extends State<TripWorkspaceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Always open at the Trip's Itinerary tab (Screen 3) per navigation flow spec
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openAddEditItineraryItemModal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add / Edit Dated Itinerary Item',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Screen 4 Skeleton — Full dated itinerary persistence, drag-and-drop order, and overlap checks ship in Week 2.',
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = widget.authService.currentProfile?.uid ?? '';
    final role = widget.trip.roleFor(uid);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trip.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              label: Text(role.toUpperCase()),
              backgroundColor: TropicaTheme.lagoonMint,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: TropicaTheme.sunsetAmber,
          tabs: const [
            Tab(text: 'Itinerary', icon: Icon(Icons.schedule)),
            Tab(text: 'Search', icon: Icon(Icons.travel_explore)),
            Tab(text: 'Checklist', icon: Icon(Icons.checklist)),
            Tab(text: 'Packing', icon: Icon(Icons.backpack_outlined)),
            Tab(text: 'Members', icon: Icon(Icons.group_outlined)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildItinerarySkeleton(context),
          _buildSectionPlaceholder(
            title: 'Activity Search',
            subtitle:
                'Filter activities by location, category, and budget with offline & stale-cache handling.',
            icon: Icons.travel_explore,
          ),
          _buildSectionPlaceholder(
            title: 'Trip Checklist',
            subtitle:
                'Shared preparation tasks with member assignments and reset/restore support.',
            icon: Icons.fact_check_outlined,
          ),
          _buildSectionPlaceholder(
            title: 'Shared Packing List',
            subtitle:
                'Per-item atomic packing check-offs with duplicate prevention.',
            icon: Icons.luggage_outlined,
          ),
          _buildMembersOverview(context),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('open_add_itinerary_item_button'),
        onPressed: _openAddEditItineraryItemModal,
        icon: const Icon(Icons.add),
        label: const Text('Add Dated Itinerary Item'),
      ),
    );
  }

  Widget _buildItinerarySkeleton(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(
              Icons.wb_sunny_outlined,
              color: TropicaTheme.oceanTeal,
            ),
            title: const Text('South Beach Morning Walk'),
            subtitle: const Text('Day 1 · 09:00 AM – 10:30 AM'),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(
              Icons.restaurant_outlined,
              color: TropicaTheme.oceanTeal,
            ),
            title: const Text('Little Havana Food Tour'),
            subtitle: const Text('Day 1 · 11:00 AM – 01:30 PM'),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionPlaceholder({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 48, color: TropicaTheme.oceanTeal),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMembersOverview(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: widget.trip.memberRoles.entries.map((entry) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text('Member ID: ${entry.key}'),
            trailing: Chip(label: Text(entry.value.toUpperCase())),
          ),
        );
      }).toList(),
    );
  }
}
