// lib/features/book_review/book_review_service.dart
// 功能：處理與 Firestore 'bookReviews' 集合及其子集合相關的數據操作。

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:book_me_app/features/book_review/book_review.dart';
import 'package:book_me_app/features/book_review/comment.dart';

/// `BookReviewService` 提供了與讀書心得及其留言在 Firestore 和 Storage 互動的數據庫操作。
class BookReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// 上傳書籍封面圖片到 Firebase Storage。
  /// @param imageXFile - 要上傳的圖片檔案 (XFile 類型)。
  /// @param userId - 上傳用戶的 ID。
  /// @returns 圖片的下載 URL，如果上傳失敗則為 null。
  Future<String?> uploadBookCover(XFile imageXFile, String userId) async {
    try {
      final String fileName = 'book_covers/${userId}/${DateTime.now().millisecondsSinceEpoch}_${imageXFile.name}';

      UploadTask uploadTask;
      if (kIsWeb) {
        final bytes = await imageXFile.readAsBytes();
        uploadTask = _storage.ref().child(fileName).putData(bytes);
      } else {
        uploadTask = _storage.ref().child(fileName).putFile(File(imageXFile.path));
      }
      
      final TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      print('圖片上傳成功，URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('圖片上傳失敗: $e');
      return null;
    }
  }

  /// 新增一篇讀書心得。
  /// @param bookReview - 待新增的讀書心得物件。
  /// @returns 新增的心得物件 (包含 Firestore 生成的 ID)，如果失敗則為 null。
  Future<BookReview?> addReview(BookReview bookReview) async {
    try {
      final docRef = await _firestore.collection('bookReviews').add(bookReview.toJson());
      final newReviewWithId = bookReview.copyWith(id: docRef.id);
      return newReviewWithId;
    } catch (e) {
      print('新增心得失敗: $e');
      return null;
    }
  }

  /// 獲取所有公開的讀書心得的即時數據流。
  /// @returns 包含所有公開心得的 Stream。
  Stream<List<BookReview>> getPublicBookReviewsStream() {
    return _firestore
        .collection('bookReviews')
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots() // 使用 snapshots 獲取即時更新
        .map((snapshot) => snapshot.docs.map((doc) => BookReview.fromDocument(doc)).toList());
  }

  /// 獲取指定用戶的所有讀書心得的即時數據流。
  /// @param userId - 用戶 ID。
  /// @returns 包含指定用戶所有心得的 Stream。
  Stream<List<BookReview>> getUserBookReviewsStream(String userId) {
    return _firestore
        .collection('bookReviews')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots() // 使用 snapshots 獲取即時更新
        .map((snapshot) => snapshot.docs.map((doc) => BookReview.fromDocument(doc)).toList());
  }

  /// 更新讀書心得的按讚狀態。
  /// @param reviewId - 心得 ID。
  /// @param userId - 操作用戶 ID。
  /// @param isLiking - 如果為 true 表示按讚，false 表示取消按讚。
  /// @returns 更新後的心得物件，如果失敗則為 null。
  Future<BookReview?> toggleLike(String reviewId, String userId, bool isLiking) async {
    final DocumentReference reviewRef = _firestore.collection('bookReviews').doc(reviewId);

    try {
      BookReview? updatedReview;
      await _firestore.runTransaction((transaction) async {
        final DocumentSnapshot reviewSnapshot = await transaction.get(reviewRef);

        if (!reviewSnapshot.exists) {
          throw Exception("讀書心得不存在。");
        }

        BookReview currentReview = BookReview.fromDocument(reviewSnapshot);
        List<String> currentLikedBy = List.from(currentReview.likedBy);
        int currentLikesCount = currentReview.likesCount;

        if (isLiking) { // 如果是按讚
          if (!currentLikedBy.contains(userId)) {
            currentLikedBy.add(userId);
            currentLikesCount++;
          }
        } else { // 如果是取消按讚
          if (currentLikedBy.contains(userId)) {
            currentLikedBy.remove(userId);
            currentLikesCount--;
          }
        }

        updatedReview = currentReview.copyWith(
          likesCount: currentLikesCount,
          likedBy: currentLikedBy,
          updatedAt: DateTime.now(),
        );

        transaction.update(reviewRef, {
          'likesCount': updatedReview!.likesCount,
          'likedBy': updatedReview!.likedBy,
          'updatedAt': Timestamp.now(),
        });
      });
      return updatedReview;
    } catch (e) {
      print('更新按讚失敗: $e');
      return null;
    }
  }

  /// 新增留言。
  /// @param reviewId - 留言所屬的心得 ID。
  /// @param comment - 待新增的留言物件 (不含 ID)。
  /// @returns 新增的留言物件 (包含 Firestore 生成的 ID)，如果失敗則為 null。
  Future<Comment?> addComment(String reviewId, Comment comment) async {
    final DocumentReference reviewRef = _firestore.collection('bookReviews').doc(reviewId);

    try {
      Comment? addedCommentWithId;
      await _firestore.runTransaction((transaction) async {
        // 1. 新增留言到子集合
        final commentDocRef = await reviewRef.collection('comments').add(comment.toJson());
        addedCommentWithId = comment.copyWith(id: commentDocRef.id);

        // 2. 更新心得主文件的 commentsCount
        final DocumentSnapshot reviewSnapshot = await transaction.get(reviewRef);
        if (!reviewSnapshot.exists) {
          throw Exception("讀書心得不存在，無法新增留言。");
        }
        int currentCommentsCount = (reviewSnapshot.data() as Map<String, dynamic>)['commentsCount'] ?? 0;
        transaction.update(reviewRef, {
          'commentsCount': currentCommentsCount + 1,
          'updatedAt': Timestamp.now(),
        });
      });
      return addedCommentWithId;
    } catch (e) {
      print('新增留言失敗: $e');
      return null;
    }
  }

  /// 獲取某篇心得所有留言的即時數據流。
  /// @param reviewId - 要讀取留言的心得 ID。
  /// @returns 包含所有留言的 Stream。
  Stream<List<Comment>> getCommentsStream(String reviewId) {
    return _firestore
        .collection('bookReviews')
        .doc(reviewId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots() // 使用 snapshots 獲取即時更新
        .map((snapshot) => snapshot.docs.map((doc) => Comment.fromDocument(doc)).toList());
  }
}