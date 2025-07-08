// lib/features/book_review/create_review_screen.dart
// 功能：提供介面讓用戶新增一篇讀書心得，並支援書籍封面圖片上傳。

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart'; // 引入圖片選擇器
import 'dart:io'; // 用於 File 類型
import 'package:flutter/foundation.dart' show kIsWeb; // 引入 kIsWeb 判斷是否為 Web 平台

import 'package:book_me_app/core/app_theme.dart'; // 引入主題設定
import 'package:book_me_app/features/auth/auth_controller.dart'; // 引入認證控制器
import 'package:book_me_app/features/book_review/book_review_controller.dart'; // 引入讀書心得控制器
import 'package:book_me_app/features/book_review/book_review.dart'; // 引入讀書心得模型的新路徑 (已扁平化)
import 'package:book_me_app/core/app_controller.dart'; // 引入 AppController

/// `CreateReviewScreen` 提供了一個表單介面，讓用戶可以輸入並發布新的讀書心得。
/// 該畫面將收集書籍資訊、心得內容和書籍封面圖片，並透過 `BookReviewController` 進行提交。
class CreateReviewScreen extends StatefulWidget {
  const CreateReviewScreen({super.key});

  @override
  State<CreateReviewScreen> createState() => _CreateReviewScreenState();
}

class _CreateReviewScreenState extends State<CreateReviewScreen> {
  final _formKey = GlobalKey<FormState>(); // 用於表單驗證的 Key
  final TextEditingController _bookTitleController = TextEditingController();
  final TextEditingController _bookAuthorController = TextEditingController();
  final TextEditingController _reviewContentController = TextEditingController();
  final TextEditingController _quotesController = TextEditingController(); // 暫時用一個欄位處理金句
  final TextEditingController _tagsController = TextEditingController(); // 暫時用一個欄位處理標籤

  final AuthController authController = Get.find<AuthController>();
  final BookReviewController bookReviewController = Get.find<BookReviewController>();

  XFile? _selectedXFile; // 用於儲存選擇的圖片 XFile，適用於 Web 和原生
  File? _selectedFile; // 僅用於原生平台 (File 類型)

  @override
  void dispose() {
    _bookTitleController.dispose();
    _bookAuthorController.dispose();
    _reviewContentController.dispose();
    _quotesController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  /// 處理圖片選擇。
  /// 允許用戶從相簿選擇圖片。
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery); // 從相簿選擇圖片

