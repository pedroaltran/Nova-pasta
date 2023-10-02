import 'package:flutter/material.dart';

class HomeUser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
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
        child: Text('Historico de treinos'),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //Função aqui
        },
        child: Icon(Icons.watch),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                //Função aqui
              },
            ),
            SizedBox(), // Este SizedBox é apenas para criar espaço no meio
            IconButton(
              icon: Icon(Icons.auto_graph_rounded),
              onPressed: () {
                // Adicione aqui a ação para a terceira opção
              },
            ),
          ],
        ),
      ),
    );
  }
}
