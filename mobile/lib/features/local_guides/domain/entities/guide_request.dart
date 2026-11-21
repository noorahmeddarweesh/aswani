import 'guide.dart';
import 'guide_enums.dart';

/// Request body entity to book/request a guide.
class GuideRequestCreate {
  const GuideRequestCreate({
    required this.guideId,
    required this.date,
    required this.duration,
    this.durationHours,
    required this.startTime,
    required this.groupSize,
    required this.language,
    this.interests = const [],
    this.notes,
  });

  final String guideId;
  final String date;
  final RequestDuration duration;
  final int? durationHours;
  final String startTime;
  final int groupSize;
  final GuideLanguage language;
  final List<GuideSpecialty> interests;
  final String? notes;
}

/// Result returned after submitting a guide request.
class GuideRequestResult {
  const GuideRequestResult({
    required this.id,
    required this.status,
  });

  final String id;
  final RequestStatus status;
}

/// Full guide request item returned in /mine list.
class GuideRequestItem {
  const GuideRequestItem({
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

  final String id;
  final GuideSummary guide;
  final String date;
  final RequestDuration duration;
  final int? durationHours;
  final String startTime;
  final int groupSize;
  final GuideLanguage language;
  final List<GuideSpecialty> interests;
  final RequestStatus status;
  final String createdAt;
}
