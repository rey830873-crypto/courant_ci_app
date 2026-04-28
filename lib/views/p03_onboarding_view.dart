import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import 'p02_landing_page.dart';

class P03OnboardingView extends StatefulWidget {
  const P03OnboardingView({super.key});

  @override
  State<P03OnboardingView> createState() => _P03OnboardingViewState();
}

class _P03OnboardingViewState extends State<P03OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "title": "Suivez votre consommation",
      "text": "Visualisez en temps réel votre consommation d'énergie et évitez les surprises.",
      "icon": "bar_chart"
    },
    {
      "title": "Payez en un clic",
      "text": "Réglez vos factures via Mobile Money en toute sécurité sans vous déplacer.",
      "icon": "payment"
    },
    {
      "title": "Signalez les pannes",
      "text": "Une coupure ? Un poteau tombé ? Signalez-le directement depuis l'application.",
      "icon": "report_problem"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) => setState(() => _currentPage = value),
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getIcon(index),
                        size: 120,
                        color: AppTheme.cieOrange,
                      ),
                      const SizedBox(height: 40),
                      Text(
                        _onboardingData[index]['title']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _onboardingData[index]['text']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => _buildDot(index),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage == _onboardingData.length - 1) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const P02LandingPage()),
                          );
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 55),
                        backgroundColor: AppTheme.cieOrange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: Text(
                        _currentPage == _onboardingData.length - 1 ? "COMMENCER" : "SUIVANT",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(int index) {
    switch (index) {
      case 0: return Icons.bar_chart_rounded;
      case 1: return Icons.account_balance_wallet_rounded;
      case 2: return Icons.warning_amber_rounded;
      default: return Icons.bolt_rounded;
    }
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? AppTheme.cieOrange : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
