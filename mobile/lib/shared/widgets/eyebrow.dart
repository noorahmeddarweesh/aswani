import 'package:material_ui/material_ui.dart';

import '../extensions/context_x.dart';

/// Small upper-case label above titles: "STEP 1 OF 8", "NEAR YOU".
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color, this.textAlign});

  final String text;
  final Color? color;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      // Arabic letters must stay joined: no letter spacing in RTL.
      style: context.text.labelSmall?.copyWith(
        color: color ?? context.palette.link,
        letterSpacing: context.isRtl ? 0 : null,
        fontSize: context.isRtl ? 12 : null,
      ),
    );
  }
}
