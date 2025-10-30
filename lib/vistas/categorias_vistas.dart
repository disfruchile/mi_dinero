// Archivo: lib/vistas/categorias_vistas.dart
// Contiene la vista para la gestión (CRUD) de categorías, con confirmación de eliminación.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logica/categorias_logica.dart';
import '../modelos/categorias_modelo.dart';

/// Comentario: Mapeo de colores predefinidos para la selección en la UI.
final Map<String, Color> coloresDisponibles = {
  'Negro': Colors.black,
  'Azul': Colors.blue,
  'Rojo': Colors.red,
  'Verde': Colors.green,
  'Púrpura': Colors.purple,
  'Naranja': Colors.orange,
};

/// Comentario: Función auxiliar para convertir un Color de Flutter a un String Hex.
String colorToHex(Color color) {
  // Ignoramos la advertencia sobre 'value' ya que el uso aquí es simple y funcional.
  // Es la forma más directa de obtener el valor HEX.
  return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
}

/// Comentario: Función auxiliar para convertir un String Hex a un Color de Flutter.
Color hexToColor(String hexString) {
  try {
    final hex = hexString.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  } catch (e) {
    return Colors.black;
  }
}

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
          if (gestion.categorias.isEmpty) {
            return const Center(child: Text('No hay categorías aún. Añade una.'));
          }

          return ListView.builder(
            itemCount: gestion.categorias.length,
            itemBuilder: (context, index) {
              final categoria = gestion.categorias[index];

              final Color colorCategoria = hexToColor(categoria.color);

              // ⭐️ LÓGICA DE VISUALIZACIÓN DE TIPO (USANDO TIPOS APLICABLES)
              final bool isEntrada = categoria.tiposAplicables.contains(TipoCategoria.entrada);
              final bool isSalida = categoria.tiposAplicables.contains(TipoCategoria.salida);
              final bool isTransferencia = categoria.tiposAplicables.contains(TipoCategoria.transferencia);
              final bool isTodos = categoria.tiposAplicables.contains(TipoCategoria.todos);

              String tipoDisplay;
              Color colorPrincipal;

              if (isTodos) {
                tipoDisplay = 'Todas';
                colorPrincipal = Colors.grey;
              } else if (isEntrada && !isSalida && !isTransferencia) {
                tipoDisplay = 'Entrada';
                colorPrincipal = Colors.green;
              } else if (isSalida && !isEntrada && !isTransferencia) {
                tipoDisplay = 'Salida';
                colorPrincipal = Colors.red;
              } else if (isTransferencia && !isEntrada && !isSalida) {
                tipoDisplay = 'Transf.';
                colorPrincipal = Colors.blue.shade800;
              } else {
                tipoDisplay = 'Mixta'; // Para categorías que aplican a varios tipos
                colorPrincipal = Colors.blueGrey;
              }
              // ⭐️ FIN LÓGICA DE VISUALIZACIÓN

              return ListTile(
                leading: Icon(Icons.circle, color: colorCategoria),
                title: Text(categoria.nombre),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorPrincipal,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        tipoDisplay,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _mostrarConfirmacionEliminar(context, gestion, categoria),
                    ),
                  ],
                ),
                onTap: () => _mostrarDialogoEdicion(context, categoria),
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

  /// Comentario: Muestra un diálogo de confirmación antes de eliminar una categoría.
  void _mostrarConfirmacionEliminar(BuildContext context, CategoriaGestion gestion, Categoria categoria) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar la categoría "${categoria.nombre}"? Esta acción no se puede deshacer.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              onPressed: () {
                gestion.eliminarCategoria(categoria.idCategoria);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }


  /// Comentario: Muestra un diálogo para crear una nueva categoría.
  void _mostrarDialogoNuevaCategoria(BuildContext context) {
    final TextEditingController nombreController = TextEditingController();
    Color colorSeleccionado = Colors.black;
    Set<TipoCategoria> tiposAplicables = {TipoCategoria.todos}; // Inicializado a 'todos'

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Nueva Categoría'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: nombreController,
                      decoration: const InputDecoration(labelText: 'Nombre de la Categoría'),
                    ),
                    const SizedBox(height: 20),
                    // SELECTOR DE COLOR
                    _buildColorSelector(context, colorSeleccionado, (newColor) {
                      setState(() {
                        colorSeleccionado = newColor;
                      });
                    }),
                    const SizedBox(height: 20),
                    // SELECTOR DE TIPOS APLICABLES
                    _TipoCategoriaSelector(
                      selectedTypes: tiposAplicables,
                      onChanged: (newTypes) {
                        setState(() {
                          tiposAplicables = newTypes;
                        });
                      },
                    ),
                  ],
                ),
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
                        colorToHex(colorSeleccionado),
                        tiposAplicables,
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

  /// Comentario: Muestra un diálogo para editar una categoría existente.
  void _mostrarDialogoEdicion(BuildContext context, Categoria categoria) {
    final TextEditingController nombreController = TextEditingController(text: categoria.nombre);
    Color colorSeleccionado = hexToColor(categoria.color);
    Set<TipoCategoria> tiposAplicables = Set.from(categoria.tiposAplicables);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Editar Categoría'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: nombreController,
                      decoration: const InputDecoration(labelText: 'Nombre de la Categoría'),
                    ),
                    const SizedBox(height: 20),
                    // SELECTOR DE COLOR
                    _buildColorSelector(context, colorSeleccionado, (newColor) {
                      setState(() {
                        colorSeleccionado = newColor;
                      });
                    }),
                    const SizedBox(height: 20),
                    // SELECTOR DE TIPOS APLICABLES
                    _TipoCategoriaSelector(
                      selectedTypes: tiposAplicables,
                      onChanged: (newTypes) {
                        setState(() {
                          tiposAplicables = newTypes;
                        });
                      },
                    ),
                  ],
                ),
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

                      // Creamos un nuevo objeto Categoria con los datos actualizados
                      final Categoria categoriaActualizada = Categoria(
                        idCategoria: categoria.idCategoria,
                        nombre: nombreController.text,
                        color: colorToHex(colorSeleccionado),
                        tiposAplicables: tiposAplicables.isEmpty ? {TipoCategoria.todos} : tiposAplicables,
                      );

                      gestion.editarCategoria(categoriaActualizada);
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

  /// Comentario: Widget auxiliar para la selección de color mediante Dropdown.
  Widget _buildColorSelector(BuildContext context, Color currentColor, Function(Color) onColorChanged) {
    // ... (El código de este widget se mantiene sin cambios)
    String colorName = coloresDisponibles.entries.firstWhere(
      (entry) => entry.value.value == currentColor.value,
      orElse: () => MapEntry('Personalizado', currentColor),
    ).key;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Color:', style: TextStyle(fontWeight: FontWeight.bold)),
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: currentColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade400, width: 1.5),
          ),
        ),
        DropdownButton<String>(
          value: coloresDisponibles.keys.contains(colorName) ? colorName : 'Negro',
          items: coloresDisponibles.keys.map((String name) {
            return DropdownMenuItem<String>(
              value: name,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: coloresDisponibles[name],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(name),
                ],
              ),
            );
          }).toList(),
          onChanged: (String? newName) {
            if (newName != null) {
              onColorChanged(coloresDisponibles[newName]!);
            }
          },
        ),
      ],
    );
  }
}

