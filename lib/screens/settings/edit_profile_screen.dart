import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/layout/mc_scaffold.dart';
import '../../widgets/inputs/mc_text_field.dart';
import '../../widgets/buttons/mc_primary_button.dart';
import '../../widgets/common/mc_toast.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  String _gender = 'Male';
  DateTime? _dob;
  String _bloodType = 'B+';
  bool _isSaving = false;
  bool _hasChanged = false;

  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
  ];

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider);
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    // Track changes to enable/disable save button
    _nameController.addListener(_onChanged);
    _emailController.addListener(_onChanged);
    _phoneController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onChanged() {
    final user = ref.read(authProvider);
    final changed =
        (_nameController.text.trim() != (user?.name ?? '')) ||
        (_emailController.text.trim() != (user?.email ?? '')) ||
        (_phoneController.text.trim() != (user?.phone ?? '')) ||
        (_gender != 'Male') ||
        (_bloodType != 'B+');
    if (changed != _hasChanged) setState(() => _hasChanged = changed);
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final initial = _dob ?? DateTime(now.year - 40, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      McToast.showError(context, 'Full name is required');
      return;
    }

    setState(() => _isSaving = true);

    final data = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
    };

    // Attempt backend update
    final authSvc = ref.read(authServiceProvider);
    try {
      final updatedUser = await authSvc.updateProfile(data);
      if (!mounted) return;
      if (updatedUser != null) {
        ref.read(authProvider.notifier).updateUser(updatedUser);
        if (mounted) {
          McToast.showSuccess(context, 'Profile updated');
        }
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        // fallback to local update
        final current = ref.read(authProvider);
        if (current != null) {
          final updated = current.copyWith(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
          );
          ref.read(authProvider.notifier).updateUser(updated);
        }
        if (mounted) {
          McToast.showWarning(context, 'Profile saved locally (offline)');
        }
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        McToast.showError(context, 'Failed to update profile');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return McScaffold(
      title: 'Edit Profile',
      showBackButton: true,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    radius: 48,
                    backgroundColor: AppTheme.primaryDark,
                    child: Icon(
                      Icons.person_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(6.0),
                        child: Icon(Icons.edit, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Patient ID: MC-8829-NP', style: AppTheme.caption),
            const SizedBox(height: 20),

            Text(
              'Personal Information',
              style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            McTextField(label: 'Full Name', controller: _nameController),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickDob,
              child: AbsorbPointer(
                child: McTextField(
                  label: 'Date of Birth',
                  hint: _dob != null
                      ? '${_dob!.day}/${_dob!.month}/${_dob!.year}'
                      : 'Select date of birth',
                  controller: TextEditingController(text: ''),
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _gender,
              decoration: const InputDecoration(),
              items: const [
                DropdownMenuItem(value: 'Male', child: Text('Male')),
                DropdownMenuItem(value: 'Female', child: Text('Female')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _gender = v);
              },
            ),
            const SizedBox(height: 12),
            Text('Blood Type', style: AppTheme.labelText),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _bloodTypes.map((bt) {
                final selected = bt == _bloodType;
                return ChoiceChip(
                  label: Text(bt),
                  selected: selected,
                  onSelected: (_) => setState(() => _bloodType = bt),
                  selectedColor: AppTheme.primaryColor,
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              'Contact Details',
              style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            McTextField(
              label: 'Email Address',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            McTextField(
              label: 'Phone Number',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
            const Spacer(),
            McPrimaryButton(
              label: 'Save Changes',
              isLoading: _isSaving,
              onTap: _hasChanged && !_isSaving ? _save : null,
            ),
          ],
        ),
      ),
    );
  }
}
