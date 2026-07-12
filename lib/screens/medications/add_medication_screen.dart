import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/medication_model.dart';
import '../../models/reminder_model.dart' hide TimeOfDay;
import '../../providers/auth_provider.dart';
import '../../providers/medication_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../widgets/common/mc_toast.dart';
import '../../services/camera_service.dart';

class AddMedicationScreen extends ConsumerStatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  ConsumerState<AddMedicationScreen> createState() =>
      _AddMedicationScreenState();
}

class _AddMedicationScreenState extends ConsumerState<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _supplyController = TextEditingController(text: '30');

  String _selectedForm = 'tablet';
  String? _pillPhotoPath;
  bool _isLoading = false;
  TimeOfDay _selectedTime = TimeOfDay(hour: 8, minute: 0);
  final Set<int> _selectedDays = {}; // 0=Sunday, 1=Monday, ..., 6=Saturday

  final CameraService _cameraService = CameraService();
  MedicationModel? _editingMedication;
  bool _isEditing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _supplyController.dispose();
    super.dispose();
  }

  /// Shows a bottom sheet letting the user pick Camera or Gallery.
  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Photo',
                style: TextStyle(
                  color: Color(0xFF0D1E30),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4FB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Color(0xFF0E6B94),
                  ),
                ),
                title: const Text(
                  'Take a Photo',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D1E30),
                  ),
                ),
                subtitle: const Text(
                  'Use your camera',
                  style: TextStyle(color: Color(0xFF6F7D8E), fontSize: 12),
                ),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  try {
                    final path = await _cameraService.capturePhoto();
                    if (path != null && mounted) {
                      setState(() => _pillPhotoPath = path);
                      if (mounted) {
                        McToast.showSuccess(
                          context,
                          'Photo captured successfully',
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      McToast.showError(context, 'Failed to capture photo');
                    }
                  }
                },
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4FB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: Color(0xFF0E6B94),
                  ),
                ),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D1E30),
                  ),
                ),
                subtitle: const Text(
                  'Pick an existing photo',
                  style: TextStyle(color: Color(0xFF6F7D8E), fontSize: 12),
                ),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  try {
                    final path = await _cameraService.pickFromGallery();
                    if (path != null && mounted) {
                      setState(() => _pillPhotoPath = path);
                      if (mounted) {
                        McToast.showSuccess(
                          context,
                          'Photo added successfully',
                        );
                      }
                    } else if (mounted) {
                      McToast.showWarning(context, 'No photo was selected');
                    }
                  } catch (e) {
                    if (mounted) {
                      McToast.showError(context, 'Failed to pick photo');
                    }
                  }
                },
              ),
              if (_pillPhotoPath != null) ...[
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFD92D20),
                    ),
                  ),
                  title: const Text(
                    'Remove Photo',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFD92D20),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    setState(() => _pillPhotoPath = null);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              dialHandColor: const Color(0xFF0E6B94),
              hourMinuteTextColor: const Color(0xFF0D1E30),
              dialBackgroundColor: Colors.grey[100],
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  void _toggleDay(int day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDays.isEmpty) {
      McToast.showError(context, 'Please select at least one day');
      return;
    }

    setState(() => _isLoading = true);
    final user = ref.read(authProvider);

    // Convert int day indices (0=Sun..6=Sat) to 3-letter strings
    const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final selectedDayStrings = _selectedDays.map((i) => dayNames[i]).toList();

    // Build "HH:mm" scheduled time string
    final scheduledTime =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    MedicationModel medication;
    if (_isEditing && _editingMedication != null) {
      medication = _editingMedication!.copyWith(
        name: _nameController.text.trim(),
        dosage:
            '${_nameController.text.trim()} ${_selectedTime.format(context)}',
        form: _selectedForm,
        instructions: selectedDayStrings.join(', '),
        totalSupply: int.tryParse(_supplyController.text) ?? 30,
        currentSupply: int.tryParse(_supplyController.text) ?? 30,
        pillPhotoUrl: _pillPhotoPath,
      );
    } else {
      medication = MedicationModel(
        id: const Uuid().v4(),
        userId: user?.id ?? '',
        name: _nameController.text.trim(),
        dosage: '${int.tryParse(_supplyController.text) ?? 30}mg',
        form: _selectedForm,
        instructions: selectedDayStrings.join(', '),
        totalSupply: int.tryParse(_supplyController.text) ?? 30,
        currentSupply: int.tryParse(_supplyController.text) ?? 30,
        refillThreshold: 7,
        pillPhotoUrl: _pillPhotoPath,
      );
    }

    MedicationModel? addedMedication;
    var success = false;

    if (_isEditing) {
      success = await ref
          .read(medicationProvider.notifier)
          .updateMedication(medication);

      // Also update the linked reminder's scheduledTime and days so it
      // propagates to alarms, upcoming/missed schedule, and supply status.
      if (success) {
        final reminders = ref.read(reminderProvider);
        final linked = reminders.where((r) => r.medicationId == medication.id);
        for (final r in linked) {
          final updatedReminder = r.copyWith(
            scheduledTime: scheduledTime,
            days: selectedDayStrings,
          );
          await ref
              .read(reminderProvider.notifier)
              .updateReminder(updatedReminder);
        }
      }
    } else {
      addedMedication = await ref
          .read(medicationProvider.notifier)
          .addMedication(medication);
      success = addedMedication != null;
    }

    if (!_isEditing && addedMedication != null) {
      final reminder = ReminderModel(
        id: const Uuid().v4(),
        userId: user?.id ?? '',
        medicationId: addedMedication.id,
        scheduledTime: scheduledTime,
        days: selectedDayStrings,
      );
      await ref.read(reminderProvider.notifier).addReminder(reminder);
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      McToast.showSuccess(
        context,
        _isEditing ? 'Medication updated' : 'Medication added successfully',
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      McToast.showError(context, 'Failed to add medication');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isEditing) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is MedicationModel) {
        _editingMedication = args;
        _isEditing = true;
        _nameController.text = _editingMedication!.name;
        _supplyController.text = _editingMedication!.totalSupply.toString();
        _selectedForm = _editingMedication!.form;
        _pillPhotoPath = _editingMedication!.pillPhotoUrl;
        // dosage stored as string time in model; attempt to parse
        try {
          final parts = _editingMedication!.dosage.split(':');
          final hour = int.tryParse(parts[0]) ?? 8;
          final minutePart = parts.length > 1 ? parts[1] : '00';
          final minute = int.tryParse(minutePart.split(' ').first) ?? 0;
          _selectedTime = TimeOfDay(hour: hour, minute: minute);
        } catch (_) {}
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B3D66),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.close, color: Colors.white, size: 28),
        ),
        title: const Text(
          'Add Medication',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 100,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photo Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _showPhotoOptions,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F6FC),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF0E6B94),
                              width: 2,
                            ),
                          ),
                          child: _pillPhotoPath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: _pillPhotoPath!.startsWith('http')
                                      ? Image.network(
                                          _pillPhotoPath!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.add_a_photo_rounded,
                                                    size: 50,
                                                    color: Color(0xFF0E6B94),
                                                  ),
                                        )
                                      : Image.file(
                                          File(_pillPhotoPath!),
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.add_a_photo_rounded,
                                                    size: 50,
                                                    color: Color(0xFF0E6B94),
                                                  ),
                                        ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.add_a_photo_rounded,
                                      size: 50,
                                      color: Color(0xFF0E6B94),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'ADD PHOTO',
                                      style: TextStyle(
                                        color: Color(0xFF0E6B94),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Tap to add a photo from camera or gallery.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF6F7D8E),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildLabel('Identify your medicine'),
                const SizedBox(height: 12),
                _buildTextField(
                  label: 'Medication Name',
                  hint: 'e.g. Paracetamol',
                  controller: _nameController,
                  validator: (val) => val == null || val.isEmpty
                      ? 'Medication name required'
                      : null,
                ),
                const SizedBox(height: 20),
                _buildLabel('Supply Days'),
                const SizedBox(height: 8),
                _buildTextField(
                  label: '',
                  hint: '30',
                  controller: _supplyController,
                  keyboardType: TextInputType.number,
                  validator: (val) => val == null || int.tryParse(val) == null
                      ? 'Enter days'
                      : null,
                ),
                const SizedBox(height: 20),
                _buildLabel('Reminder Time'),
                const SizedBox(height: 8),
                _buildTimePickerField(),
                const SizedBox(height: 20),
                _buildLabel('Repeat on Days'),
                const SizedBox(height: 12),
                _buildDaySelector(),
                if (_selectedDays.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Select at least one day',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFD92D20),
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(
                            color: Color(0xFF0E6B94),
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Add another',
                          style: TextStyle(
                            color: Color(0xFF0E6B94),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0E6B94),
                          disabledBackgroundColor: Colors.grey[300],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Save',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded, size: 18),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
    text,
    style: const TextStyle(
      color: Color(0xFF0D1E30),
      fontSize: 15,
      fontWeight: FontWeight.w700,
    ),
  );

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFBFD6E8), fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E8F0), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E8F0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0E6B94), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      style: const TextStyle(
        color: Color(0xFF0D1E30),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTimePickerField() {
    return GestureDetector(
      onTap: () => _selectTime(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E8F0), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedTime.format(context),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0D1E30),
              ),
            ),
            const Icon(
              Icons.access_time_rounded,
              color: Color(0xFF0E6B94),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
          .asMap()
          .entries
          .map((entry) {
            final day = entry.key;
            final dayName = entry.value;
            final isSelected = _selectedDays.contains(day);
            return GestureDetector(
              onTap: () => _toggleDay(day),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0E6B94) : Colors.white,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0E6B94)
                        : const Color(0xFFBFD6E8),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF0D1E30),
                    ),
                  ),
                ),
              ),
            );
          })
          .toList(),
    );
  }
}
