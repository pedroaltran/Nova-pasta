class Atleta {
  String emailAtleta;
  String nomeAtleta;
  String dataNascimentoAtleta;
  String nacionalidadeAtleta;
  String rgAtleta;
  String cpfAtleta;
  String sexoAtleta;
  String cepAtleta;
  String cidadeAtleta;
  String logradouroAtleta;
  String numAtleta;
  String bairroAtleta;
  String ufAtleta;
  String convenioMedicoAtleta;
  String fotoAtestadoAtleta;
  String fotoRgAtleta;
  String fotoCpfAtleta;
  String fotoCompResidenciaAtleta;
  String foto3x4Atleta;
  String fotoRegulamentoAtleta;
  List<String> estilosAtleta;
  List<String> provasAtleta;
  Map<String, String> telefonesAtleta;
  String? complEnderecoAtleta;
  String? nomeMaeAtleta;
  String? nomePaiAtleta;
  String? clubeOrigemAtleta;
  String? localTrabalhoAtleta;
  List<String>? alergiaMedAtleta;

  Atleta({
    required this.emailAtleta,
    required this.nomeAtleta,
    required this.dataNascimentoAtleta,
    required this.nacionalidadeAtleta,
    required this.rgAtleta,
    required this.cpfAtleta,
    required this.sexoAtleta,
    required this.cepAtleta,
    required this.cidadeAtleta,
    required this.logradouroAtleta,
    required this.numAtleta,
    required this.bairroAtleta,
    required this.ufAtleta,
    required this.convenioMedicoAtleta,
    required this.fotoAtestadoAtleta,
    required this.fotoRgAtleta,
    required this.fotoCpfAtleta,
    required this.fotoCompResidenciaAtleta,
    required this.foto3x4Atleta,
    required this.fotoRegulamentoAtleta,
    required this.estilosAtleta,
    required this.provasAtleta,
    this.telefonesAtleta = const {},
    this.complEnderecoAtleta,
    this.nomeMaeAtleta,
    this.nomePaiAtleta,
    this.clubeOrigemAtleta,
    this.localTrabalhoAtleta,
    this.alergiaMedAtleta,
  });
  @override
  String toString() {
    return 'Atleta{'
        'emailAtleta: $emailAtleta, '
        'nomeAtleta: $nomeAtleta, '
        'dataNascimentoAtleta: $dataNascimentoAtleta, '
        'nacionalidadeAtleta: $nacionalidadeAtleta, '
        'rgAtleta: $rgAtleta, '
        'cpfAtleta: $cpfAtleta, '
        'sexoAtleta: $sexoAtleta, '
        'cepAtleta: $cepAtleta, '
        'cidadeAtleta: $cidadeAtleta, '
        'logradouroAtleta: $logradouroAtleta, '
        'numAtleta: $numAtleta, '
        'bairroAtleta: $bairroAtleta, '
        'ufAtleta: $ufAtleta, '
        'convenioMedicoAtleta: $convenioMedicoAtleta, '
        'fotoAtestadoAtleta: $fotoAtestadoAtleta, '
        'fotoRgAtleta: $fotoRgAtleta, '
        'fotoCpfAtleta: $fotoCpfAtleta, '
        'fotoCompResidenciaAtleta: $fotoCompResidenciaAtleta, '
        'foto3x4Atleta: $foto3x4Atleta, '
        'fotoRegulamentoAtleta: $fotoRegulamentoAtleta, '
        'estilosAtleta: $estilosAtleta, '
        'provasAtleta: $provasAtleta, '
        'telefonesAtleta: $telefonesAtleta, '
        'complEnderecoAtleta: $complEnderecoAtleta, '
        'nomeMaeAtleta: $nomeMaeAtleta, '
        'nomePaiAtleta: $nomePaiAtleta, '
        'clubeOrigemAtleta: $clubeOrigemAtleta, '
        'localTrabalhoAtleta: $localTrabalhoAtleta, '
        'alergiaMedAtleta: $alergiaMedAtleta}';
  }
}
