import 'package:cloud_firestore/cloud_firestore.dart';

class Observacao {
  final String id;
  final String uid;
  final String relatedId; // ID da transação ou meta vinculada
  final String text;
  final DateTime createdAt;

  Observacao({
    required this.id,
    required this.uid,
    required this.relatedId,
    required this.text,
    required this.createdAt,
  });

  factory Observacao.fromJson(Map<String, dynamic> json, {String? docId}) {
    DateTime parsedDate;
    var rawDate = json['createdAt'];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.parse(rawDate);
    } else {
      parsedDate = DateTime.now();
    }

    return Observacao(
      id: docId ?? json['id'] ?? '',
      uid: json['uid'] ?? '',
      relatedId: json['relatedId'] ?? '',
      text: json['text'] ?? '',
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'relatedId': relatedId,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
