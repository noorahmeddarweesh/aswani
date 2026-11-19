import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/config/env.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../error_text.dart';
import '../validators/auth_validators.dart';
import '../viewmodels/reset_password_view_model.dart';
import '../widgets/auth_scaffold.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, required this.identifier});

  final String identifier;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final messenger = ScaffoldMessenger.of(context);
    final message = context.l10n.passwordUpdated;
    final done = await ref
        .read(resetPasswordViewModelProvider.notifier)
        .submit(
          identifier: widget.identifier,
          code: _code.text,
          newPassword: _password.text,
        );
    if (done && mounted) {
      messenger.showSnackBar(SnackBar(content: Text(message)));
      context.go(AppRoutes.signIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(resetPasswordViewModelProvider);
    final codeError = state.fieldError('code');

    return AuthScaffold(
      icon: LucideIcons.check,
      title: l10n.resetTitle,
      subtitle: l10n.resetSubtitle,
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                fieldKey: const Key('reset.code'),
                label: l10n.fieldCode,
                hint: '- - - -',
                controller: _code,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                serverError: codeError == null
                    ? null
                    : l10n.errorFor(codeError),
                validator: (v) => l10n.validation(AuthValidators.code(v)),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                fieldKey: const Key('reset.password'),
                label: l10n.fieldNewPassword,
                controller: _password,
                isPassword: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                validator: (v) => l10n.validation(AuthValidators.password(v)),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.lg),
              FormErrorText(
                state.failure != null && codeError == null
                    ? l10n.errorFor(state.failure!.code)
                    : null,
              ),
              PrimaryButton(
                label: l10n.savePassword,
                loading: state.submitting,
                onPressed: _submit,
              ),
              if (Env.useMocks) MockHint(l10n.mockCodeHint),
            ],
          ),
        ),
      ],
    );
  }
}
