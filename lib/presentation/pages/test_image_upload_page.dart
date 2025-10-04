import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme_helper.dart';

class TestImageUploadPage extends StatefulWidget {
  const TestImageUploadPage({super.key});

  @override
  State<TestImageUploadPage> createState() => _TestImageUploadPageState();
}

class _TestImageUploadPageState extends State<TestImageUploadPage> {
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images.map((xFile) => File(xFile.path)));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking images: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Image Upload'),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: AppThemeHelper.getBackgroundGradientDecoration(context),
        child: Padding(
          padding: AppThemeHelper.getStandardPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: AppThemeHelper.getCardPadding(context),
                decoration: AppThemeHelper.getCardDecoration(context),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_upload,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: AppThemeHelper.smallSpacing),
                    Text(
                      'Image Upload Test',
                      style: AppThemeHelper.getHeadlineStyle(context),
                    ),
                    const SizedBox(height: AppThemeHelper.tinySpacing),
                    Text(
                      'Test the image upload functionality',
                      style: AppThemeHelper.getBodyStyle(context),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppThemeHelper.standardSpacing),
              
              // Image Picker Button
              Container(
                padding: AppThemeHelper.getCardPadding(context),
                decoration: AppThemeHelper.getCardDecoration(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Images',
                      style: AppThemeHelper.getTitleStyle(context),
                    ),
                    const SizedBox(height: AppThemeHelper.smallSpacing),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _pickImages,
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text('Pick Images'),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppThemeHelper.standardSpacing),
              
              // Selected Images Preview
              if (_selectedImages.isNotEmpty) ...[
                Container(
                  padding: AppThemeHelper.getCardPadding(context),
                  decoration: AppThemeHelper.getCardDecoration(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Images (${_selectedImages.length})',
                        style: AppThemeHelper.getTitleStyle(context),
                      ),
                      const SizedBox(height: AppThemeHelper.smallSpacing),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(right: AppThemeHelper.smallSpacing),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _selectedImages[index],
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedImages.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppThemeHelper.standardSpacing),
                
                // Upload Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Handle upload logic here
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Upload functionality would be implemented here'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.upload),
                    label: const Text('Upload Images'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 