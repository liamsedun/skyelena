import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ApiService _api = ApiService();
  bool _loading = true;

  final _businessNameCtrl = TextEditingController();
  final _greetingCtrl = TextEditingController();
  final _emergencyNumberCtrl = TextEditingController();
  final _autoReplyCtrl = TextEditingController();

  String _aiTone = 'friendly';
  String _aiVoice = 'Polly.Joanna';
  String? _tier;
  int _minutesUsed = 0;
  int _minutesLimit = 50;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _api.getSettings();
      final sub = await _api.getSubscription();

      if (mounted) {
        setState(() {
          _businessNameCtrl.text = settings['businessName'] ?? '';
          _greetingCtrl.text = settings['greetingMessage'] ??
              'Hello, thank you for calling. How can I assist you today?';
          _emergencyNumberCtrl.text = settings['emergencyNumber'] ?? '';
          _autoReplyCtrl.text = settings['autoReply'] ?? '';
          _aiTone = settings['aiTone'] ?? 'friendly';
          _aiVoice = settings['aiVoice'] ?? 'Polly.Joanna';
          _tier = sub['tier'] ?? 'FREE';
          _minutesUsed = sub['minutesUsed'] ?? 0;
          _minutesLimit = sub['minutesLimit'] ?? 50;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveSettings() async {
    try {
      await _api.updateSettings({
        'businessName': _businessNameCtrl.text,
        'greetingMessage': _greetingCtrl.text,
        'emergencyNumber': _emergencyNumberCtrl.text,
        'autoReply': _autoReplyCtrl.text,
        'aiTone': _aiTone,
        'aiVoice': _aiVoice,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _greetingCtrl.dispose();
    _emergencyNumberCtrl.dispose();
    _autoReplyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('Subscription', [
                    _buildInfoRow('Plan', _tier ?? 'FREE'),
                    _buildInfoRow('Minutes Used', '$_minutesUsed / $_minutesLimit'),
                    LinearProgressIndicator(
                      value: _minutesLimit > 0 ? _minutesUsed / _minutesLimit : 0,
                      backgroundColor: AppTheme.cardColor,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _minutesUsed > _minutesLimit ? AppTheme.errorColor : AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _upgradePlan(),
                        child: Text(
                          _tier == 'FREE' ? 'Upgrade Plan' : 'Manage Billing',
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _buildSection('Business Info', [
                    TextField(
                      controller: _businessNameCtrl,
                      decoration: const InputDecoration(labelText: 'Business Name'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emergencyNumberCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Emergency Transfer Number',
                        hintText: '+1234567890',
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _buildSection('SkyElena', [
                    TextField(
                      controller: _greetingCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Greeting Message',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _aiTone,
                      decoration: const InputDecoration(labelText: 'AI Tone'),
                      items: const [
                        DropdownMenuItem(value: 'formal', child: Text('Formal')),
                        DropdownMenuItem(value: 'friendly', child: Text('Friendly')),
                        DropdownMenuItem(value: 'casual', child: Text('Casual')),
                      ],
                      onChanged: (v) => setState(() => _aiTone = v!),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _autoReplyCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Auto Reply (after hours)',
                      ),
                      maxLines: 2,
                    ),
                  ]),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveSettings,
                    child: const Text('Save Settings'),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        try {
                          final portal = await _api.getBillingPortal();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Billing portal: ${portal['url']}'),
                              ),
                            );
                          }
                        } catch (e) {
                          // handle
                        }
                      },
                      child: const Text('Billing Portal'),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _upgradePlan() async {
    try {
      final tier = _tier == 'FREE' ? 'STARTER' : 'GROWTH';
      final session = await _api.createCheckoutSession(tier);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checkout URL: ${session['url']}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }
}
