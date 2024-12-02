import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'agendar_evento.dart'; // Importa la página para agendar eventos

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
          .from('eventos') // Nombre de tu tabla
          .select()
          .eq('correo', correo);

      setState(() {
        _reservas = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar reservas: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Bloquear el botón físico de retroceso
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mis Reservas'),
          centerTitle: true,
          automaticallyImplyLeading: false, // Elimina la flecha de retroceso
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    if (_reservas.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text('No tienes reservas registradas.'),
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
                            margin: const EdgeInsets.all(10),
                            child: ListTile(
                              title: Text(
                                reserva['tipo_evento'] ?? 'Evento',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Fecha: ${reserva['fecha']}'),
                                  Text('Hora: ${reserva['hora']}'),
                                  if (reserva['tipo_evento'] == 'Serenata')
                                    Text('Canciones: ${reserva['canciones'] ?? 'N/A'}'),
                                  if (reserva['tipo_evento'] == 'Evento') ...[
                                    Text('Horas: ${reserva['horas'] ?? 'N/A'}'),
                                    Text('Sonido: ${reserva['sonido'] ?? 'N/A'}'),
                                  ],
                                  Text('Precio: \$${reserva['monto'] ?? '0'}'),
                                ],
                              ),
                              trailing: const Icon(Icons.event),
                            ),
                          );
                        },
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AgendarEventoPage()),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Agendar un evento'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

extension on PostgrestList {
  get error => null;
}
