import 'package:material_ui/material_ui.dart';

import '../extensions/context_x.dart';
import 'app_image.dart';

/// A person's round photo, or the first letter of their name on a soft blue
/// circle when there is no photo (as in the designs: "M", "ع").
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 36,
  });

  final String name;
  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final letter = name.trim().isEmpty ? '?' : name.trim().characters.first;
    return SizedBox.square(
      dimension: size,
      child: ClipOval(
        child: imageUrl != null
            ? AppImage(imageUrl!)
            : ColoredBox(
                color: context.palette.highlight.withValues(alpha: 0.35),
                child: Center(
                  child: Text(
                    letter.toUpperCase(),
                    style: context.text.titleMedium?.copyWith(
                      fontSize: size * 0.42,
                      color: context.colors.primary,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
