import 'package:flutter/material.dart';
import '../controller/forgot_password_controller.dart';
import 'widgets/message_helpers.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _controller = ForgotPasswordController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _message;
  bool _isSuccess = false;

  Future<void> _requestReset() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() {
        _message = null;
      });
      showAppSnackBar(
        context,
        'Informe um e-mail válido para continuar.',
        isError: true,
      );
      return;
    }

    final email = _emailController.text.trim();
    final success = _controller.requestPasswordReset(email);

    if (success) {
      setState(() {
        _isSuccess = true;
        _message =
            'Instruções para redefinir a senha foram enviadas para o seu e-mail.';
      });
      await showInformationDialog(
        context,
        title: 'Recuperação de senha',
        content:
            'Instruções para redefinir a senha foram enviadas para o seu e-mail.',
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } else {
      setState(() {
        _isSuccess = false;
        _message = 'Erro ao solicitar recuperação de senha. Tente novamente.';
      });
      showAppSnackBar(
        context,
        'Erro ao solicitar recuperação de senha. Tente novamente.',
        isError: true,
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
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
      appBar: AppBar(
        title: const Text('Esqueceu a senha?'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Digite o e-mail cadastrado para receber instruções de recuperação de senha.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 24),
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
                              if (value == null || value.trim().isEmpty) {
                                return 'Informe seu e-mail.';
                              }
                              if (!_controller.isValidEmail(value)) {
                                return 'Informe um e-mail válido.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          if (_message != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _isSuccess
                                    ? Colors.green.withValues(alpha: 0.14)
                                    : Colors.red.withValues(alpha: 0.14),
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
                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: ElevatedButton(
                              onPressed: _requestReset,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Solicitar recuperação',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
