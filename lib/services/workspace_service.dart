import 'dart:math';
import 'package:flutter/material.dart';

enum UserRole { owner, editor, viewer }

enum AccessLevel { view, edit, comment }

class WorkspaceUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final Color avatarColor;

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
  final AccessLevel accessLevel;

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
  static final Random _random = Random.secure();

  static List<WorkspaceUser> getTeamMembers() {
    return const [
      WorkspaceUser(
        id: '1',
        name: 'Анна М.',
        email: 'anna@email.com',
        role: UserRole.owner,
        avatarColor: Color(0xFF6366F1),
      ),
      WorkspaceUser(
        id: '2',
        name: 'Дмитрий К.',
        email: 'dima@email.com',
        role: UserRole.editor,
        avatarColor: Color(0xFF10B981),
      ),
      WorkspaceUser(
        id: '3',
        name: 'Елена С.',
        email: 'elena@email.com',
        role: UserRole.viewer,
        avatarColor: Color(0xFFF59E0B),
      ),
    ];
  }

  static List<Comment> getComments(String presentationId) {
    final now = DateTime(2026, 1, 1, 12); // фиксируем для стабильности UI

    return [
      Comment(
        id: '1',
        userId: '2',
        userName: 'Дмитрий К.',
        text: 'Отличный слайд! Может, добавить статистику?',
        createdAt: now.subtract(const Duration(hours: 2)),
        slideIndex: 0,
      ),
      Comment(
        id: '2',
        userId: '3',
        userName: 'Елена С.',
        text: 'Согласна, цифры сделают убедительнее',
        createdAt: now.subtract(const Duration(hours: 1)),
        slideIndex: 0,
      ),
      Comment(
        id: '3',
        userId: '2',
        userName: 'Дмитрий К.',
        text: 'Тут нужно поправить заголовок',
        createdAt: now.subtract(const Duration(minutes: 30)),
        slideIndex: 2,
        isResolved: true,
      ),
    ];
  }

  static List<SharedPresentation> getSharedPresentations() {
    final now = DateTime(2026, 1, 1, 12);

    return [
      SharedPresentation(
        id: '1',
        title: 'Стратегия развития 2026',
        ownerName: 'Максим Ж.',
        slideCount: 15,
        sharedAt: now.subtract(const Duration(days: 1)),
        accessLevel: AccessLevel.edit,
      ),
      SharedPresentation(
        id: '2',
        title: 'Отчёт за Q1',
        ownerName: 'Анна М.',
        slideCount: 10,
        sharedAt: now.subtract(const Duration(days: 3)),
        accessLevel: AccessLevel.view,
      ),
      SharedPresentation(
        id: '3',
        title: 'Питч-дек для инвесторов',
        ownerName: 'Дмитрий К.',
        slideCount: 12,
        sharedAt: now.subtract(const Duration(days: 7)),
        accessLevel: AccessLevel.comment,
      ),
    ];
  }

  static String generateShareLink(
    String presentationId,
    AccessLevel accessLevel,
  ) {
    final token = _secureToken();
    return 'https://prezentator-ai.com/share/$presentationId?token=$token&access=$accessLevel';
  }

  static String generateInviteLink(String workspaceId) {
    final token = _secureToken();
    return 'https://prezentator-ai.com/join/$workspaceId?invite=$token';
  }

  static String _secureToken() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    return base64UrlEncode(bytes).substring(0, 10);
  }
}