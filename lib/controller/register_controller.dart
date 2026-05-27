import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/usuario.dart';

class RegisterController {
  static final RegExp _emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}");

  bool isValidEmail(String email) {
    return _emailRegex.hasMatch(email.trim());
  }

  bool validatePasswordComplexity(String password) {
    if (password.length < 6) return false;
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final hasSpecial = RegExp(r'[!@#\$%^&*(),.?":{}|<>\-_=+\\\/\[\]]').hasMatch(password);
    return hasUppercase && hasLowercase && hasSpecial;
  }

  Future<String?> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      // 1. Create user in Firebase Auth
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user?.uid;
      if (uid == null) {
        return "Erro ao recuperar o identificador do usuário.";
      }

      // 2. Save additional user details in Firestore
      final userModel = Usuario(
        uid: uid,
        nome: name.trim(),
        email: email.trim(),
        telefone: phone.trim(),
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .set(userModel.toJson());

      return null; // success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return "Este endereço de e-mail já está sendo utilizado por outra conta.";
        case 'invalid-email':
          return "E-mail com formato inválido.";
        case 'weak-password':
          return "A senha fornecida é muito fraca.";
        default:
          return "Erro no cadastro: ${e.message ?? e.code}";
      }
    } catch (e) {
      return "Erro desconhecido ao realizar cadastro: $e";
    }
  }
}
