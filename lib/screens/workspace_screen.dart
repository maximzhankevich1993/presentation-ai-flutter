import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/workspace_service.dart';

class WorkspaceScreen extends StatelessWidget {
  const WorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF1E1E2A) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('Команда'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showInviteDialog(context),
            icon: const Icon(Icons.person_add),
            tooltip: 'Пригласить',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Участники',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 16.h),

            ...WorkspaceService.getTeamMembers().map((user) {
              final color = _safeColor(user.avatarColor);

              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: color,
                      radius: 24.r,
                      child: Text(
                        user.name.isNotEmpty
                            ? user.name[0]
                            : '?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(width: 16.w),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color:
                            _roleColor(user.role).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _roleText(user.role),
                        style: TextStyle(
                          color: _roleColor(user.role),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            SizedBox(height: 32.h),

            Text(
              'Общие презентации',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 16.h),

            ...WorkspaceService.getSharedPresentations()
                .map((p) {
              return GestureDetector(
                onTap: () {
                  // можно открыть презентацию
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48.w,
                        height: 48.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5)
                              .withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.insert_drive_file,
                          color: Color(0xFF4F46E5),
                        ),
                      ),

                      SizedBox(width: 16.w),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.title ?? 'Без названия',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '${p.ownerName ?? 'unknown'} • ${p.slideCount ?? 0} слайдов',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              );
            }),

            if (!userProvider.isPremium) ...[
              SizedBox(height: 32.h),

              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFF59E0B)
                          .withOpacity(0.1),
                      const Color(0xFFD97706)
                          .withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFF59E0B)
                        .withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B)
                            .withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.crown,
                        color: Color(0xFFF59E0B),
                      ),
                    ),

                    SizedBox(width: 16.w),

                    Expanded(
                      child: Text(
                        'Командная работа доступна в Premium',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),

                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFF59E0B),
                      ),
                      child: const Text('Premium'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _safeColor(String? color) {
    try {
      if (color == null || color.isEmpty) {
        return Colors.grey;
      }
      return Color(
        int.parse(color.replaceFirst('#', '0xFF')),
      );
    } catch (_) {
      return Colors.grey;
    }
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'owner':
        return const Color(0xFF6366f1);
      case 'editor':
        return const Color(0xFF10b981);
      case 'viewer':
        return const Color(0xFFf59e0b);
      default:
        return Colors.grey;
    }
  }

  String _roleText(String role) {
    switch (role) {
      case 'owner':
        return 'Владелец';
      case 'editor':
        return 'Редактор';
      case 'viewer':
        return 'Зритель';
      default:
        return role;
    }
  }

  void _showInviteDialog(BuildContext context) {
    final inviteLink =
        WorkspaceService.generateInviteLink('workspace-1');

    void copyLink() {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ссылка скопирована')),
      );
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Пригласить в команду'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Отправьте эту ссылку:',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                inviteLink,
                style: TextStyle(fontSize: 12.sp),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
          ElevatedButton(
            onPressed: () {
              copyLink();
              Navigator.pop(context);
            },
            child: const Text('Копировать'),
          ),
        ],
      ),
    );
  }
}