import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_viewmodel.dart';
import '../core/app_theme.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<UserViewModel>(context, listen: false);
    _nameController = TextEditingController(text: viewModel.userName);
    _emailController = TextEditingController(text: "client@cie.ci");
    _phoneController = TextEditingController(text: "+225 0102030405");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<UserViewModel>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Modifier le profil")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: isDark ? AppTheme.surfaceDark : Colors.grey[200],
                  backgroundImage: viewModel.profileImageUrl != null 
                      ? NetworkImage(viewModel.profileImageUrl!) 
                      : null,
                  child: viewModel.profileImageUrl == null
                      ? const Icon(Icons.person, size: 60, color: AppTheme.cieOrange)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      // Simuler le choix d'une photo
                      viewModel.setProfileImage("https://ui-avatars.com/api/?name=${viewModel.userName}&background=FF6B00&color=fff");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Photo de profil mise à jour (Simulation)")),
                      );
                    },
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.cieOrange,
                      child: Icon(Icons.camera_alt, size: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            _buildTextField("Nom Complet", _nameController, isDark),
            const SizedBox(height: 20),
            _buildTextField("Email", _emailController, isDark),
            const SizedBox(height: 20),
            _buildTextField("Numéro de téléphone", _phoneController, isDark),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                viewModel.updateProfile(
                  name: _nameController.text,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profil mis à jour avec succès")),
                );
                Navigator.pop(context);
              },
              child: const Text("ENREGISTRER LES MODIFICATIONS"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? AppTheme.surfaceDark : Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ),
          ),
        ),
      ],
    );
  }
}
