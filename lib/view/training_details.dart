import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pinatacao/models/atleta.dart';
import 'package:pinatacao/models/treinador.dart';
import 'package:pinatacao/models/treino.dart';
import 'package:pinatacao/services/auth_service.dart';
import 'package:pinatacao/themes/theme_provider.dart';
import 'package:provider/provider.dart';

enum LapAverageStatus {
  belowAverageRange,
  inAverageRange,
  aboveAverageRange
}

class TrainingDetails extends StatefulWidget {
  const TrainingDetails({
    super.key,
    required this.treino,
    required this.tituloTreino
  });

  final Treino treino;
  final String tituloTreino;

  @override
  State<TrainingDetails> createState() => _TrainingDetailsState();
}

class _TrainingDetailsState extends State<TrainingDetails> {
  final AuthService _authService = AuthService();
  String _supervisorName = "";
  bool _showAboveAverageRange = true;
  bool _showInAverageRange = true;
  bool _showBelowAverageRange = true;
  double _averageLapSeconds = 0;
  final List<(
    int lapSeconds,
    LapAverageStatus averageStatus
  )> _lapsData = [];

  void _loadLaps() async {
    DateTime previousTime = widget.treino.horaInicio;
    List<int> lapsSeconds = [];
    int totalOfSeconds = 0;

    for(var lap in widget.treino.voltas) {
      int differenceInSeconds = lap.difference(previousTime).inSeconds;
      lapsSeconds.add(differenceInSeconds);
      totalOfSeconds += differenceInSeconds;
      previousTime = lap;
    }

    _averageLapSeconds = totalOfSeconds / lapsSeconds.length;

    for(var lapSeconds in lapsSeconds) {
      _lapsData.add((
        lapSeconds,
        lapSeconds > _averageLapSeconds * 1.2
        ? LapAverageStatus.belowAverageRange
        : (lapSeconds < _averageLapSeconds * 0.8
          ? LapAverageStatus.aboveAverageRange
          : LapAverageStatus.inAverageRange
        )
      ));
    }

    setState(() {});
  }

  String _durationToString(Duration duration) {
    String negativeSign = duration.isNegative ? '-' : '';
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());

    return "$negativeSign${twoDigits(duration.inHours)}h${twoDigitMinutes}min${twoDigitSeconds}s";
  }

  @override
  void initState() {
    super.initState();

    _authService.getUsuario(widget.treino.emailSupervisor).then((value) {
      if(value is Atleta) {
        _supervisorName = value.nomeAtleta;
      } else if(value is Treinador) {
        _supervisorName = value.nomeTreinador;
      }
    }).then((value) => _loadLaps());
  }
  
  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(30, 50, 30, 50),
        child: Column(children: [
          Text(
            widget.tituloTreino,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25
            ),
          ),
          const SizedBox(height: 20),
          Row(children: [
            const Text(
              "Supervisor: ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_supervisorName)
          ]),
          const SizedBox(height: 10),
          Row(children: [
            const Text(
              "Estilo: ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(widget.treino.estilo)
          ]),
          const SizedBox(height: 10),
          Row(children: [
            const Text(
              "Início do Treino: ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(DateFormat("dd/MM/yyyy HH:mm:ss").format(widget.treino.horaInicio))
          ]),
          const SizedBox(height: 10),
          Row(children: [
            const Text(
              "Término do Treino: ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              widget.treino.voltas.isNotEmpty
              ? DateFormat("dd/MM/yyyy HH:mm:ss").format(widget.treino.voltas.last)
              : "-"
            )
          ]),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.monitor_heart_outlined),
            const SizedBox(width: 10),
            const Text(
              "Frequência Cardíaca Inicial: ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("${widget.treino.freqCardiacaInicio}")
          ]),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.monitor_heart_rounded),
            const SizedBox(width: 10),
            const Text(
              "Frequência Cardíaca Final: ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("${widget.treino.freqCardiacaFim}")
          ]),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.auto_graph_rounded),
            const SizedBox(width: 10),
            const Text(
              "Média de Duração de Voltas: ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_durationToString(Duration(seconds: _averageLapSeconds.round())))
          ]),
          const SizedBox(height: 30),
          const Text(
            "Voltas",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20
            ),
          ),
          const SizedBox(height: 30),
          Row(children: [
            Expanded(child: SizedBox(child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: _showBelowAverageRange, 
                  onChanged: (value) {
                    if(value != null) {
                      setState(() {
                        _showBelowAverageRange = value;
                      });
                    }
                  }
                ),
                const Text("Abaixo da Média")
              ],
            ))),
            Expanded(child: SizedBox(child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: _showInAverageRange, 
                  onChanged: (value) {
                    if(value != null) {
                      setState(() {
                        _showInAverageRange = value;
                      });
                    }
                  }
                ),
                const Text("Na Média")
              ],
            ))),
            Expanded(child: SizedBox(child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: _showAboveAverageRange, 
                  onChanged: (value) {
                    if(value != null) {
                      setState(() {
                        _showAboveAverageRange = value;
                      });
                    }
                  }
                ),
                const Text("Acima da Média")
              ],
            ))),
          ]),
          const SizedBox(height: 20),
          SizedBox(
            height: MediaQuery.sizeOf(context).height - 56,
            child: ListView.builder(
              itemCount: _lapsData.length,
              itemBuilder: (context, index) => (
                (_lapsData[index].$2 == LapAverageStatus.aboveAverageRange
                && !_showAboveAverageRange)
                || (_lapsData[index].$2 == LapAverageStatus.inAverageRange
                && !_showInAverageRange)
                || (_lapsData[index].$2 == LapAverageStatus.belowAverageRange
                && !_showBelowAverageRange)
              ) ? const SizedBox.shrink()
              : ListTile(
                leading: const Icon(Icons.pool_rounded),
                title: Text("Volta n° ${index + 1}"),
                subtitle: Text("Tempo: ${
                  _durationToString(Duration(seconds: _lapsData[index].$1))
                }"),
                trailing: _lapsData[index].$2 == LapAverageStatus.aboveAverageRange
                ? const Icon(Icons.trending_up_rounded)
                : (_lapsData[index].$2 == LapAverageStatus.belowAverageRange
                  ? const Icon(Icons.trending_down_rounded)
                  : null
                ),
              )
            ),
          )
        ]),
      ),
    );
  }
}