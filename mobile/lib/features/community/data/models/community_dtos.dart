/// JSON shapes of contract v0.2, Community (snake_case).
class AuthorDto {
  const AuthorDto({required this.id, required this.fullName, this.avatar});

  factory AuthorDto.fromJson(Map<String, dynamic> json) => AuthorDto(
    id: json['id'] as String,
    fullName: json['full_name'] as String,
    avatar: json['avatar'] as String?,
  );

  final String id;
  final String fullName;
  final String? avatar;

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'avatar': avatar,
  };
}

class PostDto {
  const PostDto({
    required this.id,
    required this.author,
    required this.images,
    required this.caption,
    required this.category,
    required this.likeCount,
    required this.commentCount,
    required this.isLiked,
    required this.isBookmarked,
    required this.createdAt,
    this.location,
  });

  factory PostDto.fromJson(Map<String, dynamic> json) => PostDto(
    id: json['id'] as String,
    author: AuthorDto.fromJson(json['author'] as Map<String, dynamic>),
    images: [for (final i in json['images'] as List<dynamic>) i as String],
    caption: json['caption'] as String,
    location: json['location'] as String?,
    category: json['category'] as String,
    likeCount: json['like_count'] as int? ?? 0,
    commentCount: json['comment_count'] as int? ?? 0,
    isLiked: json['is_liked'] as bool? ?? false,
    isBookmarked: json['is_bookmarked'] as bool? ?? false,
    createdAt: json['created_at'] as String,
  );

  final String id;
  final AuthorDto author;
  final List<String> images;
  final String caption;
  final String? location;
  final String category;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final bool isBookmarked;
  final String createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'author': author.toJson(),
    'images': images,
    'caption': caption,
    'location': location,
    'category': category,
    'like_count': likeCount,
    'comment_count': commentCount,
    'is_liked': isLiked,
    'is_bookmarked': isBookmarked,
    'created_at': createdAt,
  };
}

class HighlightDto {
  const HighlightDto({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.coverImage,
    required this.category,
  });

  factory HighlightDto.fromJson(Map<String, dynamic> json) => HighlightDto(
    id: json['id'] as String,
    titleEn: json['title_en'] as String,
    titleAr: json['title_ar'] as String,
    coverImage: json['cover_image'] as String,
    category: json['category'] as String,
  );

  final String id;
  final String titleEn;
  final String titleAr;
  final String coverImage;
  final String category;
}

class CommentDto {
  const CommentDto({
    required this.id,
    required this.author,
    required this.text,
    required this.createdAt,
  });

  factory CommentDto.fromJson(Map<String, dynamic> json) => CommentDto(
    id: json['id'] as String,
    author: AuthorDto.fromJson(json['author'] as Map<String, dynamic>),
    text: json['text'] as String,
    createdAt: json['created_at'] as String,
  );

  final String id;
  final AuthorDto author;
  final String text;
  final String createdAt;
}
