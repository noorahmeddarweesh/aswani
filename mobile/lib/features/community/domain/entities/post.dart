/// Post categories (contract v0.2, Community).
enum PostCategory {
  localExperience('local_experience'),
  nubian('nubian'),
  nile('nile'),
  food('food'),
  other('other');

  const PostCategory(this.wire);

  /// The value the API uses.
  final String wire;

  static PostCategory fromWire(String? value) => PostCategory.values.firstWhere(
    (c) => c.wire == value,
    orElse: () => PostCategory.other,
  );
}

/// Who wrote a post or a comment.
class Author {
  const Author({required this.id, required this.fullName, this.avatarUrl});

  final String id;
  final String fullName;

  /// Null: the app shows the first letter of the name.
  final String? avatarUrl;
}

class Post {
  const Post({
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

  final String id;
  final Author author;
  final List<String> images;
  final String caption;
  final String? location;
  final PostCategory category;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final bool isBookmarked;
  final DateTime createdAt;

  Post copyWith({
    int? likeCount,
    int? commentCount,
    bool? isLiked,
    bool? isBookmarked,
  }) => Post(
    id: id,
    author: author,
    images: images,
    caption: caption,
    location: location,
    category: category,
    likeCount: likeCount ?? this.likeCount,
    commentCount: commentCount ?? this.commentCount,
    isLiked: isLiked ?? this.isLiked,
    isBookmarked: isBookmarked ?? this.isBookmarked,
    createdAt: createdAt,
  );
}

/// A circle at the top of the feed (Nubia, On the Nile, Local life): tapping
/// it shows the posts of its category.
class Highlight {
  const Highlight({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.coverImage,
    required this.category,
  });

  final String id;
  final String titleEn;
  final String titleAr;
  final String coverImage;
  final PostCategory category;

  String title(String languageCode) => languageCode == 'ar' ? titleAr : titleEn;
}

class Comment {
  const Comment({
    required this.id,
    required this.author,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final Author author;
  final String text;
  final DateTime createdAt;
}
