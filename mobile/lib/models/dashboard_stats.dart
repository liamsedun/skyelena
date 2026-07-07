import 'call_model.dart';
import 'booking_model.dart';
import 'user_model.dart';

class DashboardStats {
  final int todayAppointments;
  final int totalCalls;
  final int missedCalls;
  final int todayCalls;
  final int totalMessages;
  final int unreadMessages;
  final List<CallModel> recentCalls;
  final List<BookingModel> upcomingBookings;
  final SubscriptionModel? subscription;

  DashboardStats({
    required this.todayAppointments,
    required this.totalCalls,
    required this.missedCalls,
    required this.todayCalls,
    required this.totalMessages,
    required this.unreadMessages,
    required this.recentCalls,
    required this.upcomingBookings,
    this.subscription,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      todayAppointments: json['todayAppointments'] ?? 0,
      totalCalls: json['totalCalls'] ?? 0,
      missedCalls: json['missedCalls'] ?? 0,
      todayCalls: json['todayCalls'] ?? 0,
      totalMessages: json['totalMessages'] ?? 0,
      unreadMessages: json['unreadMessages'] ?? 0,
      recentCalls: (json['recentCalls'] as List? ?? [])
          .map((e) => CallModel.fromJson(e))
          .toList(),
      upcomingBookings: (json['upcomingBookings'] as List? ?? [])
          .map((e) => BookingModel.fromJson(e))
          .toList(),
      subscription: json['subscription'] != null
          ? SubscriptionModel.fromJson(json['subscription'])
          : null,
    );
  }
}
