/// DTO for POST /api/place-reports multipart form.
/// Fields: place_id, reason, details, photo?.
class PlaceReportCreateDto {
  const PlaceReportCreateDto({
    required this.placeId,
    required this.reason,
    required this.details,
    this.photo,
  });

  factory PlaceReportCreateDto.fromJson(Map<String, dynamic> json) =>
      PlaceReportCreateDto(
        placeId: json['place_id'] as String,
        reason: json['reason'] as String,
        details: json['details'] as String,
        photo: json['photo'] as String?,
      );

  final String placeId;
  final String reason;
  final String details;
  final String? photo;

  Map<String, dynamic> toJson() => {
    'place_id': placeId,
    'reason': reason,
    'details': details,
    if (photo != null) 'photo': photo,
  };
}

/// DTO for POST /api/place-reports response:
/// { data: { id, status: "pending", points_pending: 25 } }.
class PlaceReportResultDto {
  const PlaceReportResultDto({
    required this.id,
    required this.status,
    required this.pointsPending,
  });

  factory PlaceReportResultDto.fromJson(Map<String, dynamic> json) =>
      PlaceReportResultDto(
        id: json['id'] as String,
        status: json['status'] as String? ?? 'pending',
        pointsPending: json['points_pending'] as int? ?? 25,
      );

  final String id;
  final String status;
  final int pointsPending;

  Map<String, dynamic> toJson() => {
    'id': id,
    'status': status,
    'points_pending': pointsPending,
  };
}

/// Nested place summary in PlaceReportItemDto.
class PlaceReportPlaceSummaryDto {
  const PlaceReportPlaceSummaryDto({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.image,
  });

  factory PlaceReportPlaceSummaryDto.fromJson(Map<String, dynamic> json) =>
      PlaceReportPlaceSummaryDto(
        id: json['id'] as String,
        nameEn: json['name_en'] as String,
        nameAr: json['name_ar'] as String,
        image: json['image'] as String,
      );

  final String id;
  final String nameEn;
  final String nameAr;
  final String image;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name_en': nameEn,
    'name_ar': nameAr,
    'image': image,
  };
}

/// DTO for items returned in GET /api/place-reports/mine.
/// Fields: id, place { id, name_en, name_ar, image }, reason, status, points_awarded, created_at.
class PlaceReportItemDto {
  const PlaceReportItemDto({
    required this.id,
    required this.place,
    required this.reason,
    required this.status,
    this.pointsAwarded,
    required this.createdAt,
  });

  factory PlaceReportItemDto.fromJson(Map<String, dynamic> json) =>
      PlaceReportItemDto(
        id: json['id'] as String,
        place: PlaceReportPlaceSummaryDto.fromJson(
          json['place'] as Map<String, dynamic>,
        ),
        reason: json['reason'] as String,
        status: json['status'] as String? ?? 'pending',
        pointsAwarded: json['points_awarded'] as int?,
        createdAt: json['created_at'] as String,
      );

  final String id;
  final PlaceReportPlaceSummaryDto place;
  final String reason;
  final String status;
  final int? pointsAwarded;
  final String createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'place': place.toJson(),
    'reason': reason,
    'status': status,
    if (pointsAwarded != null) 'points_awarded': pointsAwarded,
    'created_at': createdAt,
  };
}
