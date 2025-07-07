// lib/features/book_review/book_review_controller.dart
// 功能：管理讀書心得相關的邏輯和資料操作，包含圖片上傳。

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; // 引入 Firebase Storage
import 'dart:io'; // 用於 File 類型
import 'dart:async'; // [新增] 引入 StreamSubscription

import 'package:book_me_app/models/book_review.dart'; // 引入讀書心得模型

/// `BookReviewController` 負責管理應用程式中的讀書心得資料。
/// 它提供了新增心得、讀取指定用戶心得等功能，並與 Firebase Firestore 和 Storage 互動。
class BookReviewController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore 實例
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth 實例
  final FirebaseStorage _storage = FirebaseStorage.instance; // Firebase Storage 實例

  // 當前用戶發布的讀書心得列表
  // 使用 RxList 讓 UI 可以響應式地監聽變化
  final RxList<BookReview> userBookReviews = <BookReview>[].obs;

  final RxBool isLoading = false.obs; // 讀取數據時的載入狀態或圖片上傳時的載入狀態
  final RxString errorMessage = ''.obs; // 錯誤訊息

  StreamSubscription<User?>? _authStateSubscription; // [新增] 用於監聽認證狀態變化的訂閱

  @override
  void onInit() {
    super.onInit();
    // [修正] 使用 listen 監聽 Firebase Auth 的狀態變化
    _authStateSubscription = _auth.authStateChanges().listen((user) {
      if (user != null) {
        fetchUserBookReviews(user.uid); // 如果用戶登入，則載入心得
      } else {
        userBookReviews.clear(); // 如果用戶登出，則清空心得列表
      }
    });
  }

  @override
  void onClose() {
    _authStateSubscription?.cancel(); // [新增] 在控制器關閉時取消訂閱，防止記憶體洩漏
    super.onClose();
  }

  /// 上傳書籍封面圖片到 Firebase Storage。
  /// @param imageFile - 要上傳的圖片檔案。
  /// @returns 圖片的下載 URL，如果上傳失敗則為 null。
  Future<String?> uploadBookCover(File imageFile) async {
    try {
      if (_auth.currentUser == null) {
        throw Exception('用戶未登入，無法上傳圖片。');
      }

      final String userId = _auth.currentUser!.uid;
      // 確保檔名唯一，避免覆蓋
      final String fileName = 'book_covers/${userId}/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}'; 

      final uploadTask = _storage.ref().child(fileName).putFile(imageFile); // 建立上傳任務
      final TaskSnapshot snapshot = await uploadTask.whenComplete(() {}); // 等待上傳完成
      
      final String downloadUrl = await snapshot.ref.getDownloadURL(); // 獲取圖片的下載 URL
      print('圖片上傳成功，URL: $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (e) {
      errorMessage.value = '圖片上傳失敗: ${e.message}';
      print('Firebase 錯誤 (圖片上傳): ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      errorMessage.value = '圖片上傳失敗: ${e.toString()}';
      print('未知錯誤 (圖片上傳): ${e.toString()}');
      return null;
    }
  }

  /// 新增一篇讀書心得。
  /// @param bookReview - 待新增的讀書心得物件 (其中 id 欄位為空)。
  Future<void> addReview(BookReview bookReview) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      if (_auth.currentUser == null) {
        throw Exception('用戶未登入，無法新增心得。');
      }

      // 將心得儲存到 Firestore 的 'bookReviews' 集合中
      // 使用 add 方法讓 Firestore 自動生成文件 ID
      final docRef = await _firestore.collection('bookReviews').add(bookReview.toJson());
      
      // 更新心得的 ID 為 Firestore 生成的 ID
      final newReview = BookReview(
        id: docRef.id,
        userId: bookReview.userId,
        userName: bookReview.userName,
        userAvatarUrl: bookReview.userAvatarUrl,
        bookTitle: bookReview.bookTitle,
        bookAuthor: bookReview.bookAuthor,
        bookCoverUrl: bookReview.bookCoverUrl, // 確保包含圖片 URL
        reviewContent: bookReview.reviewContent,
        quotes: bookReview.quotes,
        tags: bookReview.tags,
        isPublic: bookReview.isPublic,
        likesCount: bookReview.likesCount,
        likedBy: bookReview.likedBy,
        commentsCount: bookReview.commentsCount,
        createdAt: bookReview.createdAt,
        updatedAt: bookReview.updatedAt,
      );

      // 將新增的心得插入到列表的開頭，以便立即在 UI 中看到
      userBookReviews.insert(0, newReview);

      Get.snackbar('新增成功', '您的讀書心得已成功發布！', snackPosition: SnackPosition.BOTTOM);
    } on FirebaseException catch (e) {
      errorMessage.value = '新增心得失敗: ${e.message}';
      print('Firebase 錯誤 (新增心得): ${e.code} - ${e.message}');
    } catch (e) {
      errorMessage.value = '新增心得失敗: ${e.toString()}';
      print('未知錯誤 (新增心得): ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  /// 讀取指定用戶的所有讀書心得。
  /// @param userId - 要讀取心得的用戶 ID。
  Future<void> fetchUserBookReviews(String userId) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      // 從 Firestore 讀取指定用戶的所有心得，並按創建時間降序排列
      final querySnapshot = await _firestore
          .collection('bookReviews')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true) // 最新心得顯示在前面
          .get();

      // 將讀取到的文件轉換為 BookReview 物件列表
      final reviews = querySnapshot.docs.map((doc) => BookReview.fromDocument(doc)).toList();
      userBookReviews.assignAll(reviews); // 更新可觀察列表

      print('成功讀取用戶 $userId 的 ${reviews.length} 篇心得。');
    } on FirebaseException catch (e) {
      errorMessage.value = '讀取心得失敗: ${e.message}';
      print('Firebase 錯誤 (讀取心得): ${e.code} - ${e.message}');
    } catch (e) {
      errorMessage.value = '讀取心得失敗: ${e.toString()}';
      print('未知錯誤 (讀取心得): ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // TODO: 未來可添加更新、刪除心得、按讚、留言等方法
}
