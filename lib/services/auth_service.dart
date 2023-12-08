import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinatacao/main.dart';
import 'package:pinatacao/models/administrador.dart';
import 'package:pinatacao/models/atleta.dart';
import 'package:pinatacao/models/treinador.dart';
import 'package:pinatacao/models/treino.dart';
import 'package:pinatacao/models/usuario.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<Usuario?> autoLogar() async {
    (String, String)? credentials = await lerUsuario();

    if (credentials == null) {
      return null;
    }

    return await logarUsuario(credentials.$1, credentials.$2);
  }

  Future<Usuario?> logarUsuario(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user == null) {
        return null;
      }

      Usuario? userResult;

      QuerySnapshot admSnapshot = await FirebaseFirestore.instance
          .collection('administradores')
          .where('emailAdministrador', isEqualTo: email)
          .get();

      if (admSnapshot.docs.isNotEmpty) {
        userResult = Administrador.fromMap(
            admSnapshot.docs.first.data() as Map<String, dynamic>);
      } else {
        QuerySnapshot coachSnapshot = await FirebaseFirestore.instance
            .collection('treinadores')
            .where('emailTreinador', isEqualTo: email)
            .get();

        if (coachSnapshot.docs.isNotEmpty) {
          userResult = Treinador.fromMap(
              coachSnapshot.docs.first.data() as Map<String, dynamic>);
        } else {
          QuerySnapshot athleteSnapshot = await FirebaseFirestore.instance
              .collection('atletas')
              .where('emailAtleta', isEqualTo: email)
              .get();

          if (athleteSnapshot.docs.isNotEmpty) {
            userResult = Atleta.fromMap(
                athleteSnapshot.docs.first.data() as Map<String, dynamic>);
          }
        }
      }

      if (userResult != null) {
        await armazenarUsuario(email, password);
      }

      return userResult;
    } on FirebaseAuthException catch (_) {
      return null;
    }
  }

  Future<bool> armazenarUsuario(String email, String password) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return (await prefs.setString("userEmail", email) &&
        await prefs.setString("userPassword", password));
  }

  Future<(String, String)?> lerUsuario() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email, password;

    email = prefs.getString("userEmail");
    password = prefs.getString("userPassword");

    if (email == null || password == null) {
      return null;
    }

    return (email, password);
  }

  Future<Usuario?> getUsuario(String email) async {
    try {
      QuerySnapshot admSnapshot = await FirebaseFirestore.instance
          .collection('administradores')
          .where('emailAdministrador', isEqualTo: email)
          .get();

      if (admSnapshot.docs.isNotEmpty) {
        return Administrador.fromMap(
            admSnapshot.docs.first.data() as Map<String, dynamic>);
      } else {
        QuerySnapshot coachSnapshot = await FirebaseFirestore.instance
            .collection('treinadores')
            .where('emailTreinador', isEqualTo: email)
            .get();

        if (coachSnapshot.docs.isNotEmpty) {
          return Treinador.fromMap(
              coachSnapshot.docs.first.data() as Map<String, dynamic>);
        } else {
          QuerySnapshot athleteSnapshot = await FirebaseFirestore.instance
              .collection('atletas')
              .where('emailAtleta', isEqualTo: email)
              .get();

          if (athleteSnapshot.docs.isNotEmpty) {
            return Atleta.fromMap(
                athleteSnapshot.docs.first.data() as Map<String, dynamic>);
          }
        }
      }
    } on Exception catch (_) {}

    return null;
  }

  Future<List<Usuario>> getUsuarios({bool includeAdm = false}) async {
    List<Usuario> users = [];

    QuerySnapshot coachSnapshot =
        await FirebaseFirestore.instance.collection('treinadores').get();

    if (coachSnapshot.docs.isNotEmpty) {
      for (var doc in coachSnapshot.docs) {
        users.add(Treinador.fromMap(doc.data() as Map<String, dynamic>));
      }
    }

    QuerySnapshot athleteSnapshot =
        await FirebaseFirestore.instance.collection('atletas').get();

    if (athleteSnapshot.docs.isNotEmpty) {
      for (var doc in athleteSnapshot.docs) {
        users.add(Atleta.fromMap(doc.data() as Map<String, dynamic>));
      }
    }

    if (includeAdm) {
      QuerySnapshot admSnapshot =
          await FirebaseFirestore.instance.collection('administradores').get();

      if (admSnapshot.docs.isNotEmpty) {
        for (var doc in admSnapshot.docs) {
          users.add(Administrador.fromMap(doc.data() as Map<String, dynamic>));
        }
      }
    }

    return users;
  }

  Future<List<Treino>> getTreinos({String? athleteEmail}) async {
    List<Treino> trainings = [];

    CollectionReference trainingReference =
        await FirebaseFirestore.instance.collection('treinos');

    if (athleteEmail != null) {
      trainingReference.where("emailAtleta", isEqualTo: athleteEmail);
    }

    QuerySnapshot trainingSnapshot = await trainingReference.get();

    if (trainingSnapshot.docs.isNotEmpty) {
      for (var doc in trainingSnapshot.docs) {
        trainings.add(Treino.fromMap(doc.data() as Map<String, dynamic>));
      }
    }

    return trainings;
  }

  Future<void> cadastrarUsuario(
      {required String email, required String userType}) async {
    try {
      bool emailExist = await verificarEmailExistente(email);

      if (emailExist) {
        print('Email já registrado');
        return;
      }
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: gerarSenhaAleatoria(),
      );
      print('E-mail de verificação enviado para $email');
    } catch (e) {
      print('Erro ao cadastrar usuário: $e');
    }
  }

  Future<bool> verificarEmailExistente(String email) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('email', isEqualTo: email)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Erro ao verificar email existente: $e');
      return false;
    }
  }

  String gerarSenhaAleatoria() {
    Random random = Random();
    int firstCharacter = "0".codeUnitAt(0);
    int lastCharacter = "z".codeUnitAt(0);
    int characterRange = lastCharacter - firstCharacter;
    String senha = "";

    for (int i = 0; i < 10; i++) {
      senha +=
          String.fromCharCode(firstCharacter + random.nextInt(characterRange));
    }

    return senha;
  }

  Future<void> cadastrarAtleta(Atleta atleta, String user) async {
    try {
      CollectionReference atletas =
          FirebaseFirestore.instance.collection('atletas');

      await atletas
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set(atleta.toMap());
      print('Atleta cadastrado com sucesso!');
      await cadastrarUsuario(email: atleta.emailAtleta, userType: 'Atleta');
    } catch (e) {
      print('Erro ao cadastrar atleta: $e');
    }
  }

  Future<void> cadastrarTreinador(Treinador treinador, String user) async {
    try {
      CollectionReference treinadores =
          FirebaseFirestore.instance.collection('treinadores');

      await treinadores
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set(treinador.toMap());
      print('Treinador cadastrado com sucesso!');
      await cadastrarUsuario(
          email: treinador.emailTreinador, userType: 'Treinador');
    } catch (e) {
      print('Erro ao cadastrar treinador: $e');
    }
  }

  Future<void> cadastrarTreino(Treino treino) async {
    try {
      CollectionReference treinos =
          FirebaseFirestore.instance.collection('treinos');
      await treinos.add(treino.toMap());

      print('Treino cadastrado com sucesso!');
    } catch (e) {
      print('Erro ao cadastrar treino: $e');
    }
  }

  Future<User?> signIn(String emailF, String pass) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: emailF, password: pass);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Erro ao logar: $e');
      return null;
    }
  }

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print("Erro ao enviar email de recuperação de senha: $e");
    }
  }

  Future<Map<String, String>> getUsuarioAtualData() async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user != null) {
        DocumentSnapshot atletaSnapshot = await FirebaseFirestore.instance
            .collection('atletas')
            .doc(user.uid)
            .get();

        if (atletaSnapshot.exists) {
          Map<String, dynamic> atletaData =
              atletaSnapshot.data() as Map<String, dynamic>;
          return {
            'nome': atletaData['nomeAtleta'],
            'email': atletaData['emailAtleta'],
          };
        }
        DocumentSnapshot treinadorSnapshot = await FirebaseFirestore.instance
            .collection('treinadores')
            .doc(user.uid)
            .get();

        if (treinadorSnapshot.exists) {
          Map<String, dynamic> treinadorData =
              treinadorSnapshot.data() as Map<String, dynamic>;
          return {
            'nome': treinadorData['nomeTreinador'],
            'email': treinadorData['emailTreinador'],
          };
        }
        return {};
      } else {
        return {};
      }
    } catch (e) {
      print('Erro ao obter dados do usuário: $e');
      rethrow;
    }
  }

  Future<void> sair(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove("userEmail");
    await prefs.remove("userPassword");

    await _firebaseAuth.signOut().then((user) => Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false));
  }
}
