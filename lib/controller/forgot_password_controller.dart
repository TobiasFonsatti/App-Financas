import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordController {
  static final RegExp _emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}");

  bool isValidEmail(String email) {
    return _emailRegex.hasMatch(email.trim());
  }

  // Envia e-mail de redefinição de senha real via Firebase Auth
  Future<String?> requestPasswordReset(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      return null; // success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return "O formato do e-mail é inválido.";
        case 'user-not-found':
          return "Nenhum usuário cadastrado com este e-mail.";
        default:
          return "Erro: ${e.message ?? e.code}";
      }
    } catch (_) {
      return "Erro ao solicitar recuperação de senha. Tente novamente.";
    }
  }
}