import 'dart:typed_data';

import 'package:dio/dio.dart';

/// One photo chosen by the user, ready to upload (contract v0.2, "Photo
/// uploads"). Built from the picker's file in the presentation layer, so
/// `core` does not depend on the picker.
class UploadFile {
  const UploadFile({
    required this.name,
    required this.bytes,
    required this.path,
  });

  /// File name with its extension, e.g. `IMG_0042.jpg`.
  final String name;
  final Uint8List bytes;

  /// Where the picker left the file: shown as a preview before upload.
  final String path;

  String get extension {
    final dot = name.lastIndexOf('.');
    return dot < 0 ? '' : name.substring(dot + 1).toLowerCase();
  }
}

/// Upload rules shared by every form (contract v0.2).
abstract final class UploadRules {
  static const int maxPhotos = 6;
  static const int maxBytes = 5 * 1024 * 1024;
  static const Set<String> extensions = {'jpg', 'jpeg', 'png', 'webp'};
}

/// Why a photo cannot be uploaded; `null` when it can. The codes are the
/// contract's error codes, so the app shows the same message either way.
String? checkUpload(UploadFile file) {
  if (!UploadRules.extensions.contains(file.extension)) {
    return 'UNSUPPORTED_FILE_TYPE';
  }
  if (file.bytes.length > UploadRules.maxBytes) return 'FILE_TOO_LARGE';
  return null;
}

/// Builds a `multipart/form-data` body: text fields keep their `snake_case`
/// names, lists repeat the field (`languages=ar`, `languages=en`), and every
/// file goes under [filesField] (`images`, `photos`, `avatar`, ...).
///
/// The body is built from bytes, so `FormData.clone()` works and the request
/// can be sent again after a token refresh.
FormData buildFormData({
  Map<String, Object?> fields = const {},
  String filesField = 'images',
  List<UploadFile> files = const [],
}) {
  final form = FormData();
  for (final MapEntry(:key, :value) in fields.entries) {
    switch (value) {
      case null:
        break;
      case final Iterable<Object?> list:
        for (final item in list) {
          if (item != null) form.fields.add(MapEntry(key, '$item'));
        }
      default:
        form.fields.add(MapEntry(key, '$value'));
    }
  }
  for (final file in files) {
    form.files.add(
      MapEntry(
        filesField,
        MultipartFile.fromBytes(
          file.bytes,
          filename: file.name,
          contentType: DioMediaType('image', _subtype(file.extension)),
        ),
      ),
    );
  }
  return form;
}

String _subtype(String extension) => switch (extension) {
  'png' => 'png',
  'webp' => 'webp',
  _ => 'jpeg',
};
