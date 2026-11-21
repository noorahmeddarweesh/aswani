import 'dart:typed_data';

import 'package:aswani/core/network/upload.dart';

/// A picked photo for tests: [name] sets the type; a name containing
/// "too_large" makes it just over the 5 MB limit.
UploadFile testPhoto(String name) => UploadFile(
  name: name,
  path: '/picked/$name',
  bytes: Uint8List(
    name.contains('too_large') ? UploadRules.maxBytes + 1 : 1024,
  ),
);
