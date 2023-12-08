import 'package:pinatacao/models/usuario.dart';

class Atleta extends Usuario {
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
  Map<String, String> telefonesAtleta;
  String? complEnderecoAtleta;
  String? nomeMaeAtleta;
  String? nomePaiAtleta;
  String? clubeOrigemAtleta;

  Atleta({
    super.id,
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
    required this.telefonesAtleta,
    this.complEnderecoAtleta,
    this.nomeMaeAtleta,
    this.nomePaiAtleta,
    this.clubeOrigemAtleta,
  });

  factory Atleta.fromMap(Map<String, dynamic> map) => Atleta(
        emailAtleta: map["emailAtleta"],
        nomeAtleta: map["nomeAtleta"],
        dataNascimentoAtleta: map["dataNascimentoAtleta"],
        nacionalidadeAtleta: map["nacionalidadeAtleta"],
        rgAtleta: map["rgAtleta"],
        cpfAtleta: map["cpfAtleta"],
        sexoAtleta: map["sexoAtleta"],
        cepAtleta: map["cepAtleta"],
        cidadeAtleta: map["cidadeAtleta"],
        logradouroAtleta: map["logradouroAtleta"],
        numAtleta: map["numAtleta"],
        bairroAtleta: map["bairroAtleta"],
        ufAtleta: map["ufAtleta"],
        convenioMedicoAtleta: map["convenioMedicoAtleta"],
        fotoAtestadoAtleta: map["imgUrlAtestado"],
        fotoRgAtleta: map["imgUrlRg"],
        fotoCpfAtleta: map["imgUrlCpf"],
        fotoCompResidenciaAtleta: map["imgUrlCompResidencia"],
        foto3x4Atleta: map["imgUrl3x4"],
        fotoRegulamentoAtleta: map["imgUrlRegulamento"],
        telefonesAtleta: (map["telefonesAtleta"] as Map).map((key, value) {
          if (key is String && value is String) {
            return MapEntry(key, value);
          }
          return MapEntry(key.toString(), value.toString());
        }),
        complEnderecoAtleta: map["complEnderecoAtleta"],
        nomeMaeAtleta: map["nomeMaeAtleta"],
        nomePaiAtleta: map["nomePaiAtleta"],
        clubeOrigemAtleta: map["clubeOrigemAtleta"],
      );

  Map<String, dynamic> toMap() {
    return {
      'emailAtleta': emailAtleta,
      'nomeAtleta': nomeAtleta,
      'dataNascimentoAtleta': dataNascimentoAtleta,
      'nacionalidadeAtleta': nacionalidadeAtleta,
      'rgAtleta': rgAtleta,
      'cpfAtleta': cpfAtleta,
      'sexoAtleta': sexoAtleta,
      'cepAtleta': cepAtleta,
      'cidadeAtleta': cidadeAtleta,
      'logradouroAtleta': logradouroAtleta,
      'numAtleta': numAtleta,
      'bairroAtleta': bairroAtleta,
      'ufAtleta': ufAtleta,
      'convenioMedicoAtleta': convenioMedicoAtleta,
      'imgUrlAtestado': fotoAtestadoAtleta,
      'imgUrlRg': fotoRgAtleta,
      'imgUrlCpf': fotoCpfAtleta,
      'imgUrlCompResidencia': fotoCompResidenciaAtleta,
      'imgUrl3x4': foto3x4Atleta,
      'imgUrlRegulamento': fotoRegulamentoAtleta,
      'telefonesAtleta': telefonesAtleta,
      'complEnderecoAtleta': complEnderecoAtleta,
      'nomeMaeAtleta': nomeMaeAtleta,
      'nomePaiAtleta': nomePaiAtleta,
      'clubeOrigemAtleta': clubeOrigemAtleta,
    };
  }

  toJson() {
    return {
      "Id": id,
      "Email": emailAtleta,
      "Nome": nomeAtleta,
      "DataNascimento": dataNascimentoAtleta,
      "Nacionalidade": nacionalidadeAtleta,
      "Rg": rgAtleta,
      "Cpf": cpfAtleta,
      "Sexo": sexoAtleta,
      "Cep": cepAtleta,
      "Cidade": cidadeAtleta,
      "Logradouro": logradouroAtleta,
      "Numero": numAtleta,
      "Bairro": bairroAtleta,
      "Uf": ufAtleta,
      "ConvenioMedico": convenioMedicoAtleta,
      "FotoAtestado": fotoAtestadoAtleta,
      "FotoRg": fotoRgAtleta,
      "FotoCpf": fotoCpfAtleta,
      "FotoCompResidencia": fotoCompResidenciaAtleta,
      "Foto3x4": foto3x4Atleta,
      "FotoRegulamento": fotoRegulamentoAtleta,
      "Telefones": telefonesAtleta,
      "ComplEndereco": complEnderecoAtleta,
      "NomeMae": nomeMaeAtleta,
      "NomePai": nomePaiAtleta,
      "ClubeOrigem": clubeOrigemAtleta,
    };
  }
}
