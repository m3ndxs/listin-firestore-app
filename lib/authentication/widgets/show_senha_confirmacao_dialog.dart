import 'package:flutter/material.dart';
import 'package:listin/authentication/services/auth_service.dart';

void showSenhaConfirmacaoDialog({
  required BuildContext context,
  required String email,
}) {
  showDialog(
    context: context,
    builder: (context) {
      TextEditingController senhaConfirmacaoController =
          TextEditingController();

      return AlertDialog(
        title: Text("Deseja remover a conta com o email $email?"),
        content: SizedBox(
          height: 175,
          child: Column(
            children: [
              const Text(
                "Para confirmar a remoção da senha, insira sua senha:",
              ),
              TextFormField(
                controller: senhaConfirmacaoController,
                obscureText: true,
                decoration: const InputDecoration(label: Text("Senha")),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              AuthService().removerConta(
                senha: senhaConfirmacaoController.text,
              ).then((String? erro) {
                if (erro == null) {
                  Navigator.pop(context);
                }
              });
            },
            child: const Text("Excluir conta"),
          ),
        ],
      );
    },
  );
}
