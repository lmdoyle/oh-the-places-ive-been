import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/visit.dart';
import 'user_service.dart';

class FeedService {
  static final _db = FirebaseFirestore.instance;

  // Firestore 'whereIn' caps at 30 values, so only the first 30 followed
  // users are covered. Fine for an MVP follow-graph size; revisit with
  // fan-out writes (a per-user feed collection) once that's a real limit.
  static Stream<List<Visit>> feedForUser(String userId) async* {
    final followingIds = await UserService.followingIds(userId);
    if (followingIds.isEmpty) {
      yield [];
      return;
    }

    final firstChunk = followingIds.take(30).toList();

    // Sorted/limited client-side rather than via .orderBy()/.limit() so this
    // doesn't need a composite index set up in Firestore.
    yield* _db
        .collection('visits')
        .where('userId', whereIn: firstChunk)
        .where('isPublic', isEqualTo: true)
        .snapshots()
        .map((snap) {
      final visits =
          snap.docs.map((d) => Visit.fromMap(d.id, d.data())).toList();
      visits.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return visits.take(50).toList();
    });
  }
}