/// Comentario: Widget para seleccionar múltiples TipoCategoria.
class _TipoCategoriaSelector extends StatefulWidget {
  final Set<TipoCategoria> selectedTypes;
  final ValueChanged<Set<TipoCategoria>> onChanged;

  const _TipoCategoriaSelector({
    super.key,
    required this.selectedTypes,
    required this.onChanged,
  });

  @override
  State<_TipoCategoriaSelector> createState() => __TipoCategoriaSelectorState();
}

class __TipoCategoriaSelectorState extends State<_TipoCategoriaSelector> {
  final List<TipoCategoria> _availableTypes = [
    TipoCategoria.entrada,
    TipoCategoria.salida,
    TipoCategoria.transferencia,
  ];

  @override
  Widget build(BuildContext context) {
    // Determina si está en modo "Todos" (cuando el set contiene solo 'todos' o está vacío, aunque en la vista de edición siempre debería tener algo).
    final bool todosSelected = widget.selectedTypes.contains(TipoCategoria.todos) || widget.selectedTypes.isEmpty;
    // La selección real de tipos específicos es el set sin 'todos'.
    final Set<TipoCategoria> currentSelection = todosSelected ? {} : Set.from(widget.selectedTypes);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 📝 CORRECCIÓN: Etiqueta cambiada de frase a solo "Tipo:"
        const Text('Tipo:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        // Opción 'Todas'
        Row(
          children: [
            Checkbox(
              value: todosSelected,
              onChanged: (bool? value) {
                if (value == true) {
                  // Si se selecciona 'Todas', forzamos el estado a {TipoCategoria.todos}
                  widget.onChanged({TipoCategoria.todos});
                } else if (value == false && todosSelected) {
                  // ⭐️ CORRECCIÓN DEL BUG: Al desmarcar 'Todas', pasamos a un estado de un solo tipo (Entrada)
                  // en lugar de un set vacío, para evitar que 'Todas' se vuelva a marcar inmediatamente.
                  widget.onChanged({TipoCategoria.entrada});
                }
              },
            ),
            const Text('Todas (Entrada, Salida, Transferencia)'),
          ],
        ),

        // Opciones específicas
        Wrap(
          spacing: 8.0,
          children: _availableTypes.map((type) {
            final bool isSelected = currentSelection.contains(type);

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: isSelected,
                  // ⭐️ CORRECCIÓN DEL BUG: onChanged ya no es 'null' si 'todosSelected' es true.
                  // Esto permite hacer clic para salir del modo 'Todas'.
                  onChanged: (bool? value) {
                    setState(() {
                      final Set<TipoCategoria> newSelection = Set.from(currentSelection);

                      if (value == true) {
                        newSelection.add(type);
                      } else {
                        newSelection.remove(type);
                      }

                      // Si el usuario desmarca el último tipo específico, volvemos a 'Todas'.
                      if (newSelection.isEmpty) {
                        widget.onChanged({TipoCategoria.todos});
                      } else {
                        widget.onChanged(newSelection);
                      }
                    });
                  },
                ),
                Text(type.name.substring(0, 1).toUpperCase() + type.name.substring(1)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}