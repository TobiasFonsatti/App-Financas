class LoginController {
  static final RegExp _emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}");

  String? username;
  String? password;

  bool login(String email, String pass) {
    if (email.toLowerCase() == 'admin@financas.com' && pass == '1234') {
      username = email;
      password = pass;
      return true;
    }
    return false;
  }

  bool isValidEmail(String email) {
    return _emailRegex.hasMatch(email.trim());
  }
}
