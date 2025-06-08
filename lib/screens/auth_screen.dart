import 'package:flutter/material.dart';
import '/services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  static const routeName = '/auth';

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  var _isLoading = false;
  var _isLoginMode = true;
  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  // Método principal para submeter o formulário de login ou registro
  Future<void> _submit() async {
    // Valida o formulário. Se inválido, não faz nada.
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // Salva o estado atual do formulário
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    String? errorMessage;

    try {
      if (_isLoginMode) {
        errorMessage = await _authService.login(
          email: _emailController.text.trim(),
          password: _senhaController.text.trim(),
        );
      } else {
        errorMessage = await _authService.register(
          email: _emailController.text.trim(),
          nome: _nomeController.text.trim(),
          senha: _senhaController.text.trim(),
        );
      }
      if (errorMessage != null) {
        _showErrorSnackBar(errorMessage);
      }
    } catch (e) {
      _showErrorSnackBar("Ocorreu um erro inesperado. Tente novamente.");
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _formKey.currentState?.reset();
      _nomeController.clear();
      _emailController.clear();
      _senhaController.clear();
    });
  }

  Future<void> _resetPassword() async {
    final emailController = TextEditingController();
    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Redefinir Senha'),
            content: TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Digite seu e-mail'),
            ),
            actions: [
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              ElevatedButton(
                child: const Text('Enviar'),
                onPressed: () async {
                  final email = emailController.text.trim();
                  if (email.isNotEmpty) {
                    Navigator.of(ctx).pop();
                    String? message = await _authService.trocarSenha(
                      email: email,
                    );
                    if (message == null) {
                      _showInfoSnackBar(
                        'Link para redefinição de senha enviado para $email',
                      );
                    } else {
                      _showErrorSnackBar(message);
                    }
                  }
                },
              ),
            ],
          ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLoginMode ? 'Login' : 'Criar Conta')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Campo de Nome (Aparece apenas no modo de registro)
                    if (!_isLoginMode)
                      TextFormField(
                        key: const ValueKey('nome'),
                        controller: _nomeController,
                        decoration: const InputDecoration(labelText: 'Nome'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira seu nome.';
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 12),

                    // Campo de E-mail
                    TextFormField(
                      key: const ValueKey('email'),
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'E-mail'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || !value.contains('@')) {
                          return 'Por favor, insira um e-mail válido.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Campo de Senha
                    TextFormField(
                      key: const ValueKey('senha'),
                      controller: _senhaController,
                      decoration: const InputDecoration(labelText: 'Senha'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'A senha deve ter pelo menos 6 caracteres.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Se estiver carregando, mostra o indicador, senão, o botão
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 15,
                          ),
                        ),
                        child: Text(_isLoginMode ? 'LOGIN' : 'REGISTRAR'),
                      ),

                    if (!_isLoading)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: _toggleMode,
                            child: Text(
                              _isLoginMode
                                  ? 'Criar nova conta'
                                  : 'Já tenho uma conta',
                            ),
                          ),
                          if (_isLoginMode) const Text('|'),
                          if (_isLoginMode)
                            TextButton(
                              onPressed: _resetPassword,
                              child: const Text('Esqueci a senha'),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
