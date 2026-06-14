import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../config/app_theme.dart';
import '../../models/medication_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/medication_provider.dart';
import '../../widgets/layout/mc_scaffold.dart';
import '../../widgets/inputs/mc_text_field.dart';
import '../../widgets/inputs/mc_dropdown.dart';
import '../../widgets/buttons/mc_primary_button.dart';
import '../../widgets/common/mc_toast.dart';
import '../../services/camera_service.dart';

class AddMedicationScreen extends ConsumerStatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  ConsumerState<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends ConsumerState<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _supplyController = TextEditingController(text: '30');
  final _thresholdController = TextEditingController(text: '7');
  
  String _selectedForm = 'tablet';
  String? _pillPhotoPath;
  bool _isLoading = false;

  final CameraService _cameraService = CameraService();

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    _supplyController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  void _capturePhoto() async {
    final path = await _cameraService.capturePhoto();
    if (path != null) {
      setState(() => _pillPhotoPath = path);
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final user = ref.read(authProvider);

    final medication = MedicationModel(
      id: const Uuid().v4(),
      userId: user?.id ?? '',
      name: _nameController.text.trim(),
      dosage: _dosageController.text.trim(),
      form: _selectedForm,
      instructions: _instructionsController.text.trim(),
      totalSupply: int.tryParse(_supplyController.text) ?? 30,
      currentSupply: int.tryParse(_supplyController.text) ?? 30,
      refillThreshold: int.tryParse(_thresholdController.text) ?? 7,
      pillPhotoUrl: _pillPhotoPath,
    );

    final success = await ref.read(medicationProvider.notifier).addMedication(medication);
    setState(() => _isLoading = false);

    if (success && mounted) {
      McToast.showSuccess(context, 'Medication added successfully');
      Navigator.of(context).pop();
    } else if (mounted) {
      McToast.showError(context, 'Failed to add medication');
    }
  }

  @override
  Widget build(BuildContext context) {
    return McScaffold(
      title: 'Add Medication',
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _capturePhoto,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.dividerColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.textHint),
                    ),
                    child: _pillPhotoPath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              File(_pillPhotoPath!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.add_a_photo, size: 40),
                            ),
                          )
                        : const Icon(Icons.add_a_photo_rounded, size: 40, color: AppTheme.textHint),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              McTextField(
                label: 'Medication Name',
                hint: 'e.g. Paracetamol',
                controller: _nameController,
                validator: (val) => val == null || val.isEmpty ? 'Medication name required' : null,
              ),
              const SizedBox(height: 16),
              McTextField(
                label: 'Dosage / Strength',
                hint: 'e.g. 500mg',
                controller: _dosageController,
                validator: (val) => val == null || val.isEmpty ? 'Dosage required' : null,
              ),
              const SizedBox(height: 16),
              McDropdown<String>(
                label: 'Medication Form',
                value: _selectedForm,
                items: const [
                  DropdownMenuItem(value: 'tablet', child: Text('Tablet')),
                  DropdownMenuItem(value: 'capsule', child: Text('Capsule')),
                  DropdownMenuItem(value: 'liquid', child: Text('Liquid')),
                  DropdownMenuItem(value: 'inhaler', child: Text('Inhaler')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedForm = val);
                },
              ),
              const SizedBox(height: 16),
              McTextField(
                label: 'Instructions (Optional)',
                hint: 'e.g. Take after meal',
                controller: _instructionsController,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: McTextField(
                      label: 'Total Supply Count',
                      controller: _supplyController,
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || int.tryParse(val) == null ? 'Enter number' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: McTextField(
                      label: 'Refill Threshold (days)',
                      controller: _thresholdController,
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || int.tryParse(val) == null ? 'Enter days' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              McPrimaryButton(
                label: 'Save Medication',
                isLoading: _isLoading,
                onTap: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
