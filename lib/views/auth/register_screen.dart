import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/session_viewmodel.dart';

/// Inscription par numéro de téléphone (CDC section 6.2, étape 2). Le
/// numéro est envoyé au format E.164 avec l'indicatif ivoirien (+225).
///
/// Pas d'étape de vérification par code SMS : tout est simulé en local
/// (aucun vrai SMS n'est envoyé), donc demander à la personne de
/// recopier un code n'apportait rien de plus qu'une étape à vide.
/// Une fois le numéro saisi, une étape facultative permet de
/// renseigner nom/prénom et email — aucun des deux n'est obligatoire
/// (CDC : "pas de compte obligatoire" reste vrai même en mode inscrit,
/// on ne bloque jamais sur ces champs).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

enum _RegisterStep { phone, profile }

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  _RegisterStep _step = _RegisterStep.phone;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String get _formattedPhone {
    final digits = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    return '+225$digits';
  }

  void _continueToProfileStep() {
    if (_phoneController.text.trim().isEmpty) return;
    setState(() => _step = _RegisterStep.profile);
  }

  Future<void> _finishRegistration() async {
    if (!mounted) return;
    final authVM = context.read<AuthViewModel>();
    await authVM.verifyOtp(
      _formattedPhone,
      displayName: _nameController.text.trim(),
      email: _emailController.text.trim(),
    );
    // Navigation de secours : si le router redirect (refreshListenable)
    // ne s'est pas déclenché pour une raison quelconque, on force la
    // navigation vers le tableau de bord.
    if (!mounted) return;
    final session = context.read<SessionViewModel>();
    if (session.isRegistered) {
      context.go(AppRoutes.dashboard);
    }
  }

  void _skipProfileStep() => _finishRegistration();

  void _editPhoneNumber() {
    context.read<AuthViewModel>().resetError();
    setState(() => _step = _RegisterStep.phone);
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
                switch (_step) {
                  _RegisterStep.phone => 'Ton numéro CI',
                  _RegisterStep.profile => 'Pour finir (facultatif)',
                },
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                switch (_step) {
                  _RegisterStep.phone =>
                    'Ton numéro identifie ton compte CIC.',
                  _RegisterStep.profile =>
                    'Ajoute ton nom et ton email pour personnaliser ton '
                        'profil. Tu peux passer cette étape, ton compte '
                        'sera créé quand même.',
                },
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),
              if (_step == _RegisterStep.phone) ...[
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
                  controller: _nameController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nom et prénom (facultatif)',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email (facultatif)',
                    prefixIcon: Icon(Icons.mail_outline),
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
                label: switch (_step) {
                  _RegisterStep.phone => 'Continuer',
                  _RegisterStep.profile => 'Terminer',
                },
                isLoading: authVM.isBusy,
                onPressed: switch (_step) {
                  _RegisterStep.phone => _continueToProfileStep,
                  _RegisterStep.profile => _finishRegistration,
                },
              ),
              if (_step == _RegisterStep.profile) ...[
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Passer cette étape',
                  variant: PrimaryButtonVariant.text,
                  isLoading: authVM.isBusy,
                  onPressed: _skipProfileStep,
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Modifier le numéro',
                  variant: PrimaryButtonVariant.text,
                  isLoading: authVM.isBusy,
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
