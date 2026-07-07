import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../models/call_model.dart';
import '../../core/utils/formatters.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  final ApiService _api = ApiService();
  List<CallModel> _calls = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCalls();
  }

  Future<void> _loadCalls() async {
    try {
      final data = await _api.getCalls();
      if (mounted) {
        setState(() {
          _calls = data.map((e) => CallModel.fromJson(e)).toList();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'MISSED': return AppTheme.errorColor;
      case 'HANDLED': return AppTheme.successColor;
      case 'ESCALATED': return AppTheme.warningColor;
      case 'VOICEMAIL': return AppTheme.primaryColor;
      default: return AppTheme.textSecondary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'MISSED': return Icons.phone_missed;
      case 'HANDLED': return Icons.phone_in_talk;
      case 'ESCALATED': return Icons.support_agent;
      case 'VOICEMAIL': return Icons.voicemail;
      default: return Icons.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Call History')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _calls.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.phone_missed, size: 64, color: AppTheme.textMuted),
                      SizedBox(height: 16),
                      Text('No calls yet', style: TextStyle(color: AppTheme.textSecondary)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadCalls,
                  child: ListView.builder(
                    itemCount: _calls.length,
                    itemBuilder: (context, index) {
                      final call = _calls[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _statusColor(call.status).withOpacity(0.2),
                            child: Icon(
                              _statusIcon(call.status),
                              color: _statusColor(call.status),
                              size: 20,
                            ),
                          ),
                          title: Text(
                            Formatters.formatPhone(call.caller),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${Formatters.timeAgo(call.createdAt)} · ${Formatters.formatDuration(call.duration)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Chip(
                            label: Text(
                              Formatters.callStatusLabel(call.status),
                              style: const TextStyle(fontSize: 11, color: Colors.white),
                            ),
                            backgroundColor: _statusColor(call.status),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onTap: () => _showCallDetail(call),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  void _showCallDetail(CallModel call) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Call Details',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _detailRow('From', Formatters.formatPhone(call.caller)),
            _detailRow('Duration', Formatters.formatDuration(call.duration)),
            _detailRow('Status', Formatters.callStatusLabel(call.status)),
            _detailRow('Time', Formatters.formatDateTime(call.createdAt)),
            if (call.intent != null) _detailRow('Intent', call.intent!),
            if (call.summary != null) ...[
              const SizedBox(height: 12),
              const Text('Summary', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
              const SizedBox(height: 4),
              Text(call.summary!, style: const TextStyle(color: AppTheme.textPrimary)),
            ],
            if (call.recordingUrl != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play Recording'),
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
