import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../models/features.dart';
import '../providers/user_provider.dart';
import 'premium_screen.dart';

class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E2A) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('Все возможности'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero-секция
            _buildHeroSection(context, userProvider),
            
            // Категории с фичами
            ...FeaturesCatalog.categories.entries.map((entry) {
              final category = entry.key;
              final categoryName = entry.value;
              final features = FeaturesCatalog.getByCategory(category);
              
              return _buildCategorySection(
                context: context,
                categoryName: categoryName,
                features: features,
                userProvider: userProvider,
              );
            }),
            
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, UserProvider userProvider) {
    return Container(
      padding: EdgeInsets.all(24.w),
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '🚀 30+ уникальных функций',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '${FeaturesCatalog.getFreeFeatures().length} бесплатно • ${FeaturesCatalog.getPremiumFeatures().length} в Premium',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16.sp,
            ),
          ),
          if (!userProvider.isPremium) ...[
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PremiumScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF4F46E5),
              ),
              child: const Text('Разблокировать всё'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategorySection({
    required BuildContext context,
    required String categoryName,
    required List<AppFeature> features,
    required UserProvider userProvider,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 16.h),
          child: Text(
            categoryName,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...features.map((feature) => _buildFeatureTile(context, feature, userProvider)),
      ],
    );
  }

  Widget _buildFeatureTile(BuildContext context, AppFeature feature, UserProvider userProvider) {
    final isLocked = feature.tier == FeatureTier.premium && !userProvider.isPremium;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: feature.isHighlighted 
              ? const Color(0xFF4F46E5).withOpacity(0.3) 
              : Colors.grey.withOpacity(0.1),
        ),
        boxShadow: feature.isHighlighted ? [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Иконка
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: isLocked 
                  ? Colors.grey.withOpacity(0.1) 
                  : const Color(0xFF4F46E5).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                feature.icon,
                style: TextStyle(fontSize: 24.sp),
              ),
            ),
          ),
          
          SizedBox(width: 16.w),
          
          // Контент
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        feature.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: isLocked ? Colors.grey : null,
                        ),
                      ),
                    ),
                    if (isLocked)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'PREMIUM',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (feature.tier == FeatureTier.enterprise)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3A5F),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'БИЗНЕС',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  feature.description,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}