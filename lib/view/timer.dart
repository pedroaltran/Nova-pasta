import 'package:flutter/material.dart';
import 'package:pinatacao/models/atleta.dart';
import 'package:pinatacao/models/treinador.dart';
import 'package:pinatacao/models/treino.dart';
import 'package:pinatacao/models/usuario.dart';
import 'package:pinatacao/services/auth_service.dart';
import 'dart:async';

import 'package:pinatacao/themes/theme_provider.dart';
import 'package:pinatacao/widgets/user_selector_dialog.dart';
import 'package:provider/provider.dart';

class TrainingRegistrationScreen extends StatefulWidget {
  const TrainingRegistrationScreen({
    super.key,
    required this.atleta
  });

  final Atleta atleta;

  @override
  State<TrainingRegistrationScreen> createState() =>
      _TrainingRegistrationScreenState();
}

class _TrainingRegistrationScreenState
    extends State<TrainingRegistrationScreen> {
  final TextEditingController estiloController = TextEditingController();
  final TextEditingController freqCardiacaController = TextEditingController();
  String nomeResponsavel = "";
  Usuario? responsavel;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: estiloController,
              decoration: const InputDecoration(labelText: 'Estilo'),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: freqCardiacaController,
              decoration: const InputDecoration(
                  labelText: 'Frequência Cardíaca Inicial'),
            ),
            const SizedBox(height: 16.0),
            Container(
              child: Row(children: [
                const Text(
                  "Responsável: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Expanded(child: Text(nomeResponsavel)),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context, 
                      builder: (context) => UserSelectorDialog(
                        onConfirm: (usuario) {
                          if(usuario != null) {
                            responsavel = usuario;

                            if(usuario is Treinador) {
                              setState(() => nomeResponsavel = usuario.nomeTreinador);
                              return;
                            }
                            setState(() => nomeResponsavel = (usuario as Atleta).nomeAtleta);
                          }
                        }
                      )
                    );
                  }, 
                  icon: const Icon(Icons.edit)
                ),
              ]),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                double? freqCardiacaInicial = double.tryParse(freqCardiacaController.text);
                String aviso = "";

                if(
                  estiloController.text.isEmpty
                  || nomeResponsavel.isEmpty
                ) {
                  aviso = "Favor preencher todos os campos.";
                } else if(freqCardiacaInicial == null) {
                  aviso = "Favor inserir um número na frequência cardíaca.";
                }

                if(aviso != "") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(aviso),
                      duration: const Duration(seconds: 3),
                    ),
                  );

                  return;
                }

                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => CronometroScreen(
                    atleta: widget.atleta,
                    estilo: estiloController.text,
                    freqCardiacaInical: freqCardiacaInicial!,
                    emailResponsavel: responsavel! is Atleta
                    ? (responsavel! as Atleta).emailAtleta
                    : (responsavel! as Treinador).emailTreinador,
                  ),
                ));
              },
              child: const Text('Iniciar'),
            ),
          ],
        ),
      ),
    );
  }
}

class CronometroScreen extends StatefulWidget {
  const CronometroScreen({
    super.key,
    required this.atleta,
    required this.estilo,
    required this.freqCardiacaInical,
    required this.emailResponsavel
  });

  final Atleta atleta;
  final String estilo;
  final double freqCardiacaInical;
  final String emailResponsavel;

  @override
  State<CronometroScreen> createState() => _CronometroScreenState();
}

class _CronometroScreenState extends State<CronometroScreen> {
  int seconds = 0, minutes = 0, hours = 0;
  String digitSeconds = "00", digitMinutes = "00", digitHours = "00";
  Timer? timer;
  bool started = false;
  List<DateTime> laps = [];
  List<String> lapsText = [];
  bool showFinishButton = false;
  bool showHeartRateInput = false;
  TextEditingController heartRateController = TextEditingController();
  bool showResetButton = false;
  bool showSendButton = false;
  DateTime? startTime;


  void send() {
    double? freqCardiacaFinal = double.tryParse(heartRateController.text);

    if(freqCardiacaFinal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Favor inserir um número na frequência cardíaca."),
          duration: Duration(seconds: 3),
        ),
      );

