import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/zone_status_style.dart';
import '../../data/models/zone_model.dart';
import '../../viewmodels/map_viewmodel.dart';
import '../../viewmodels/session_viewmodel.dart';
import 'widgets/commune_detail_sheet.dart';

/// Carte interactive d'Abidjan (F3, fond OpenStreetMap — gratuit, sans
/// clé API). Un marqueur par commune, coloré selon le statut réseau
/// temps réel agrégé depuis les signalements Firestore (F1). Taper un
/// marqueur ouvre le détail de la commune (F4).
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MapViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Carte du réseau')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter:
                  const LatLng(AppConstants.mapCenterLat, AppConstants.mapCenterLng),
              initialZoom: AppConstants.mapDefaultZoom,
              minZoom: AppConstants.mapMinZoom,
              maxZoom: AppConstants.mapMaxZoom,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.cic.courant_ci_app',
              ),
              MarkerLayer(
                markers: [
                  for (final commune in AppConstants.abidjanCommunes)
                    Marker(
                      point: LatLng(commune.latitude, commune.longitude),
                      width: 90,
                      height: 52,
                      child: _CommuneMarker(
                        commune: commune,
                        status: vm.statusFor(commune.name),
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (!vm.isReady)
            Container(
              color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.6),
              child: const Center(child: CircularProgressIndicator()),
            ),
          const Positioned(left: 16, right: 16, bottom: 16, child: _Legend()),
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton.extended(
              heroTag: 'map_agencies_fab',
              onPressed: () => context.push(AppRoutes.agencies),
              label: const Text('Agences CIE'),
              icon: const Icon(Icons.business),
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        heroTag: 'map_recenter_fab',
        onPressed: _recenterOnUserZone,
        tooltip: 'Centrer sur ma zone',
        child: const Icon(Icons.my_location),
      ),
    );
  }

  void _recenterOnUserZone() {
    final communeName = context.read<SessionViewModel>().commune;
    Commune? target;
    for (final commune in AppConstants.abidjanCommunes) {
      if (commune.name == communeName) {
        target = commune;
        break;
      }
    }
    if (target == null) return;
    _mapController.move(LatLng(target.latitude, target.longitude), 13);
  }
}

/// Marqueur "pastille colorée + nom de commune" affiché sur la carte.
/// La couleur reflète le statut réseau (F1) ; une icône d'alerte
/// s'affiche en cas de signalement "danger" récent.
class _CommuneMarker extends StatelessWidget {
  final Commune commune;
  final ZoneStatusInfo? status;

  const _CommuneMarker({required this.commune, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = (status?.status ?? ZoneStatus.normal).color;

    return GestureDetector(
      onTap: status == null ? null : () => _openDetail(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: status?.hasRecentHazard == true
                ? const Icon(Icons.warning_amber_rounded,
                    color: AppColors.white, size: 14)
                : null,
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 2,
                ),
              ],
            ),
            child: Text(
              commune.name,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.softBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommuneDetailSheet(commune: commune, status: status!),
    );
  }
}

/// Légende des couleurs de statut, ancrée en bas de la carte.
class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          _LegendItem(color: AppColors.success, label: 'Normal'),
          _LegendItem(color: AppColors.primary, label: 'Signalé'),
          _LegendItem(color: AppColors.danger, label: 'Coupure'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
