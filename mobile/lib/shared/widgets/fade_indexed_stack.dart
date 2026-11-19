import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_motion.dart';

/// Keeps every tab alive (like IndexedStack) and fades the selected tab in
/// when the user switches. Hidden tabs have their tickers turned off, so
/// their animations (carousels, shimmer) pause.
class FadeIndexedStack extends StatefulWidget {
  const FadeIndexedStack({
    super.key,
    required this.index,
    required this.children,
  });

  final int index;
  final List<Widget> children;

  @override
  State<FadeIndexedStack> createState() => _FadeIndexedStackState();
}

class _FadeIndexedStackState extends State<FadeIndexedStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.medium,
    value: 1,
  );

  @override
  void didUpdateWidget(FadeIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index && !AppMotion.reduced(context)) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: AppMotion.enter),
      child: IndexedStack(
        index: widget.index,
        children: [
          for (var i = 0; i < widget.children.length; i++)
            TickerMode(
              enabled: i == widget.index,
              child: widget.children.elementAt(i),
            ),
        ],
      ),
    );
  }
}
