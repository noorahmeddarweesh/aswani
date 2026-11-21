enum PlaceReportReason {
  notExist('not_exist'),
  permanentlyClosed('permanently_closed'),
  temporarilyClosed('temporarily_closed'),
  incorrectLocation('incorrect_location'),
  incorrectInformation('incorrect_information'),
  other('other');

  const PlaceReportReason(this.value);
  final String value;

  static PlaceReportReason fromValue(String value) =>
      PlaceReportReason.values.firstWhere(
        (e) => e.value == value,
        orElse: () => PlaceReportReason.other,
      );
}

/// Request entity for creating a place report.
class PlaceReportCreate {
  const PlaceReportCreate({
    required this.placeId,
    required this.reason,
    required this.details,
    this.photo,
  });

  final String placeId;
  final PlaceReportReason reason;
  final String details;
  final String? photo;
}

/// Result returned from submitting a place report.
class PlaceReportResult {
  const PlaceReportResult({
    required this.id,
    required this.status,
    required this.pointsPending,
  });

  final String id;
  final String status;
  final int pointsPending;
}

/// Place summary inside a report item.
class PlaceReportPlaceSummary {
  const PlaceReportPlaceSummary({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.image,
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final String image;

  String name(String languageCode) => languageCode == 'ar' ? nameAr : nameEn;
}

/// Report item in /mine list.
class PlaceReportItem {
  const PlaceReportItem({
    required this.id,
    required this.place,
    required this.reason,
    required this.status,
    this.pointsAwarded,
    required this.createdAt,
  });

  final String id;
  final PlaceReportPlaceSummary place;
  final PlaceReportReason reason;
  final String status;
  final int? pointsAwarded;
  final String createdAt;
}
