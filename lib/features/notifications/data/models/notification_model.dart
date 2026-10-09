import 'dart:convert';
import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/notification_enums.dart';

class NotificationModel {
  final int id;
  final String title;
  final String body;
  final String type;
  final String? referenceType;
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

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.referenceType,
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

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? parsedData;
    final rawData = json['data'];
    if (rawData is String && rawData.trim().isNotEmpty) {
      try {
        parsedData = jsonDecode(rawData) as Map<String, dynamic>?;
      } catch (_) {
        parsedData = null;
      }
    } else if (rawData is Map<String, dynamic>) {
      parsedData = rawData;
    }

    DateTime? parsedReadAt;
    if (json['readAt'] != null) {
      parsedReadAt = DateTime.tryParse(json['readAt'].toString());
    }

    DateTime parsedCreatedAt;
    if (json['createdAt'] != null) {
      parsedCreatedAt =
          DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now();
    } else {
      parsedCreatedAt = DateTime.now();
    }

    return NotificationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      referenceType: json['referenceType']?.toString(),
      referenceId: (json['referenceId'] as num?)?.toInt(),
      groupId: (json['groupId'] as num?)?.toInt(),
      groupName: json['groupName']?.toString(),
      actorId: (json['actorId'] as num?)?.toInt(),
      actorName: json['actorName']?.toString(),
      actorAvatarUrl: json['actorAvatarUrl']?.toString(),
      isRead: json['isRead'] as bool? ?? false,
      readAt: parsedReadAt,
      createdAt: parsedCreatedAt,
      data: parsedData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      if (referenceType != null) 'referenceType': referenceType,
      if (referenceId != null) 'referenceId': referenceId,
      if (groupId != null) 'groupId': groupId,
      if (groupName != null) 'groupName': groupName,
      if (actorId != null) 'actorId': actorId,
      if (actorName != null) 'actorName': actorName,
      if (actorAvatarUrl != null) 'actorAvatarUrl': actorAvatarUrl,
      'isRead': isRead,
      if (readAt != null) 'readAt': readAt!.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      if (data != null) 'data': jsonEncode(data),
    };
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      title: title,
      body: body,
      type: NotificationType.fromString(type),
      referenceType: NotificationReferenceType.fromString(referenceType),
      referenceId: referenceId,
      groupId: groupId,
      groupName: groupName,
      actorId: actorId,
      actorName: actorName,
      actorAvatarUrl: actorAvatarUrl,
      isRead: isRead,
      readAt: readAt,
      createdAt: createdAt,
      data: data,
    );
  }
}

class NotificationPageModel {
  final List<NotificationModel> content;
  final int pageNumber;
  final int pageSize;
  final int totalElements;
  final int totalPages;
  final bool last;

  const NotificationPageModel({
    required this.content,
    required this.pageNumber,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
    required this.last,
  });

  factory NotificationPageModel.fromJson(Map<String, dynamic> json) {
    final rawContent = json['content'];
    final content = (rawContent is List)
        ? rawContent
            .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : <NotificationModel>[];

    final pageable = json['pageable'] as Map<String, dynamic>?;

    return NotificationPageModel(
      content: content,
      pageNumber: (pageable?['pageNumber'] as num?)?.toInt() ?? 0,
      pageSize: (pageable?['pageSize'] as num?)?.toInt() ?? 20,
      totalElements: (json['totalElements'] as num?)?.toInt() ?? content.length,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
      last: json['last'] as bool? ?? true,
    );
  }
}
