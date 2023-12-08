import 'package:flutter/material.dart';
import 'package:pinatacao/models/atleta.dart';
import 'package:pinatacao/models/treinador.dart';
import 'package:pinatacao/models/usuario.dart';
import 'package:pinatacao/services/auth_service.dart';

class UserSelectorDialog extends StatefulWidget {
  const UserSelectorDialog({
    super.key,
    required this.onConfirm
  });

  final void Function(Usuario? usuario) onConfirm;

  @override
  State<UserSelectorDialog> createState() => _UserSelectorDialogState();
}

class _UserSelectorDialogState extends State<UserSelectorDialog> {
  final AuthService _authService = AuthService();
  final List<Usuario> _users = [];
  int? _chosenUser;

  void loadUsers() async {
    _users.addAll(await _authService.getUsuarios());
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Escolha o Usuário"),
      content: Container(
        width: MediaQuery.sizeOf(context).width * 0.9,
        height: MediaQuery.sizeOf(context).height * 0.7,
        constraints: const BoxConstraints(
          maxWidth: 500
        ),
        child: ListView.builder(
          itemCount: _users.length,
          itemBuilder: (context, index) => Container(
            color: _chosenUser == index ? Theme.of(context).primaryColor.withOpacity(0.5) : null,
            child: ListTile(
              onTap: () {
                setState(() {
                  _chosenUser = index;
                });
              },
              leading: const Icon(Icons.account_circle),
              title: Text(
                _users[index] is Treinador ? 
                (_users[index] as Treinador).nomeTreinador :
                (_users[index] as Atleta).nomeAtleta
              ),
            ),
          )
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          }, 
          child: const Text("Cancelar")
        ),
        TextButton(
          onPressed: () {
            widget.onConfirm(_chosenUser == null ? null : _users[_chosenUser!]);
            Navigator.of(context).pop();
          }, 
          child: const Text("Ok")
        ),
      ],
    );
  }
}