    if (image != null) {
      setState(() {
        _selectedXFile = image; // 儲存 XFile
        if (!kIsWeb) {
          _selectedFile = File(image.path); // 如果不是 Web，也儲存為 File 類型
        }
      });
    }
  }

  /// 處理提交讀書心得的邏輯。
  Future<void> _submitReview() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (authController.currentUser.value == null) {
        Get.snackbar('操作失敗', '請先登入才能發布讀書心得。', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      // 檢查是否有選擇圖片，並處理上傳
      String? bookCoverUrl;
      if (_selectedXFile != null) {
        bookReviewController.isLoading.value = true; // 顯示載入狀態
        bookCoverUrl = await bookReviewController.uploadBookCover(_selectedXFile!);
        if (bookCoverUrl == null) {
          Get.snackbar('上傳失敗', '書籍封面圖片上傳失敗，請重試。', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
          bookReviewController.isLoading.value = false;
          return;
        }
      }

      // 創建新的讀書心得物件
      final newReview = BookReview.createNew(
        userId: authController.currentUser.value!.uid,
        userName: authController.currentUser.value!.displayName ?? authController.currentUser.value!.email ?? '匿名用戶',
        userAvatarUrl: authController.currentUser.value!.photoURL,
        bookTitle: _bookTitleController.text.trim(),
        bookAuthor: _bookAuthorController.text.trim(),
        bookCoverUrl: bookCoverUrl, // 儲存圖片 URL
        reviewContent: _reviewContentController.text.trim(),
        quotes: _quotesController.text.trim().isNotEmpty ? _quotesController.text.split(',').map((s) => s.trim()).toList() : null,
        tags: _tagsController.text.trim().isNotEmpty ? _tagsController.text.split(',').map((s) => s.trim()).toList() : null,
        isPublic: true, // 預設為公開
      );

      await bookReviewController.addReview(newReview);

      if (bookReviewController.errorMessage.isEmpty) {
        // 提交成功後返回上一頁 (個人檔案頁面)
        Get.back();
        // 提交成功後，可以將底部導覽列切換到個人檔案頁面，讓用戶立即看到心得
        // 假設個人檔案頁面在底部導覽列的索引為 4
        Get.find<AppController>().changeTabIndex(4);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        title: Text('新增讀書心得', style: theme.textTheme.headlineSmall),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        // [移除] AppBar 中的儲存按鈕
        // actions: [
        //   Obx(() => IconButton(
        //     icon: bookReviewController.isLoading.value
        //         ? const CircularProgressIndicator(color: Colors.white)
        //         : Icon(Icons.check, color: theme.primaryColor),
        //     onPressed: bookReviewController.isLoading.value ? null : _submitReview,
        //   )),
        // ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('書籍封面 (選填)', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              // 圖片選擇區域
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: AppTheme.smartHomeNeumorphic(isConcave: true, radius: 15),
                  child: _selectedXFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: kIsWeb
                              ? Image.network(
                                  _selectedXFile!.path, // Web 上 XFile.path 是 blob:URL
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                )
                              : Image.file(
                                  _selectedFile!, // 原生上使用 File
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined, size: 50, color: theme.iconTheme.color?.withOpacity(0.6)),
                            const SizedBox(height: 10),
                            Text('點擊選擇書籍封面', style: theme.textTheme.bodyMedium),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 32),
              Text('書籍資訊', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              _buildInputField(
                controller: _bookTitleController,
                labelText: '書名',
                hintText: '輸入書籍標題',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '書名不能為空';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: _bookAuthorController,
                labelText: '作者',
                hintText: '輸入作者姓名',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '作者不能為空';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              Text('我的心得', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              _buildInputField(
                controller: _reviewContentController,
                labelText: '心得內容',
                hintText: '分享您的讀書心得、感想和啟發...',
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '心得內容不能為空';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: _quotesController,
                labelText: '金句摘錄 (選填)',
                hintText: '例如: "時間是最好的老師, 但卻燒死所有學生.", "生活就像一盒巧克力", 逗號分隔',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: _tagsController,
                labelText: '標籤 (選填)',
                hintText: '例如: 勵志, 學習, 思考, 逗號分隔',
              ),
              const SizedBox(height: 32),
              Obx(() => bookReviewController.errorMessage.isNotEmpty
                  ? Text(bookReviewController.errorMessage.value, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red))
                  : const SizedBox.shrink()),
              const SizedBox(height: 80), // 為了給底部按鈕留出空間
            ],
          ),
        ),
      ),
      // [新增] 底部固定按鈕
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).padding.bottom + 20, // 考慮安全區域
          top: 10,
        ),
        decoration: AppTheme.smartHomeNeumorphic(radius: 0), // 底部導覽列樣式
        child: Obx(() => SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: bookReviewController.isLoading.value ? null : _submitReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: bookReviewController.isLoading.value
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    '發布', // 按鈕文字改為「發布」
                    style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
          ),
        )),
      ),
    );
  }

  /// 輔助函數：建立通用的表單輸入欄位。
  Widget _buildInputField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final theme = context.theme;
    return Container(
      decoration: AppTheme.smartHomeNeumorphic(isConcave: true, radius: 15),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          labelStyle: theme.textTheme.bodyMedium,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
        ),
        style: theme.textTheme.bodyLarge,
        validator: validator,
      ),
    );
  }
}
