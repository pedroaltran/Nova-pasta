import 'package:flutter/material.dart';
import 'package:pinatacao/view/create_user.dart';
import 'create_user.dart';

class HomeAdm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              // Adicione aqui a lógica para realizar o logout
              Navigator.of(context).pushReplacementNamed(
                  './main'); // Navega de volta para a tela principal (main)
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Text('Histórico de treinos', style: TextStyle(fontSize: 24.0)),
            Expanded(
              child: ListView.builder(
                itemCount: listaAtleta
                    .length, // Substitua 'listaAtletas' pelo nome da sua lista de atletas
                itemBuilder: (BuildContext context, int index) {
                  final atleta = listaAtleta[
                      index]; // Substitua 'listaAtletas' pelo nome da sua lista de atletas
                  return Card(
                    child: ListTile(
                      title: Text('Nome: ${atleta.nomeAtleta}'),
                      subtitle: Text('Email: ${atleta.emailAtleta}'),
                      // Adicione outros campos do atleta que deseja exibir
                      // Você pode personalizar a exibição de acordo com suas necessidades
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CadastroPage()),
          );
        },
        child: Icon(Icons.person_add),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
      ),
    );
  }
}
