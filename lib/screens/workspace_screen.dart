import 'dart:math';

class WorkspaceUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final String avatarColor;

  const WorkspaceUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.avatarColor,
  });
}

class Comment {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final DateTime createdAt;
  final int slideIndex;
  final bool isResolved;

  const Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
    required this.slideIndex,
    this.isResolved = false,
  });
}

class SharedPresentation {
  final String id;
  final String title;
  final String ownerName;
  final int slideCount;
  final DateTime sharedAt;
  final String accessLevel;

  const SharedPresentation({
    required this.id,
    required this.title,
    required this.ownerName,
    required this.slideCount,
    required this.sharedAt,
    required this.accessLevel,
  });
}

class WorkspaceService {
  static final Random _random = Random();

  static List<WorkspaceUser> getTeamMembers() {
    return [
      const WorkspaceUser(id: '1', name: 'Анна М.', email: 'anna@email.com', role: 'owner', avatarColor: '#6366f1'),
      const WorkspaceUser(id: '2', name: 'Дмитрий К.', email: 'dima@email.com', role: 'editor', avatarColor: '#10b981'),
      const WorkspaceUser(id: '3', name: 'Елена С.', email: 'elena@email.com', role: 'viewer', avatarColor: '#f59e0b'),
    ];
  }

  static List<Comment> getComments(String presentationId) {
    return [
      Comment(id: '1', userId: '2', userName: 'Дмитрий К.', text: 'Отличный слайд! Может, добавить статистику?', createdAt: DateTime.now().subtract(const Duration(hours: 2)), slideIndex: 0),
      Comment(id: '2', userId: '3', userName: 'Елена С.', text: 'Согласна, цифры сделают убедительнее', createdAt: DateTime.now().subtract(const Duration(hours: 1)), slideIndex: 0),
      Comment(id: '3', userId: '2', userName: 'Дмитрий К.', text: 'Тут нужно поправить заголовок', createdAt: DateTime.now().subtract(const Duration(minutes: 30)), slideIndex: 2, isResolved: true),
    ];
  }

  static List<SharedPresentation> getSharedPresentations() {
    return [
      SharedPresentation(id: '1', title: 'Стратегия развития 2026', ownerName: 'Максим Ж.', slideCount: 15, sharedAt: DateTime.now().subtract(const Duration(days: 1)), accessLevel: 'edit'),
      SharedPresentation(id: '2', title: 'Отчёт за Q1', ownerName: 'Анна М.', slideCount: 10, sharedAt: DateTime.now().subtract(const Duration(days: 3)), accessLevel: 'view'),
      SharedPresentation(id: '3', title: 'Питч-дек для инвесторов', ownerName: 'Дмитрий К.', slideCount: 12, sharedAt: DateTime.now().subtract(const Duration(days: 7)), accessLevel: 'comment'),
    ];
  }

  static String generateShareLink(String presentationId, String accessLevel) {
    final token = _random.nextInt(999999).toString().padLeft(6, '0');
    return 'https://prezentator-ai.com/share/$presentationId?token=$token&access=$accessLevel';
  }

  static String generateInviteLink(String workspaceId) {
    final token = _random.nextInt(999999).toString().padLeft(6, '0');
    return 'https://prezentator-ai.com/join/$workspaceId?invite=$token';
  }
}