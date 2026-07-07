import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:suraksha_women_safety_app/core/analytics/toilet_analytics_service.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'nearby_clean_toilets_service.dart';

enum ToiletViewMode { list, map }

class NearbyCleanToiletsScreen extends ConsumerStatefulWidget {
  const NearbyCleanToiletsScreen({
    super.key,
    this.initialViewMode = ToiletViewMode.list,
    this.initialFilters = const NearbyCleanToiletFilters(),
    this.service,
    this.analytics,
    this.locationResolver,
    this.launchExternalUri,
  });

  final ToiletViewMode initialViewMode;
  final NearbyCleanToiletFilters initialFilters;
  final NearbyCleanToiletsService? service;
  final ToiletAnalyticsService? analytics;
  final Future<Position?> Function()? locationResolver;
  final Future<bool> Function(Uri uri)? launchExternalUri;

  @override
  ConsumerState<NearbyCleanToiletsScreen> createState() =>
      _NearbyCleanToiletsScreenState();
}

class _NearbyCleanToiletsScreenState
    extends ConsumerState<NearbyCleanToiletsScreen> {
  late final NearbyCleanToiletsService _service;
  late final ToiletAnalyticsService _analytics;
  final List<NearbyCleanToilet> _toilets = [];

  GoogleMapController? _mapController;
  Position? _position;
  late NearbyCleanToiletFilters _filters;
  late ToiletViewMode _viewMode;
  NearbyCleanToilet? _selectedToilet;

  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _fetchSucceeded = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? NearbyCleanToiletsService();
    _analytics = widget.analytics ?? const ToiletAnalyticsService();
    _filters = widget.initialFilters;
    _viewMode = widget.initialViewMode;
    unawaited(_loadNearbyToilets());
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadNearbyToilets({bool refresh = false}) async {
    if (refresh) {
      setState(() => _isRefreshing = true);
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _fetchSucceeded = false;
      });
    }

    _trackEvent(
      'toilets_nearby_requested',
      details: {
        'radius_meters': _filters.radiusMeters,
        'cleanliness_min': _filters.cleanOnly ? 85 : _filters.cleanlinessMin,
        'include_closed': _filters.includeClosed,
      },
    );

    try {
      final position = await _resolveCurrentLocation();
      if (position == null) {
        if (!mounted) return;
        final l10n = AppLocalizations.of(context);
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          _fetchSucceeded = false;
          _errorMessage = l10n.t('toiletsLocationUnavailable');
        });
        _trackEvent('toilet_location_unavailable');
        return;
      }

      final toilets = await _service.fetchNearbyToilets(
        latitude: position.latitude,
        longitude: position.longitude,
        filters: _filters,
      );

      if (!mounted) return;
      setState(() {
        _position = position;
        _toilets
          ..clear()
          ..addAll(toilets);
        _selectedToilet = _toilets.isEmpty ? null : _selectedToilet;
        _isLoading = false;
        _isRefreshing = false;
        _fetchSucceeded = true;
        _errorMessage = null;
      });

      if (_viewMode == ToiletViewMode.map && _toilets.isNotEmpty) {
        _fitToMarkers();
      }
      if (_toilets.isEmpty) {
        _trackEvent('toilet_empty_result');
      }
    } on NearbyCleanToiletException catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
        _fetchSucceeded = false;
        _errorMessage = error.message;
        _toilets.clear();
        _selectedToilet = null;
      });
      _trackEvent('toilet_api_error', details: {'message': error.message});
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
        _fetchSucceeded = false;
        _errorMessage = l10n.t('toiletsConnectionError');
        _toilets.clear();
        _selectedToilet = null;
      });
      _trackEvent('toilet_api_error', details: {'message': 'unexpected_error'});
    }
  }

  Future<Position?> _resolveCurrentLocation() async {
    if (widget.locationResolver != null) {
      return widget.locationResolver!();
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (_) {
      return Geolocator.getLastKnownPosition();
    }
  }

  void _trackEvent(String event, {Map<String, Object?> details = const {}}) {
    unawaited(_analytics.logEvent(event, parameters: details));
    if (kDebugMode && details.isNotEmpty) {
      debugPrint('analytics:$event $details');
    }
  }

  Future<void> _refreshWithFilters({NearbyCleanToiletFilters? filters}) async {
    if (filters != null) {
      setState(() => _filters = filters);
      _trackEvent(
        'toilet_filter_applied',
        details: {
          'radius_meters': filters.radiusMeters,
          'clean_only': filters.cleanOnly,
          'open_now_only': filters.openNowOnly,
          'female_facility_only': filters.femaleFacilityOnly,
          'accessible_only': filters.accessibleOnly,
          'water_available_only': filters.waterAvailableOnly,
        },
      );
    }
    await _loadNearbyToilets(refresh: true);
  }

  Set<Marker> _buildMarkers() {
    return NearbyCleanToiletsService.buildMarkers(
      _toilets,
      onTap: _showToiletDetails,
    );
  }

  Future<void> _showToiletDetails(NearbyCleanToilet toilet) async {
    setState(() => _selectedToilet = toilet);
    _trackEvent('toilet_marker_clicked', details: {'toilet_id': toilet.id});
    if (!mounted) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ToiletDetailsSheet(
        toilet: toilet,
        onNavigate: () => _navigateToToilet(toilet),
        onReportIssue: () => _reportToiletIssue(toilet),
        onViewOnMap: () {
          Navigator.of(context).pop();
          setState(() => _viewMode = ToiletViewMode.map);
          _focusOnToilet(toilet);
        },
      ),
    );
  }

  Future<void> _navigateToToilet(NearbyCleanToilet toilet) async {
    _trackEvent('toilet_navigation_clicked', details: {'toilet_id': toilet.id});
    final uri = NearbyCleanToiletsService.buildNavigationUri(toilet);
    await _launchExternalUri(uri);
  }

  Future<void> _reportToiletIssue(NearbyCleanToilet toilet) async {
    final uri = NearbyCleanToiletsService.buildIssueReportUri(toilet);
    final launched = await _launchExternalUri(uri);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).t('unableToOpenIssueReporting'),
          ),
        ),
      );
    }
  }

  Future<bool> _launchExternalUri(Uri uri) async {
    if (widget.launchExternalUri != null) {
      return widget.launchExternalUri!(uri);
    }
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _focusOnToilet(NearbyCleanToilet toilet) async {
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(toilet.latitude, toilet.longitude), 16),
    );
  }

  Future<void> _fitToMarkers() async {
    if (_position == null || _toilets.isEmpty || _mapController == null) return;

    final points = <LatLng>[
      LatLng(_position!.latitude, _position!.longitude),
      ..._toilets.map((toilet) => LatLng(toilet.latitude, toilet.longitude)),
    ];

    final latitudes = points.map((p) => p.latitude).toList();
    final longitudes = points.map((p) => p.longitude).toList();
    final bounds = LatLngBounds(
      southwest: LatLng(
        latitudes.reduce((a, b) => a < b ? a : b),
        longitudes.reduce((a, b) => a < b ? a : b),
      ),
      northeast: LatLng(
        latitudes.reduce((a, b) => a > b ? a : b),
        longitudes.reduce((a, b) => a > b ? a : b),
      ),
    );

    try {
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 48),
      );
    } catch (_) {
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_position!.latitude, _position!.longitude),
          14,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final visibleToilets = _toilets;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).t('nearbyCleanToilets')),
        actions: [
          IconButton(
            tooltip: AppLocalizations.of(context).t('toiletsRefresh'),
            onPressed: _isRefreshing
                ? null
                : () => _loadNearbyToilets(refresh: true),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLight
                ? const [
                    Color(0xFFF7FAFF),
                    Color(0xFFEAF6FF),
                    Color(0xFFF9FBFE),
                  ]
                : const [
                    Color(0xFF07111F),
                    Color(0xFF0D1422),
                    Color(0xFF101827),
                  ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: _summaryCard(context),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildViewToggle(context),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildFilterChips(context),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                      ? _errorState(context, _errorMessage!)
                      : _viewMode == ToiletViewMode.list
                      ? _listView(context, visibleToilets)
                      : _mapView(context, visibleToilets),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final tone = _toilets.isEmpty
        ? const Color(0xFF3B82F6)
        : _toilets.first.isRecommended
        ? const Color(0xFF15803D)
        : _toilets.first.isUsable
        ? const Color(0xFF2563EB)
        : const Color(0xFFD97706);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : const Color(0xFF101827),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: tone.withValues(alpha: 0.26)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.05 : 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.wc_rounded, color: tone),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.t('nearbyCleanToilets'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isRefreshing
                          ? l10n.t('toiletsRefreshing')
                          : _errorMessage != null
                          ? _errorMessage!
                          : _fetchSucceeded && _toilets.isEmpty
                          ? l10n.t('toiletsNoToiletsInArea')
                          : l10n
                                .t('toiletsFoundCount')
                                .replaceAll('{count}', '${_toilets.length}'),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _statChip(
                context,
                '${_toilets.length}',
                l10n.t('toiletsResults'),
              ),
              _statChip(
                context,
                '${_filters.radiusMeters ~/ 1000} km',
                l10n.t('toiletsRadiusLabel'),
              ),
              _statChip(
                context,
                _filters.cleanOnly
                    ? l10n.t('toiletsCleanOnly')
                    : l10n.t('toiletsCleanAndUsable'),
                l10n.t('toiletsQualityLabel'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(BuildContext context, String value, String label) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isLight ? const Color(0xFFF2F6FD) : const Color(0xFF0B1220),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildViewToggle(BuildContext context) {
    return ToggleButtons(
      isSelected: [
        _viewMode == ToiletViewMode.list,
        _viewMode == ToiletViewMode.map,
      ],
      onPressed: (index) {
        setState(() => _viewMode = ToiletViewMode.values[index]);
        if (_viewMode == ToiletViewMode.map) {
          _fitToMarkers();
        }
      },
      borderRadius: BorderRadius.circular(14),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Text(AppLocalizations.of(context).t('listView')),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Text(AppLocalizations.of(context).t('mapView')),
        ),
      ],
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _radiusChip(1000),
          const SizedBox(width: 8),
          _radiusChip(2000),
          const SizedBox(width: 8),
          _radiusChip(5000),
          const SizedBox(width: 10),
          _toggleChip(
            label: _filters.cleanOnly
                ? l10n.t('toiletsCleanOnly')
                : l10n.t('toiletsCleanAndUsable'),
            active: _filters.cleanOnly,
            onSelected: (selected) {
              _refreshWithFilters(
                filters: _filters.copyWith(cleanOnly: selected),
              );
            },
          ),
          const SizedBox(width: 8),
          _toggleChip(
            label: l10n.t('toiletsOpenNowOnly'),
            active: _filters.openNowOnly,
            onSelected: (selected) {
              _refreshWithFilters(
                filters: _filters.copyWith(
                  openNowOnly: selected,
                  includeClosed: !selected,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          _toggleChip(
            label: l10n.t('toiletsFemaleFacility'),
            active: _filters.femaleFacilityOnly,
            onSelected: (selected) {
              _refreshWithFilters(
                filters: _filters.copyWith(femaleFacilityOnly: selected),
              );
            },
          ),
          const SizedBox(width: 8),
          _toggleChip(
            label: l10n.t('toiletsAccessible'),
            active: _filters.accessibleOnly,
            onSelected: (selected) {
              _refreshWithFilters(
                filters: _filters.copyWith(accessibleOnly: selected),
              );
            },
          ),
          const SizedBox(width: 8),
          _toggleChip(
            label: l10n.t('toiletsWaterAvailable'),
            active: _filters.waterAvailableOnly,
            onSelected: (selected) {
              _refreshWithFilters(
                filters: _filters.copyWith(waterAvailableOnly: selected),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _radiusChip(int meters) {
    final active = _filters.radiusMeters == meters;
    return ChoiceChip(
      label: Text('${meters ~/ 1000} km'),
      selected: active,
      onSelected: (_) {
        _refreshWithFilters(filters: _filters.copyWith(radiusMeters: meters));
      },
    );
  }

  Widget _toggleChip({
    required String label,
    required bool active,
    required ValueChanged<bool> onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: active,
      onSelected: onSelected,
    );
  }

  Widget _listView(BuildContext context, List<NearbyCleanToilet> toilets) {
    if (toilets.isEmpty) {
      return _emptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () => _loadNearbyToilets(refresh: true),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
        itemBuilder: (context, index) {
          final toilet = toilets[index];
          return _ToiletCard(
            toilet: toilet,
            onTap: () => _showToiletDetails(toilet),
            onNavigate: () => _navigateToToilet(toilet),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemCount: toilets.length,
      ),
    );
  }

  Widget _mapView(BuildContext context, List<NearbyCleanToilet> toilets) {
    if (_position == null) {
      return _emptyState(context);
    }

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(_position!.latitude, _position!.longitude),
            zoom: 14,
          ),
          markers: {
            Marker(
              markerId: const MarkerId('me'),
              position: LatLng(_position!.latitude, _position!.longitude),
              infoWindow: InfoWindow(
                title: AppLocalizations.of(context).t('youAreHere'),
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure,
              ),
            ),
            ..._buildMarkers(),
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          onMapCreated: (controller) {
            _mapController = controller;
            if (_toilets.isNotEmpty) {
              unawaited(_fitToMarkers());
            }
          },
        ),
        if (toilets.isEmpty)
          Positioned(
            left: 16,
            right: 16,
            bottom: 18,
            child: _emptyStateCard(context),
          )
        else
          Positioned(
            left: 16,
            right: 16,
            bottom: 18,
            child: _mapBottomSummary(context, toilets),
          ),
      ],
    );
  }

  Widget _mapBottomSummary(
    BuildContext context,
    List<NearbyCleanToilet> toilets,
  ) {
    final highlighted = _selectedToilet ?? toilets.first;
    return GestureDetector(
      onTap: () => _showToiletDetails(highlighted),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: _badgeColor(highlighted).withValues(alpha: 0.12),
              child: Icon(Icons.wc_rounded, color: _badgeColor(highlighted)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    highlighted.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${highlighted.distanceLabel} - ${highlighted.safetyDisplayStatus}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _showToiletDetails(highlighted),
              icon: const Icon(Icons.keyboard_arrow_up_rounded),
            ),
          ],
        ),
      ),
    );
  }

  Color _badgeColor(NearbyCleanToilet toilet) {
    if (toilet.isRecommended) return const Color(0xFF15803D);
    if (toilet.isUsable) return const Color(0xFF2563EB);
    if (toilet.needsCaution) return const Color(0xFFD97706);
    if (toilet.availabilityStatus == 'Not recommended' ||
        toilet.availabilityStatus.toLowerCase() == 'closed' ||
        toilet.availabilityStatus.toLowerCase() == 'under maintenance') {
      return const Color(0xFFB91C1C);
    }
    return const Color(0xFF7C3AED);
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: _emptyStateCard(context),
      ),
    );
  }

  Widget _emptyStateCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off_rounded, size: 40),
          const SizedBox(height: 10),
          Text(
            l10n.t('toiletsNoToiletsInAreaHint'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              FilledButton(
                onPressed: () => _refreshWithFilters(
                  filters: _filters.copyWith(
                    radiusMeters: _filters.radiusMeters == 1000
                        ? 2000
                        : _filters.radiusMeters == 2000
                        ? 5000
                        : 5000,
                  ),
                ),
                child: Text(AppLocalizations.of(context).t('toiletsIncreaseRadius')),
              ),
              OutlinedButton(
                onPressed: () => _loadNearbyToilets(refresh: true),
                child: Text(AppLocalizations.of(context).t('toiletsRefresh')),
              ),
              OutlinedButton(
                onPressed: () => setState(() => _viewMode = ToiletViewMode.map),
                child: Text(AppLocalizations.of(context).t('toiletsOpenMap')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _errorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline_rounded, size: 40),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: () => _loadNearbyToilets(refresh: true),
                child: Text(AppLocalizations.of(context).t('toiletsTryAgain')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToiletCard extends StatelessWidget {
  const _ToiletCard({
    required this.toilet,
    required this.onTap,
    required this.onNavigate,
  });

  final NearbyCleanToilet toilet;
  final VoidCallback onTap;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final badgeColor = _badgeColor(toilet);
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: badgeColor.withValues(alpha: 0.22)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: badgeColor.withValues(alpha: 0.12),
                    child: Icon(Icons.wc_rounded, color: badgeColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          toilet.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          toilet.distanceLabel,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  _statusTag(toilet.safetyDisplayStatus, badgeColor),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                toilet.address.isNotEmpty
                    ? toilet.address
                    : 'Address not available',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _facilityChip(
                    Icons.female_rounded,
                    toilet.facilities.female,
                    'Female',
                  ),
                  _facilityChip(
                    Icons.accessible_rounded,
                    toilet.facilities.accessible,
                    'Accessible',
                  ),
                  _facilityChip(
                    Icons.water_drop_rounded,
                    toilet.facilities.waterAvailable,
                    'Water',
                  ),
                  _facilityChip(
                    Icons.male_rounded,
                    toilet.facilities.male,
                    'Male',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${l10n.t('toiletsCleanlinessLabel')}: ${toilet.cleanlinessStatus} • ${l10n.t('toiletsAvailabilityLabel')}: ${toilet.availabilityStatus}',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 6),
              Text(
                toilet.lastUpdatedAt != null
                    ? '${l10n.t('toiletsLastUpdated')} ${_formatTimestamp(toilet.lastUpdatedAt!)}'
                    : l10n.t('toiletsLastUpdatedNotAvailable'),
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onTap,
                      child: Text(l10n.t('toiletsViewOnMap')),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: onNavigate,
                      child: Text(l10n.t('toiletsNavigate')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _badgeColor(NearbyCleanToilet toilet) {
    if (toilet.isRecommended) return const Color(0xFF15803D);
    if (toilet.isUsable) return const Color(0xFF2563EB);
    if (toilet.needsCaution) return const Color(0xFFD97706);
    if (toilet.availabilityStatus == 'Not recommended' ||
        toilet.availabilityStatus.toLowerCase() == 'closed' ||
        toilet.availabilityStatus.toLowerCase() == 'under maintenance') {
      return const Color(0xFFB91C1C);
    }
    return const Color(0xFF7C3AED);
  }

  static Widget _statusTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }

  static Widget _facilityChip(IconData icon, bool enabled, String label) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      backgroundColor: enabled ? null : Colors.grey.shade300,
      side: BorderSide(
        color: enabled ? Colors.transparent : Colors.grey.shade400,
      ),
    );
  }
}

class ToiletDetailsSheet extends StatelessWidget {
  const ToiletDetailsSheet({super.key, 
    required this.toilet,
    required this.onNavigate,
    required this.onReportIssue,
    required this.onViewOnMap,
  });

  final NearbyCleanToilet toilet;
  final VoidCallback onNavigate;
  final VoidCallback onReportIssue;
  final VoidCallback onViewOnMap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final badgeColor = _ToiletCard._badgeColor(toilet);
    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.36,
      maxChildSize: 0.9,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: badgeColor.withValues(alpha: 0.12),
                    child: Icon(Icons.wc_rounded, color: badgeColor),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          toilet.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(toilet.distanceLabel),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _detailRow(
                l10n.t('toiletsCleanlinessScore'),
                toilet.cleanlinessScore?.toString() ??
                    l10n.t('toiletsStatusNotVerified'),
              ),
              _detailRow(
                l10n.t('toiletsCleanlinessStatus'),
                toilet.cleanlinessStatus,
              ),
              _detailRow(
                l10n.t('toiletsAvailability'),
                toilet.availabilityStatus,
              ),
              _detailRow(
                l10n.t('toiletsAddress'),
                toilet.address.isNotEmpty
                    ? toilet.address
                    : l10n.t('toiletsAddressNotAvailable'),
              ),
              _detailRow(
                l10n.t('toiletsFacilities'),
                [
                      if (toilet.facilities.female)
                        l10n.t('toiletsFacilityFemale'),
                      if (toilet.facilities.male) l10n.t('toiletsFacilityMale'),
                      if (toilet.facilities.accessible)
                        l10n.t('toiletsFacilityAccessible'),
                      if (toilet.facilities.waterAvailable)
                        l10n.t('toiletsFacilityWater'),
                    ].join(' • ').trim().isEmpty
                    ? l10n.t('toiletsStatusNotVerified')
                    : [
                        if (toilet.facilities.female)
                          l10n.t('toiletsFacilityFemale'),
                        if (toilet.facilities.male)
                          l10n.t('toiletsFacilityMale'),
                        if (toilet.facilities.accessible)
                          l10n.t('toiletsFacilityAccessible'),
                        if (toilet.facilities.waterAvailable)
                          l10n.t('toiletsFacilityWater'),
                      ].join(' • '),
              ),
              _detailRow(
                l10n.t('toiletsLastUpdated'),
                toilet.lastUpdatedAt != null
                    ? _formatTimestamp(toilet.lastUpdatedAt!)
                    : l10n.t('toiletsNotAvailable'),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: onNavigate,
                child: Text(l10n.t('toiletsNavigate')),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: onReportIssue,
                child: Text(l10n.t('toiletsReportIssue')),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: onViewOnMap,
                child: Text(l10n.t('toiletsViewOnMap')),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

String _formatTimestamp(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour >= 12 ? 'PM' : 'AM';
  return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year} $hour:$minute $period';
}
