import 'package:flutter/material.dart';
import '../controller/login_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _controller = LoginController();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  String? _message;
  bool? _isSuccess;
  bool _rememberMe = false;

  void _login() {
    final user = _userController.text;
    final pass = _passController.text;
    final success = _controller.login(user, pass);

    setState(() {
      _isSuccess = success;
      _message = success
          ? 'Login realizado com sucesso!'
          : 'Usuário ou senha inválidos.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final backgroundGradient = widget.isDarkMode
        ? const LinearGradient(
            colors: [Color(0xFF133E28), Color(0xFF0E2F1F)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          )
        : const LinearGradient(
            colors: [Color(0xFFE7F7EE), Color(0xFFDAF0E0)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -20),
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 160,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.account_balance_wallet,
                            size: 160,
                            color: Colors.green,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: widget.isDarkMode
                                ? Colors.white.withOpacity(0.08)
                                : Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: widget.isDarkMode
                                    ? Colors.black.withOpacity(0.35)
                                    : Colors.black.withOpacity(0.12),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: _userController,
                                  style: TextStyle(
                                    color: widget.isDarkMode
                                        ? Colors.green.shade100
                                        : Colors.green.shade900,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Usuário',
                                    labelStyle: TextStyle(
                                      color: widget.isDarkMode
                                          ? Colors.green.shade200
                                          : Colors.green.shade700,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.person,
                                      color: widget.isDarkMode
                                          ? Colors.green.shade200
                                          : Colors.green.shade700,
                                    ),
                                    filled: true,
                                    fillColor: widget.isDarkMode
                                        ? Colors.white.withOpacity(0.05)
                                        : Colors.green.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: _passController,
                                  style: TextStyle(
                                    color: widget.isDarkMode
                                        ? Colors.green.shade100
                                        : Colors.green.shade900,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Senha',
                                    labelStyle: TextStyle(
                                      color: widget.isDarkMode
                                          ? Colors.green.shade200
                                          : Colors.green.shade700,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock,
                                      color: widget.isDarkMode
                                          ? Colors.green.shade200
                                          : Colors.green.shade700,
                                    ),
                                    filled: true,
                                    fillColor: widget.isDarkMode
                                        ? Colors.white.withOpacity(0.05)
                                        : Colors.green.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  obscureText: true,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: _rememberMe,
                                          onChanged: (value) {
                                            setState(() {
                                              _rememberMe = value ?? false;
                                            });
                                          },
                                          activeColor: Colors.green,
                                        ),
                                        Text(
                                          'Lembrar',
                                          style: TextStyle(
                                            color: widget.isDarkMode
                                                ? Colors.green.shade100
                                                : Colors.green.shade900,
                                          ),
                                        ),
                                      ],
                                    ),
                                    TextButton(
                                      onPressed: () {},
                                      child: Text(
                                        'Esqueceu a senha?',
                                        style: TextStyle(
                                          color: widget.isDarkMode
                                              ? Colors.green.shade200
                                              : Colors.green.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                if (_message != null) ...[
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: _isSuccess == true
                                          ? Colors.green.withOpacity(0.14)
                                          : Colors.red.withOpacity(0.14),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          _isSuccess == true
                                              ? Icons.check_circle
                                              : Icons.error,
                                          color: _isSuccess == true
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _message!,
                                            style: TextStyle(
                                              color: _isSuccess == true
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: -40,
                          left: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.green,
                            child: const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: _login,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          'LOGIN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: widget.onToggleTheme,
                    icon: Icon(
                      widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      color: Colors.green,
                    ),
                    tooltip: widget.isDarkMode ? 'Modo claro' : 'Modo escuro',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
