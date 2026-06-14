import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/layout/mc_scaffold.dart';

class AccessibilitySettingsScreen extends ConsumerStatefulWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  ConsumerState<AccessibilitySettingsScreen> createState() => _AccessibilitySettingsScreenState();
}

class _AccessibilitySettingsScreenState extends ConsumerState<AccessibilitySettingsScreen> {
  double _fontSize = 16.0;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider);
    if (user != null) {
      _fontSize = user.settings.fontSize;
    }
  }

  void _saveFontSize(double val) {
    setState(() => _fontSize = val);
    final user = ref.read(authProvider);
    if (user != null) {
      final updatedSettings = user.settings.copyWith(fontSize: val);
      ref.read(authProvider.notifier).updateSettings(updatedSettings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return McScaffold(
      title: 'Accessibility',
      showBackButton: true,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Font Size Scaling', style: AppTheme.heading2),
            const SizedBox(height: 8),
            Text(
              'Enlarge text size across the application screens to improve readability.',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                const Icon(Icons.text_fields_rounded, size: 20),
                Expanded(
                  child: Slider.adaptive(
                    min: 14.0,
                    max: 24.0,
                    divisions: 5,
                    value: _fontSize,
                    label: '${_fontSize.toInt()}pt',
                    onChanged: _saveFontSize,
                  ),
                ),
                const Icon(Icons.text_fields_rounded, size: 32),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.dividerColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Sample Text Display at ${_fontSize.toInt()}pt scale.',
                style: TextStyle(fontSize: _fontSize, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
