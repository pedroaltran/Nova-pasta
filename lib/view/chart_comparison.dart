import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pinatacao/models/treino.dart';
import 'package:pinatacao/services/auth_service.dart';
import 'package:pinatacao/themes/theme_provider.dart';
import 'package:pinatacao/widgets/training_filter_dialog.dart';
import 'package:provider/provider.dart';

class ChartComparison extends StatefulWidget {
  const ChartComparison({super.key});

  @override
  State<ChartComparison> createState() => _ChartComparisonState();
}

class _ChartComparisonState extends State<ChartComparison> {
  final AuthService _authService = AuthService();
  final List<Treino> _trainings = [];
  final Random _random = Random();
  Map<String, List<FlSpot>> _mappedLines = {};
  List<LineChartBarData> _lines = [];
  String _estilo = "";
  bool _masc = true;
  bool _fem = true;
  (DateTime min, DateTime max) _dateFilter = (
    DateTime.now().subtract(const Duration(days: 7)),
    DateTime.now().add(const Duration(hours: 1))
  );
  
  Future<void> _loadTrainings() async {
    _trainings.clear();

    _trainings.addAll(await _authService.getTreinos());
    _trainings.sort((a, b) => a.horaInicio.compareTo(b.horaInicio));
  }

  void _loadLines() async {
    await _loadTrainings();
    _lines.clear();
    _mappedLines.clear();

    for(var training in _trainings) {
      if(
        (_estilo != "" && training.estilo != _estilo)
        || (training.sexoAtleta.toLowerCase() == "m" && !_masc)
        || (training.sexoAtleta.toLowerCase() == "f" && !_fem)
        || training.horaInicio.compareTo(_dateFilter.$1) < 0
        || training.horaInicio.compareTo(_dateFilter.$2) > 0
      ) {
        continue;
      }

      if(!_mappedLines.containsKey(training.emailAtleta)) {
        _mappedLines[training.emailAtleta] = <FlSpot>[];
      }

      _mappedLines[training.emailAtleta]!.add(FlSpot(
        _mappedLines[training.emailAtleta]!.length.toDouble(), 
        training.voltas.length.toDouble()
      ));
    }

    for(var mappedLineKey in _mappedLines.keys) {
      _lines.add(LineChartBarData(
        spots: _mappedLines[mappedLineKey] ?? [],
        color: Color.fromRGBO(
          _random.nextInt(200), 
          _random.nextInt(200), 
          _random.nextInt(200), 
          1
        ),
      ));
    }

    setState(() {});
  }

  void _updateFilter() {
    showDialog(
      context: context, 
      builder: (context) => TrainingFilterDialog(
        estilo: _estilo,
        masc: _masc,
        fem: _fem,
        periodo: _dateFilter,
        onConfirm: (estilo, masc, fem, periodo) {
          _estilo = estilo;
          _masc = masc;
          _fem = fem;
          _dateFilter = periodo;

          _loadLines();
        },
      )
    );
  }

  @override
  void initState() {
    super.initState();
    _loadLines();
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
      body: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: _loadLines, 
              icon: const Icon(Icons.refresh_rounded)
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: _updateFilter, 
              icon: const Icon(Icons.filter_alt),
            )
          ],
        ),
        Expanded(child: Center(child: Container(
          height: MediaQuery.sizeOf(context).height - 100,
          width: MediaQuery.sizeOf(context).width * 0.8,
          constraints: const BoxConstraints(
            minHeight: 0,
            maxHeight: 600,
            minWidth: 0,
            maxWidth: 1000
          ),
          child: FittedBox(child: SizedBox(
            height: 400,
            width: 700,
            child: Column(
              children: [
                const Row(children: [Text("Número de voltas")]),
                Expanded(child: LineChart(
                  LineChartData(
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        ),
                        left: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        ),
                      ),
                    ), 
                    lineBarsData: _lines
                  ),
                )),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [Text("Sequência de treinos")]
                ),
              ],
            ),
          ))
          
          
          ,
        ))),
      ]),
    );
  }
}