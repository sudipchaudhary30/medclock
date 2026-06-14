import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/family_provider.dart';
import '../../widgets/layout/mc_scaffold.dart';
import '../../widgets/inputs/mc_text_field.dart';
import '../../widgets/inputs/mc_dropdown.dart';
import '../../widgets/buttons/mc_primary_button.dart';
import '../../widgets/common/mc_toast.dart';

class AddMemberScreen extends ConsumerStatefulWidget {
  const AddMemberScreen({super.key});

  @override
  ConsumerState<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends ConsumerState<AddMemberScreen> {
  final _nameController = TextEditingController();
  String _selectedRole = 'patient';
  String _selectedColor = '#2D7DD2';
  bool _isLoading = false;

  final List<Map<String, String>> _colors = [
    {'name': 'Blue', 'value': '#2D7DD2'},
    {'name': 'Red', 'value': '#FF6B6B'},
    {'name': 'Green', 'value': '#45CB85'},
    {'name': 'Orange', 'value': '#FFB347'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_nameController.text.trim().isEmpty) {
      McToast.showError(context, 'Member name required');
      return;
    }

    setState(() => _isLoading = true);
    final success = await ref.read(familyProvider.notifier).addMember(
      _nameController.text.trim(),
      _selectedRole,
      _selectedColor,
    );
    setState(() => _isLoading = false);

    if (success && mounted) {
      McToast.showSuccess(context, 'Member added to circle.');
      Navigator.of(context).pop();
    } else if (mounted) {
      McToast.showError(context, 'Failed to add member.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return McScaffold(
      title: 'Add Family Member',
      showBackButton: true,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            McTextField(
              label: 'Member Name',
              hint: 'e.g. John Doe',
              controller: _nameController,
            ),
            const SizedBox(height: 16),
            McDropdown<String>(
              label: 'Role',
              value: _selectedRole,
              items: const [
                DropdownMenuItem(value: 'patient', child: Text('Patient')),
                DropdownMenuItem(value: 'caregiver', child: Text('Caregiver')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedRole = val);
              },
            ),
            const SizedBox(height: 16),
            McDropdown<String>(
              label: 'Color Theme',
              value: _selectedColor,
              items: _colors.map((c) {
                return DropdownMenuItem(
                  value: c['value'],
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Color(int.parse(c['value']!.replaceFirst('#', '0xFF'))),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(c['name']!),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedColor = val);
              },
            ),
            const Spacer(),
            McPrimaryButton(
              label: 'Add Member',
              isLoading: _isLoading,
              onTap: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
