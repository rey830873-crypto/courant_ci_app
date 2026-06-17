/// Chemins de toutes les routes de l'application.
/// Centralisés ici pour que les écrans puissent naviguer sans dépendre
/// directement de la configuration de GoRouter (pas d'import circulaire).
class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String authChoice = '/auth';
  static const String register = '/auth/register';
  static const String signIn = '/auth/sign-in';

  // Shell principal (bottom navigation)
  static const String dashboard = '/dashboard';
  static const String tips = '/dashboard/tips';
  static const String simulator = '/dashboard/simulator';
  static const String map = '/map';
  static const String agencies = '/map/agencies';
  static const String meter = '/meter';
  static const String report = '/report';
  static const String profile = '/profile';
  static const String about = '/profile/about';
}
