import '../../domain/entities/lateness_entry.dart';

class LatenessModel extends LatenessEntry {
  const LatenessModel({required super.date, required super.minutes});

  factory LatenessModel.fromJson(Map<String, dynamic> json) {
    return LatenessModel(
      date: DateTime.parse(json['date'] as String),
      minutes: json['minutes'] as int,
    );
  }
}
