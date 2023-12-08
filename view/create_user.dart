import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pinatacao/models/atleta.dart';

class CadastroPage extends StatefulWidget {
  @override
  _CadastroPageState createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
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
    estilosAtleta: [],
    provasAtleta: [],
    telefonesAtleta: {},
  );

  List<Atleta> listaAtleta = [];

  final TextEditingController _cepController = TextEditingController();
  final TextEditingController _logradouroController = TextEditingController();
  final TextEditingController _bairroController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _ufController = TextEditingController();

  // Alterado para String?
  String? _selectedAthleteOrCoach;
  String? _selectedNaturalidade;
  List<String> _countries = [];

  Map<String, String> _countryFlags = {};

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

      _countryFlags = Map.fromIterable(data,
          key: (country) => country['name']['common'],
          value: (country) => country['flags']['png']);

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
      // Lida com erros aqui, por exemplo, exibir uma mensagem de erro para o usuário
      print('Erro ao buscar endereço: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    _countries.sort();

    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
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
                decoration: InputDecoration(labelText: 'Atleta ou Treinador'),
              ),
              SizedBox(height: 16.0),
              Visibility(
                visible: _selectedAthleteOrCoach == 'Atleta',
                child: Column(
                  children: [
                    SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        decoration: InputDecoration(
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
                    SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        decoration: InputDecoration(
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
                    SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
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
                    SizedBox(height: 16.0),
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
                                SizedBox(width: 8),
                                Text(country),
                              ],
                            ),
                          );
                        }).toList(),
                        decoration: InputDecoration(
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
                    SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 8,
                            child: TextFormField(
                              controller: _cepController,
                              decoration: InputDecoration(
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
                          SizedBox(
                            width: 5.0,
                          ),
                          Expanded(
                            flex: 2,
                            child: Material(
                              elevation: 2.0,
                              shape: CircleBorder(),
                              color: Colors.blue,
                              child: IconButton(
                                icon: Icon(Icons.search, color: Colors.white),
                                onPressed: () {
                                  buscaCep(_cepController.text);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        controller: _cidadeController,
                        decoration: InputDecoration(
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
                    SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        controller: _logradouroController,
                        decoration: InputDecoration(
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
                    SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        controller: _bairroController,
                        decoration: InputDecoration(
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
                    SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        controller: _ufController,
                        decoration: InputDecoration(
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
                    SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
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
                          SizedBox(
                              width:
                                  16.0), // Adicione um espaço entre os TextFormField
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
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
                    SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        decoration: InputDecoration(
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
                    SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        decoration: InputDecoration(
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
                    SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        decoration: InputDecoration(
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
                    SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        decoration: InputDecoration(
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
                    SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Atestado Médico',
                          labelStyle: TextStyle(fontSize: 14.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Foto RG',
                          labelStyle: TextStyle(fontSize: 14.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Foto CPF',
                          labelStyle: TextStyle(fontSize: 14.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Foto Comprovante de Residencia',
                          labelStyle: TextStyle(fontSize: 14.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Foto 3x4',
                          labelStyle: TextStyle(fontSize: 14.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Foto Regulamento Assinado',
                          labelStyle: TextStyle(fontSize: 14.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Estilos do Atleta',
                          labelStyle: TextStyle(fontSize: 14.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Provas do Atleta',
                          labelStyle: TextStyle(fontSize: 14.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Telefone',
                              labelStyle: TextStyle(fontSize: 14.0),
                            ),
                            onChanged: (value) {
                              // Atualize o valor do telefone em novoAtleta
                              novoAtleta.telefonesAtleta['celular'] = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Este campo é obrigatório"; // Mensagem de erro para campo vazio
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16.0),
                          TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Telefone de Emergência',
                              labelStyle: TextStyle(fontSize: 14.0),
                            ),
                            onChanged: (value) {
                              // Atualize o valor do telefone de emergência em novoAtleta
                              novoAtleta.telefonesAtleta['emergencia'] = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Este campo é obrigatório"; // Mensagem de erro para campo vazio
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        decoration: InputDecoration(
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
                    SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        decoration: InputDecoration(
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
                    SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        decoration: InputDecoration(
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
                    SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Local de Trabalho',
                          labelStyle: TextStyle(fontSize: 14.0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Este campo é obrigatório";
                          }
                          novoAtleta.localTrabalhoAtleta = value;
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Alergia a Medicamentos',
                          labelStyle: TextStyle(fontSize: 14.0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Este campo é obrigatório";
                          }
                          List<String> alergias = value.split(',');
                          novoAtleta.alergiaMedAtleta = alergias;
                          return null;
                        },
                      ),
                    ),
                  ], // Outros campos de Atleta
                ),
              ),
              Visibility(
                visible: _selectedAthleteOrCoach == 'Treinador',
                child: Column(
                  children: [
                    // Adicione aqui os campos específicos para Treinador
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Formação'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Se o formulário for válido, adicione o novo atleta à lista
                    listaAtleta.add(novoAtleta);

                    // Limpe o formulário para permitir o cadastro de um novo atleta
                    _formKey.currentState!.reset();

                    // Exiba uma mensagem de sucesso
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Atleta cadastrado com sucesso!'),
                      ),
                    );
                  }
                },
                child: Text('Cadastrar'),
              )
            ],
          ),
          // Campos específicos para Treinador
        ),
      ),
    );
  }
}
