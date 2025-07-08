// lib/features/book_review/book_review_controller.dart
// 功能：管理讀書心得相關的邏輯和資料操作，現在主要協調數據流和 UI 狀態。

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:flutter/material.dart'; // 引入 Material，解決 Colors 錯誤

import 'package:book_me_app/features/book_review/book_review.dart';
import 'package:book_me_app/features/book_review/comment.dart';
import 'package:book_me_app/features/book_review/book_review_service.dart'; // 引入讀書心得服務
import 'package:book_me_app/features/auth/auth_controller.dart'; // 引入 AuthController

/// `BookReviewController` 負責管理應用程式中的讀書心得資料，並協調 UI 狀態。
/// 它現在通過 `BookReviewService` 與 Firestore 互動，並使用即時監聽來同步數據。
class BookReviewController extends GetxController {
  final BookReviewService _bookReviewService = Get.find<BookReviewService>(); // 注入服務
  final AuthController _authController = Get.find<AuthController>(); // 注入 AuthController
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth 實例

  final RxList<BookReview> publicBookReviews = <BookReview>[].obs; // 所有公開的心得
  final RxList<BookReview> userBookReviews = <BookReview>[].obs; // 當前用戶的心得
  final RxList<Comment> currentReviewComments = <Comment>[].obs; // 特定心得的留言

  final RxBool isLoading = false.obs; // 通用載入狀態
  final RxString errorMessage = ''.obs; // 錯誤訊息

  StreamSubscription<List<BookReview>>? _publicReviewsSubscription; // 公開心得訂閱
  StreamSubscription<List<BookReview>>? _userReviewsSubscription; // 用戶心得訂閱
  StreamSubscription<List<Comment>>? _commentsSubscription; // 留言訂閱
  StreamSubscription<User?>? _authStateSubscription; // 認證狀態訂閱

  @override
  void onInit() {
    super.onInit();
    // 監聽 Firebase Auth 的狀態變化，並根據登入狀態管理用戶心得的監聽
    _authStateSubscription = _auth.authStateChanges().listen((user) {
      if (user != null) {
        startUserReviewsListener(user.uid); // 如果用戶登入，則開始監聽自己的心得
      } else {
        stopUserReviewsListener(); // 如果用戶登出，則停止監聽並清空列表
      }
    });

    // 開始監聽所有公開心得
    startPublicReviewsListener();
  }

  @override
  void onClose() {
    _publicReviewsSubscription?.cancel();
    _userReviewsSubscription?.cancel();
    _commentsSubscription?.cancel();
    _authStateSubscription?.cancel();
    super.onClose();
  }

  /// 清空當前讀書心得的留言列表。
  /// 在離開心得詳情頁時呼叫，避免舊數據殘留和潛在的 setState() called after dispose() 錯誤。
  void clearCurrentReviewComments() {
    currentReviewComments.clear();
    print('已清空當前心得的留言列表。');
  }

