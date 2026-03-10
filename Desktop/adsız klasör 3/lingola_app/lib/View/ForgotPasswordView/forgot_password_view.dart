import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:lingola_app/Services/auth_service.dart';
import 'package:lingola_app/src/navigation/app_routes.dart';
import 'package:lingola_app/src/theme/colors.dart';
import 'package:lingola_app/src/theme/radius.dart';
import 'package:lingola_app/src/theme/spacing.dart';
import 'package:lingola_app/src/theme/typography.dart';

/// E-posta ile şifre sıfırlama linki gönderir (Firebase).
/// E-posta/şifre girişi eklediğinizde onboarding veya login ekranından
/// "Şifremi unuttum" ile bu sayfaya yönlendirin.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (_isLoading || _emailSent) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final error = await AuthService.instance.sendPasswordResetEmail(
      _emailController.text.trim(),
    );
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (error == null) _emailSent = true;
    });

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.canPop() ? context.pop() : context.go(AppPaths.onboarding),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: _emailSent ? _buildSuccessContent() : _buildFormContent(),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Şifremi unuttum',
            style: AppTypography.onboardingTitle,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Kayıtlı e-posta adresinizi girin, size şifre sıfırlama bağlantısı gönderelim.',
            style: AppTypography.onboardingDescription.copyWith(color: AppColors.onboardingText),
          ),
          SizedBox(height: AppSpacing.xl),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: 'E-posta',
              hintText: 'ornek@email.com',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
              filled: true,
              fillColor: AppColors.surface,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'E-posta girin';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(v.trim())) {
                return 'Geçerli bir e-posta adresi girin';
              }
              return null;
            },
          ),
          SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: _isLoading ? null : _sendResetEmail,
            style: FilledButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Sıfırlama bağlantısı gönder'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.mark_email_read_outlined, size: 64, color: AppColors.primary),
        SizedBox(height: AppSpacing.xl),
        Text(
          'E-posta gönderildi',
          style: AppTypography.onboardingTitle,
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          '${_emailController.text.trim()} adresine şifre sıfırlama bağlantısı gönderdik. E-postayı kontrol edin (spam klasörüne de bakın).',
          style: AppTypography.onboardingDescription.copyWith(color: AppColors.onboardingText),
        ),
        SizedBox(height: AppSpacing.xl),
        FilledButton(
          onPressed: () => context.canPop() ? context.pop() : context.go(AppPaths.onboarding),
          style: FilledButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          ),
          child: const Text('Girişe dön'),
        ),
      ],
    );
  }
}
