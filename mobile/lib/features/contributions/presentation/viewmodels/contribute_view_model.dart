import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/upload.dart';
import '../../../../core/pagination/paged.dart';
import '../../../../core/result/result.dart';
import '../../contributions_providers.dart';
import '../../domain/entities/contribution.dart';

/// Form problems the screen shows under each field.
enum ContributeField { name, category, description, address, contact }

/// Egyptian mobile number, same rule as `identifier` in contract v0.1.
final _egyptianMobile = RegExp(r'^(\+20|0020|0)?1[0125]\d{8}$');

class ContributeState {
  const ContributeState({
    this.category,
    this.name = '',
    this.description = '',
    this.address = '',
    this.contact = '',
    this.photos = const [],
    this.showErrors = false,
    this.submitting = false,
    this.failure,
  });

  final ContributionCategory? category;
  final String name;
  final String description;
  final String address;
  final String contact;
  final List<UploadFile> photos;

  /// Errors appear after the first "Preview & submit".
  final bool showErrors;
  final bool submitting;
  final Failure? failure;

  static const int maxName = 80;
  static const int maxDescription = 500;

  Map<ContributeField, bool> get _problems {
    final phone = contact.replaceAll(RegExp(r'[\s-]'), '');
    return {
      ContributeField.category: category == null,
      ContributeField.name: name.trim().length < 2,
      ContributeField.description: description.trim().isEmpty,
      ContributeField.address: address.trim().isEmpty,
      ContributeField.contact:
          phone.isNotEmpty && !_egyptianMobile.hasMatch(phone),
    };
  }

  bool get isValid => !_problems.values.any((p) => p);

  /// True when [field] should show its error now.
  bool error(ContributeField field) =>
      (showErrors && (_problems[field] ?? false)) ||
      (failure?.fieldErrors.containsKey(_wire(field)) ?? false);

  static String _wire(ContributeField f) => switch (f) {
    ContributeField.contact => 'contact_number',
    _ => f.name,
  };

  ContributeState copyWith({
    ContributionCategory? category,
    String? name,
    String? description,
    String? address,
    String? contact,
    List<UploadFile>? photos,
    bool? showErrors,
    bool? submitting,
    Failure? Function()? failure,
  }) => ContributeState(
    category: category ?? this.category,
    name: name ?? this.name,
    description: description ?? this.description,
    address: address ?? this.address,
    contact: contact ?? this.contact,
    photos: photos ?? this.photos,
    showErrors: showErrors ?? this.showErrors,
    submitting: submitting ?? this.submitting,
    failure: failure != null ? failure() : this.failure,
  );
}

/// The three steps of "Make your place part of ASWANI": category, details
/// (with photos), preview, then submit. Lives while its screens are open.
class ContributeViewModel extends Notifier<ContributeState> {
  @override
  ContributeState build() => const ContributeState();

  void start(ContributionCategory category) =>
      state = ContributeState(category: category);

  void setCategory(ContributionCategory c) =>
      state = state.copyWith(category: c);
  void setName(String v) => state = state.copyWith(name: v);
  void setDescription(String v) => state = state.copyWith(description: v);
  void setAddress(String v) => state = state.copyWith(address: v);
  void setContact(String v) => state = state.copyWith(contact: v);
  void setPhotos(List<UploadFile> v) => state = state.copyWith(photos: v);

  /// "Preview & submit": true when the form can go to the preview.
  bool review() {
    state = state.copyWith(showErrors: true, failure: () => null);
    return state.isValid;
  }

  /// Returns true when the contribution was received.
  Future<bool> submit() async {
    if (!state.isValid || state.submitting) return false;
    state = state.copyWith(submitting: true, failure: () => null);
    final contact = state.contact.replaceAll(RegExp(r'[\s-]'), '');
    final result = await ref
        .read(contributionsRepositoryProvider)
        .submit(
          ContributionDraft(
            category: state.category!,
            name: state.name.trim(),
            description: state.description.trim(),
            address: state.address.trim(),
            contactNumber: contact.isEmpty ? null : contact,
          ),
          state.photos,
        );
    if (!ref.mounted) return false;
    switch (result) {
      case Success():
        state = state.copyWith(submitting: false);
        ref.invalidate(myContributionsProvider);
        return true;
      case Error(:final failure):
        state = state.copyWith(submitting: false, failure: () => failure);
        return false;
    }
  }
}

final contributeProvider =
    NotifierProvider.autoDispose<ContributeViewModel, ContributeState>(
      ContributeViewModel.new,
    );

/// "Added activities".
final myContributionsProvider = FutureProvider.autoDispose<Paged<Contribution>>(
  (ref) async {
    final result = await ref.read(contributionsRepositoryProvider).getMine();
    return switch (result) {
      Success(:final value) => value,
      Error(:final failure) => throw failure,
    };
  },
);
