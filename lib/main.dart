//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:pinatacao/models/administrador.dart';
import 'package:pinatacao/models/usuario.dart';
import 'package:pinatacao/services/auth_service.dart';
import 'package:pinatacao/themes/theme_provider.dart';
import 'package:pinatacao/view/home_adm.dart';
import 'package:pinatacao/view/home_user.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Painel de Login',
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      locale: const Locale("pt", "BR"),
      supportedLocales: const [Locale("pt", "BR")],
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  final String _mockEmail1 = 'adm';
  final String _mockPassword = '123';

  void _showForgotPasswordDialog(BuildContext context) {
    TextEditingController forgotPasswordEmailController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Esqueci minha senha'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('Insira seu e-mail para redefinir a senha:'),
              TextFormField(
                controller: forgotPasswordEmailController,
                decoration: const InputDecoration(labelText: 'E-mail'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                String email = forgotPasswordEmailController.text;

                await AuthService().resetPassword(email);

                Future.sync(() {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Um e-mail de recuperação de senha foi enviado para $email.'),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                });
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  void tryLogin({bool auto = false}) {
    if (auto) {
      _authService.autoLogar().then((user) {
        if (user != null) {
          redirectUser(user);
        }
      });

      return;
    }

    _authService
        .logarUsuario(
      _emailController.text,
      _passwordController.text,
    )
        .then((user) {
      if (user != null) {
        redirectUser(user);
        return;
      }

      if (_emailController.text == _mockEmail1 &&
          _passwordController.text == _mockPassword) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeAdm(adm: null)),
          (route) => false,
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Falha ao fazer login. Verifique suas credenciais.'),
      ));
    });
  }

  void redirectUser(Usuario usuario) {
    Future.delayed(const Duration(seconds: 1), () {
      if (usuario is Administrador) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeAdm(adm: usuario)),
            (route) => false);

        return;
      }
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeUser(usuario: usuario)),
          (route) => false);
    });
  }

  @override
  void initState() {
    super.initState();
    tryLogin(auto: true);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/images/unaerp-logo.png',
                    width: 240,
                    height: 150,
                  ),
                ],
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * .9,
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                width: MediaQuery.of(context).size.width * .9,
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Senha',
                  ),
                  onFieldSubmitted: (_) => tryLogin(),
                ),
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: tryLogin,
                child: const Text('Login'),
              ),
              const SizedBox(height: 16.0),
              TextButton(
                onPressed: () {
                  _showForgotPasswordDialog(context);
                },
                child: const Text('Esqueci minha senha'),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}
