import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

enum ReportTargetType { visit, comment, user }

class ReportService {
  static final _db = FirebaseFirestore.instance;

  // Content auto-hides once its report count crosses this, pending review.
  static const autoHideThreshold = 3;

  static Future<void> submitReport({
    required ReportTargetType targetType,
    required String targetId,
    required String reason,
  }) async {
    final reporterId = AuthService.currentUser?.uid;
    if (reporterId == null) return;

    final reportsRef = _db.collection('reports');
    final targetRef = _targetRef(targetType, targetId);

    await _db.runTransaction((tx) async {
      tx.set(reportsRef.doc(), {
        'targetType': targetType.name,
        'targetId': targetId,
        'reporterId': reporterId,
        'reason': reason,
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      });
      tx.update(targetRef, {'reportCount': FieldValue.increment(1)});
    });

    final targetDoc = await targetRef.get();
    final reportCount = (targetDoc.data()?['reportCount'] as int?) ?? 0;
    if (reportCount >= autoHideThreshold) {
      await targetRef.update({'hidden': true});
    }
  }

  static DocumentReference<Map<String, dynamic>> _targetRef(
      ReportTargetType type, String id) {
    switch (type) {
      case ReportTargetType.visit:
        return _db.collection('visits').doc(id);
      case ReportTargetType.comment:
        // Comments are nested under their visit; callers pass
        // "visitId/commentId" as the id for this target type.
        final parts = id.split('/');
        return _db
            .collection('visits')
            .doc(parts[0])
            .collection('comments')
            .doc(parts[1]);
      case ReportTargetType.user:
        return _db.collection('users').doc(id);
    }
  }
}
