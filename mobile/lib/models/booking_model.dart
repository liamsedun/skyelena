class BookingModel {
  final String id;
  final String customerName;
  final String? customerPhone;
  final String? customerEmail;
  final String title;
  final String? description;
  final DateTime date;
  final int duration;
  final String status;
  final String? source;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.customerName,
    this.customerPhone,
    this.customerEmail,
    required this.title,
    this.description,
    required this.date,
    this.duration = 30,
    this.status = 'PENDING',
    this.source,
    required this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? '',
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'],
      customerEmail: json['customerEmail'],
      title: json['title'] ?? '',
      description: json['description'],
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      duration: json['duration'] ?? 30,
      status: json['status'] ?? 'PENDING',
      source: json['source'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
