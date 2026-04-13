import 'package:flutter/material.dart';
import 'widgets/app_drawer.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      drawer: const AppDrawer(currentRoute: 'Sobre'),
      appBar: AppBar(
        title: const Text('Sobre'),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: isDark
            ? const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF133E28), Color(0xFF0E2F1F)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sobre o Aplicativo',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF86EFAC) : null,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Disciplina: Programação para Dispositivos Móveis',
                style: TextStyle(fontSize: 16, color: isDark ? const Color(0xFF86EFAC) : null),
              ),
              const SizedBox(height: 8),
              Text(
                'Instituição: Fatec Ribeirão Preto',
                style: TextStyle(fontSize: 16, color: isDark ? const Color(0xFF86EFAC) : null),
              ),
              const SizedBox(height: 8),
              Text(
                'Professor: Rodrigo Plotze',
                style: TextStyle(fontSize: 16, color: isDark ? const Color(0xFF86EFAC) : null),
              ),
              const SizedBox(height: 8),
              Text(
                'Versão: 1.0',
                style: TextStyle(fontSize: 16, color: isDark ? const Color(0xFF86EFAC) : null),
              ),
              const SizedBox(height: 18),
              Text(
                'Equipe:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF86EFAC) : null,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• Artur Ruiz\n• Tobias Fonsatti',
                style: TextStyle(fontSize: 16, color: isDark ? const Color(0xFF86EFAC) : null),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
