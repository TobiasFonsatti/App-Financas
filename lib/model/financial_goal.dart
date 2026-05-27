import 'package:cloud_firestore/cloud_firestore.dart';

class FinancialGoal {
  final String id;
  final String uid;
  final String name;
  final String emoji;
  final double targetAmount;
  final double currentAmount;
  final int monthsLeft;
  final bool paused;
  final DateTime createdAt;

  FinancialGoal({
    required this.id,
    required this.uid,
    required this.name,
    required this.emoji,
    required this.targetAmount,
    required this.currentAmount,
    required this.monthsLeft,
    this.paused = false,
    required this.createdAt,
  });

  double get progress =>
      targetAmount == 0 ? 0.0 : (currentAmount / targetAmount).clamp(0.0, 1.0);

  double get remaining =>
      (targetAmount - currentAmount).clamp(0.0, double.infinity);

  double get monthlyNeeded =>
      monthsLeft <= 0 ? remaining : remaining / monthsLeft;

  factory FinancialGoal.fromJson(Map<String, dynamic> json, {String? docId}) {
    DateTime parsedDate;
    var rawDate = json['createdAt'];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.parse(rawDate);
    } else {
      parsedDate = DateTime.now();
    }

    return FinancialGoal(
      id: docId ?? json['id'] ?? '',
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      emoji: json['emoji'] ?? '🎯',
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0.0,
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0.0,
      monthsLeft: json['monthsLeft'] ?? 0,
      paused: json['paused'] ?? false,
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'name': name,
      'emoji': emoji,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'monthsLeft': monthsLeft,
      'paused': paused,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
