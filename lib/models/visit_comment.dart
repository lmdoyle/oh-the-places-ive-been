class VisitComment {
  final String id;
  final String visitId;
  final String userId;
  final String text;
  final DateTime createdAt;

  const VisitComment({
    required this.id,
    required this.visitId,
    required this.userId,
    required this.text,
    required this.createdAt,
  });

  factory VisitComment.fromMap(String id, Map<String, dynamic> map) {
    return VisitComment(
      id: id,
      visitId: map['visitId'] as String,
      userId: map['userId'] as String,
      text: map['text'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'visitId': visitId,
      'userId': userId,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
