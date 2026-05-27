import 'package:cloud_firestore/cloud_firestore.dart';

class Transacao {
  final String id;
  final String uid;
  final String description;
  final double amount;
  final String date;
  final String type; // 'income' or 'expense'
  final DateTime createdAt;

  Transacao({
    required this.id,
    required this.uid,
    required this.description,
    required this.amount,
    required this.date,
    required this.type,
    required this.createdAt,
  });

  factory Transacao.fromJson(Map<String, dynamic> json, {String? docId}) {
    DateTime parsedDate;
    var rawDate = json['createdAt'];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.parse(rawDate);
    } else {
      parsedDate = DateTime.now();
    }

    return Transacao(
      id: docId ?? json['id'] ?? '',
      uid: json['uid'] ?? '',
      description: json['description'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] ?? '',
      type: json['type'] ?? 'expense',
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'description': description,
      'amount': amount,
      'date': date,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
