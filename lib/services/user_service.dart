import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import '../models/follow_event.dart';
import 'auth_service.dart';

class UserService {
  static final _db = FirebaseFirestore.instance;
  static CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  static Future<void> createUserProfile(AppUser user) async {
    await _users.doc(user.uid).set(user.toMap());
  }

  static Future<AppUser?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.id, doc.data()!);
  }

  static Stream<AppUser?> userStream(String uid) {
    return _users.doc(uid).snapshots().map(
        (d) => d.exists ? AppUser.fromMap(d.id, d.data()!) : null);
  }

  static Future<void> follow(String targetUid) async {
    final userId = AuthService.currentUser?.uid;
    if (userId == null || userId == targetUid) return;

    final followingRef =
        _users.doc(userId).collection('following').doc(targetUid);
    final followerRef =
        _users.doc(targetUid).collection('followers').doc(userId);

    await _db.runTransaction((tx) async {
      final existing = await tx.get(followingRef);
      if (existing.exists) return;
      tx.set(followingRef, {'createdAt': DateTime.now().toIso8601String()});
      tx.set(followerRef, {'createdAt': DateTime.now().toIso8601String()});
      tx.update(_users.doc(userId), {'followingCount': FieldValue.increment(1)});
      tx.update(_users.doc(targetUid), {'followerCount': FieldValue.increment(1)});
    });
  }

  static Future<void> unfollow(String targetUid) async {
    final userId = AuthService.currentUser?.uid;
    if (userId == null || userId == targetUid) return;

    final followingRef =
        _users.doc(userId).collection('following').doc(targetUid);
    final followerRef =
        _users.doc(targetUid).collection('followers').doc(userId);

    await _db.runTransaction((tx) async {
      final existing = await tx.get(followingRef);
      if (!existing.exists) return;
      tx.delete(followingRef);
      tx.delete(followerRef);
      tx.update(_users.doc(userId), {'followingCount': FieldValue.increment(-1)});
      tx.update(_users.doc(targetUid), {'followerCount': FieldValue.increment(-1)});
    });
  }

  static Stream<bool> isFollowing(String targetUid) {
    final userId = AuthService.currentUser?.uid;
    if (userId == null) return Stream.value(false);
    return _users
        .doc(userId)
        .collection('following')
        .doc(targetUid)
        .snapshots()
        .map((d) => d.exists);
  }

  static Future<List<String>> followingIds(String userId) async {
    final snap = await _users.doc(userId).collection('following').get();
    return snap.docs.map((d) => d.id).toList();
  }

  // Fetches the follower's profile for each entry since the followers
  // subcollection only stores the uid + timestamp, not display info.
  static Stream<List<FollowEvent>> followerEvents(String userId) {
    return _users
        .doc(userId)
        .collection('followers')
        .snapshots()
        .asyncMap((snap) async {
      final events = await Future.wait(snap.docs.map((d) async {
        final follower = await getUser(d.id);
        return FollowEvent(
          followerId: d.id,
          followerName: follower?.displayName ?? 'Someone',
          followerPhotoUrl: follower?.photoUrl,
          createdAt: DateTime.parse(d.data()['createdAt'] as String),
        );
      }));
      return events;
    });
  }

  static Future<List<AppUser>> searchByName(String query) async {
    if (query.trim().isEmpty) return [];
    final snap = await _users
        .orderBy('displayName')
        .startAt([query])
        .endAt(['$query'])
        .limit(20)
        .get();
    return snap.docs.map((d) => AppUser.fromMap(d.id, d.data())).toList();
  }
}
