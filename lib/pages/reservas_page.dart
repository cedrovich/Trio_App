import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'agendar_evento.dart';
import 'principal_page.dart';
import 'edit_event.dart'; // Importa la página de edición

class ReservasPage extends StatefulWidget {
  const ReservasPage({super.key});

  @override
  _ReservasPageState createState() => _ReservasPageState();
}

class _ReservasPageState extends State<ReservasPage> {
  List<Map<String, dynamic>> _reservas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReservas();
  }

  Future<void> _fetchReservas() async {
    try {
      final correo = Supabase.instance.client.auth.currentUser?.email;
      if (correo == null) {
        throw 'No se encontró el correo del usuario autenticado.';
      }

      final response = await Supabase.instance.client
          .from('eventos')
          .select()
          .eq('correo', correo);

      setState(() {
        _reservas = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar reservas: $e'),
          backgroundColor: const Color(0xFF892E2E),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PrincipalPage()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Mis Reservas',
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF892E2E),
          elevation: 0,
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF892E2E)),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    if (_reservas.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            'No tienes reservas registradas.',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: const Color(0xFF892E2E),
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _reservas.length,
                        itemBuilder: (context, index) {
                          final reserva = _reservas[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                reserva['tipo_evento'] ?? 'Evento',
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: const Color(0xFF892E2E),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  _buildInfoRow(Icons.calendar_today, 'Fecha: ${reserva['fecha']}'),
                                  _buildInfoRow(Icons.access_time, 'Hora: ${reserva['hora']}'),
                                  if (reserva['tipo_evento'] == 'Serenata')
                                    _buildInfoRow(Icons.music_note, 'Canciones: ${reserva['canciones'] ?? 'N/A'}'),
                                  if (reserva['tipo_evento'] == 'Evento') ...[
                                    _buildInfoRow(Icons.timer, 'Horas: ${reserva['horas'] ?? 'N/A'}'),
                                    _buildInfoRow(Icons.speaker, 'Sonido: ${reserva['sonido'] ?? 'N/A'}'),
                                  ],
                                  _buildInfoRow(Icons.attach_money, 'Precio: \$${reserva['monto'] ?? '0'}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Color(0xFF892E2E)),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditEventPage(eventData: reserva),
                                        ),
                                      ).then((_) => _fetchReservas());
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
        floatingActionButton: SizedBox(
          width: 90,
          height: 40,
          child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AgendarEventoPage()),
              );
            },
            backgroundColor: const Color(0xFF892E2E),
            icon: const Icon(Icons.add, color: Colors.white, size: 15),
            label: Text(
              'Agendar',
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
