import 'package:intl/intl.dart';

class Visit {
  final String id;
  final String userId;
  final String placeName;
  final String country;
  final String? state;
  final double latitude;
  final double longitude;
  final DateTime? visitedFrom;
  final DateTime? visitedTo;
  final List<String> photoUrls;
  final int? rating;
  final String? comment;
  final bool isPublic;
  final DateTime createdAt;
  final int likeCount;
  final int commentCount;

  const Visit({
    required this.id,
    required this.userId,
    required this.placeName,
    required this.country,
    this.state,
    required this.latitude,
    required this.longitude,
    this.visitedFrom,
    this.visitedTo,
    this.photoUrls = const [],
    this.rating,
    this.comment,
    this.isPublic = true,
    required this.createdAt,
    this.likeCount = 0,
    this.commentCount = 0,
  });

  String? get dateRangeLabel {
    if (visitedFrom == null) return null;
    if (visitedTo == null || visitedTo!.isAtSameMomentAs(visitedFrom!)) {
      return DateFormat.yMMMd().format(visitedFrom!);
    }
    return '${DateFormat.yMMMd().format(visitedFrom!)} – '
        '${DateFormat.yMMMd().format(visitedTo!)}';
  }

  factory Visit.fromMap(String id, Map<String, dynamic> map) {
    return Visit(
      id: id,
      userId: map['userId'] as String,
      placeName: map['placeName'] as String,
      country: map['country'] as String,
      state: map['state'] as String?,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      visitedFrom: map['visitedFrom'] != null
          ? DateTime.parse(map['visitedFrom'] as String)
          : null,
      visitedTo: map['visitedTo'] != null
          ? DateTime.parse(map['visitedTo'] as String)
          : null,
      photoUrls: List<String>.from(map['photoUrls'] as List? ?? []),
      rating: map['rating'] as int?,
      comment: map['comment'] as String?,
      isPublic: map['isPublic'] as bool? ?? true,
      createdAt: DateTime.parse(map['createdAt'] as String),
      likeCount: map['likeCount'] as int? ?? 0,
      commentCount: map['commentCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'placeName': placeName,
      'country': country,
      'state': state,
      'latitude': latitude,
      'longitude': longitude,
      'visitedFrom': visitedFrom?.toIso8601String(),
      'visitedTo': visitedTo?.toIso8601String(),
      'photoUrls': photoUrls,
      'rating': rating,
      'comment': comment,
      'isPublic': isPublic,
      'createdAt': createdAt.toIso8601String(),
      'likeCount': likeCount,
      'commentCount': commentCount,
    };
  }
}
