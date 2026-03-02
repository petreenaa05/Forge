import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forge/providers/auth_provider.dart';
import 'package:forge/providers/user_provider.dart';
import 'package:forge/core/theme/app_theme.dart';
import 'package:forge/core/constants/app_constants.dart';

/// Freelancer profile setup screen.
/// Collects name, skills, experience, bio, location; toggles availability.
class ProviderSetupScreen extends StatefulWidget {
  const ProviderSetupScreen({super.key});

  @override
  State<ProviderSetupScreen> createState() => _ProviderSetupScreenState();
}

class _ProviderSetupScreenState extends State<ProviderSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();

  final Set<String> _selectedSkills = {};
  bool _available = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill if user already has partial data
    final user = context.read<UserProvider>().user;
    if (user != null) {
      _nameCtrl.text = user.name;
      _bioCtrl.text = user.bio;
      _locationCtrl.text = user.location;
      _experienceCtrl.text = user.experience > 0 ? user.experience.toString() : '';
      _selectedSkills.addAll(user.skills);
      _available = user.available;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _locationCtrl.dispose();
    _experienceCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one skill category'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final uid = context.read<AuthProvider>().uid;
    if (uid == null) return;

    final userProvider = context.read<UserProvider>();

    await userProvider.updateUser(uid, {
      'name': _nameCtrl.text.trim(),
      'bio': _bioCtrl.text.trim(),
      'location': _locationCtrl.text.trim(),
      'experience': int.tryParse(_experienceCtrl.text.trim()) ?? 0,
      'skills': _selectedSkills.toList(),
      'available': _available,
      'verified': true, // Mock admin verification for hackathon
    });

    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed('/provider-home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Setup Your Profile'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar placeholder
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: AppTheme.primary.withOpacity(0.1),
                        child: const Text('👩‍🔧', style: TextStyle(fontSize: 40)),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Name
                _label('Full Name'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Enter your full name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 20),

                // Skills
                _label('Skills / Categories'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: kCategories.map((cat) {
                    final selected = _selectedSkills.contains(cat.name);
                    return FilterChip(
                      label: Text('${cat.emoji} ${cat.name}'),
                      selected: selected,
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            _selectedSkills.add(cat.name);
                          } else {
                            _selectedSkills.remove(cat.name);
                          }
                        });
                      },
                      selectedColor: AppTheme.primary.withOpacity(0.15),
                      checkmarkColor: AppTheme.primary,
                      labelStyle: TextStyle(
                        color: selected ? AppTheme.primary : AppTheme.textMedium,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: selected
                              ? AppTheme.primary
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Experience
                _label('Years of Experience'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _experienceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'e.g. 3',
                    prefixIcon: Icon(Icons.work_outline),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 20),

                // Bio
                _label('Bio'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _bioCtrl,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Tell clients about yourself...',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 20),

                // Location
                _label('Location'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _locationCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Mumbai, India',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 20),

                // Availability toggle
                Card(
                  child: SwitchListTile(
                    title: const Text(
                      'Available for work',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      _available
                          ? 'Clients can see and book you'
                          : 'You\'re hidden from search results',
                      style: const TextStyle(fontSize: 13),
                    ),
                    value: _available,
                    activeColor: AppTheme.verified,
                    onChanged: (v) => setState(() => _available = v),
                    secondary: Icon(
                      _available ? Icons.visibility : Icons.visibility_off,
                      color: _available ? AppTheme.verified : AppTheme.textMedium,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Save
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text('Save & Continue'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppTheme.textDark,
      ),
    );
  }
}
