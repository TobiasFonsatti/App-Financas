import 'login_controller.dart';

class ForgotPasswordController {
  final LoginController _loginController = LoginController();

  bool isValidEmail(String email) {
    return _loginController.isValidEmail(email);
  }

  // Simula o envio de recuperação de senha
  bool requestPasswordReset(String email) {
    return isValidEmail(email);
  }
}