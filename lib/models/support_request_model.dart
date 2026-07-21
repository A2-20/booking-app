class SupportRequestModel {
  final String id;
  final String subject;
  final String message;
  final String status;
  final String priority;
  final String? adminReply;
  final DateTime? repliedAt;
  final DateTime createdAt;

  SupportRequestModel({
    required this.id,
    required this.subject,
    required this.message,
    required this.status,
    required this.priority,
    this.adminReply,
    this.repliedAt,
    required this.createdAt,
  });

  factory SupportRequestModel.fromJson(Map<String, dynamic> json) {
    return SupportRequestModel(
      id: (json['id'] ?? '').toString(),
      subject: (json['subject'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      status: (json['status'] ?? 'pending').toString(),
      priority: (json['priority'] ?? 'medium').toString(),
      adminReply:
          json['admin_reply'] as String? ?? json['adminReply'] as String?,
      repliedAt: (json['replied_at'] ?? json['repliedAt']) != null
          ? DateTime.tryParse(
              (json['replied_at'] ?? json['repliedAt']).toString(),
            )
          : null,
      createdAt:
          DateTime.tryParse(
            (json['created_at'] ?? json['createdAt'] ?? '').toString(),
          ) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'message': message,
      'status': status,
      'priority': priority,
      'admin_reply': adminReply,
      'replied_at': repliedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