      return;
    }

    final AuthService authService = AuthService();

    authService.cadastrarTreino(Treino(
      emailAtleta: widget.atleta.emailAtleta, 
      emailSupervisor: widget.emailResponsavel, 
      estilo: widget.estilo, 
      sexoAtleta: widget.atleta.sexoAtleta, 
      horaInicio: startTime!, 
      freqCardiacaInicio: widget.freqCardiacaInical, 
      freqCardiacaFim: freqCardiacaFinal, 
      voltas: laps
    )).then((value) {
      saveHeartRate();
      reset();
    });
  }

  void stop() {
    timer!.cancel();
    setState(() {
      started = false;
      showFinishButton = true;
      showResetButton = true;
      showSendButton = true;
    });
  }

  void reset() {
    timer!.cancel();
    setState(() {
      seconds = 0;
      minutes = 0;
      hours = 0;
      digitSeconds = "00";
      digitMinutes = "00";
      digitHours = "00";
      started = false;
      laps.clear();
      lapsText.clear();
      showFinishButton = false;
      showResetButton = false;
      showSendButton = false;
    });
    startTime = null;
  }

  void addLaps() {
    setState(() {
      laps.add(DateTime.now());
      lapsText.add("$digitHours:$digitMinutes:$digitSeconds");
    });
  }

  void finish() {
    timer?.cancel();
    addLaps();
    setState(() {
      showFinishButton = false;
      showHeartRateInput = true;
    });
  }

  void saveHeartRate() {
    setState(() {
      showHeartRateInput = false;
    });
  }

  void start() {
    started = true;

    setState(() {
      showSendButton = false;
      showResetButton = false;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      int localSeconds = seconds + 1;
      int localMinutes = minutes;
      int localHours = hours;

      if (localSeconds > 59) {
        if (localMinutes > 59) {
          localHours++;
          localMinutes = 0;
        } else {
          localMinutes++;
          localSeconds = 0;
        }
      }

      setState(() {
        seconds = localSeconds;
        minutes = localMinutes;
        hours = localHours;

        digitSeconds = (seconds >= 10) ? "$seconds" : "0$seconds";
        digitMinutes = (minutes >= 10) ? "$minutes" : "0$minutes";
        digitHours = (hours >= 10) ? "$hours" : "0$hours";
      });

      if(localMinutes >= 30) {
        stop();
        finish();
      }
    });
    startTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    ScrollController scrollController = ScrollController();

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!showHeartRateInput)
                const Center(
                  child: Text(
                    "Tempo Cronômetro",
                    style: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(
                height: 20.0,
              ),
              if (!showHeartRateInput)
                Center(
                  child: Text(
                    "$digitHours:$digitMinutes:$digitSeconds",
                    style: const TextStyle(
                      fontSize: 80.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (showHeartRateInput)
                TextFormField(
                  controller: heartRateController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Frequência Cardíaca Final',
                  ),
                ),
              if (!showHeartRateInput)
                Container(
                  height: 200.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Theme.of(context).colorScheme.secondary),
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: laps.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Volta nº${index + 1}",
                              style: TextStyle(
                                  fontSize: 16.0,
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                            Text(
                              lapsText[index],
                              style: const TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20.0),
              if (!showHeartRateInput)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: TextButton.icon(
                        onPressed: () {
                          (!started) ? start() : stop();
                        },
                        style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            foregroundColor:
                                Theme.of(context).colorScheme.primary),
                        icon: Icon(
                          (!started) ? Icons.play_arrow : Icons.pause,
                        ),
                        label: Text(
                          (!started) ? "Iniciar" : "Pausar",
                          style: const TextStyle(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Visibility(
                      visible: started,
                      child: Flexible(
                        child: TextButton.icon(
                          onPressed: () {
                            finish();
                          },
                          style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.primary),
                          icon: const Icon(
                            Icons.stop,
                          ),
                          label: const Text(
                            "Finalizar",
                            style: TextStyle(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Flexible(
                      child: Visibility(
                        visible: started,
                        child: TextButton.icon(
                          onPressed: () {
                            addLaps();
                          },
                          style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.primary),
                          icon: const Icon(
                            Icons.add,
                          ),
                          label: const Text(
                            "Volta",
                            style: TextStyle(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Flexible(
                      child: Visibility(
                        visible: showResetButton,
                        child: TextButton.icon(
                          onPressed: () {
                            reset();
                          },
                          style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.primary),
                          icon: const Icon(
                            Icons.refresh,
                          ),
                          label: const Text(
                            "Resetar",
                            style: TextStyle(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Flexible(
                      child: Visibility(
                        visible: showSendButton,
                        child: TextButton.icon(
                          onPressed: () {
                            stop();
                            finish();
                          },
                          style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.primary),
                          icon: const Icon(
                            Icons.upload_rounded,
                          ),
                          label: const Text(
                            "Enviar",
                            style: TextStyle(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              if (showHeartRateInput)
                ElevatedButton(
                  onPressed: () {
                    send();
                  },
                  child: const Text('Salvar Frequência Cardíaca Final'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
