import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../viewmodels/auth_viewmodel.dart';

/// Inscription par numéro de téléphone + code OTP (CDC section 6.2,
/// étape 2). Le numéro est envoyé au format E.164 avec l'indicatif
/// ivoirien (+225).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _otpRequested = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  String get _formattedPhone {
    final digits = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    return '+225$digits';
  }

  Future<void> _sendCode() async {
    final authVM = context.read<AuthViewModel>();
    await authVM.sendOtp(_formattedPhone);
    if (!mounted) return;
    if (authVM.status == AuthFlowStatus.codeSent) {
      setState(() => _otpRequested = true);
    }
  }

  Future<void> _verifyCode() async {
    final authVM = context.read<AuthViewModel>();
    await authVM.verifyOtp(_otpController.text.trim());
  }

  void _editPhoneNumber() {
    context.read<AuthViewModel>().resetToPhoneStep();
    setState(() => _otpRequested = false);
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _otpRequested ? 'Entre le code reçu' : 'Ton numéro CI',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _otpRequested
                    ? 'Un code à 6 chiffres a été envoyé par SMS au '
                        '$_formattedPhone.'
                    : 'On t\'envoie un code par SMS pour vérifier ton '
                        'numéro.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),
              if (!_otpRequested) ...[
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Numéro de téléphone',
                    prefixText: '+225 ',
                    hintText: '07 00 00 00 00',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
              ] else ...[
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                  decoration: const InputDecoration(
                    counterText: '',
                    hintText: '------',
                  ),
                ),
              ],
              if (authVM.status == AuthFlowStatus.error &&
                  authVM.errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          size: 18, color: AppColors.danger),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authVM.errorMessage!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.danger),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 28),
              PrimaryButton(
                label: _otpRequested ? 'Vérifier' : 'Envoyer le code',
                isLoading: authVM.isBusy,
                onPressed: _otpRequested ? _verifyCode : _sendCode,
              ),
              if (_otpRequested) ...[
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Modifier le numéro',
                  variant: PrimaryButtonVariant.text,
                  onPressed: _editPhoneNumber,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
