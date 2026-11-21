import 'guide_dto.dart';

/// DTO for POST /api/guide-requests body.
/// Fields: guide_id, date, duration, duration_hours?, start_time, group_size,
/// language, interests?, notes?.
class GuideRequestCreateDto {
  const GuideRequestCreateDto({
    required this.guideId,
    required this.date,
    required this.duration,
    this.durationHours,
    required this.startTime,
    required this.groupSize,
    required this.language,
    this.interests,
    this.notes,
  });

  factory GuideRequestCreateDto.fromJson(Map<String, dynamic> json) =>
      GuideRequestCreateDto(
        guideId: json['guide_id'] as String,
        date: json['date'] as String,
        duration: json['duration'] as String,
        durationHours: json['duration_hours'] as int?,
        startTime: json['start_time'] as String,
        groupSize: json['group_size'] as int,
        language: json['language'] as String,
        interests: (json['interests'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(),
        notes: json['notes'] as String?,
      );

  final String guideId;
  final String date;
  final String duration;
  final int? durationHours;
  final String startTime;
  final int groupSize;
  final String language;
  final List<String>? interests;
  final String? notes;

  Map<String, dynamic> toJson() => {
    'guide_id': guideId,
    'date': date,
    'duration': duration,
    if (durationHours != null) 'duration_hours': durationHours,
    'start_time': startTime,
    'group_size': groupSize,
    'language': language,
    if (interests != null) 'interests': interests,
    if (notes != null) 'notes': notes,
  };
}

/// DTO for POST /api/guide-requests response: { "id", "status": "pending" }.
class GuideRequestResultDto {
  const GuideRequestResultDto({
    required this.id,
    required this.status,
  });

  factory GuideRequestResultDto.fromJson(Map<String, dynamic> json) =>
      GuideRequestResultDto(
        id: json['id'] as String,
        status: json['status'] as String? ?? 'pending',
      );

  final String id;
  final String status;

  Map<String, dynamic> toJson() => {
    'id': id,
    'status': status,
  };
}

/// DTO for items returned in GET /api/guide-requests/mine.
/// Fields: id, guide { id, full_name, photo }, date, duration, duration_hours,
/// start_time, group_size, language, interests[], status, created_at.
class GuideRequestItemDto {
  const GuideRequestItemDto({
    required this.id,
    required this.guide,
    required this.date,
    required this.duration,
    this.durationHours,
    required this.startTime,
    required this.groupSize,
    required this.language,
    required this.interests,
    required this.status,
    required this.createdAt,
  });

  factory GuideRequestItemDto.fromJson(Map<String, dynamic> json) =>
      GuideRequestItemDto(
        id: json['id'] as String,
        guide: GuideSummaryDto.fromJson(json['guide'] as Map<String, dynamic>),
        date: json['date'] as String,
        duration: json['duration'] as String,
        durationHours: json['duration_hours'] as int?,
        startTime: json['start_time'] as String,
        groupSize: json['group_size'] as int,
        language: json['language'] as String,
        interests: (json['interests'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        status: json['status'] as String? ?? 'pending',
        createdAt: json['created_at'] as String,
      );

  final String id;
  final GuideSummaryDto guide;
  final String date;
  final String duration;
  final int? durationHours;
  final String startTime;
  final int groupSize;
  final String language;
  final List<String> interests;
  final String status;
  final String createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'guide': guide.toJson(),
    'date': date,
    'duration': duration,
    if (durationHours != null) 'duration_hours': durationHours,
    'start_time': startTime,
    'group_size': groupSize,
    'language': language,
    'interests': interests,
    'status': status,
    'created_at': createdAt,
  };
}
