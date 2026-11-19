import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/responsive/window_size.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/aswani_logo.dart';
import '../../../../shared/widgets/circle_icon_button.dart';

/// Common layout of the auth screens: back button, brand or icon tile,
/// title, subtitle, then the form.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.icon,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  /// Icon tile shown instead of the brand (reset password screens).
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: MaxWidthBox(
          maxWidth: 520,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.xl,
            ),
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: CircleIconButton.back(
                      tooltip: context.l10n.back,
                      onPressed: () =>
                          context.canPop() ? context.pop() : context.go('/'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: AppSpacing.xl),
                        if (icon == null) ...[
                          const Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: AswaniLogo(),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            context.l10n.authTagline,
                            style: context.text.bodySmall,
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                        ] else ...[
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: context.palette.successTint,
                                borderRadius: AppRadii.lgAll,
                              ),
                              child: Icon(icon, color: context.palette.link),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                        Text(title, style: context.text.headlineLarge),
                        const SizedBox(height: AppSpacing.xs),
                        Text(subtitle, style: context.text.bodyMedium),
                        const SizedBox(height: AppSpacing.xl),
                        ...children,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A form-level error (not tied to one field), shown above the button.
class FormErrorText extends StatelessWidget {
  const FormErrorText(this.message, {super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Semantics(
        liveRegion: true,
        child: Text(
          message!,
          style: context.text.bodyMedium?.copyWith(color: context.colors.error),
        ),
      ),
    );
  }
}

/// "Question? Action" line under the main button.
class AuthSwitchLink extends StatelessWidget {
  const AuthSwitchLink({
    super.key,
    required this.question,
    required this.action,
    required this.onTap,
  });

  final String question;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(onPressed: onTap, child: Text('$question $action')),
    );
  }
}

/// Small hint shown only with mock data, so testers know what to type.
class MockHint extends StatelessWidget {
  const MockHint(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: context.text.bodySmall?.copyWith(
          color: context.palette.textTertiary,
        ),
      ),
    );
  }
}
