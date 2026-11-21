import 'dart:io' show File;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../extensions/context_x.dart';

/// Shows an image from `assets/images/`. When the file is not there yet,
/// draws a branded placeholder instead, so screens can be built and reviewed
/// before the final photos arrive.
class AppImage extends StatelessWidget {
  const AppImage(
    this.path, {
    super.key,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.semanticLabel,
  });

  final String path;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String? semanticLabel;

  /// Images bundled with the app, read once at startup by [preload].
  /// Null (tests) means "unknown": try to load and fall back on error.
  static Set<String>? _bundled;

  /// Reads the asset list so missing photos show the placeholder directly,
  /// instead of failing to load (which floods the web console with 404s).
  static Future<void> preload() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      _bundled = manifest.listAssets().toSet();
    } on Object {
      _bundled = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // A photo just picked on this phone (before upload): a file path on
    // mobile, a `blob:` URL on the web.
    final picked =
        path.startsWith('blob:') ||
        path.startsWith('/') ||
        path.startsWith('file:') ||
        RegExp(r'^[A-Za-z]:[\\/]').hasMatch(path);
    final network = path.startsWith('http') || (kIsWeb && picked);
    if (!network && !picked && _bundled != null && !_bundled!.contains(path)) {
      const placeholder = _ImagePlaceholder();
      if (borderRadius == null) return placeholder;
      return ClipRRect(borderRadius: borderRadius!, child: placeholder);
    }
    final image = picked && !kIsWeb
        ? Image.file(
            File(path.replaceFirst('file://', '')),
            fit: fit,
            width: double.infinity,
            height: double.infinity,
            semanticLabel: semanticLabel,
            excludeFromSemantics: semanticLabel == null,
            errorBuilder: (context, error, stackTrace) =>
                const _ImagePlaceholder(),
          )
        : network
        ? Image.network(
            path,
            fit: fit,
            width: double.infinity,
            height: double.infinity,
            semanticLabel: semanticLabel,
            excludeFromSemantics: semanticLabel == null,
            errorBuilder: (context, error, stackTrace) =>
                const _ImagePlaceholder(),
          )
        : Image.asset(
            path,
            fit: fit,
            width: double.infinity,
            height: double.infinity,
            semanticLabel: semanticLabel,
            excludeFromSemantics: semanticLabel == null,
            errorBuilder: (context, error, stackTrace) =>
                const _ImagePlaceholder(),
          );
    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            context.palette.highlight,
            context.colors.secondary,
            context.colors.primary,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          LucideIcons.image,
          size: 28,
          color: context.colors.onPrimary.withValues(alpha: 0.35),
        ),
      ),
    );
  }
}

/// Dark gradient over a photo so white text on it stays readable.
class PhotoScrim extends StatelessWidget {
  const PhotoScrim({super.key, this.strength = 0.75});

  final double strength;

  @override
  Widget build(BuildContext context) {
    final dark = context.palette.brandSurface;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.25, 1],
          colors: [
            dark.withValues(alpha: 0),
            dark.withValues(alpha: strength),
          ],
        ),
      ),
    );
  }
}
