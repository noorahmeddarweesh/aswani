import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_motion.dart';

/// Page transition used by every screen: the new page fades in while moving
/// slightly from the end side (right in English, left in Arabic).
CustomTransitionPage<void> appPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppMotion.medium,
    reverseTransitionDuration: AppMotion.medium,
    transitionsBuilder: (context, animation, secondary, child) {
      if (AppMotion.reduced(context)) return child;
      final curved = CurvedAnimation(parent: animation, curve: AppMotion.enter);
      final rtl = Directionality.of(context) == TextDirection.rtl;
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween(
            begin: Offset(rtl ? -0.06 : 0.06, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
