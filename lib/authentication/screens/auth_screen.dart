import 'package:flutter/material.dart';
import 'package:listin/_core/my_colors.dart';
import 'package:listin/authentication/services/auth_service.dart';
import 'package:listin/authentication/widgets/show_snack_bar.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool isEntrando = true;

  final _formKey = GlobalKey<FormState>();

  AuthService authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 32),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: MyColors.greenlightAccent,
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Image.network(
                      "https://github.com/ricarthlima/listin_assetws/raw/main/logo-icon.png",
                      height: 64,
                    ),
                    Padding(
                      padding: const EdgeInsetsGeometry.all(8),
                      child: Text(
                        (isEntrando)
                            ? "Bem vindo ao Listin!"
                            : "Vamos Começar?",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      (isEntrando)
                          ? "Faça seu login para criar sua lista de compras"
                          : "Faça seu cadastro para começar a criar sua lista de compras com Listin.",
                      textAlign: TextAlign.center,
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(label: Text("E-mail")),
                      validator: (value) {
                        if (value == null || value == "") {
                          return "O valor de e-mail deve ser preenchido";
                        }
                        if (!value.contains("@") ||
                            !value.contains(".") ||
                            value.length < 4) {
                          return "O e-mail deve ser válido";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(label: Text("Senha")),
                      validator: (value) {
                        if (value == null || value.length < 4) {
                          return "Insira uma senha válida";
                        }
                        return null;
                      },
                    ),
                    Visibility(
                      visible: isEntrando,
                      child: TextButton(
                        onPressed: () {
                          redefinicaoSenhaClicado();
                        },
                        child: Text("Esqueci minha senha"),
                      ),
                    ),
                    Visibility(
                      visible: !isEntrando,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              label: Text("Confirme a senha"),
                            ),
                            validator: (value) {
                              if (value != _passwordController.text) {
                                return "As senhas devem ser iguais";
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              label: Text("Nome"),
                            ),
                            validator: (value) {
                              if (value == null || value.length < 3) {
                                return "Insira um nome válido";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        botaoEnviarClicado();
                      },
                      child: Text((isEntrando) ? "Entrar" : "Cadastrar"),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isEntrando = !isEntrando;
                        });
                      },
                      child: Text(
                        (isEntrando)
                            ? "Ainda não tem conta?\nClique aqui para cadastrar."
                            : "Já tem uma conta?\nClique aqui para entrar",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: MyColors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  dynamic botaoEnviarClicado() {
    String email = _emailController.text;
    String senha = _passwordController.text;
    String nome = _nameController.text;

    if (_formKey.currentState!.validate()) {
      if (isEntrando) {
        _entrarUsuario(email: email, password: senha);
      } else {
        _criarUsuario(email: email, password: senha, name: nome);
      }
    }
  }

  void _entrarUsuario({required String email, required String password}) {
    authService.entrarUsuario(email: email, password: password).then((
      String? erro,
    ) {
      if (erro != null) {
        showSnackBar(context: context, message: erro);
      }
    });
  }

  void _criarUsuario({
    required String email,
    required String password,
    required String name,
  }) {
    authService
        .cadastrarUsuario(email: email, password: password, name: name)
        .then((String? erro) {
          if (erro != null) {
            showSnackBar(context: context, message: erro);
          }
        });
  }

  void redefinicaoSenhaClicado() {
    String email = _emailController.text;

    showDialog(
      context: context,
      builder: (context) {
        TextEditingController redefinicaoSenhaController =
            TextEditingController(text: email);
        return AlertDialog(
          title: const Text("Confirme o email para a redefinição de senha"),
          content: TextFormField(
            controller: redefinicaoSenhaController,
            decoration: const InputDecoration(label: Text("Conrfime o email")),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                authService
                    .redefinicaoSenha(email: redefinicaoSenhaController.text)
                    .then((String? erro) {
                      if (erro == null) {
                        showSnackBar(
                          context: context,
                          message: "Email de redefinição enviado!",
                          isErro: false,
                        );
                      } else {
                        showSnackBar(context: context, message: erro);
                      }
                      Navigator.pop(context);
                    });
              },
              child: const Text("Redefinir senha"),
            ),
          ],
        );
      },
    );
  }
}
