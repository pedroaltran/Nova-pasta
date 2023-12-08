import 'package:flutter/material.dart';
import 'package:pinatacao/models/administrador.dart';
import 'package:pinatacao/models/atleta.dart';
import 'package:pinatacao/themes/theme_provider.dart';
import 'package:pinatacao/view/create_user.dart';
import 'package:pinatacao/widgets/navbar.dart';
import 'package:provider/provider.dart';

class HomeAdm extends StatelessWidget {
  final Atleta atleta = Atleta(
    emailAtleta: 'pedroaltran@live.com',
    nomeAtleta: 'Pedro Altran',
    dataNascimentoAtleta: '20/02/1999',
    nacionalidadeAtleta: 'Brasileiro',
    rgAtleta: '50.400.400-0',
    cpfAtleta: '220.400.400-80',
    sexoAtleta: 'Masculino',
    cepAtleta: '14000-320',
    cidadeAtleta: 'Ribeirão Preto',
    logradouroAtleta: '',
    numAtleta: '',
    bairroAtleta: '',
    ufAtleta: '',
    convenioMedicoAtleta: 'Não',
    fotoAtestadoAtleta: 'Não',
    fotoRgAtleta: 'Não',
    fotoCpfAtleta: 'Não',
    fotoCompResidenciaAtleta: 'Não',
    foto3x4Atleta: 'Não',
    fotoRegulamentoAtleta: 'Não',
    telefonesAtleta: {'celular': '16997433394', 'emergencia': ''},
    complEnderecoAtleta: '',
    nomeMaeAtleta: 'Marilda',
    nomePaiAtleta: 'Marcos',
    clubeOrigemAtleta: 'Unaerp',
  );
  final Administrador? adm;

  HomeAdm({super.key, required this.adm});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      drawer: const NavBar(),
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Center(
          child: Image.asset(
            themeProvider.isDarkMode
                ? 'assets/images/logoapp-white.png'
                : 'assets/images/logoapp.png',
            width: 150,
            height: 70,
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 24.0),
              child: Text('Histórico de treinos',
                  style: TextStyle(fontSize: 22.0)),
            ),
            AtletaDetailsWidget(atleta: atleta),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CadastroPage()),
          );
        },
        child: const Icon(Icons.person_add),
      ),
      bottomNavigationBar: const BottomAppBar(
        shape: CircularNotchedRectangle(),
      ),
    );
  }
}

class AtletaDetailsWidget extends StatelessWidget {
  final Atleta atleta;

  const AtletaDetailsWidget({super.key, required this.atleta});

  void _exibirDetalhes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          width: 350.0,
          child: SingleChildScrollView(
            child: ListView(
              shrinkWrap: true,
              children: [
                const Text(
                  'Detalhes do Treino',
                  style: TextStyle(fontSize: 18.0),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 4.0,
                  child: ListTile(
                    title: const Text('Nome do Atleta'),
                    subtitle: Text(atleta.nomeAtleta),
                    leading: const Icon(Icons.person),
                  ),
                ),
                Card(
                  elevation: 4.0,
                  child: ListTile(
                    title: const Text('Email'),
                    subtitle: Text(atleta.emailAtleta),
                    leading: const Icon(Icons.email),
                  ),
                ),
                Card(
                  elevation: 4.0,
                  child: ListTile(
                    title: const Text('Data de Nascimento'),
                    subtitle: Text(atleta.dataNascimentoAtleta),
                    leading: const Icon(Icons.calendar_today),
                  ),
                ),
                Card(
                  elevation: 4.0,
                  child: ListTile(
                    title: const Text('Nacionalidade'),
                    subtitle: Text(atleta.nacionalidadeAtleta),
                    leading: const Icon(Icons.public),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Detalhes do Treino',
                  style: TextStyle(fontSize: 18.0)),
              const SizedBox(height: 8),
              Text('Nome do atleta: ${atleta.nomeAtleta}'),
              Text('Email: ${atleta.emailAtleta}'),
              Text('Data de Nascimento: ${atleta.dataNascimentoAtleta}'),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _exibirDetalhes(context);
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text('Exibir Mais'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
