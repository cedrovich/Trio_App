import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EventDetailsPage extends StatelessWidget {
  final Map<String, dynamic> eventData;

  const EventDetailsPage({super.key, required this.eventData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalles del Evento',
          style: GoogleFonts.roboto(color: Color.fromARGB(255, 255, 255, 255), fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF892E2E),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del evento
            if (eventData['image_url'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  eventData['image_url'],
                  width: double.infinity,
                  fit: BoxFit.contain, // Cambiado a BoxFit.contain
                ),
              ),
            const SizedBox(height: 16),
            // Título del evento
            Text(
              eventData['title'] ?? 'Sin título',
              style: GoogleFonts.roboto(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF892E2E),
              ),
            ),
            const SizedBox(height: 10),
            // Descripción del evento
            Text(
              eventData['description'] ?? 'Sin descripción',
              style: GoogleFonts.roboto(fontSize: 16, color: Colors.grey[800]),
            ),
            const SizedBox(height: 20),
            // Detalles adicionales
            if (eventData['additional_details'] != null &&
                eventData['additional_details'].isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detalles Adicionales:',
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    eventData['additional_details'],
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
