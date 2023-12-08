import 'package:pinatacao/models/usuario.dart';

class Administrador extends Usuario {
  final String nomeAdministrador;
  final String emailAdministrador;

  Administrador({
    super.id,
   required this.nomeAdministrador,
   required this.emailAdministrador
  });

  factory Administrador.fromMap(Map<String, dynamic> map) => Administrador(
    nomeAdministrador: map["nomeAdministrador"], 
    emailAdministrador: map["emailAdministrador"]
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "nomeAdministrador": nomeAdministrador,
    "emailAdministrador": emailAdministrador,
  };
}