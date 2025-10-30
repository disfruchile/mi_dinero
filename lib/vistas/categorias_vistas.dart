// Archivo: lib/vistas/categorias_vistas.dart
// Contiene la vista para la gestión (CRUD) de categorías.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logica/categorias_logica.dart';
import '../modelos/categorias_modelo.dart';

/// Comentario: Pantalla para crear, ver, editar y eliminar categorías.
class VistaGestionCategorias extends StatelessWidget {
  const VistaGestionCategorias({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Categorías'),
      ),
      body: Consumer<CategoriaGestion>(
        builder: (context, gestion, child) {
          return ListView.builder(
            itemCount: gestion.categorias.length,
            itemBuilder: (context, index) {
              final categoria = gestion.categorias[index];
              // ⭐ Uso de 'ingreso' y 'gasto' corregido (minúsculas)
              final String tipo = categoria.tipo == TipoOperacion.ingreso ? 'Ingreso' : 'Gasto';
              final Color color = categoria.tipo == TipoOperacion.ingreso ? Colors.green : Colors.red;

              return ListTile(
                title: Text(categoria.nombre),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        tipo,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => gestion.eliminarCategoria(categoria.idCategoria),
                    ),
                  ],
                ),
                onTap: () {
                  // Implementación futura para editar categoría
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'añadirCategoriaFAB',
        onPressed: () => _mostrarDialogoNuevaCategoria(context),
        tooltip: 'Añadir Categoría',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Comentario: Muestra un diálogo para crear una nueva categoría.
  void _mostrarDialogoNuevaCategoria(BuildContext context) {
    final TextEditingController nombreController = TextEditingController();
    TipoOperacion tipoSeleccionado = TipoOperacion.gasto;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Nueva Categoría'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: nombreController,
                    decoration: const InputDecoration(labelText: 'Nombre de la Categoría'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      const Text('Tipo:'),
                      DropdownButton<TipoOperacion>(
                        value: tipoSeleccionado,
                        items: const [
                          // ⭐ Uso de 'gasto' corregido
                          DropdownMenuItem(
                            value: TipoOperacion.gasto,
                            child: Text('Gasto'),
                          ),
                          // ⭐ Uso de 'ingreso' corregido
                          DropdownMenuItem(
                            value: TipoOperacion.ingreso,
                            child: Text('Ingreso'),
                          ),
                        ],
                        onChanged: (TipoOperacion? newValue) {
                          if (newValue != null) {
                            setState(() {
                              tipoSeleccionado = newValue;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                TextButton(
                  child: const Text('Guardar'),
                  onPressed: () {
                    if (nombreController.text.isNotEmpty) {
                      final gestion = Provider.of<CategoriaGestion>(dialogContext, listen: false);
                      gestion.agregarCategoria(
                        nombreController.text,
                        tipoSeleccionado,
                      );
                      Navigator.of(dialogContext).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}