import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/estacion.dart';
import 'login_screen.dart';
import 'add_estacion.dart'; // Importante para navegar a la creación

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Definimos el Future que contendrá la lista de estaciones
  late Future<List<Estacion>> _futureEstaciones;

  @override
  void initState() {
    super.initState();
    // Cargamos los datos al iniciar la pantalla
    _futureEstaciones = ApiService().fetchEstaciones();
  }

  // Método para refrescar la lista manualmente
  void _refreshData() {
    setState(() {
      _futureEstaciones = ApiService().fetchEstaciones();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estaciones SMAT'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Estacion>>(
        future: _futureEstaciones,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay estaciones registradas.'));
          }
          
          // Si hay datos, mostramos la lista
          final estaciones = snapshot.data!;
          return ListView.builder(
            itemCount: estaciones.length,
            itemBuilder: (context, index) {
              final estacion = estaciones[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.router, color: Colors.blue),
                  title: Text(estacion.nombre),
                  subtitle: Text(estacion.ubicacion),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Aquí podrías ir a una pantalla de detalles en el futuro
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          // Navegamos a la pantalla de agregar y esperamos el resultado
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEstacionScreen()),
          );

          // Si regresó un 'true', refrescamos la lista
          if (result == true) {
            _refreshData();
          }
        },
      ),
    );
  }
}