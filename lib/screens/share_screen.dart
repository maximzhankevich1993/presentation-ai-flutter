import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/workspace_service.dart';

class ShareScreen extends StatefulWidget {
  final String presentationId;
  final String presentationTitle;

  const ShareScreen({
    super.key,
    required this.presentationId,
    required this.presentationTitle,
  });

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  String _accessLevel = 'view';
  String _shareLink = '';

  @override
  void initState() {
    super.initState();
    _generateLink();
  }

  void _generateLink() {
    _shareLink = WorkspaceService.generateShareLink(
      widget.presentationId,
      _accessLevel,
    );

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF1E1E2A) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('Поделиться'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Поделиться презентацией',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              widget.presentationTitle,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 32.h),

            Text(
              'Уровень доступа',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),

            _buildAccessOption(
              'view',
              'Просмотр',
              'Могут только смотреть',
              Icons.visibility_outlined,
            ),
            _buildAccessOption(
              'comment',
              'Комментирование',
              'Могут оставлять комментарии',
              Icons.comment_outlined,
            ),
            _buildAccessOption(
              'edit',
              'Редактирование',
              'Могут изменять презентацию',
              Icons.edit_outlined,
            ),

            SizedBox(height: 32.h),

            Text(
              'Ссылка для шаринга',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),

            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _shareLink,
                      style: TextStyle(fontSize: 13.sp),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ссылка скопирована!'),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.copy,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            Text(
              'Пригласить людей',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),

            TextField(
              decoration: InputDecoration(
                hintText: 'Введите email',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                suffixIcon: SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Отправить'),
                  ),
                ),
              ),
            ),

            SizedBox(height: 32.h),

            Text(
              'Люди с доступом',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),

            ...WorkspaceService.getTeamMembers().map(
              (user) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: _parseColor(user.avatarColor),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0] : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  user.name,
                  style: TextStyle(fontSize: 14.sp),
                ),
                subtitle: Text(
                  _roleText(user.role),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessOption(
    String value,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _accessLevel == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _accessLevel = value;
          _generateLink();
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4F46E5).withOpacity(0.1)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4F46E5)
                : Colors.grey.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF4F46E5)
                  : Colors.grey,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF4F46E5),
              ),
          ],
        ),
      ),
    );
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

  Color _parseColor(String color) {
    try {
      return Color(int.parse(color.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.grey;
    }
  }
}