import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/visit.dart';
import '../models/visit_comment.dart';
import 'auth_service.dart';

class VisitService {
  static final _db = FirebaseFirestore.instance;
  static CollectionReference<Map<String, dynamic>> get _visits =>
      _db.collection('visits');

  static Future<String> addVisit(Visit visit) async {
    final doc = await _visits.add(visit.toMap());
    return doc.id;
  }

  // Deleting a document doesn't cascade to its subcollections in Firestore,
  // so likes/comments have to be cleaned up explicitly or they'd be
  // orphaned (harmless, but a permanent storage leak).
  static Future<void> deleteVisit(String visitId) async {
    final visitRef = _visits.doc(visitId);
    final likes = await visitRef.collection('likes').get();
    final comments = await visitRef.collection('comments').get();

    final batch = _db.batch();
    for (final doc in likes.docs) {
      batch.delete(doc.reference);
    }
    for (final doc in comments.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(visitRef);
    await batch.commit();
  }

  static Future<void> updateVisit(
    String visitId,
    Map<String, dynamic> updates,
  ) async {
    await _visits.doc(visitId).update(updates);
  }

  // Sorted client-side rather than via .orderBy() so this doesn't need a
  // composite index (userId equality + createdAt order) set up in Firestore.
  static Stream<List<Visit>> visitsForUser(String userId) {
    return _visits.where('userId', isEqualTo: userId).snapshots().map((snap) {
      final visits = snap.docs
          .map((d) => Visit.fromMap(d.id, d.data()))
          .toList();
      visits.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return visits;
    });
  }

  static Future<Visit?> getVisit(String visitId) async {
    final doc = await _visits.doc(visitId).get();
    if (!doc.exists) return null;
    return Visit.fromMap(doc.id, doc.data()!);
  }

  static Stream<Visit?> visitStream(String visitId) {
    return _visits
        .doc(visitId)
        .snapshots()
        .map((doc) => doc.exists ? Visit.fromMap(doc.id, doc.data()!) : null);
  }

  static Future<void> setLiked(String visitId, bool liked) async {
    final userId = AuthService.currentUser?.uid;
    if (userId == null) return;
    final likeRef = _visits.doc(visitId).collection('likes').doc(userId);
    final visitRef = _visits.doc(visitId);

    await _db.runTransaction((tx) async {
      final likeDoc = await tx.get(likeRef);
      if (liked && !likeDoc.exists) {
        tx.set(likeRef, {'createdAt': DateTime.now().toIso8601String()});
        tx.update(visitRef, {'likeCount': FieldValue.increment(1)});
      } else if (!liked && likeDoc.exists) {
        tx.delete(likeRef);
        tx.update(visitRef, {'likeCount': FieldValue.increment(-1)});
      }
    });
  }

  static Stream<bool> isLikedByCurrentUser(String visitId) {
    final userId = AuthService.currentUser?.uid;
    if (userId == null) return Stream.value(false);
    return _visits
        .doc(visitId)
        .collection('likes')
        .doc(userId)
        .snapshots()
        .map((d) => d.exists);
  }

  static Future<void> addComment(String visitId, String text) async {
    final userId = AuthService.currentUser?.uid;
    if (userId == null) return;
    final visitRef = _visits.doc(visitId);
    final commentRef = visitRef.collection('comments').doc();

    await _db.runTransaction((tx) async {
      tx.set(commentRef, {
        'visitId': visitId,
        'userId': userId,
        'text': text,
        'createdAt': DateTime.now().toIso8601String(),
      });
      tx.update(visitRef, {'commentCount': FieldValue.increment(1)});
    });
  }

  static Stream<List<VisitComment>> commentsForVisit(String visitId) {
    return _visits
        .doc(visitId)
        .collection('comments')
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => VisitComment.fromMap(d.id, d.data()))
              .toList(),
        );
  }
}
