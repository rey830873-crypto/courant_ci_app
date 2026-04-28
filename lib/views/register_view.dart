import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../viewmodels/user_viewmodel.dart';
import 'main_screen.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  bool _acceptTerms = false;
  String? _selectedCommune;

  final List<String> _communes = [
    "Abobo", "Adjamé", "Anyama", "Attécoubé", "Bingerville", 
    "Cocody", "Koumassi", "Marcory", "Plateau", "Port-Bouët", 
    "Songon", "Treichville", "Yopougon"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.cieOrange),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(Icons.bolt_rounded, size: 50, color: AppTheme.cieOrange),
              const SizedBox(height: 10),
              const Text(
                "Créer mon compte",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Rejoignez la communauté CIC",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(child: _buildTextField("Prénom")),
                  const SizedBox(width: 15),
                  Expanded(child: _buildTextField("Nom")),
                ],
              ),
              const SizedBox(height: 15),
              _buildTextField("+225", keyboardType: TextInputType.phone),
              const SizedBox(height: 15),
              _buildDropdown(),
              const SizedBox(height: 15),
              _buildTextField("Quartier"),
              const SizedBox(height: 15),
              _buildTextField("Numéro de compteur CIE (optionnel)"),
              const SizedBox(height: 15),
              _buildTextField("Code PIN (4 chiffres)", obscure: true, keyboardType: TextInputType.number),
              const SizedBox(height: 15),
              _buildTextField("Confirmer le code PIN", obscure: true, keyboardType: TextInputType.number),
              const SizedBox(height: 15),
              Row(
                children: [
                  Checkbox(
                    value: _acceptTerms,
                    activeColor: AppTheme.cieOrange,
                    onChanged: (val) => setState(() => _acceptTerms = val ?? false),
                  ),
                  const Expanded(
                    child: Text(
                      "J'accepte les conditions d'utilisation",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _acceptTerms ? () {
                  // Simulation d'inscription et connexion directe
                  Provider.of<UserViewModel>(context, listen: false).login("Utilisateur");
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                    (route) => false,
                  );
                } : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  backgroundColor: AppTheme.cieOrange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "CRÉER MON COMPTE",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, {bool obscure = false, TextInputType? keyboardType}) {
    return TextFormField(
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.light ? Colors.grey[100] : Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light ? Colors.grey[100] : Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCommune,
          hint: const Text("Sélectionnez votre commune", style: TextStyle(color: Colors.grey)),
          isExpanded: true,
          items: _communes.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedCommune = newValue;
            });
          },
        ),
      ),
    );
  }
}
