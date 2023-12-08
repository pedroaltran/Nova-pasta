import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:pinatacao/models/administrador.dart';
import 'package:pinatacao/models/atleta.dart';
import 'package:pinatacao/models/treino.dart';
import 'package:pinatacao/models/usuario.dart';
import 'package:pinatacao/services/auth_service.dart';
import 'package:pinatacao/themes/theme_provider.dart';
import 'package:pinatacao/view/chart_comparison.dart';
import 'package:pinatacao/view/timer.dart';
import 'package:pinatacao/view/training_details.dart';
import 'package:pinatacao/widgets/navbar.dart';
import 'package:provider/provider.dart';

class HomeUser extends StatefulWidget {
  final Usuario usuario;
  final TipoUsuario tipoUsuario;
  
  const HomeUser({
    super.key,
    required this.usuario
  }): 
  assert(usuario is! Administrador),
  tipoUsuario = usuario is Atleta ? TipoUsuario.atleta : TipoUsuario.treinador;

  @override
  State<HomeUser> createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> {
  final AuthService _authService = AuthService();
  final List<Treino> _trainings = [];
  (DateTime min, DateTime max) _dateFilter = (
    DateTime.now().subtract(const Duration(days: 7)),
    DateTime.now().add(const Duration(hours: 1))
  );

  void _updateDateFilter() async {
    List<DateTime>? dateTimeList = await showOmniDateTimeRangePicker(
      context: context,
      is24HourMode: true,
      startInitialDate: _dateFilter.$1,
      endInitialDate: _dateFilter.$2,
    );

    if(dateTimeList != null && dateTimeList.length == 2) {
      setState(() {
        _dateFilter = (dateTimeList.first, dateTimeList.last);
      });
    }
  }

  void _loadTrainings() {
    if(widget.tipoUsuario == TipoUsuario.atleta) {
      _trainings.clear();

      _authService.getTreinos(
        athleteEmail: (widget.usuario as Atleta).emailAtleta
      ).then((value) {
        _trainings.addAll(value);
        _trainings.sort((a, b) => a.horaInicio.compareTo(b.horaInicio));
        setState(() {});
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTrainings();
  }

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
      body: widget.tipoUsuario != TipoUsuario.atleta
      ? const Center(child: Text('Histórico de Treinos'))
      : Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: _loadTrainings, 
              icon: const Icon(Icons.refresh_rounded)
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: _updateDateFilter, 
              icon: const Icon(Icons.filter_alt),
            )
          ],
        ),
        Expanded(child: ListView.builder(
          itemCount: _trainings.length,
          itemBuilder: (context, index) => (
            _trainings[index].horaInicio.compareTo(_dateFilter.$1) > 0
            && _trainings[index].horaInicio.compareTo(_dateFilter.$2) < 0
          ) ? InkWell(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => TrainingDetails(
                treino: _trainings[index],
                tituloTreino: "Treino n° ${index + 1}",
              )
            )),
            child: ListTile(
              leading: const Icon(Icons.fitness_center_rounded),
              title: Text("Treino n° ${index + 1}"),
              trailing: Text(DateFormat("dd/MM/yyyy").format(_trainings[index].horaInicio)),
            ),
          ) : const SizedBox.shrink()
        )),
      ]),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: widget.tipoUsuario == TipoUsuario.atleta ? () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TrainingRegistrationScreen(
                atleta: widget.usuario as Atleta,
              )
            ),
          );
        } : null,
        child: const Icon(Icons.watch),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {},
            ),
            const SizedBox(),
            IconButton(
              icon: const Icon(Icons.auto_graph_rounded),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChartComparison()
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
