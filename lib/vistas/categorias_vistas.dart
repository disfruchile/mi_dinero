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
              
              // Determina el tipo principal para el display
              final String tipo = categoria.tipo == TipoOperacion.entrada ? 'Entrada' : 'Salida'; // ⭐ REEMPLAZADO: Ingreso/Gasto -> Entrada/Salida
              final Color color = categoria.tipo == TipoOperacion.entrada ? Colors.green : Colors.red; // ⭐ REEMPLAZADO

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
                  // _mostrarDialogoEdicion(context, categoria); // Función pendiente de implementación
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
    // ⭐ REEMPLAZADO: Valor por defecto es TipoOperacion.salida
    TipoOperacion tipoSeleccionado = TipoOperacion.salida; 
    
    // ⭐ PENDIENTE: Aquí se deberían inicializar los selectores de color y TipoCategoria
    
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
                          // ⭐ REEMPLAZADO: Dropdown para Salida
                          DropdownMenuItem(
                            value: TipoOperacion.salida,
                            child: Text('Salida'),
                          ),
                          // ⭐ REEMPLAZADO: Dropdown para Entrada
                          DropdownMenuItem(
                            value: TipoOperacion.entrada,
                            child: Text('Entrada'),
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
                  // ⭐ PENDIENTE: Selectores de Color y Tipos Aplicables aquí
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
                      
                      // ⭐ PENDIENTE: Los nuevos parámetros (color y tiposAplicables) no se están enviando.
                      // Por ahora, se envía un color por defecto y un set vacío (que se convierte a 'todos' en la lógica).
                      gestion.agregarCategoria(
                        nombreController.text,
                        tipoSeleccionado,
                        '#000000', // Color por defecto
                        {},       // Tipos aplicables por defecto (se resuelve como 'todos')
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