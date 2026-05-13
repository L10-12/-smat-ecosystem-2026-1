import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/estacion.dart';
import 'login_screen.dart';
import 'add_estacion.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Instancia del servicio de API para realizar peticiones
  final ApiService apiService = ApiService();
  // Future que almacenará la lista de estaciones
  late Future<List<Estacion>> futureEstaciones;

  @override
  void initState() {
    super.initState();
    // Carga inicial de datos
    _cargarEstaciones();
  }

  void _cargarEstaciones() {
    setState(() {
      futureEstaciones = apiService.fetchEstaciones();
    });
  }

  // Lógica para el diálogo de edición
  void _mostrarDialogoEdicion(Estacion estacion) {
    final nombreCtrl = TextEditingController(text: estacion.nombre);
    final ubicacionCtrl = TextEditingController(text: estacion.ubicacion);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editar Estación"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),
            TextField(
              controller: ubicacionCtrl,
              decoration: const InputDecoration(labelText: "Ubicación"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              // Llama al método de edición en el servicio
              bool ok = await apiService.editarEstacion(
                estacion.id,
                nombreCtrl.text,
                ubicacionCtrl.text,
              );
              if (ok) {
                if (!mounted) return;
                Navigator.pop(context);
                _cargarEstaciones(); // Refresca la UI
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estaciones SMAT'),
        actions: [
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
        future: futureEstaciones,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay estaciones disponibles'));
          }

          // Implementación de RefreshIndicator para actualizar al arrastrar
          return RefreshIndicator(
            onRefresh: () async {
              _cargarEstaciones();
              await futureEstaciones;
            },
            child: ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final estacion = snapshot.data![index];

                // Implementación de Dismissible para borrar al deslizar
                return Dismissible(
                  key: Key(estacion.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) async {
                    bool ok = await apiService.eliminarEstacion(estacion.id);
                    if (ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("${estacion.nombre} eliminada")),
                      );
                    } else {
                      _cargarEstaciones(); // Revierte el borrado visual si falla la API
                    }
                  },
                  child: ListTile(
                    leading: const Icon(Icons.router),
                    title: Text(estacion.nombre),
                    subtitle: Text(estacion.ubicacion),
                    onTap: () => _mostrarDialogoEdicion(estacion),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          // Al regresar de añadir, si hubo éxito, refresca la lista
          final bool? result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEstacionScreen()),
          );
          if (result == true) {
            _cargarEstaciones();
          }
        },
      ),
    );
  }
}