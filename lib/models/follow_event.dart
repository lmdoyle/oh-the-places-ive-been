class FollowEvent {
  final String followerId;
  final String followerName;
  final String? followerPhotoUrl;
  final DateTime createdAt;

  const FollowEvent({
    required this.followerId,
    required this.followerName,
    this.followerPhotoUrl,
    required this.createdAt,
  });
}
