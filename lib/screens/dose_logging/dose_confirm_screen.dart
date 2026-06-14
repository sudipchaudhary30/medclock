import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../config/app_theme.dart';
import '../../models/medication_model.dart';
import '../../models/reminder_model.dart';
import '../../models/dose_log_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dose_log_provider.dart';
import '../../widgets/layout/mc_scaffold.dart';
import '../../widgets/buttons/mc_primary_button.dart';
import '../../widgets/media/mc_pill_image.dart';
import '../../widgets/common/mc_toast.dart';
import '../../services/camera_service.dart';

class DoseConfirmScreen extends ConsumerStatefulWidget {
  const DoseConfirmScreen({super.key});

  @override
  ConsumerState<DoseConfirmScreen> createState() => _DoseConfirmScreenState();
}

class _DoseConfirmScreenState extends ConsumerState<DoseConfirmScreen> {
  String? _capturedPhotoPath;
  bool _isLoading = false;

  final CameraService _cameraService = CameraService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      if (args['autoCamera'] == true) {
        _capturePhoto();
      }
    });
  }

  void _capturePhoto() async {
    final path = await _cameraService.capturePhoto();
    if (path != null) {
      setState(() => _capturedPhotoPath = path);
    }
  }

  void _confirm() async {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final ReminderModel reminder = args['reminder'];
    final MedicationModel medication = args['medication'];
    final user = ref.read(authProvider);

    setState(() => _isLoading = true);

    final log = DoseLogModel(
      id: const Uuid().v4(),
      userId: user?.id ?? '',
      medicationId: medication.id,
      reminderId: reminder.id,
      status: DoseStatus.taken,
      confirmedAt: DateTime.now(),
      scheduledAt: DateTime.now(), // Simplified
      photoUrl: _capturedPhotoPath,
      confirmedBy: user?.id,
    );

    final success = await ref.read(doseLogProvider.notifier).logDose(log);
    setState(() => _isLoading = false);

    if (success && mounted) {
      McToast.showSuccess(context, 'Dose logged successfully!');
      Navigator.of(context).pop();
    } else if (mounted) {
      McToast.showError(context, 'Failed to log dose.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final MedicationModel medication = args['medication'];

    return McScaffold(
      title: 'Confirm Dose',
      showBackButton: true,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: McPillImage(
                imageUrl: medication.pillPhotoUrl,
                size: 100,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              medication.name,
              style: AppTheme.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${medication.dosage} · ${medication.form}',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            if (_capturedPhotoPath == null)
              OutlinedButton.icon(
                onPressed: _capturePhoto,
                icon: const Icon(Icons.camera_alt_rounded),
                label: const Text('Capture Pill Photo Proof'),
              )
            else
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded, color: AppTheme.successColor),
                  SizedBox(width: 8),
                  Text('Photo Attached'),
                ],
              ),
            const SizedBox(height: 24),
            McPrimaryButton(
              label: 'Confirm Taken',
              isLoading: _isLoading,
              onTap: _confirm,
            ),
          ],
        ),
      ),
    );
  }
}
