import 'package:flutter/material.dart';
import 'inicio.dart';
import 'widgets/message_helpers.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _acceptedTerms = false;
  bool _submitted = false;
  String? _formMessage;
  bool _isSuccess = false;

  static final RegExp _emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}");

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o número de telefone.';
    }

    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10 || digits.length > 11) {
      return 'Informe um telefone válido com DDD.';
    }
    if (digits.startsWith('0')) {
      return 'Informe um DDD válido.';
    }
    if (digits.length == 11 && digits[2] != '9') {
      return 'Informe um telefone celular válido com DDD.';
    }
    return null;
  }

  TextStyle _buildInputTextStyle(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return TextStyle(
      color: brightness == Brightness.dark ? Colors.white : Colors.black87,
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: const OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.green.shade700, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
      errorStyle: const TextStyle(
        color: Colors.red,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  void _submit() {
    final form = _formKey.currentState;
    if (form == null) return;

    setState(() {
      _submitted = true;
    });

    if (!_acceptedTerms) {
      setState(() {
        _isSuccess = false;
        _formMessage = 'Você deve aceitar os termos de uso para continuar.';
      });
      showInformationDialog(
        context,
        title: 'Atenção',
        content: 'Você deve aceitar os termos de uso para continuar.',
      );
      return;
    }

    if (!form.validate()) {
      setState(() {
        _isSuccess = false;
        _formMessage =
            'Corrija os campos destacados em vermelho para prosseguir.';
      });
      showAppSnackBar(
        context,
        'Corrija os campos destacados em vermelho para prosseguir.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSuccess = true;
      _formMessage = 'Cadastro realizado com sucesso! Bem-vindo ao aplicativo.';
    });
    showAppSnackBar(
      context,
      'Cadastro realizado com sucesso! Bem-vindo ao aplicativo.',
    );

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomeView(
            isDarkMode: widget.isDarkMode,
            onToggleTheme: widget.onToggleTheme,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Usuário'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Voltar',
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            autovalidateMode: _submitted
                ? AutovalidateMode.always
                : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                const Icon(Icons.person_add, size: 96, color: Colors.green),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  style: _buildInputTextStyle(context),
                  decoration: _buildInputDecoration(
                    label: 'Nome do usuário',
                    icon: Icons.person,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o nome do usuário.';
                    }
                    if (value.trim().length < 2) {
                      return 'Informe um nome válido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: _buildInputTextStyle(context),
                  decoration: _buildInputDecoration(
                    label: 'E-mail',
                    icon: Icons.email,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o e-mail.';
                    }
                    if (!_emailRegex.hasMatch(value.trim())) {
                      return 'Informe um e-mail válido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: _buildInputTextStyle(context),
                  decoration: _buildInputDecoration(
                    label: 'Número de telefone (DDD)',
                    icon: Icons.phone,
                  ),
                  validator: (value) {
                    final error = _validatePhone(value);
                    if (error != null) {
                      return error;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  style: _buildInputTextStyle(context),
                  decoration: _buildInputDecoration(
                    label: 'Senha',
                    icon: Icons.lock,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe a senha.';
                    }
                    if (value.length < 6) {
                      return 'A senha deve ter ao menos 6 caracteres.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  style: _buildInputTextStyle(context),
                  decoration: _buildInputDecoration(
                    label: 'Confirmação de senha',
                    icon: Icons.lock_outline,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirme sua senha.';
                    }
                    if (value != _passwordController.text) {
                      return 'As senhas não coincidem.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _acceptedTerms,
                      onChanged: (value) {
                        setState(() {
                          _acceptedTerms = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _acceptedTerms = !_acceptedTerms;
                          });
                        },
                        child: const Text(
                          'Eu aceito os termos de uso e a política de privacidade.',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_formMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: _isSuccess
                          ? Colors.green.withValues(alpha: 0.15)
                          : Colors.red.withValues(alpha: 0.15),
                      border: Border.all(
                        color: _isSuccess ? Colors.green : Colors.red,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _formMessage!,
                      style: TextStyle(
                        color:
                            Theme.of(context).brightness == Brightness.dark &&
                                _formMessage ==
                                    'Você deve aceitar os termos de uso para continuar.'
                            ? Colors.white
                            : Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: const Text('Criar conta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
