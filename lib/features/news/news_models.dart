// lib/features/news/news_models.dart
// [命名重構 V4.4]
// 功能：檔案已從 feed_models.dart 更名為 news_models.dart。

import 'dart:convert';

class StoryData {
  final String name;
  final bool hasNewStory;
  final String? avatarUrl;

  StoryData({
    required this.name,
    required this.hasNewStory,
    this.avatarUrl,
  });
}

class PostData {
  final String userName;
  final String? userAvatarUrl;
  final String? location;
  final String cardTitle;
  final String cardSubtitle;
  final String cardGradientStart;
  final String cardGradientEnd;
  final String caption;
  int likesCount;
  final String timeAgo;
  final List<Comment> comments;
  bool isLiked;
  bool isSaved;

  PostData({
    required this.userName,
    this.userAvatarUrl,
    this.location,
    required this.cardTitle,
    required this.cardSubtitle,
    required this.cardGradientStart,
    required this.cardGradientEnd,
    required this.caption,
    required this.likesCount,
    required this.timeAgo,
    required this.comments,
    this.isLiked = false,
    this.isSaved = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'location': location,
      'cardTitle': cardTitle,
      'cardSubtitle': cardSubtitle,
      'cardGradientStart': cardGradientStart,
      'cardGradientEnd': cardGradientEnd,
      'caption': caption,
      'likesCount': likesCount,
      'timeAgo': timeAgo,
      'comments': comments.map((c) => c.toJson()).toList(),
      'isLiked': isLiked,
      'isSaved': isSaved,
    };
  }

  factory PostData.fromJson(Map<String, dynamic> json) {
    var commentsList = <Comment>[];
    if (json['comments'] != null && json['comments'] is List) {
      commentsList = (json['comments'] as List)
          .map((c) => Comment.fromJson(c as Map<String, dynamic>))
          .toList();
    }

    return PostData(
      userName: json['userName'],
      userAvatarUrl: json['userAvatarUrl'],
      location: json['location'],
      cardTitle: json['cardTitle'],
      cardSubtitle: json['cardSubtitle'],
      cardGradientStart: json['cardGradientStart'],
      cardGradientEnd: json['cardGradientEnd'],
      caption: json['caption'],
      likesCount: json['likesCount'],
      timeAgo: json['timeAgo'],
      comments: commentsList,
      isLiked: json['isLiked'] ?? false,
      isSaved: json['isSaved'] ?? false,
    );
  }
}

class Comment {
  final String userName;
  final String text;

  Comment({
    required this.userName,
    required this.text,
  });

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'text': text,
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      userName: json['userName'],
      text: json['text'],
    );
  }
}
