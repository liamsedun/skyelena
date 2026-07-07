import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../models/booking_model.dart';
import '../../core/utils/formatters.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final ApiService _api = ApiService();
  List<BookingModel> _bookings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      final data = await _api.getBookings();
      if (mounted) {
        setState(() {
          _bookings = data.map((e) => BookingModel.fromJson(e)).toList();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'CONFIRMED': return AppTheme.successColor;
      case 'PENDING': return AppTheme.warningColor;
      case 'CANCELLED': return AppTheme.errorColor;
      case 'COMPLETED': return AppTheme.primaryColor;
      default: return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appointments')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_month_outlined, size: 64, color: AppTheme.textMuted),
                      SizedBox(height: 16),
                      Text('No appointments', style: TextStyle(color: AppTheme.textSecondary)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadBookings,
                  child: ListView.builder(
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      final booking = _bookings[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _statusColor(booking.status).withOpacity(0.2),
                            child: Icon(Icons.person, color: _statusColor(booking.status)),
                          ),
                          title: Text(booking.customerName,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            '${Formatters.formatDate(booking.date)} at ${Formatters.formatTime(booking.date)}',
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              if (booking.status == 'PENDING')
                                const PopupMenuItem(value: 'confirm', child: Text('Confirm')),
                              if (booking.status != 'COMPLETED')
                                const PopupMenuItem(value: 'cancel', child: Text('Cancel')),
                              const PopupMenuItem(value: 'delete', child: Text('Delete')),
                            ],
                            onSelected: (value) => _handleAction(value, booking),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBookingModal(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _handleAction(String action, BookingModel booking) async {
    try {
      if (action == 'confirm') {
        await _api.updateBooking(booking.id, {'status': 'CONFIRMED'});
      } else if (action == 'cancel') {
        await _api.updateBooking(booking.id, {'status': 'CANCELLED'});
      } else if (action == 'delete') {
        await _api.deleteBooking(booking.id);
      }
      _loadBookings();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }

  void _showAddBookingModal() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final titleController = TextEditingController();
    final dateController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('New Appointment',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Customer Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone (optional)'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email (optional)'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: 'Date & Time',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 10, minute: 0),
                    );
                    if (time != null) {
                      dateController.text =
                          '${Formatters.formatDate(date)} ${time.format(context)}';
                    }
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  try {
                    await _api.createBooking({
                      'customerName': nameController.text,
                      'customerPhone': phoneController.text,
                      'customerEmail': emailController.text,
                      'title': titleController.text,
                      'date': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
                      'source': 'app',
                    });
                    Navigator.pop(context);
                    _loadBookings();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorColor),
                    );
                  }
                },
                child: const Text('Create Appointment'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
