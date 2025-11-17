import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../shared/models/geofence_model.dart';
import '../../../core/theme/app_constants.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/services/location_service.dart';
import '../data/repositories/geofence_repository.dart';

class GeofenceSelectorScreen extends ConsumerStatefulWidget {
  final GeofenceModel? initialSelection;

  const GeofenceSelectorScreen({
    super.key,
    this.initialSelection,
  });

  @override
  ConsumerState<GeofenceSelectorScreen> createState() => _GeofenceSelectorScreenState();
}

class _GeofenceSelectorScreenState extends ConsumerState<GeofenceSelectorScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  GeofenceModel? _selectedGeofence;
  List<GeofenceModel> _geofences = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCity = 'Tous';
  String _selectedCategory = 'Tous';

  @override
  void initState() {
    super.initState();
    _selectedGeofence = widget.initialSelection;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Get current location
      _currentPosition = await ref.read(locationServiceProvider).getCurrentLocation();

      // Load geofences
      _geofences = await ref.read(geofenceRepositoryProvider).getPublicGeofences();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  List<GeofenceModel> get _filteredGeofences {
    return _geofences.where((g) {
      final matchesSearch = _searchQuery.isEmpty ||
          g.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (g.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

      final matchesCity = _selectedCity == 'Tous' || g.city == _selectedCity;

      final matchesCategory = _selectedCategory == 'Tous' || g.category == _selectedCategory;

      return matchesSearch && matchesCity && matchesCategory;
    }).toList();
  }

  Set<String> get _availableCities {
    final cities = _geofences.map((g) => g.city).whereType<String>().toSet();
    return {'Tous', ...cities};
  }

  Set<String> get _availableCategories {
    final categories = _geofences.map((g) => g.category).whereType<String>().toSet();
    return {'Tous', ...categories};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélectionner un lieu'),
        actions: [
          if (_selectedGeofence != null)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () => Navigator.pop(context, _selectedGeofence),
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Chargement des lieux...')
          : Column(
              children: [
                // Search and Filters
                _buildSearchAndFilters(),

                // Map
                Expanded(
                  flex: 3,
                  child: _buildMap(),
                ),

                // Geofences List
                Expanded(
                  flex: 2,
                  child: _buildGeofencesList(),
                ),
              ],
            ),
      floatingActionButton: _currentPosition != null
          ? FloatingActionButton.extended(
              onPressed: _goToCurrentLocation,
              icon: const Icon(Icons.my_location),
              label: const Text('Ma position'),
            )
          : null,
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey[100],
      child: Column(
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher un lieu...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 8),
          // Filters
          Row(
            children: [
              Expanded(
                child: _buildFilterChip(
                  label: _selectedCity,
                  icon: Icons.location_city,
                  onTap: () => _showCityFilter(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip(
                  label: _selectedCategory,
                  icon: Icons.category,
                  onTap: () => _showCategoryFilter(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildMap() {
    if (_currentPosition == null) {
      return const Center(child: Text('Impossible de charger la carte'));
    }

    final initialCamera = CameraPosition(
      target: _selectedGeofence != null
          ? LatLng(_selectedGeofence!.latitude, _selectedGeofence!.longitude)
          : LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      zoom: 13,
    );

    final markers = _filteredGeofences.map((geofence) {
      return Marker(
        markerId: MarkerId(geofence.id.toString()),
        position: LatLng(geofence.latitude, geofence.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          geofence.id == _selectedGeofence?.id
              ? BitmapDescriptor.hueGreen
              : BitmapDescriptor.hueRed,
        ),
        onTap: () => _selectGeofence(geofence),
        infoWindow: InfoWindow(
          title: geofence.name,
          snippet: geofence.description,
        ),
      );
    }).toSet();

    // Add circles for geofences
    final circles = _filteredGeofences.map((geofence) {
      return Circle(
        circleId: CircleId(geofence.id.toString()),
        center: LatLng(geofence.latitude, geofence.longitude),
        radius: geofence.radiusMeters,
        fillColor: (geofence.id == _selectedGeofence?.id
                ? Colors.green
                : Colors.blue)
            .withOpacity(0.2),
        strokeColor: geofence.id == _selectedGeofence?.id
            ? Colors.green
            : Colors.blue,
        strokeWidth: 2,
      );
    }).toSet();

    return GoogleMap(
      initialCameraPosition: initialCamera,
      markers: markers,
      circles: circles,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      onMapCreated: (controller) => _mapController = controller,
      onTap: (_) => setState(() => _selectedGeofence = null),
    );
  }

  Widget _buildGeofencesList() {
    final filtered = _filteredGeofences;

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aucun lieu trouvé',
              style: AppTextStyles.headingMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedCity = 'Tous';
                  _selectedCategory = 'Tous';
                });
              },
              child: const Text('Réinitialiser les filtres'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final geofence = filtered[index];
        final isSelected = geofence.id == _selectedGeofence?.id;
        final distance = _currentPosition != null
            ? Geolocator.distanceBetween(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
                geofence.latitude,
                geofence.longitude,
              )
            : null;

        return Card(
          elevation: isSelected ? 4 : 1,
          color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isSelected ? AppColors.primary : Colors.grey[300],
              child: Icon(
                _getCategoryIcon(geofence.category),
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
            title: Text(
              geofence.name,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (geofence.description != null)
                  Text(
                    geofence.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      geofence.city ?? 'Non spécifié',
                      style: AppTextStyles.bodySmall,
                    ),
                    if (distance != null) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.navigation, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        _formatDistance(distance),
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ],
                ),
              ],
            ),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: AppColors.primary)
                : const Icon(Icons.radio_button_unchecked),
            onTap: () => _selectGeofence(geofence),
          ),
        );
      },
    );
  }

  void _selectGeofence(GeofenceModel geofence) {
    setState(() => _selectedGeofence = geofence);

    // Move camera to selected geofence
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(geofence.latitude, geofence.longitude),
        15,
      ),
    );
  }

  void _goToCurrentLocation() {
    if (_currentPosition != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          15,
        ),
      );
    }
  }

  void _showCityFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Filtrer par ville', style: AppTextStyles.headingMedium),
            const SizedBox(height: 16),
            ..._availableCities.map((city) => ListTile(
                  title: Text(city),
                  trailing: city == _selectedCity
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() => _selectedCity = city);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showCategoryFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Filtrer par catégorie', style: AppTextStyles.headingMedium),
            const SizedBox(height: 16),
            ..._availableCategories.map((category) => ListTile(
                  leading: Icon(_getCategoryIcon(category)),
                  title: Text(category),
                  trailing: category == _selectedCategory
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() => _selectedCategory = category);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'gym':
      case 'fitness':
        return Icons.fitness_center;
      case 'park':
      case 'parc':
        return Icons.park;
      case 'library':
      case 'bibliothèque':
        return Icons.local_library;
      case 'office':
      case 'bureau':
        return Icons.business;
      case 'restaurant':
        return Icons.restaurant;
      case 'cafe':
      case 'café':
        return Icons.local_cafe;
      default:
        return Icons.place;
    }
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
