import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/config/env.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../error_text.dart';
import '../validators/auth_validators.dart';
import '../viewmodels/sign_in_view_model.dart';
import '../widgets/auth_scaffold.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ref
        .read(signInViewModelProvider.notifier)
        .submit(identifier: _identifier.text, password: _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(signInViewModelProvider);
    // Navigation after success is done by the router (session changed).

    return AuthScaffold(
      title: l10n.signInTitle,
      subtitle: l10n.signInSubtitle,
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                fieldKey: const Key('signIn.identifier'),
                label: l10n.fieldIdentifier,
                hint: l10n.fieldIdentifierHint,
                controller: _identifier,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.username],
                validator: (v) => l10n.validation(AuthValidators.identifier(v)),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                fieldKey: const Key('signIn.password'),
                label: l10n.fieldPassword,
                controller: _password,
                isPassword: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                validator: (v) =>
                    l10n.validation(AuthValidators.requiredField(v)),
                onSubmitted: (_) => _submit(),
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: () => context.push(AppRoutes.forgotPassword),
                  child: Text(l10n.forgotPassword),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              FormErrorText(
                state.failure == null
                    ? null
                    : l10n.errorFor(state.failure!.code),
              ),
              PrimaryButton(
                label: l10n.signInButton,
                loading: state.submitting,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.xs),
              AuthSwitchLink(
                question: l10n.noAccount,
                action: l10n.createAccountLink,
                onTap: () => context.pushReplacement(AppRoutes.signUp),
              ),
              if (Env.useMocks) MockHint(l10n.mockSignInHint),
            ],
          ),
        ),
      ],
    );
  }
}
