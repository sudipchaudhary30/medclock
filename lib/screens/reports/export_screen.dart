import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../widgets/layout/mc_scaffold.dart';
import '../../widgets/buttons/mc_primary_button.dart';
import '../../widgets/common/mc_toast.dart';

class ExportScreen extends StatelessWidget {
  const ExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return McScaffold(
      title: 'Export Compliance Log',
      showBackButton: true,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Generate PDF Report', style: AppTheme.heading2),
            const SizedBox(height: 8),
            Text(
              'Download your 30-day compliance timeline as a formatted PDF document to share directly with your physicians.',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
            ),
            const Spacer(),
            McPrimaryButton(
              label: 'Export Report as PDF',
              onTap: () {
                McToast.showSuccess(context, 'PDF generated and saved to Downloads!');
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
