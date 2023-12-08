import 'package:flutter/material.dart';
import 'package:pinatacao/view/home_adm.dart';
import 'package:pinatacao/view/home_user.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  // Simulando dados de usuário
  final String _mockEmail1 = 'adm';
  final String _mockEmail2 = 'atleta';
  final String _mockPassword = '123';

  void _showForgotPasswordDialog(BuildContext context) {
    TextEditingController _forgotPasswordEmailController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Esqueci minha senha'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Insira seu e-mail para redefinir a senha:'),
              TextFormField(
                controller: _forgotPasswordEmailController,
                decoration: InputDecoration(labelText: 'E-mail'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Lógica para enviar e-mail de recuperação de senha
                String email = _forgotPasswordEmailController.text;

                // Exemplo: Enviar o email para redefinir a senha
                print('Solicitar redefinição de senha para: $email');

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Um e-mail de recuperação de senha foi enviado para $email.'),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              child: Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login App'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * .9,
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              SizedBox(
                width: MediaQuery.of(context).size.width * .9,
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Senha',
                  ),
                ),
              ),
              SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {
                  // Verificar os dados de login
                  if (_emailController.text == _mockEmail1 &&
                      _passwordController.text == _mockPassword) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeAdm()),
                    );
                  } else if (_emailController.text == _mockEmail2 &&
                      _passwordController.text == _mockPassword) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeUser()),
                    );
                  }
                  // Se os dados de login forem válidos, navegue para a próxima tela ou realize a ação desejada
                  // Exemplo: Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                  else {
                    // Se os dados de login forem inválidos, exiba uma mensagem de erro
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Email ou senha incorretos.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Text('Login'),
              ),
              SizedBox(height: 16.0), // Espaçamento adicional
              TextButton(
                onPressed: () {
                  // Exibir o diálogo "Esqueci minha senha"
                  _showForgotPasswordDialog(context);
                },
                child: Text('Esqueci minha senha'),
              ),
              SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}
