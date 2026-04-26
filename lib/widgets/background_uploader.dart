import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../screens/premium_screen.dart';

class BackgroundUploader extends StatefulWidget {
  final Function(String imagePath) onImageSelected;

  const BackgroundUploader({super.key, required this.onImageSelected});

  @override
  State<BackgroundUploader> createState() => _BackgroundUploaderState();
}

class _BackgroundUploaderState extends State<BackgroundUploader> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  double _darkness = 0.3;
  double _blur = 0.0;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      
      if (image != null) {
        setState(() => _selectedImage = File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось загрузить изображение')),
        );
      }
    }
  }

  void _applyBackground() {
    if (_selectedImage != null) {
      widget.onImageSelected(_selectedImage!.path);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    
    if (!userProvider.isPremium) {
      return _buildPremiumRequired();
    }
    
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Загрузить свой фон', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          
          SizedBox(height: 20.h),
          
          // Источник изображения
          Row(
            children: [
              Expanded(
                child: _buildOptionCard(
                  icon: Icons.photo_library,
                  title: 'Галерея',
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildOptionCard(
                  icon: Icons.camera_alt,
                  title: 'Камера',
                  onTap: () => _pickImage(ImageSource.camera),
                ),
              ),
            ],
          ),
          
          // Предпросмотр
          if (_selectedImage != null) ...[
            SizedBox(height: 20.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Image.file(
                    _selectedImage!,
                    height: 200.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    height: 200.h,
                    width: double.infinity,
                    color: Colors.black.withOpacity(_darkness),
                  ),
                  if (_blur > 0)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _selectedImage!,
                        height: 200.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        color: Colors.black.withOpacity(0.3),
                        colorBlendMode: BlendMode.darken,
                      ),
                    ),
                  Center(
                    child: Text(
                      'Предпросмотр текста',
                      style: TextStyle(
                        color: _darkness > 0.5 ? Colors.white : Colors.black,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // Затемнение
            Text('Затемнение: ${(_darkness * 100).toInt()}%'),
            Slider(
              value: _darkness,
              min: 0,
              max: 0.8,
              onChanged: (value) => setState(() => _darkness = value),
            ),
            
            // Размытие
            Text('Размытие: ${(_blur * 10).toInt()}%'),
            Slider(
              value: _blur,
              min: 0,
              max: 5,
              onChanged: (value) => setState(() => _blur = value),
            ),
            
            SizedBox(height: 20.h),
            
            // Кнопка применить
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyBackground,
                child: const Text('Применить фон'),
              ),
            ),
          ],
          
          SizedBox(height: 16.h),
          
          Text(
            'Поддерживаются JPG, PNG, HEIC\nРекомендуемый размер: 1920×1080',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40.sp, color: const Color(0xFF4F46E5)),
            SizedBox(height: 8.h),
            Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumRequired() {
    return Container(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock, size: 48.sp, color: Colors.amber[700]),
          SizedBox(height: 16.h),
          const Text(
            'Premium функция',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Text(
            'Загрузка своего фона доступна только в Premium версии',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen()));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
            child: const Text('Перейти на Premium'),
          ),
        ],
      ),
    );
  }
}