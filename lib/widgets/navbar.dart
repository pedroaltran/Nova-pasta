import 'package:flutter/material.dart';
import 'package:pinatacao/services/auth_service.dart';
import 'package:pinatacao/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    AuthService authService = AuthService();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          FutureBuilder<Map<String, String>>(
            future: authService.getUsuarioAtualData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                print('Erro ao carregar dados do usuário: ${snapshot.error}');
                return const Text('Erro ao carregar dados do usuário');
              } else {
                Map<String, String> userData = snapshot.data!;
                String nome = userData['nome'] ?? 'Erro ao carregar nome';
                String email = userData['email'] ?? 'Erro ao carregar email';

                return UserAccountsDrawerHeader(
                  accountName: Text(nome),
                  accountEmail: Text(email),
                  currentAccountPicture: CircleAvatar(
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/perfil.jpg',
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 16.0),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text(
              'Meu Perfil',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            ),
            onTap: () => print('fav'),
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text(
              'Treinos Favoritos',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            ),
            onTap: () => print('fav'),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text(
              'Configurações',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            ),
            onTap: () => print('fav'),
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode_sharp),
            title: const Text(
              'Dark/Light',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            ),
            onTap: () {
              themeProvider.toggleTheme();
            },
          ),
          //const Spacer(),
          const Divider(height: 30),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text(
              'Exit',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            ),
            onTap: () {
              authService.sair(context);
            },
          ),
        ],
      ),
    );
  }
}
