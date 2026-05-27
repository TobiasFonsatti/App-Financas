import 'package:firebase_auth/firebase_auth.dart';

class LoginController {
  static final RegExp _emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}");

  String? username;
  String? password;

  Future<String?> login(String email, String pass) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: pass,
      );
      if (credential.user != null) {
        username = email;
        password = pass;
        return null; // success
      }
      return "Não foi possível realizar o login.";
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return "E-mail com formato inválido.";
        case 'user-disabled':
          return "Este usuário foi desativado.";
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return "E-mail ou senha incorretos.";
        default:
          return "Erro na autenticação: ${e.message ?? e.code}";
      }
    } catch (_) {
      return "E-mail ou senha incorretos.";
    }
  }

  bool isValidEmail(String email) {
    return _emailRegex.hasMatch(email.trim());
  }
}
