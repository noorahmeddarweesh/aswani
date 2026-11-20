import '../../domain/entities/post.dart';
import '../models/community_dtos.dart';

extension AuthorMapper on AuthorDto {
  Author toEntity() => Author(id: id, fullName: fullName, avatarUrl: avatar);
}

extension PostMapper on PostDto {
  Post toEntity() => Post(
    id: id,
    author: author.toEntity(),
    images: images,
    caption: caption,
    location: location,
    category: PostCategory.fromWire(category),
    likeCount: likeCount,
    commentCount: commentCount,
    isLiked: isLiked,
    isBookmarked: isBookmarked,
    createdAt: DateTime.parse(createdAt),
  );
}

extension HighlightMapper on HighlightDto {
  Highlight toEntity() => Highlight(
    id: id,
    titleEn: titleEn,
    titleAr: titleAr,
    coverImage: coverImage,
    category: PostCategory.fromWire(category),
  );
}

extension CommentMapper on CommentDto {
  Comment toEntity() => Comment(
    id: id,
    author: author.toEntity(),
    text: text,
    createdAt: DateTime.parse(createdAt),
  );
}
