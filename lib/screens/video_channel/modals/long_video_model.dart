/// Model for long-form videos (channel videos, YouTube-style).
class LongVideoItem {
  final int id;
  final String title;
  final String? description;
  final String? videoUrl;
  final String? thumbnailUrl;
  final String? duration;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int likeCount;
  final int commentCount;

  LongVideoItem({
    required this.id,
    required this.title,
    this.description,
    this.videoUrl,
    this.thumbnailUrl,
    this.duration,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.likeCount = 0,
    this.commentCount = 0,
  });

  factory LongVideoItem.fromJson(Map<String, dynamic> json) {
    return LongVideoItem(
      id: (json['id'] is int) ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      videoUrl: json['video_url']?.toString(),
      thumbnailUrl: json['thumbnail_url']?.toString(),
      duration: json['duration']?.toString(),
      status: json['status']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
      likeCount: (json['like_count'] is int) ? json['like_count'] as int : int.tryParse(json['like_count']?.toString() ?? '0') ?? 0,
      commentCount: (json['comment_count'] is int) ? json['comment_count'] as int : int.tryParse(json['comment_count']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'video_url': videoUrl,
        'thumbnail_url': thumbnailUrl,
        'duration': duration,
        'status': status,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'like_count': likeCount,
        'comment_count': commentCount,
      };
}

/// Result of list_public with pagination.
class LongVideoListResult {
  final List<LongVideoItem> videos;
  final bool hasMore;
  LongVideoListResult({required this.videos, required this.hasMore});
}
