import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PromoPage extends StatefulWidget {
  const PromoPage({super.key});

  @override
  _PromoPageState createState() => _PromoPageState();
}

class _PromoPageState extends State<PromoPage> {
  int _reservasCount = 0;
  bool _isLoading = true;
  bool _hasPromotion = false; // Si el usuario tiene la sexta reserva gratis

  @override
  void initState() {
    super.initState();
    _fetchUserReservas();
  }

  // Método para obtener las reservas del usuario autenticado
  Future<void> _fetchUserReservas() async {
    try {
      final correo = Supabase.instance.client.auth.currentUser?.email;
      if (correo == null) {
        throw 'No se encontró el correo del usuario autenticado.';
      }

      // Consulta a la tabla de eventos sin usar genéricos
      final response = await Supabase.instance.client
          .from('eventos')
          .select()
          .eq('correo', correo) as List<dynamic>;

      // Verificar si la consulta devolvió datos
      if (response.isNotEmpty) {
        setState(() {
          _reservasCount = response.length;
          _hasPromotion = _reservasCount >= 5; // Promoción activa si tiene 5 reservas o más
        });
      }

      setState(() {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Promociones'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Esto elimina la flecha de retroceso
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¡Gracias por tu preferencia!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Tarjeta de fidelidad
                  Card(
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reservas realizadas: $_reservasCount',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _hasPromotion
                                ? '¡Felicidades! Tu sexta reserva es gratis.'
                                : 'Te faltan ${5 - _reservasCount} reservas para tu próxima serenata o evento gratis.',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _hasPromotion ? Colors.green : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Botón para reservar un evento
                  Center(
                    child: ElevatedButton(
                      onPressed: _hasPromotion
                          ? () {
                              // Lógica para redirigir a la página de reservas gratis
                            }
                          : null,
                      child: Text(
                        _hasPromotion
                            ? 'Agendar evento gratis'
                            : 'Agendar evento',
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
