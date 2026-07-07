class CallModel {
  final String id;
  final String callSid;
  final String caller;
  final String callee;
  final int duration;
  final String status;
  final String? transcript;
  final String? summary;
  final String? recordingUrl;
  final String? intent;
  final String? outcome;
  final String? voicemailUrl;
  final DateTime createdAt;

  CallModel({
    required this.id,
    required this.callSid,
    required this.caller,
    required this.callee,
    required this.duration,
    required this.status,
    this.transcript,
    this.summary,
    this.recordingUrl,
    this.intent,
    this.outcome,
    this.voicemailUrl,
    required this.createdAt,
  });

  factory CallModel.fromJson(Map<String, dynamic> json) {
    return CallModel(
      id: json['id'] ?? '',
      callSid: json['callSid'] ?? '',
      caller: json['caller'] ?? '',
      callee: json['callee'] ?? '',
      duration: json['duration'] ?? 0,
      status: json['status'] ?? 'HANDLED',
      transcript: json['transcript'],
      summary: json['summary'],
      recordingUrl: json['recordingUrl'],
      intent: json['intent'],
      outcome: json['outcome'],
      voicemailUrl: json['voicemailUrl'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
