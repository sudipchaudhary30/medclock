import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sync_code_provider.dart';
import '../../widgets/layout/mc_scaffold.dart';
import '../../widgets/common/mc_toast.dart';

class AddMemberScreen extends ConsumerStatefulWidget {
  const AddMemberScreen({super.key});

  @override
  ConsumerState<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends ConsumerState<AddMemberScreen> {
  @override
  void initState() {
    super.initState();
    // Proactively generate code on load if not already generated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider);
      ref.read(syncCodeProvider.notifier).generateCode(
            user?.id ?? 'MC-8829-NP',
            user?.name ?? 'Animesh Sharma',
          );
    });
  }

  String _formatCode(String code) {
    if (code.length == 6) {
      return '${code.substring(0, 3)} ${code.substring(3, 6)}';
    }
    return code;
  }

  @override
  Widget build(BuildContext context) {
    final syncCodeInfo = ref.watch(syncCodeProvider);

    return McScaffold(
      title: 'Add Family Member',
      showBackButton: true,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            // Sync Icon Badge
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFE6F2F7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sync_rounded,
                  color: Color(0xFF0F6D95),
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Link Your Caregiver',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F1E24),
                fontFamily: 'serif',
              ),
            ),
            const SizedBox(height: 12),

            const Text(
              'Share this 6-digit sync code with your caregiver. Once they enter this code on their dashboard, your accounts will link securely.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF536A73),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Large Code Display Card
            if (syncCodeInfo != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF0F6D95), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F6D95).withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      _formatCode(syncCodeInfo.code),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F6D95),
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: Color(0xFFD35400),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Code valid for 24 hours',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFD35400),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              const Center(child: CircularProgressIndicator()),
            ],

            const Spacer(),
            const SizedBox(height: 24),

            // Action Buttons
            if (syncCodeInfo != null) ...[
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: syncCodeInfo.code));
                  McToast.showSuccess(context, 'Sync code copied to clipboard');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F6D95),
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text(
                  'Copy Code',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  ref.read(syncCodeProvider.notifier).generateCode(
                        ref.read(authProvider)?.id ?? 'MC-8829-NP',
                        ref.read(authProvider)?.name ?? 'Animesh Sharma',
                      );
                  McToast.showSuccess(context, 'New sync code generated');
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFCBDCDD)),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Generate New Code',
                  style: TextStyle(color: Color(0xFF0F6D95), fontWeight: FontWeight.bold),
                ),
              ),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
