import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../widgets/buttons/mc_primary_button.dart';
import '../../widgets/inputs/mc_text_field.dart';
import '../../widgets/common/mc_toast.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  void _submit() {
    if (_emailController.text.trim().isEmpty) {
      McToast.showError(context, 'Please enter your email');
      return;
    }
    McToast.showSuccess(context, 'Reset link sent to ${_emailController.text}');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Forgot your password?',
              style: AppTheme.heading2,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your email address and we will send you instructions to reset it.',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 32),
            McTextField(
              label: 'Email',
              hint: 'Enter your email address',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            McPrimaryButton(
              label: 'Send Reset Link',
              onTap: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
