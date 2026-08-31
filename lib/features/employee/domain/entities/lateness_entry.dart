import 'package:equatable/equatable.dart';

class LatenessEntry extends Equatable {
  final DateTime date;
  final int minutes;

  const LatenessEntry({required this.date, required this.minutes});

  @override
  List<Object?> get props => [date, minutes];
}
