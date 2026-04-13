import 'package:flutter/material.dart';
import '../controller/login_controller.dart';
import 'inicio.dart';
import 'cadastro.dart';
import 'esqueceu_senha.dart';
import 'widgets/message_helpers.dart';

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
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _message;
  bool _isSuccess = false;
  bool _rememberMe = false;

  void _login() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() {
        _message = null;
      });
      showAppSnackBar(
        context,
        'Preencha e valide os campos para continuar.',
        isError: true,
      );
      return;
    }

    final email = _emailController.text.trim();
    final password = _passController.text;
    final success = _controller.login(email, password);

    if (success) {
      setState(() {
        _isSuccess = true;
        _message = 'Login realizado com sucesso!';
      });

      showAppSnackBar(context, 'Login realizado com sucesso!');
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => HomeView(
              isDarkMode: widget.isDarkMode,
              onToggleTheme: widget.onToggleTheme,
            ),
          ),
        );
      });
      return;
    }

    setState(() {
      _isSuccess = false;
      _message =
          'E-mail ou senha inválidos. Verifique suas credenciais e tente novamente.';
    });
    showAppSnackBar(
      context,
      'E-mail ou senha inválidos. Verifique suas credenciais e tente novamente.',
      isError: true,
    );
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RegisterView(
          isDarkMode: widget.isDarkMode,
          onToggleTheme: widget.onToggleTheme,
        ),
      ),
    );
  }

  void _navigateToForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ForgotPasswordView(
          onToggleTheme: widget.onToggleTheme,
          isDarkMode: widget.isDarkMode,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
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
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: widget.isDarkMode
                                    ? Colors.black.withValues(alpha: 0.35)
                                    : Colors.black.withValues(alpha: 0.12),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    autofillHints: const [AutofillHints.email],
                                    style: TextStyle(
                                      color: widget.isDarkMode
                                          ? Colors.green.shade100
                                          : Colors.green.shade900,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: 'E-mail',
                                      labelStyle: TextStyle(
                                        color: widget.isDarkMode
                                            ? Colors.green.shade200
                                            : Colors.green.shade700,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.email,
                                        color: widget.isDarkMode
                                            ? Colors.green.shade200
                                            : Colors.green.shade700,
                                      ),
                                      filled: true,
                                      fillColor: widget.isDarkMode
                                          ? Colors.white.withValues(alpha: 0.05)
                                          : Colors.green.shade50,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Informe seu e-mail.';
                                      }
                                      if (!_controller.isValidEmail(value)) {
                                        return 'Informe um e-mail válido.';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _passController,
                                    obscureText: true,
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
                                          ? Colors.white.withValues(alpha: 0.05)
                                          : Colors.green.shade50,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Informe sua senha.';
                                      }
                                      return null;
                                    },
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
                                        onPressed: _navigateToForgotPassword,
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
                                        color: _isSuccess
                                            ? Colors.green.withValues(
                                                alpha: 0.14,
                                              )
                                            : Colors.red.withValues(
                                                alpha: 0.14,
                                              ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            _isSuccess
                                                ? Icons.check_circle
                                                : Icons.error,
                                            color: _isSuccess
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              _message!,
                                              style: TextStyle(
                                                color: _isSuccess
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
                            color: Colors.green.withValues(alpha: 0.35),
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
                          'Entrar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.green, width: 1.8),
                      ),
                      child: TextButton(
                        onPressed: _navigateToRegister,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          'Criar conta',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
