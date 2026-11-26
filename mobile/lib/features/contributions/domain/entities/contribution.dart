/// Categories of "Make your place part of ASWANI" (contract v0.2).
enum ContributionCategory {
  restaurant('restaurant'),
  cafe('cafe'),
  entertainment('entertainment'),
  maintenance('maintenance'),
  clinic('clinic'),
  other('other');

  const ContributionCategory(this.wire);

  final String wire;

  static ContributionCategory? fromWire(String? value) =>
      ContributionCategory.values.where((c) => c.wire == value).firstOrNull;
}

enum ContributionStatus {
  pending,
  accepted,
  rejected;

  static ContributionStatus fromWire(String? value) => ContributionStatus.values
      .firstWhere((s) => s.name == value, orElse: () => pending);
}

/// An activity the user added (Profile > Added activities).
class Contribution {
  const Contribution({
    required this.id,
    required this.category,
    required this.name,
    required this.status,
    required this.pointsAwarded,
    required this.createdAt,
  });

  final String id;
  final ContributionCategory category;
  final String name;
  final ContributionStatus status;
  final int pointsAwarded;
  final DateTime createdAt;
}

/// What the user typed, sent with the photos.
/// One contribution with everything the form needs (GET /contributions/{id},
/// contract v0.3), so it can be edited.
class ContributionDetails {
  const ContributionDetails({
    required this.id,
    required this.draft,
    required this.photos,
    required this.status,
  });

  final String id;
  final ContributionDraft draft;

  /// URLs of the photos already sent.
  final List<String> photos;
  final ContributionStatus status;
}

class ContributionDraft {
  const ContributionDraft({
    required this.category,
    required this.name,
    required this.description,
    required this.address,
    this.contactNumber,
  });

  final ContributionCategory category;
  final String name;
  final String description;
  final String address;
  final String? contactNumber;
}
