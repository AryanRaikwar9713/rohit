class ReelModel {
  final String id;
  final String videoUrl;
  final String thumbnailUrl;
  final String title;
  final String description;
  final int likes;
  final int comments;
  final int shares;
  final ReelUser user;
  final bool isLiked;
  final DateTime createdAt;

  ReelModel({
    required this.id,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.title,
    required this.description,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.user,
    required this.isLiked,
    required this.createdAt,
  });

  ReelModel copyWith({
    String? id,
    String? videoUrl,
    String? thumbnailUrl,
    String? title,
    String? description,
    int? likes,
    int? comments,
    int? shares,
    ReelUser? user,
    bool? isLiked,
    DateTime? createdAt,
  }) {
    return ReelModel(
      id: id ?? this.id,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      user: user ?? this.user,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ReelUser {
  final String id;
  final String username;
  final String profileImage;

  ReelUser({
    required this.id,
    required this.username,
    required this.profileImage,
  });
}
