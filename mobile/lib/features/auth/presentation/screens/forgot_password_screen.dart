import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../core/theme/app_spacing.dart';
import '../error_text.dart';
import '../validators/auth_validators.dart';
import '../viewmodels/forgot_password_view_model.dart';
import '../widgets/auth_scaffold.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifier = TextEditingController();

  @override
  void dispose() {
    _identifier.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final identifier = _identifier.text.trim();
    final sent = await ref
        .read(forgotPasswordViewModelProvider.notifier)
        .submit(identifier: identifier);
    if (sent && mounted) {
      unawaited(
        context.push(
          Uri(
            path: AppRoutes.resetPassword,
            queryParameters: {'identifier': identifier},
          ).toString(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(forgotPasswordViewModelProvider);
    final fieldError = state.fieldError('identifier');

    return AuthScaffold(
      icon: LucideIcons.lock,
      title: l10n.forgotTitle,
      subtitle: l10n.forgotSubtitle,
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                fieldKey: const Key('forgot.identifier'),
                label: l10n.fieldIdentifier,
                hint: l10n.fieldIdentifierHint,
                controller: _identifier,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.email],
                serverError: fieldError == null
                    ? null
                    : l10n.errorFor(fieldError),
                validator: (v) => l10n.validation(AuthValidators.identifier(v)),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.lg),
              FormErrorText(
                state.failure != null && fieldError == null
                    ? l10n.errorFor(state.failure!.code)
                    : null,
              ),
              PrimaryButton(
                label: l10n.sendCode,
                loading: state.submitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
