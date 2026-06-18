import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../viewmodels/agencies_viewmodel.dart';
import '../../viewmodels/session_viewmodel.dart';
import '../../data/models/agency_model.dart';

class AgenciesView extends StatelessWidget {
  const AgenciesView({super.key});

  @override
  Widget build(BuildContext context) {
    final commune = context.read<SessionViewModel>().commune;
    return ChangeNotifierProvider(
      create: (_) => AgenciesViewModel(userCommune: commune),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Agences CIE'),
        ),
        body: Column(
          children: [
            const _SearchBar(),
            // Label contextuel : commune de l'utilisateur ou "toutes"
            Consumer<AgenciesViewModel>(
              builder: (context, vm, _) {
                final label = vm.isSearching
                    ? 'Résultats de recherche'
                    : (commune != null && commune.isNotEmpty)
                        ? 'Agences à $commune'
                        : 'Toutes les agences';
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(label,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textSecondary)),
                  ),
                );
              },
            ),
            Expanded(
              child: Consumer<AgenciesViewModel>(
                builder: (context, vm, child) {
                  if (vm.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (vm.agencies.isEmpty) {
                    return Center(
                      child: Text(
                        vm.isSearching
                            ? 'Aucune agence trouvée pour cette recherche.'
                            : 'Aucune agence disponible pour ta commune.\n'
                                'Utilise la barre de recherche pour en trouver une.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: vm.agencies.length,
                    itemBuilder: (context, index) {
                      return _AgencyTile(agency: vm.agencies[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AgenciesViewModel>();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: vm.search,
        decoration: InputDecoration(
          hintText: 'Rechercher une agence...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}

class _AgencyTile extends StatelessWidget {
  final AgencyModel agency;

  const _AgencyTile({required this.agency});

  Future<void> _makeCall(BuildContext context) async {
    final url = Uri.parse('tel:${agency.phone}');
    try {
      await launchUrl(url);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir le téléphone.')),
        );
      }
    }
  }

  Future<void> _openDirections(BuildContext context) async {
    final url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${agency.latitude},${agency.longitude}');
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir Google Maps.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      agency.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      agency.commune,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.business, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  agency.address,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _makeCall(context),
                  icon: const Icon(Icons.phone_outlined, size: 18),
                  label: const Text('Appeler'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openDirections(context),
                  icon: const Icon(Icons.directions_outlined, size: 18),
                  label: const Text('Itinéraire'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
