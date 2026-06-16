import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'viewmodels/theme_viewmodel.dart';

/// Widget racine de CourantInfo CI.
/// Branche [AppTheme] (clair/sombre, piloté par [ThemeViewModel]) sur le
/// [GoRouter] construit dans `main.dart`.
class CICApp extends StatelessWidget {
  final GoRouter router;

  const CICApp({required this.router, super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeViewModel>().themeMode;

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      // Désactive le HeroController automatique de MaterialApp.router.
      //
      // Ce contrôleur scanne tout l'arbre de widgets à chaque frame pour
      // détecter des paires de Hero à animer entre deux routes — utile
      // pour des transitions de type "image qui s'agrandit". On n'utilise
      // aucun Hero volontairement dans cette app, mais certains widgets
      // Material (AppBar, etc.) en posent parfois un de façon implicite.
      // Avec le shell principal qui garde 5 écrans (5 AppBar) montés
      // simultanément via IndexedStack pour préserver leur état, ce
      // balayage automatique se corrompt et déclenche en cascade les
      // erreurs observées (`_dependents.isEmpty`, `RenderObject.child ==
      // child`, `Duplicate GlobalKeys`, `TextEditingController used after
      // disposed`) lors de la fermeture d'un dialogue ou d'un changement
      // de thème. Le HeroControllerScope.none ci-dessous retire
      // entièrement ce mécanisme, sans qu'on perde quoi que ce soit
      // puisqu'aucune transition Hero n'était utilisée.
      builder: (context, child) {
        return HeroControllerScope.none(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
