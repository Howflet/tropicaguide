import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/tropica_theme.dart';

class ProfilePreferencesScreen extends StatefulWidget {
  final AuthService authService;

  const ProfilePreferencesScreen({
    super.key,
    required this.authService,
  });

  @override
  State<ProfilePreferencesScreen> createState() =>
      _ProfilePreferencesScreenState();
}

class _ProfilePreferencesScreenState extends State<ProfilePreferencesScreen> {
  static const List<String> _allPreferences = [
    'Beach & Water',
    'Local Food',
    'History & Culture',
    'Outdoor Adventure',
    'Nightlife',
    'Photography',
    'Family Friendly',
  ];

  late TextEditingController _nameController;
  late TextEditingController _destinationController;
  late Set<String> _selectedPreferences;
  late List<String> _savedDestinations;
  late double _maxDailyBudget;
  late String _travelPace;
  String? _feedbackMessage;

  @override
  void initState() {
    super.initState();
    final profile = widget.authService.currentProfile!;
    _nameController = TextEditingController(text: profile.displayName);
    _destinationController = TextEditingController();
    _selectedPreferences = Set<String>.from(profile.preferences);
    _savedDestinations = List<String>.from(profile.savedDestinations);
    _maxDailyBudget = profile.maxDailyBudget;
    _travelPace = profile.travelPace;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final profile = widget.authService.currentProfile;
    if (profile == null) return;

    try {
      await widget.authService.updateProfile(
        actorUid: profile.uid,
        targetUid: profile.uid,
        displayName: _nameController.text,
        preferences: _selectedPreferences.toList(),
        savedDestinations: _savedDestinations,
        maxDailyBudget: _maxDailyBudget,
        travelPace: _travelPace,
      );
      if (!mounted) return;
      setState(() {
        _feedbackMessage = 'Traveler profile and private preferences saved.';
      });
    } on AuthException catch (e) {
      setState(() {
        _feedbackMessage = e.message;
      });
    }
  }

  void _addDestination() {
    final text = _destinationController.text.trim();
    if (text.isEmpty || _savedDestinations.contains(text)) return;
    setState(() {
      _savedDestinations.add(text);
      _destinationController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: TropicaTheme.oceanTeal,
                      child: Text(
                        profile.displayName.isNotEmpty
                            ? profile.displayName[0].toUpperCase()
                            : 'T',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.displayName,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            profile.email,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          const Chip(
                            label: Text('Private Owner-Only Profile'),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      key: const Key('sign_out_button'),
                      tooltip: 'Sign Out',
                      onPressed: () => widget.authService.signOut(),
                      icon: const Icon(Icons.logout),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  key: const Key('profile_display_name_input'),
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Travel Preferences',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allPreferences.map((pref) {
                    final selected = _selectedPreferences.contains(pref);
                    return FilterChip(
                      label: Text(pref),
                      selected: selected,
                      onSelected: (value) {
                        setState(() {
                          if (value) {
                            _selectedPreferences.add(pref);
                          } else {
                            _selectedPreferences.remove(pref);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text(
                  'Daily Target Budget: \$${_maxDailyBudget.toStringAsFixed(0)}/day',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Slider(
                  value: _maxDailyBudget,
                  min: 50,
                  max: 400,
                  divisions: 35,
                  label: '\$${_maxDailyBudget.toStringAsFixed(0)}',
                  onChanged: (value) {
                    setState(() {
                      _maxDailyBudget = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _travelPace,
                  decoration: const InputDecoration(
                    labelText: 'Preferred Itinerary Pace',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Relaxed', child: Text('Relaxed')),
                    DropdownMenuItem(
                      value: 'Balanced',
                      child: Text('Balanced'),
                    ),
                    DropdownMenuItem(value: 'Packed', child: Text('Packed')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _travelPace = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saved Destinations',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('new_destination_input'),
                        controller: _destinationController,
                        decoration: const InputDecoration(
                          hintText: 'Add a destination (e.g., Nassau, BS)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      key: const Key('add_destination_button'),
                      onPressed: _addDestination,
                      child: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _savedDestinations.map((dest) {
                    return InputChip(
                      label: Text(dest),
                      onDeleted: () {
                        setState(() {
                          _savedDestinations.remove(dest);
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        if (_feedbackMessage != null) ...[
          const SizedBox(height: 12),
          Container(
            key: const Key('profile_saved_banner'),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.teal.shade200),
            ),
            child: Text(
              _feedbackMessage!,
              style: TextStyle(color: Colors.teal.shade900),
            ),
          ),
        ],
        const SizedBox(height: 16),
        ElevatedButton.icon(
          key: const Key('save_profile_button'),
          onPressed: _saveProfile,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save Private Preferences'),
        ),
      ],
    );
  }
}
