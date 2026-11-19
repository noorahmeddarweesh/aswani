import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../error_text.dart';
import '../validators/auth_validators.dart';
import '../viewmodels/sign_up_view_model.dart';
import '../widgets/auth_scaffold.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _agreed = false;
  bool _showTermsError = false;

  @override
  void dispose() {
    _name.dispose();
    _identifier.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    final valid = _formKey.currentState?.validate() ?? false;
    setState(() => _showTermsError = !_agreed);
    if (!valid || !_agreed) return;
    ref
        .read(signUpViewModelProvider.notifier)
        .submit(
          fullName: _name.text,
          identifier: _identifier.text,
          password: _password.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(signUpViewModelProvider);
    final identifierError = state.fieldError('identifier');
    final generalError = state.failure != null && identifierError == null
        ? l10n.errorFor(state.failure!.code)
        : null;

    return AuthScaffold(
      title: l10n.signUpTitle,
      subtitle: l10n.signUpSubtitle,
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                fieldKey: const Key('signUp.name'),
                label: l10n.fieldFullName,
                hint: l10n.fieldFullNameHint,
                controller: _name,
                keyboardType: TextInputType.name,
                autofillHints: const [AutofillHints.name],
                validator: (v) => l10n.validation(AuthValidators.fullName(v)),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                fieldKey: const Key('signUp.identifier'),
                label: l10n.fieldIdentifier,
                hint: l10n.fieldIdentifierHint,
                controller: _identifier,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                serverError: identifierError == null
                    ? null
                    : l10n.errorFor(identifierError),
                validator: (v) => l10n.validation(AuthValidators.identifier(v)),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                fieldKey: const Key('signUp.password'),
                label: l10n.fieldPassword,
                controller: _password,
                isPassword: true,
                autofillHints: const [AutofillHints.newPassword],
                validator: (v) => l10n.validation(AuthValidators.password(v)),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                fieldKey: const Key('signUp.confirm'),
                label: l10n.fieldConfirmPassword,
                controller: _confirm,
                isPassword: true,
                textInputAction: TextInputAction.done,
                validator: (v) => l10n.validation(
                  AuthValidators.confirmPassword(v, _password.text),
                ),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.sm),
              InkWell(
                key: const Key('signUp.terms'),
                borderRadius: AppRadii.smAll,
                onTap: () => setState(() {
                  _agreed = !_agreed;
                  if (_agreed) _showTermsError = false;
                }),
                child: Row(
                  children: [
                    Checkbox(
                      value: _agreed,
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      onChanged: (v) => setState(() {
                        _agreed = v ?? false;
                        if (_agreed) _showTermsError = false;
                      }),
                    ),
                    Expanded(
                      child: Text(
                        l10n.agreeTerms,
                        style: context.text.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              if (_showTermsError)
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: AppSpacing.sm,
                  ),
                  child: Text(
                    l10n.validationTerms,
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.error,
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
              FormErrorText(generalError),
              PrimaryButton(
                label: l10n.createAccountButton,
                loading: state.submitting,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.xs),
              AuthSwitchLink(
                question: l10n.haveAccount,
                action: l10n.welcomeSignIn,
                onTap: () => context.pushReplacement(AppRoutes.signIn),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
