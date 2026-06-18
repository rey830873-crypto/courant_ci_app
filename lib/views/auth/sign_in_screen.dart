import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../viewmodels/auth_viewmodel.dart';

/// Reconnexion par numéro de téléphone : pour une personne déjà
/// inscrite (sur cet appareil ou un autre, ex: après un changement de
/// téléphone) qui ne devrait pas avoir à refaire toute l'inscription
/// pour retrouver son compte.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String get _formattedPhone {
    final digits = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    return '+225$digits';
  }

  Future<void> _submit() async {
    if (_phoneController.text.trim().isEmpty) return;
    final authVM = context.read<AuthViewModel>();
    await authVM.signIn(_formattedPhone);
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Se connecter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Retrouve ton compte avec le numéro utilisé à '
                'l\'inscription.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),
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
              if (authVM.status == AuthFlowStatus.error &&
                  authVM.errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                      // Si le numéro n'a simplement pas de compte (pas une
                      // panne technique), on propose directement la suite
                      // logique plutôt que de laisser la personne bloquée.
                      if (authVM.accountNotFound) ...[
                        const SizedBox(height: 12),
                        PrimaryButton(
                          label: 'Créer un compte',
                          icon: Icons.person_add_alt,
                          onPressed: () {
                            authVM.resetError();
                            context.push(AppRoutes.register);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 28),
              PrimaryButton(
                label: 'Se connecter',
                isLoading: authVM.isBusy,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
