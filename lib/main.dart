import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'viewmodels/user_viewmodel.dart';
import 'views/p01_splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<UserViewModel>(context);
    return MaterialApp(
      title: 'Courant CI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: viewModel.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const P01SplashScreen(),
    );
  }
}
