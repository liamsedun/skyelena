import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../models/dashboard_stats.dart';
import '../../models/call_model.dart';
import '../../models/booking_model.dart';
import '../../widgets/stat_card.dart';
import '../../core/utils/formatters.dart';
import '../calls/calls_screen.dart';
import '../messages/messages_screen.dart';
import '../bookings/bookings_screen.dart';
import '../settings/settings_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final ApiService _api = ApiService();
  DashboardStats? _stats;
  bool _loading = true;
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _DashboardTab(),
    const CallsScreen(),
    const MessagesScreen(),
    const BookingsScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final data = await _api.getDashboardStats();
      if (mounted) {
        setState(() {
          _stats = DashboardStats.fromJson(data);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.phone_outlined), label: 'Calls'),
          BottomNavigationBarItem(icon: Icon(Icons.message_outlined), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SkyElena'),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final auth = ref.watch(authServiceProvider);
              return IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => auth.logout(),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer(
                builder: (context, ref, _) {
                  final auth = ref.watch(authServiceProvider);
                  return Text(
                    'Welcome, ${auth.currentUser?.name ?? 'User'}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Consumer(
                builder: (context, ref, _) {
                  final auth = ref.watch(authServiceProvider);
                  final sub = auth.currentUser?.subscription;
                  return Text(
                    '${sub?.tier ?? 'FREE'} Plan | ${sub?.minutesUsed ?? 0}/${sub?.minutesLimit ?? 50} min used',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Today',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Consumer(
                builder: (context, ref, _) => ApiCaller(
                  builder: (stats) => GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      StatCard(
                        label: 'Appointments',
                        value: '${stats?.todayAppointments ?? 0}',
                        icon: Icons.calendar_today,
                        color: AppTheme.secondaryColor,
                      ),
                      StatCard(
                        label: 'Calls Today',
                        value: '${stats?.todayCalls ?? 0}',
                        icon: Icons.phone_in_talk,
                        color: AppTheme.primaryColor,
                      ),
                      StatCard(
                        label: 'Missed Calls',
                        value: '${stats?.missedCalls ?? 0}',
                        icon: Icons.phone_missed,
                        color: AppTheme.errorColor,
                      ),
                      StatCard(
                        label: 'Messages',
                        value: '${stats?.totalMessages ?? 0}',
                        icon: Icons.message,
                        color: AppTheme.warningColor,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Upcoming Appointments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Consumer(
                builder: (context, ref, _) => ApiCaller(
                  builder: (stats) {
                    final bookings = stats?.upcomingBookings ?? [];
                    if (bookings.isEmpty) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              'No upcoming appointments',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: bookings.take(3).map((b) => _BookingTile(booking: b)).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingTile extends StatelessWidget {
  final BookingModel booking;
  const _BookingTile({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
          child: const Icon(Icons.person, color: AppTheme.primaryColor),
        ),
        title: Text(booking.customerName, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${booking.title} - ${Formatters.formatTime(booking.date)}'),
        trailing: Chip(
          label: Text(
            booking.status,
            style: const TextStyle(fontSize: 11, color: Colors.white),
          ),
          backgroundColor: booking.status == 'CONFIRMED'
              ? AppTheme.successColor
              : AppTheme.warningColor,
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}

class ApiCaller extends StatelessWidget {
  final Widget Function(DashboardStats?) builder;
  const ApiCaller({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DashboardStats>(
      future: _fetchStats(),
      builder: (context, snapshot) {
        return builder(snapshot.data);
      },
    );
  }

  Future<DashboardStats> _fetchStats() async {
    try {
      final data = await ApiService().getDashboardStats();
      return DashboardStats.fromJson(data);
    } catch (e) {
      return DashboardStats(
        todayAppointments: 0,
        totalCalls: 0,
        missedCalls: 0,
        todayCalls: 0,
        totalMessages: 0,
        unreadMessages: 0,
        recentCalls: [],
        upcomingBookings: [],
      );
    }
  }
}