  /// [優化] 開始監聽所有公開的讀書心得。
  void startPublicReviewsListener() {
    isLoading.value = true; // 開始載入
    _publicReviewsSubscription?.cancel(); // 先取消舊的訂閱
    _publicReviewsSubscription = _bookReviewService.getPublicBookReviewsStream().listen(
      (reviews) {
        publicBookReviews.assignAll(reviews); // 即時更新列表
        print('即時更新了 ${reviews.length} 篇公開心得。');
        // [修正] 將 isLoading.value = false; 的賦值操作推遲到下一幀
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (isLoading.value == true) { // 避免重複設置，或在已載入完成後再次設置
             isLoading.value = false;
          }
        });
      },
      onError: (error) {
        errorMessage.value = '讀取公開心得失敗: $error';
        print('Firebase 錯誤 (即時讀取公開心得): $error');
        Get.snackbar(
          '錯誤',
          '載入公開心得失敗，請稍後再試。',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
        // [修正] 錯誤時也要將 isLoading 設為 false
        WidgetsBinding.instance.addPostFrameCallback((_) {
          isLoading.value = false;
        });
      },
    );
  }

  /// [優化] 開始監聽指定用戶的讀書心得。
  /// @param userId - 要監聽心得的用戶 ID。
  void startUserReviewsListener(String userId) {
    isLoading.value = true; // 開始載入
    _userReviewsSubscription?.cancel(); // 先取消舊的訂閱
    _userReviewsSubscription = _bookReviewService.getUserBookReviewsStream(userId).listen(
      (reviews) {
        userBookReviews.assignAll(reviews); // 即時更新列表
        print('即時更新了用戶 $userId 的 ${reviews.length} 篇心得。');
        // [修正] 將 isLoading.value = false; 的賦值操作推遲到下一幀
        WidgetsBinding.instance.addPostFrameCallback((_) {
           if (isLoading.value == true) {
             isLoading.value = false;
           }
        });
      },
      onError: (error) {
        errorMessage.value = '讀取用戶心得失敗: $error';
        print('Firebase 錯誤 (即時讀取用戶心得): $error');
        Get.snackbar(
          '錯誤',
          '載入用戶心得失敗，請稍後再試。',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
        // [修正] 錯誤時也要將 isLoading 設為 false
        WidgetsBinding.instance.addPostFrameCallback((_) {
          isLoading.value = false;
        });
      },
    );
  }

  /// 停止監聽用戶心得並清空列表。
  void stopUserReviewsListener() {
    _userReviewsSubscription?.cancel();
    userBookReviews.clear();
    print('已停止監聽用戶心得並清空列表。');
  }

  /// [優化] 開始監聽某篇心得的所有留言。
  /// @param reviewId - 要監聽留言的心得 ID。
  void startCommentsListener(String reviewId) {
    isLoading.value = true; // 開始載入
    _commentsSubscription?.cancel(); // 先取消舊的訂閱
    _commentsSubscription = _bookReviewService.getCommentsStream(reviewId).listen(
      (comments) {
        currentReviewComments.assignAll(comments); // 即時更新列表
        print('即時更新了心得 $reviewId 的 ${comments.length} 則留言。');
        // [修正] 將 isLoading.value = false; 的賦值操作推遲到下一幀
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (isLoading.value == true) {
             isLoading.value = false;
          }
        });
      },
      onError: (error) {
        errorMessage.value = '讀取留言失敗: $error';
        print('Firebase 錯誤 (即時讀取留言): $error');
        Get.snackbar(
          '錯誤',
          '載入留言失敗，請稍後再試。',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
        // [修正] 錯誤時也要將 isLoading 設為 false
        WidgetsBinding.instance.addPostFrameCallback((_) {
          isLoading.value = false;
        });
      },
    );
  }

  /// 停止監聽某篇心得的留言並清空列表。
  void stopCommentsListener() {
    _commentsSubscription?.cancel();
    currentReviewComments.clear();
    print('已停止監聽留言並清空列表。');
  }

  /// 上傳書籍封面圖片到 Firebase Storage。
  /// @param imageFile - 要上傳的圖片檔案 (XFile 類型)。
  /// @returns 圖片的下載 URL，如果上傳失敗則為 null。
  Future<String?> uploadBookCover(XFile imageXFile) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final currentUserUid = _auth.currentUser?.uid;
      if (currentUserUid == null) {
        Get.snackbar('錯誤', '用戶未登入，無法上傳圖片。', snackPosition: SnackPosition.BOTTOM, backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
        return null;
      }
      final downloadUrl = await _bookReviewService.uploadBookCover(imageXFile, currentUserUid);
      if (downloadUrl == null) {
        throw Exception('圖片上傳失敗。');
      }
      return downloadUrl;
    } catch (e) {
      errorMessage.value = '圖片上傳失敗: ${e.toString()}';
      Get.snackbar('錯誤', '圖片上傳失敗，請稍後再試。', snackPosition: SnackPosition.BOTTOM, backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// 新增一篇讀書心得。
  /// @param bookReview - 待新增的讀書心得物件。
  Future<void> addReview(BookReview bookReview) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      if (_auth.currentUser == null) {
        Get.snackbar('錯誤', '用戶未登入，無法新增心得。', snackPosition: SnackPosition.BOTTOM, backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
        return;
      }
      final newReviewWithId = await _bookReviewService.addReview(bookReview);
      if (newReviewWithId == null) {
        throw Exception('新增心得失敗。');
      }
      // 因為現在是即時監聽，數據會自動更新到 publicBookReviews 和 userBookReviews 列表中，
      // 所以這裡不需要手動 insert 了。
      Get.snackbar('成功', '您的讀書心得已成功發布！', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage.value = '新增心得失敗: ${e.toString()}';
      Get.snackbar('錯誤', '新增心得失敗，請稍後再試。', snackPosition: SnackPosition.BOTTOM, backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
    } finally {
      isLoading.value = false;
    }
  }

  /// 按讚/取消按讚功能。
  /// @param review - 要操作的讀書心得物件。
  /// @param userId - 當前操作的用戶 ID。
  Future<void> toggleLike(BookReview review, String userId) async {
    if (userId.isEmpty) {
      Get.snackbar('提示', '請先登入才能按讚。', snackPosition: SnackPosition.BOTTOM, backgroundColor: Get.theme.colorScheme.secondary, colorText: Get.theme.colorScheme.onSecondary);
      return;
    }
    // isLoading.value = true; // 按讚操作不顯示全屏 loading，而是局部 loading 或只顯示 UI 變化
    errorMessage.value = '';
    try {
      final success = await _bookReviewService.toggleLike(review.id, userId, !review.likedBy.contains(userId));
      if (success != null) {
        Get.snackbar('成功', review.likedBy.contains(userId) ? '您已取消對這篇心得的讚。' : '您已喜歡這篇心得！', snackPosition: SnackPosition.BOTTOM);
        // 由於使用即時監聽，列表會自動更新，無需手動修改 publicBookReviews/userBookReviews
      } else {
        throw Exception('按讚操作失敗。');
      }
    } catch (e) {
      errorMessage.value = '更新按讚失敗: ${e.toString()}';
      Get.snackbar('錯誤', '更新按讚失敗，請稍後再試。', snackPosition: SnackPosition.BOTTOM, backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
    } finally {
      // isLoading.value = false;
    }
  }

  /// 新增留言。
  /// @param reviewId - 留言所屬的心得 ID。
  /// @param content - 留言內容。
  Future<void> addComment(String reviewId, String content) async {
    final currentUser = _authController.currentUser.value;
    final currentAppUser = _authController.currentAppUser.value;

    if (currentUser == null || currentAppUser == null || content.trim().isEmpty) {
      Get.snackbar('錯誤', '留言內容不能為空或用戶未登入。', snackPosition: SnackPosition.BOTTOM, backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
      return;
    }
    
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final newComment = Comment.createNew(
        reviewId: reviewId,
        userId: currentUser.uid,
        userName: currentAppUser.userName,
        userAvatarUrl: currentAppUser.userAvatarUrl,
        content: content,
      );
      final addedCommentWithId = await _bookReviewService.addComment(reviewId, newComment);
      if (addedCommentWithId == null) {
        throw Exception('新增留言失敗。');
      }
      // 因為現在是即時監聽，留言列表會自動更新
      Get.snackbar('成功', '您的留言已發布！', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage.value = '新增留言失敗: ${e.toString()}';
      Get.snackbar('錯誤', '新增留言失敗，請稍後再試。', snackPosition: SnackPosition.BOTTOM, backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
    } finally {
      isLoading.value = false;
    }
  }
}