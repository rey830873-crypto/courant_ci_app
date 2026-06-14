import 'package:go_router/go_router.dart';
import '../../data/models/user_model.dart';
import '../../viewmodels/session_viewmodel.dart';
import '../../views/auth/auth_choice_screen.dart';
import '../../views/auth/register_screen.dart';
import '../../views/dashboard/dashboard_screen.dart';
import '../../views/tips/tips_view.dart';
import '../../views/dashboard/simulator_view.dart';
import '../../views/map/agencies_view.dart';
import '../../views/map/map_screen.dart';
import '../../views/meter/meter_screen.dart';
import '../../views/onboarding/onboarding_screen.dart';
import '../../views/profile/profile_screen.dart';
import '../../views/report/report_screen.dart';
import '../../views/shell/main_shell.dart';
import '../../views/splash/splash_screen.dart';
import 'app_routes.dart';

/// Construit le [GoRouter] de l'application.
///
/// La navigation est entièrement pilotée par [SessionViewModel] :
/// - tant que l'onboarding n'est pas terminé → /onboarding
/// - onboarding terminé mais aucun mode choisi → /auth
/// - sinon → shell principal (5 onglets, dont /dashboard)
///
/// `refreshListenable: session` permet de réévaluer la redirection dès
/// qu'un de ces états change (ex: fin de l'onboarding, passage en mode
/// invité ou inscrit).
class AppRouter {
  AppRouter._();

  static GoRouter create(SessionViewModel session) {
    return GoRouter(
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

        // Un compte déjà inscrit n'a plus besoin de revoir l'auth.
        // Un invité, lui, peut encore accéder à /auth/register pour
        // créer un compte plus tard (CTA dans le profil).
        if (mode == UserMode.registered && isAuthFlow) {
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
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              MainShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) => const DashboardScreen(),
                routes: [
                  GoRoute(
                    path: 'tips',
                    builder: (context, state) => const TipsView(),
                  ),
                  GoRoute(
                    path: 'simulator',
                    builder: (context, state) => const SimulatorView(),
                  ),
                ],
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: AppRoutes.map,
                builder: (context, state) => const MapScreen(),
                routes: [
                  GoRoute(
                    path: 'agencies',
                    builder: (context, state) => const AgenciesView(),
                  ),
                ],
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: AppRoutes.meter,
                builder: (context, state) => const MeterScreen(),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: AppRoutes.report,
                builder: (context, state) => const ReportScreen(),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ]),
          ],
        ),
      ],
    );
  }
}
