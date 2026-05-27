import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  final String uid;
  final String nome;
  final String email;
  final String telefone;
  final DateTime createdAt;

  Usuario({
    required this.uid,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.createdAt,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    var rawDate = json['createdAt'];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.parse(rawDate);
    } else {
      parsedDate = DateTime.now();
    }

    return Usuario(
      uid: json['uid'] ?? '',
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      telefone: json['telefone'] ?? '',
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
