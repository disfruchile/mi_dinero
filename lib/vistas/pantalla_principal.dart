// Archivo: lib/vistas/pantalla_principal.dart
// Contiene la vista principal de la aplicación con la estructura de botones y balance.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logica/categorias_logica.dart';
import 'categorias_vistas.dart'; // Importación correcta de la vista de categorías

/// Comentario: Pantalla principal de la aplicación.
class PantallaPrincipal extends StatelessWidget {
  const PantallaPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoriaGestion>(
      builder: (context, gestion, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Mi Dinero'),
            actions: [
              // Comentario: Botón para navegar a la gestión de categorías.
              IconButton(
                icon: const Icon(Icons.category),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const VistaGestionCategorias(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Sección de Balance
                const Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Column(
                    children: [
                      Text('Balance Total:', style: TextStyle(fontSize: 24)),
                      Text('\$ 0.00', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Contenedores de Efectivo y Transferencia
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Caja de Efectivo
                      Expanded(
                        child: _buildFondoBox(
                          Colors.green.shade100,
                          'Efectivo',
                          // Botones de Efectivo
                          Column(
                            children: [
                              _buildOperacionButton(Colors.green, Icons.add, 'Ingreso'),
                              const SizedBox(height: 5),
                              _buildOperacionButton(Colors.red, Icons.remove, 'Gasto'),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Caja de Transferencia
                      Expanded(
                        child: _buildFondoBox(
                          Colors.blue.shade100,
                          'Transferencia',
                          // Botones de Transferencia
                          Column(
                            children: [
                              _buildOperacionButton(Colors.green, Icons.add, 'Ingreso'),
                              const SizedBox(height: 5),
                              _buildOperacionButton(Colors.red, Icons.remove, 'Gasto'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Lista de Operaciones (Placeholder)
                const Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Últimas Operaciones:', style: TextStyle(fontSize: 20)),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text('Lista de operaciones aquí'),
                  ),
                ),
              ],
            ),
          ),
          // ⭐ Corregido: FAB sin Hero duplicado, para añadir una operación
          floatingActionButton: FloatingActionButton(
            heroTag: 'añadirOperacionFAB',
            onPressed: () {
               // Lógica para abrir el diálogo de añadir nueva operación
            },
            tooltip: 'Añadir nueva operación',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  /// Comentario: Widget auxiliar para construir las cajas de Efectivo/Transferencia.
  Widget _buildFondoBox(Color color, String titulo, Widget botones) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(titulo, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Text('\$ 0.00'),
          const SizedBox(height: 10),
          botones,
        ],
      ),
    );
  }

  /// Comentario: Widget auxiliar para construir los botones de Ingreso/Gasto.
  Widget _buildOperacionButton(Color color, IconData icon, String texto) {
    return ElevatedButton.icon(
      onPressed: () { /* Lógica para la operación */ },
      icon: Icon(icon, size: 16),
      label: Text(texto, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 30),
      ),
    );
  }
}