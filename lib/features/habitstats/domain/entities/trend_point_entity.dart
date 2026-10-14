import 'package:equatable/equatable.dart';

/// Pure domain entity representing a single data point in a habit trend chart.
class TrendPointEntity extends Equatable {
  final double x;
  final double y;
  final DateTime? date;

  const TrendPointEntity({
    required this.x,
    required this.y,
    this.date,
  });

  @override
  List<Object?> get props => [x, y, date];
}
