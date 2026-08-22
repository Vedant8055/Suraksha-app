import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';

/// Circle crop editor shown after a gallery photo is picked.
class ProfilePhotoCropScreen extends StatefulWidget {
  const ProfilePhotoCropScreen({super.key, required this.sourcePath});

  final String sourcePath;

  static Future<String?> open(BuildContext context, String sourcePath) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => ProfilePhotoCropScreen(sourcePath: sourcePath),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<ProfilePhotoCropScreen> createState() => _ProfilePhotoCropScreenState();
}

class _ProfilePhotoCropScreenState extends State<ProfilePhotoCropScreen> {
  final _controller = CropController();
  Uint8List? _imageBytes;
  bool _ready = false;
  bool _cropping = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final bytes = await File(widget.sourcePath).readAsBytes();
      if (!mounted) return;
      setState(() => _imageBytes = bytes);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadError = AppLocalizations.of(context).t('profilePhotoCropFailed'));
    }
  }

  Future<void> _onCropped(CropResult result) async {
    switch (result) {
      case CropSuccess(:final croppedImage):
        try {
          final dir = await getApplicationDocumentsDirectory();
          final folder = Directory('${dir.path}/profile_photos');
          if (!await folder.exists()) {
            await folder.create(recursive: true);
          }
          final file = File(
            '${folder.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
          );
          await file.writeAsBytes(croppedImage, flush: true);
          if (!mounted) return;
          Navigator.of(context).pop(file.path);
        } catch (_) {
          if (!mounted) return;
          setState(() => _cropping = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).t('profilePhotoCropFailed'),
              ),
            ),
          );
        }
      case CropFailure():
        if (!mounted) return;
        setState(() => _cropping = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).t('profilePhotoCropFailed'),
            ),
          ),
        );
    }
  }

  void _confirmCrop() {
    if (!_ready || _cropping) return;
    setState(() => _cropping = true);
    _controller.cropCircle();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: isLight ? const Color(0xFF111827) : Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(l10n.t('profilePhotoCropTitle')),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _cropping ? null : () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _ready && !_cropping ? _confirmCrop : null,
            child: Text(
              l10n.t('done'),
              style: TextStyle(
                color: _ready && !_cropping
                    ? AppTheme.primaryColor
                    : Colors.white38,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      body: _loadError != null
          ? Center(
              child: Text(
                _loadError!,
                style: const TextStyle(color: Colors.white70),
              ),
            )
          : _imageBytes == null
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryColor),
                )
              : Stack(
                  children: [
                    Crop(
                      image: _imageBytes!,
                      controller: _controller,
                      withCircleUi: true,
                      aspectRatio: 1,
                      interactive: true,
                      baseColor: Colors.black,
                      maskColor: Colors.black.withValues(alpha: 0.62),
                      progressIndicator: const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      initialRectBuilder: InitialRectBuilder.withSizeAndRatio(
                        size: 0.82,
                        aspectRatio: 1,
                      ),
                      onStatusChanged: (status) {
                        final ready = status == CropStatus.ready;
                        if (ready == _ready || !mounted) return;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) setState(() => _ready = ready);
                        });
                      },
                      onCropped: _onCropped,
                    ),
                    if (_cropping)
                      const ColoredBox(
                        color: Color(0x66000000),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                  ],
                ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Text(
            l10n.t('profilePhotoCropHint'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ),
      ),
    );
  }
}
