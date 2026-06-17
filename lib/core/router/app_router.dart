import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/user_model.dart';
import '../../viewmodels/session_viewmodel.dart';
import '../../views/about/about_screen.dart';
import '../../views/auth/auth_choice_screen.dart';
import '../../views/auth/register_screen.dart';
import '../../views/auth/sign_in_screen.dart';
import '../../views/dashboard/simulator_view.dart';
import '../../views/map/agencies_view.dart';
import '../../views/onboarding/onboarding_screen.dart';
import '../../views/shell/main_shell.dart';
import '../../views/splash/splash_screen.dart';
import '../../views/tips/tips_view.dart';
import 'app_routes.dart';

/// Clé stable du Navigator racine.
final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Construit le [GoRouter] de l'application.
///
/// La navigation est entièrement pilotée par [SessionViewModel] :
/// - tant que l'onboarding n'est pas terminé → /onboarding
/// - onboarding terminé mais aucun mode choisi → /auth
/// - sinon → shell principal (5 onglets, dont /dashboard)
///
/// Important : depuis la V2 de ce fichier, le shell à 5 onglets
/// (Accueil/Carte/Compteur/Signaler/Profil) n'est PLUS géré par
/// `StatefulShellRoute.indexedStack` mais par un simple [IndexedStack]
/// interne à [MainShell] (voir ce fichier). GoRouter ne voit donc plus
/// qu'UNE seule route pour tout le shell (`/dashboard`), peu importe
/// l'onglet affiché à l'intérieur. Ce choix élimine une classe de bugs
/// connus de `StatefulShellRoute` (reconstructions incohérentes du
/// Navigator lors d'un changement de thème ou de la fermeture d'un
/// `showDialog`, observées ici sous la forme `_dependents.isEmpty` et
/// `RenderObject.child == child`), au prix de ne plus avoir d'URL
/// distincte par onglet (sans impact sur Android/iOS).
///
/// Les écrans "secondaires" (Conseils, Simulateur, Agences), ouverts
/// par-dessus le shell via `context.push(...)`, restent des routes
/// GoRouter normales, déclarées ici au même niveau que `/dashboard`
/// plutôt qu'imbriquées dans le shell — leur usage côté écrans
/// (`context.push(AppRoutes.tips)`, etc.) est inchangé.
class AppRouter {
  AppRouter._();

  static GoRouter create(SessionViewModel session) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: AppRoutes.splash,
      refreshListenable: session,
      redirect: (context, state) {
        final location = state.matchedLocation;

        if (location == AppRoutes.splash) return null;

        if (!session.onboardingDone) {
          return location == AppRoutes.onboarding
              ? null
              : AppRoutes.onboarding;
        }

        final mode = session.userMode;
        final isAuthFlow = location.startsWith('/auth');

        if (mode == null) {
          return isAuthFlow ? null : AppRoutes.authChoice;
        }

        if (location == AppRoutes.onboarding) {
          return AppRoutes.dashboard;
        }

        // Un compte déjà inscrit n'a plus besoin de rester sur /auth :
        // direction le tableau de bord — y compris juste après avoir
        // terminé l'inscription depuis /auth/register (c'est le signal
        // qui doit déclencher la redirection vers l'accueil une fois
        // "Terminer"/"Passer cette étape" appelés avec succès).
        //
        // Seul un invité (mode == guest) qui vient d'arriver sur
        // /auth/register ou /auth/sign-in — pour créer un compte ou se
        // reconnecter, par exemple depuis le profil — doit pouvoir y
        // rester pendant qu'il remplit le formulaire, sans être éjecté
        // avant d'avoir terminé.
        final isOnAuthForm = location == AppRoutes.register ||
            location == AppRoutes.signIn;
        final isFillingRegisterForm = isOnAuthForm && mode == UserMode.guest;

        if (isAuthFlow && !isFillingRegisterForm) {
          return AppRoutes.dashboard;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: AppRoutes.authChoice,
          builder: (context, state) => const AuthChoiceScreen(),
        ),
        GoRoute(
          path: AppRoutes.register,
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: AppRoutes.signIn,
          builder: (context, state) => const SignInScreen(),
        ),
        // Le shell principal (5 onglets) : une seule route GoRouter,
        // l'onglet affiché est géré en interne par MainShell.
        GoRoute(
          path: AppRoutes.dashboard,
          builder: (context, state) => const MainShell(),
        ),
        // Toutes les routes ci-dessous restent reconnues quel que soit
        // l'onglet courant du shell : on est "au-dessus" du shell, pas
        // dedans, ce qui correspond exactement à leur usage actuel
        // (`context.push`, jamais `context.go` ni navigation d'onglet).
        GoRoute(
          path: AppRoutes.tips,
          builder: (context, state) => const TipsView(),
        ),
        GoRoute(
          path: AppRoutes.simulator,
          builder: (context, state) => const SimulatorView(),
        ),
        GoRoute(
          path: AppRoutes.agencies,
          builder: (context, state) => const AgenciesView(),
        ),
        GoRoute(
          path: AppRoutes.about,
          builder: (context, state) => const AboutScreen(),
        ),
      ],
    );
  }
}
