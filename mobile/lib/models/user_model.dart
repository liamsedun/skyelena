class UserModel {
  final String id;
  final String email;
  final String name;
  final String? businessName;
  final String? businessPhone;
  final String? stripeCustomerId;
  final DateTime createdAt;
  final SubscriptionModel? subscription;
  final BusinessSettingsModel? settings;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.businessName,
    this.businessPhone,
    this.stripeCustomerId,
    required this.createdAt,
    this.subscription,
    this.settings,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      businessName: json['businessName'],
      businessPhone: json['businessPhone'],
      stripeCustomerId: json['stripeCustomerId'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      subscription: json['subscription'] != null
          ? SubscriptionModel.fromJson(json['subscription'])
          : null,
      settings: json['settings'] != null
          ? BusinessSettingsModel.fromJson(json['settings'])
          : null,
    );
  }
}

class SubscriptionModel {
  final String id;
  final String tier;
  final String status;
  final int minutesUsed;
  final int minutesLimit;

  SubscriptionModel({
    required this.id,
    required this.tier,
    required this.status,
    required this.minutesUsed,
    required this.minutesLimit,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] ?? '',
      tier: json['tier'] ?? 'FREE',
      status: json['status'] ?? 'active',
      minutesUsed: json['minutesUsed'] ?? 0,
      minutesLimit: json['minutesLimit'] ?? 50,
    );
  }
}

class BusinessSettingsModel {
  final String? businessName;
  final String? businessHours;
  final String aiTone;
  final String aiVoice;
  final String greetingMessage;
  final String? emergencyNumber;
  final String? autoReply;
  final String timezone;

  BusinessSettingsModel({
    this.businessName,
    this.businessHours,
    this.aiTone = 'friendly',
    this.aiVoice = 'Polly.Joanna',
    this.greetingMessage = 'Hello, thank you for calling. How can I assist you today?',
    this.emergencyNumber,
    this.autoReply,
    this.timezone = 'UTC',
  });

  factory BusinessSettingsModel.fromJson(Map<String, dynamic> json) {
    return BusinessSettingsModel(
      businessName: json['businessName'],
      businessHours: json['businessHours'],
      aiTone: json['aiTone'] ?? 'friendly',
      aiVoice: json['aiVoice'] ?? 'Polly.Joanna',
      greetingMessage: json['greetingMessage'] ?? 'Hello, thank you for calling. How can I assist you today?',
      emergencyNumber: json['emergencyNumber'],
      autoReply: json['autoReply'],
      timezone: json['timezone'] ?? 'UTC',
    );
  }
}
