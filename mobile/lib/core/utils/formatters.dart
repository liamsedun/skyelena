import 'package:intl/intl.dart';

class Formatters {
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy hh:mm a').format(date);
  }

  static String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes}m ${secs}s';
  }

  static String formatPhone(String phone) {
    if (phone.length >= 10) {
      return '${phone.substring(0, 3)} ${phone.substring(3, 6)} ${phone.substring(6)}';
    }
    return phone;
  }

  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatDate(date);
  }

  static String callStatusLabel(String status) {
    switch (status) {
      case 'MISSED':
        return 'Missed';
      case 'HANDLED':
        return 'Handled';
      case 'ESCALATED':
        return 'Escalated';
      case 'VOICEMAIL':
        return 'Voicemail';
      default:
        return status;
    }
  }
}
