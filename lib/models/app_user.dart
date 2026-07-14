class AppUser {
  final String uid;
  final String displayName;
  final String? email;
  final String? photoUrl;
  final String? bio;
  final bool isPrivate;
  final int followerCount;
  final int followingCount;

  const AppUser({
    required this.uid,
    required this.displayName,
    this.email,
    this.photoUrl,
    this.bio,
    this.isPrivate = false,
    this.followerCount = 0,
    this.followingCount = 0,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      displayName: map['displayName'] as String,
      email: map['email'] as String?,
      photoUrl: map['photoUrl'] as String?,
      bio: map['bio'] as String?,
      isPrivate: map['isPrivate'] as bool? ?? false,
      followerCount: map['followerCount'] as int? ?? 0,
      followingCount: map['followingCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'bio': bio,
      'isPrivate': isPrivate,
      'followerCount': followerCount,
      'followingCount': followingCount,
    };
  }
}
