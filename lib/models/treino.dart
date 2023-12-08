class Treino {
  final String emailAtleta;
  final String sexoAtleta;
  final String emailSupervisor;
  final String estilo;
  final DateTime horaInicio;
  final double freqCardiacaInicio;
  final double freqCardiacaFim;
  final List<DateTime> voltas;

  Treino({
    required this.emailAtleta,
    required this.emailSupervisor,
    required this.estilo,
    required this.sexoAtleta,
    required this.horaInicio,
    required this.freqCardiacaInicio,
    required this.freqCardiacaFim,
    required this.voltas
  });

  factory Treino.fromMap(Map<String, dynamic> map) => Treino(
    emailAtleta: map["emailAtleta"], 
    emailSupervisor: map["emailSupervisor"],
    estilo: map["estilo"],
    sexoAtleta: map["sexoAtleta"],
    horaInicio: DateTime.parse(map["horaInicio"]),
    freqCardiacaInicio: map["freqCardiacaInicio"],
    freqCardiacaFim: map["freqCardiacaFim"],
    voltas: [for(var volta in map["voltas"]) DateTime.parse(volta)],
  );

  Map<String, dynamic> toMap() => {
    "emailAtleta": emailAtleta,
    "emailSupervisor": emailSupervisor,
    "estilo": estilo,
    "sexoAtleta": sexoAtleta,
    "horaInicio": horaInicio.toIso8601String(),
    "freqCardiacaInicio": freqCardiacaInicio,
    "freqCardiacaFim": freqCardiacaFim,
    "voltas": [for(var volta in voltas) volta.toIso8601String()]
  };
}