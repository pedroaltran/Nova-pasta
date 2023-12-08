import 'package:pinatacao/models/usuario.dart';

class Treinador extends Usuario {
  String nomeTreinador;
  String emailTreinador;
  String formacaoTreinador;

  Treinador({
    super.id,
    required this.nomeTreinador,
    required this.emailTreinador,
    required this.formacaoTreinador,
  });

  factory Treinador.fromMap(Map<String, dynamic> map) => Treinador(
    nomeTreinador: map["nomeTreinador"], 
    emailTreinador: map["emailTreinador"], 
    formacaoTreinador: map["formacaoTreinador"]
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nomeTreinador': nomeTreinador,
      'emailTreinador': emailTreinador,
      'formacaoTreinador': formacaoTreinador,
    };
  }

  toJson() {
    return {
      'id': id,
      'nomeTreinador': nomeTreinador,
      'emailTreinador': emailTreinador,
      'formacaoTreinador': formacaoTreinador,
    };
  }
}
