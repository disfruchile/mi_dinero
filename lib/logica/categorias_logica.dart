// Archivo: lib/logica/categorias_logica.dart
// Contiene la lógica de negocio y gestiona el estado (ChangeNotifier) de las categorías.

import 'package:flutter/material.dart';
import '../modelos/categorias_modelo.dart';

/// Comentario: Clase que gestiona la lógica de las Categorías y notifica a los Widgets (ChangeNotifier).
class CategoriaGestion with ChangeNotifier {
  final CategoriaBD _categoriaBD;
  List<Categoria> _categorias = [];

  List<Categoria> get categorias => _categorias;

  CategoriaGestion(this._categoriaBD);

  /// Comentario: Carga todas las categorías desde la base de datos.
  Future<void> cargarCategorias() async {
    final List<Map<String, dynamic>> maps = await _categoriaBD.consultarCategoriasMapas();
    _categorias = maps.map((map) => Categoria.fromMap(map)).toList();
    notifyListeners();
  }

  /// Comentario: Agrega una nueva categoría.
  Future<void> agregarCategoria(String nombre, TipoOperacion tipo, String color, Set<TipoCategoria> tiposAplicables) async {
    final nuevaCategoria = Categoria(
      nombre: nombre,
      tipo: tipo,
      color: color,
      tiposAplicables: tiposAplicables.isEmpty ? {TipoCategoria.todos} : tiposAplicables,
    );
    await _categoriaBD.insertarCategoria(nuevaCategoria);
    await cargarCategorias();
  }

  /// Comentario: Edita una categoría existente.
  Future<void> editarCategoria(Categoria categoria) async {
    await _categoriaBD.actualizarCategoria(categoria);
    await cargarCategorias();
  }

  /// Comentario: Actualiza una categoría existente en la BD y recarga. (Se mantiene por si se usa directamente).
  Future<void> actualizarCategoria(Categoria categoria) async {
    await _categoriaBD.actualizarCategoria(categoria);
    await cargarCategorias();
  }

  /// Comentario: Elimina una categoría por su ID de la base de datos y del estado.
  Future<void> eliminarCategoria(String id) async {
    await _categoriaBD.eliminarCategoria(id);
    await cargarCategorias();
  }
}