// lib/features/book_review/create_review_screen.dart
// [風格改造] 功能：新增讀書心得，採用分離式擬物化風格。

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:book_me_app/core/app_controller.dart';
import 'package:book_me_app/core/themes/i_app_theme.dart';
import 'package:book_me_app/features/auth/auth_controller.dart';
import 'package:book_me_app/features/book_review/book_review_controller.dart';
import 'package:book_me_app/features/book_review/book_review.dart';

class CreateReviewScreen extends StatefulWidget {
  const CreateReviewScreen({super.key});
  @override
  State<CreateReviewScreen> createState() => _CreateReviewScreenState();
}

class _CreateReviewScreenState extends State<CreateReviewScreen> {
  // --- Controllers and Keys (保持不變) ---
  final _formKey = GlobalKey<FormState>();
  final _bookTitleController = TextEditingController();
  final _bookAuthorController = TextEditingController();
  final _reviewContentController = TextEditingController();
  final authController = Get.find<AuthController>();
  final bookReviewController = Get.find<BookReviewController>();
  final appController = Get.find<AppController>();
  XFile? _selectedXFile;
  File? _selectedFile;

  @override
  void dispose() { /* ... 保持不變 ... */ }

  Future<void> _pickImage() async { /* ... 保持不變 ... */ }
  Future<void> _submitReview() async { /* ... 保持不變 ... */ }

  @override
  Widget build(BuildContext context) {
    final IAppTheme theme = appController.currentTheme.value;

    return Scaffold(
      backgroundColor: theme.primaryBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.primaryBackgroundColor,
        elevation: 0,
        title: Text('新增讀書心得', style: theme.themeData.textTheme.headlineSmall),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text('書籍封面 (選填)', style: theme.themeData.textTheme.titleLarge),
                    const SizedBox(height: 16),
                    _buildImagePicker(theme),
                    const SizedBox(height: 32),
                    Text('書籍資訊', style: theme.themeData.textTheme.titleLarge),
                    const SizedBox(height: 16),
                    _buildInputField(theme, controller: _bookTitleController, labelText: '書名'),
                    const SizedBox(height: 16),
                    _buildInputField(theme, controller: _bookAuthorController, labelText: '作者'),
                    const SizedBox(height: 32),
                    Text('我的心得', style: theme.themeData.textTheme.titleLarge),
                    const SizedBox(height: 16),
                    _buildInputField(theme, controller: _reviewContentController, labelText: '分享您的啟發...', maxLines: 8),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            _buildBottomBar(theme),
          ],
        ),
      ),
    );
  }

  // [改造] 圖片選擇器
  Widget _buildImagePicker(IAppTheme theme) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: theme.neumorphicBoxDecoration(
            isConcave: true, radius: 20, color: theme.primaryBackgroundColor),
        child: _selectedXFile != null
            ? ClipRRect( /* ... Image display logic remains the same ... */ )
            : Column( /* ... Placeholder logic remains the same ... */ ),
      ),
    );
  }

  // [改造] 底部發布按鈕區域
  Widget _buildBottomBar(IAppTheme theme) {
    return Container(
      padding: EdgeInsets.only(
        left: 20, right: 20, bottom: MediaQuery.of(context).padding.bottom + 20, top: 10,
      ),
      decoration: BoxDecoration(color: theme.primaryBackgroundColor),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: bookReviewController.isLoading.value ? null : _submitReview,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: Ink(
            decoration: theme.neumorphicBoxDecoration(
              radius: 20,
              color: theme.themeData.primaryColor,
              gradient: LinearGradient(
                  colors: [theme.themeData.primaryColor, const Color(0xFF6A95FF)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight)),
            child: Center(
              child: Obx(() => bookReviewController.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('發布心得', style: theme.themeData.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold))),
            ),
          ),
        ),
      ),
    );
  }

  // [改造] 輸入框
  Widget _buildInputField(IAppTheme theme, {required TextEditingController controller, required String labelText, int maxLines = 1}) {
    return Container(
      decoration: theme.neumorphicBoxDecoration(isConcave: true, radius: 15, color: theme.primaryBackgroundColor),
      child: TextFormField(
        controller: controller, maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText, border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          labelStyle: theme.themeData.textTheme.bodyMedium),
        style: theme.themeData.textTheme.bodyLarge,
        validator: (v) => (v == null || v.isEmpty) ? '$labelText不能為空' : null,
      ),
    );
  }
}