import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pinatacao/models/atleta.dart';
import 'package:pinatacao/models/treinador.dart';
import 'package:pinatacao/services/auth_service.dart';
import 'package:pinatacao/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final AuthService _authService = AuthService();

  final _formKey = GlobalKey<FormState>();
  Atleta novoAtleta = Atleta(
    emailAtleta: '',
    nomeAtleta: '',
    dataNascimentoAtleta: '',
    nacionalidadeAtleta: '',
    rgAtleta: '',
    cpfAtleta: '',
    sexoAtleta: '',
    cepAtleta: '',
    cidadeAtleta: '',
    logradouroAtleta: '',
    numAtleta: '',
    bairroAtleta: '',
    ufAtleta: '',
    convenioMedicoAtleta: '',
    fotoAtestadoAtleta: '',
    fotoRgAtleta: '',
    fotoCpfAtleta: '',
    fotoCompResidenciaAtleta: '',
    foto3x4Atleta: '',
    fotoRegulamentoAtleta: '',
    telefonesAtleta: {},
  );

  Treinador novoTreinador =
      Treinador(emailTreinador: '', nomeTreinador: '', formacaoTreinador: '');

  // Campos dos atletas

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _dataNascimentoController =
      TextEditingController();
  final TextEditingController _rgController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _sexoController = TextEditingController();
  final TextEditingController _cepController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _logradouroController = TextEditingController();
  final TextEditingController _numController = TextEditingController();
  final TextEditingController _bairroController = TextEditingController();
  final TextEditingController _ufController = TextEditingController();
  final TextEditingController _convenioMedicoController =
      TextEditingController();
  final TextEditingController _telCelController = TextEditingController();
  final TextEditingController _telEmerController = TextEditingController();
  final TextEditingController _complEnderecoController =
      TextEditingController();
  final TextEditingController _nomeMaeController = TextEditingController();
  final TextEditingController _nomePaiController = TextEditingController();
  final TextEditingController _clubeOrigemController = TextEditingController();

  String? _selectedAthleteOrCoach;
  String? _selectedNaturalidade;
  List<String> _countries = [];

  String imgUrlAtestado = '';
  String imgUrlRg = '';
  String imgUrlCpf = '';
  String imgUrlCompResidencia = '';
  String imgUrl3x4 = '';
  String imgUrlRegulamento = '';

  Map<String, String> _countryFlags = {};

  final TextEditingController _nomeTreinadorController =
      TextEditingController();
  final TextEditingController _emailTreinadorController =
      TextEditingController();
  final TextEditingController _formacaoTreinadorController =
      TextEditingController();

  File? tempImage;

  @override
  void initState() {
    super.initState();
    fetchCountries().then((countries) {
      setState(() {
        _countries = countries;
      });
    });
  }

  Future<List<String>> fetchCountries() async {
    final response =
        await http.get(Uri.parse('https://restcountries.com/v3.1/all'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<String> countries = data
          .map((country) {
            final name = country['name'];
            if (name is String) {
              return name;
            }
            return name['common'];
          })
          .whereType<String>()
          .toList();

      _countryFlags = {
        for (var country in data)
          country['name']['common']: country['flags']['png']
      };

      return countries;
    } else {
      throw Exception('Falha ao carregar a lista de países');
    }
  }

  Future<void> buscaCep(String cep) async {
    final response =
        await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      _logradouroController.text = data['logradouro'];
      _cidadeController.text = data['localidade'];
      _bairroController.text = data['bairro'];
      _ufController.text = data['uf'];
    } else {
      'Erro ao buscar endereço: ${response.statusCode}';
    }
  }

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;
      tempImage = File(image.path);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    _countries.sort();

    return Scaffold(
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
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 16.0),
              Container(
                margin: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<String>(
                  padding: const EdgeInsets.all(10.0),
                  value: _selectedAthleteOrCoach,
                  onChanged: (value) {
                    setState(() {
                      _selectedAthleteOrCoach = value;
                    });
                  },
                  items: ['Atleta', 'Treinador'].map((String userType) {
                    return DropdownMenuItem<String>(
                      value: userType,
                      child: Text(userType),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Atleta ou Treinador',
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Visibility(
                visible: _selectedAthleteOrCoach == 'Atleta',
                child: Column(
                  children: [
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Email',
                          labelStyle: TextStyle(fontSize: 14.0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Este campo é obrigatório";
                          }
                          novoAtleta.emailAtleta = value;
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        controller: _nomeController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Nome Completo',
                          labelStyle: TextStyle(fontSize: 14.0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Este campo é obrigatório";
                          }
                          novoAtleta.nomeAtleta = value;
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        controller: _dataNascimentoController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Data de Nascimento',
                          labelStyle: TextStyle(fontSize: 14.0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Este campo é obrigatório";
                          }
                          novoAtleta.dataNascimentoAtleta = value;
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: DropdownButtonFormField<String>(
                        value: _selectedNaturalidade,
                        onChanged: (value) {
                          setState(() {
                            _selectedNaturalidade = value;
                          });
                        },
                        items: _countries.map((country) {
                          return DropdownMenuItem<String>(
                            value: country,
                            child: Row(
                              children: [
                                Image.network(
                                  _countryFlags[country] ?? '',
                                  width: 24,
                                  height: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(country),
                              ],
                            ),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Nacionalidade',
                          labelStyle: TextStyle(fontSize: 14.0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Este campo é obrigatório";
                          }
                          novoAtleta.nacionalidadeAtleta = value;
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 8,
                            child: TextFormField(
                              controller: _cepController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'CEP',
                                labelStyle: TextStyle(fontSize: 14.0),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Este campo é obrigatório";
                                }
                                novoAtleta.cepAtleta = value;
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 5.0,
                          ),
                          Expanded(
                            flex: 2,
                            child: Material(
                              elevation: 2.0,
                              shape: const CircleBorder(),
                              color: Colors.blue,
                              child: IconButton(
                                icon: const Icon(Icons.search,
                                    color: Colors.white),
                                onPressed: () {
                                  buscaCep(_cepController.text);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        controller: _cidadeController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Cidade',
                          labelStyle: TextStyle(fontSize: 14.0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Este campo é obrigatório";
                          }
                          novoAtleta.cidadeAtleta = value;
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        controller: _logradouroController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Logradouro',
                          labelStyle: TextStyle(fontSize: 14.0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Este campo é obrigatório";
                          }
                          novoAtleta.logradouroAtleta = value;
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        controller: _bairroController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Bairro',
                          labelStyle: TextStyle(fontSize: 14.0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Este campo é obrigatório";
                          }
                          novoAtleta.bairroAtleta = value;
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        controller: _ufController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Uf',
                          labelStyle: TextStyle(fontSize: 14.0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Este campo é obrigatório";
                          }
                          novoAtleta.ufAtleta = value;
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _numController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Numero',
                                labelStyle: TextStyle(fontSize: 14.0),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Este campo é obrigatório";
                                }
                                novoAtleta.numAtleta = value;
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: TextFormField(
                              controller: _complEnderecoController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Complemento',
                                labelStyle: TextStyle(fontSize: 14.0),
                              ),
                              validator: (value) {
                                novoAtleta.complEnderecoAtleta = value;
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        controller: _rgController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'RG',
                          labelStyle: TextStyle(fontSize: 14.0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Este campo é obrigatório";
                          }
                          novoAtleta.rgAtleta = value;
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        controller: _cpfController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'CPF',
                          labelStyle: TextStyle(fontSize: 14.0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Este campo é obrigatório";
                          }
                          novoAtleta.cpfAtleta = value;
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        controller: _sexoController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Sexo',
                          labelStyle: TextStyle(fontSize: 14.0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Este campo é obrigatório";
                          }
                          novoAtleta.sexoAtleta = value;
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        controller: _convenioMedicoController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Convenio Médico',
                          labelStyle: TextStyle(fontSize: 14.0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Este campo é obrigatório";
                          }
                          novoAtleta.convenioMedicoAtleta = value;
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _telCelController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Telefone',
                              labelStyle: TextStyle(fontSize: 14.0),
                            ),
                            onChanged: (value) {
                              novoAtleta.telefonesAtleta['celular'] = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Este campo é obrigatório";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16.0),
                          TextFormField(
                            controller: _telEmerController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Telefone de Emergência',
                              labelStyle: TextStyle(fontSize: 14.0),
                            ),
                            onChanged: (value) {
                              novoAtleta.telefonesAtleta['emergencia'] = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Este campo é obrigatório";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        controller: _nomeMaeController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Nome completo da Mãe',
                          labelStyle: TextStyle(fontSize: 14.0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Este campo é obrigatório";
                          }
                          novoAtleta.nomeMaeAtleta = value;
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        controller: _nomePaiController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Nome completo do Pai',
                          labelStyle: TextStyle(fontSize: 14.0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Este campo é obrigatório";
                          }
                          novoAtleta.nomePaiAtleta = value;
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        controller: _clubeOrigemController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Clube de Origem',
                          labelStyle: TextStyle(fontSize: 14.0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Este campo é obrigatório";
                          }
                          novoAtleta.clubeOrigemAtleta = value;
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Atestado Médico',
                      style: TextStyle(
                          fontSize: 14.0, fontWeight: FontWeight.normal),
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: IconButton(
                            icon: const Icon(Icons.camera_alt),
                            onPressed: () async {
                              final fileName = DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString();
                              final storageRef = FirebaseStorage.instance.ref();
                              final userFolderRef = storageRef.child("imagens");
                              final imageRef = userFolderRef.child(fileName);

                              await pickImage();

                              try {
                                await imageRef.putFile(tempImage!);
                                imgUrlAtestado =
                                    await imageRef.getDownloadURL();
                              } on FirebaseException catch (e) {
                                print(e);
                              }
                            })),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Foto Rg',
                      style: TextStyle(
                          fontSize: 14.0, fontWeight: FontWeight.normal),
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: IconButton(
                            icon: const Icon(Icons.camera_alt),
                            onPressed: () async {
                              final fileName = DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString();
                              final storageRef = FirebaseStorage.instance.ref();
                              final userFolderRef = storageRef.child("imagens");
                              final imageRef = userFolderRef.child(fileName);

                              await pickImage();

                              try {
                                await imageRef.putFile(tempImage!);
                                imgUrlRg = await imageRef.getDownloadURL();
                              } on FirebaseException catch (e) {
                                print(e);
                              }
                            })),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Foto Cpf',
                      style: TextStyle(
                          fontSize: 14.0, fontWeight: FontWeight.normal),
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: IconButton(
                            icon: const Icon(Icons.camera_alt),
                            onPressed: () async {
                              final fileName = DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString();
                              final storageRef = FirebaseStorage.instance.ref();
                              final userFolderRef = storageRef.child("imagens");
                              final imageRef = userFolderRef.child(fileName);

                              await pickImage();

                              try {
                                await imageRef.putFile(tempImage!);
                                imgUrlCpf = await imageRef.getDownloadURL();
                              } on FirebaseException catch (e) {
                                print(e);
                              }
                            })),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Comprovante de Residencia',
                      style: TextStyle(
                          fontSize: 14.0, fontWeight: FontWeight.normal),
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: IconButton(
                            icon: const Icon(Icons.camera_alt),
                            onPressed: () async {
                              final fileName = DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString();
                              final storageRef = FirebaseStorage.instance.ref();
                              final userFolderRef = storageRef.child("imagens");
                              final imageRef = userFolderRef.child(fileName);

                              await pickImage();

                              try {
                                await imageRef.putFile(tempImage!);
                                imgUrlCompResidencia =
                                    await imageRef.getDownloadURL();
                              } on FirebaseException catch (e) {
                                print(e);
                              }
                            })),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Foto 3x4',
                      style: TextStyle(
                          fontSize: 14.0, fontWeight: FontWeight.normal),
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: IconButton(
                            icon: const Icon(Icons.camera_alt),
                            onPressed: () async {
                              final fileName = DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString();
                              final storageRef = FirebaseStorage.instance.ref();
                              final userFolderRef = storageRef.child("imagens");
                              final imageRef = userFolderRef.child(fileName);

                              await pickImage();

                              try {
                                await imageRef.putFile(tempImage!);
                                imgUrl3x4 = await imageRef.getDownloadURL();
                              } on FirebaseException catch (e) {
                                print(e);
                              }
                            })),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Regulamento Assinado',
                      style: TextStyle(
                          fontSize: 14.0, fontWeight: FontWeight.normal),
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: IconButton(
                            icon: const Icon(Icons.camera_alt),
                            onPressed: () async {
                              final fileName = DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString();
                              final storageRef = FirebaseStorage.instance.ref();
                              final userFolderRef = storageRef.child("imagens");
                              final imageRef = userFolderRef.child(fileName);

                              await pickImage();

                              try {
                                await imageRef.putFile(tempImage!);
                                imgUrlRegulamento =
                                    await imageRef.getDownloadURL();
                              } on FirebaseException catch (e) {
                                print(e);
                              }
                            })),
                  ],
                ),
              ),
              Visibility(
                visible: _selectedAthleteOrCoach == 'Treinador',
                child: Column(
                  children: [
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        controller: _nomeTreinadorController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Nome',
                          labelStyle: TextStyle(fontSize: 14.0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Este campo é obrigatório";
                          }
                          novoTreinador.nomeTreinador = value;
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        controller: _emailTreinadorController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Email',
                          labelStyle: TextStyle(fontSize: 14.0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Este campo é obrigatório";
                          }
                          novoTreinador.emailTreinador = value;
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        controller: _formacaoTreinadorController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Formação',
                          labelStyle: TextStyle(fontSize: 14.0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Este campo é obrigatório';
                          }
                          novoTreinador.formacaoTreinador = value;
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      if (_selectedAthleteOrCoach == 'Atleta') {
                        Atleta novoAtleta = Atleta(
                          emailAtleta: _emailController.text,
                          nomeAtleta: _nomeController.text,
                          dataNascimentoAtleta: _dataNascimentoController.text,
                          nacionalidadeAtleta: _selectedNaturalidade!,
                          rgAtleta: _rgController.text,
                          cpfAtleta: _cpfController.text,
                          sexoAtleta: _sexoController.text,
                          cepAtleta: _cepController.text,
                          cidadeAtleta: _cidadeController.text,
                          logradouroAtleta: _logradouroController.text,
                          numAtleta: _numController.text,
                          bairroAtleta: _bairroController.text,
                          ufAtleta: _ufController.text,
                          convenioMedicoAtleta: _convenioMedicoController.text,
                          fotoAtestadoAtleta: imgUrlAtestado,
                          fotoRgAtleta: imgUrlRg,
                          fotoCpfAtleta: imgUrlCpf,
                          fotoCompResidenciaAtleta: imgUrlCompResidencia,
                          foto3x4Atleta: imgUrl3x4,
                          fotoRegulamentoAtleta: imgUrlRegulamento,
                          telefonesAtleta: {
                            'celular': _telCelController.text,
                            'emergencia': _telEmerController.text
                          },
                          complEnderecoAtleta: _complEnderecoController.text,
                          nomeMaeAtleta: _nomeMaeController.text,
                          nomePaiAtleta: _nomePaiController.text,
                          clubeOrigemAtleta: _clubeOrigemController.text,
                        );
                        await _authService.cadastrarAtleta(
                            novoAtleta, _selectedAthleteOrCoach!);
                      } else {
                        Treinador novoTreinador = Treinador(
                          emailTreinador: _emailTreinadorController.text,
                          nomeTreinador: _nomeTreinadorController.text,
                          formacaoTreinador: _formacaoTreinadorController.text,
                        );
                        await _authService.cadastrarTreinador(
                            novoTreinador, _selectedAthleteOrCoach!);

                        Future.sync(() {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Treinador cadastrado com sucesso!')),
                          );
                        });
                      }
                      _formKey.currentState!.reset();
                    } catch (e) {
                      String errorMessage =
                          (_selectedAthleteOrCoach == 'Atleta')
                              ? 'Erro ao cadastrar atleta'
                              : 'Erro ao cadastrar treinador';
                      if (e is FirebaseAuthException) {
                        errorMessage = e.message ?? 'Erro desconhecido';
                      }

                      Future.sync(() {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(errorMessage)),
                        );
                      });
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Erro ao cadastrar!')),
                    );
                  }
                },
                child: const Text('Cadastrar'),
              ),
              const SizedBox(height: 30.0)
            ],
          ),
        ),
      ),
    );
  }
}
