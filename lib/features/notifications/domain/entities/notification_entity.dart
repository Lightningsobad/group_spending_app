import 'notification_enums.dart';

class NotificationEntity {
  final int id;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationReferenceType referenceType;
  final int? referenceId;
  final int? groupId;
  final String? groupName;
  final int? actorId;
  final String? actorName;
  final String? actorAvatarUrl;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.referenceType,
    this.referenceId,
    this.groupId,
    this.groupName,
    this.actorId,
    this.actorName,
    this.actorAvatarUrl,
    required this.isRead,
    this.readAt,
    required this.createdAt,
    this.data,
  });

  NotificationEntity copyWith({
    int? id,
    String? title,
    String? body,
    NotificationType? type,
    NotificationReferenceType? referenceType,
    int? referenceId,
    int? groupId,
    String? groupName,
    int? actorId,
    String? actorName,
    String? actorAvatarUrl,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
    Map<String, dynamic>? data,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      referenceType: referenceType ?? this.referenceType,
      referenceId: referenceId ?? this.referenceId,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      actorId: actorId ?? this.actorId,
      actorName: actorName ?? this.actorName,
      actorAvatarUrl: actorAvatarUrl ?? this.actorAvatarUrl,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          isRead == other.isRead;

  @override
  int get hashCode => Object.hash(id, isRead);
}
