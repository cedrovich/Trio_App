import 'package:flutter/material.dart';
import 'agendar_evento.dart'; // Import the new page

class ReservasPage extends StatelessWidget {
  const ReservasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Navigate to AgendarEventoPage
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AgendarEventoPage()),
          );
        },
        child: const Text('Agendar un evento'),
      ),
    );
  }
}