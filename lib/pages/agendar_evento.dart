import 'package:flutter/material.dart';

class AgendarEventoPage extends StatefulWidget {
  const AgendarEventoPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AgendarEventoPageState createState() => _AgendarEventoPageState();
}

class _AgendarEventoPageState extends State<AgendarEventoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendar Evento'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Página para Agendar Evento',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Optional: You can add functionality here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funcionalidad de agendamiento')),
                );
              },
              child: const Text('Confirmar Evento'),
            ),
          ],
        ),
      ),
    );
  }
}