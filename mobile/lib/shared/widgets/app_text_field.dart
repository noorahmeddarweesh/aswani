import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import 'labeled_field.dart';
import '../extensions/context_x.dart';

/// Labelled text field used by every form. Password fields get a
/// show / hide button. [serverError] shows an error that came from the API
/// under this field.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.isPassword = false,
    this.serverError,
    this.onSubmitted,
    this.inputFormatters,
    this.fieldKey,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final bool isPassword;
  final String? serverError;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final Key? fieldKey;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LabeledField(
      label: widget.label,
      child: TextFormField(
        key: widget.fieldKey,
        controller: widget.controller,
        validator: widget.validator,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        autofillHints: widget.autofillHints,
        obscureText: widget.isPassword && _obscured,
        enableSuggestions: !widget.isPassword,
        autocorrect: !widget.isPassword,
        inputFormatters: widget.inputFormatters,
        autovalidateMode: AutovalidateMode.onUnfocus,
        onFieldSubmitted: widget.onSubmitted,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        style: context.text.bodyLarge,
        decoration: InputDecoration(
          hintText: widget.hint,
          errorText: widget.serverError,
          errorMaxLines: 2,
          suffixIcon: widget.isPassword
              ? IconButton(
                  tooltip: _obscured ? l10n.showPassword : l10n.hidePassword,
                  onPressed: () => setState(() => _obscured = !_obscured),
                  icon: Icon(
                    _obscured ? LucideIcons.eye : LucideIcons.eyeOff,
                    size: 18,
                    color: context.palette.textSecondary,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
