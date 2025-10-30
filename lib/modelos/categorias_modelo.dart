// Archivo: lib/modelos/categorias_modelo.dart
// Contiene el modelo de datos de Categoría (enum TipoOperacion) y su DAO (CategoriaBD).

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'base_datos.dart';

/// Comentario: Enumeración obsoleta para Tipos de Operación (Entrada/Salida).
enum TipoOperacion {
  entrada, // ⭐ REEMPLAZADO: ingreso -> entrada
  salida   // ⭐ REEMPLAZADO: gasto -> salida
}

// Comentario: NUEVO ENUM. Define a qué tipo de transacciones aplica una categoría.
enum TipoCategoria {
  entrada,        // ⭐ REEMPLAZADO: ingreso -> entrada
  salida,         // ⭐ REEMPLAZADO: gasto -> salida
  transferencia,
  todos
}

/// Comentario: Clase que representa una categoría de salida o entrada.
class Categoria {
  final String idCategoria;
  final String nombre;
  final TipoOperacion tipo; // Tipo de operación (Entrada o Salida)
  final String color;
  final Set<TipoCategoria> tiposAplicables;

  Categoria({
    String? idCategoria,
    required this.nombre,
    required this.tipo,
    this.color = '#000000',
    Set<TipoCategoria>? tiposAplicables,
  }) : idCategoria = idCategoria ?? const Uuid().v4(),
       tiposAplicables = tiposAplicables ?? {TipoCategoria.todos};

  // Comentario: Convierte el objeto Categoria a un Map para la base de datos.
  Map<String, dynamic> toMap() {
    final List<int> tiposIndices = tiposAplicables.map((t) => t.index).toList();

    return {
      'idCategoria': idCategoria,
      'nombre': nombre,
      'tipo': tipo.index,
      'color': color,
      'tiposAplicables': tiposIndices.join(','),
    };
  }

  // Comentario: Crea un objeto Categoria desde un Map de la base de datos.
  static Categoria fromMap(Map<String, dynamic> map) {
    final String tiposStr = map['tiposAplicables'] as String? ?? TipoCategoria.todos.index.toString();
    final Set<TipoCategoria> tipos = tiposStr.split(',')
        .map((e) => TipoCategoria.values[int.parse(e)])
        .toSet();

    return Categoria(
      idCategoria: map['idCategoria'] as String,
      nombre: map['nombre'] as String,
      tipo: TipoOperacion.values[map['tipo'] as int],
      color: map['color'] as String,
      tiposAplicables: tipos,
    );
  }
}

/// Comentario: Objeto de Acceso a Datos (DAO) para la entidad Categoria.
class CategoriaBD {
  final BaseDatosManager _dbManager;
  static const String nombreTabla = 'categorias';

  CategoriaBD(this._dbManager);

  // Comentario: Crea la tabla de Categorías en la base de datos.
  static void crearTabla(Database db) {
    db.execute('''
      CREATE TABLE $nombreTabla (
        idCategoria TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        tipo INTEGER NOT NULL,
        color TEXT NOT NULL DEFAULT '#000000',
        tiposAplicables TEXT NOT NULL DEFAULT '3'
      )
    ''');
  }

  /// Comentario: Inserta una nueva categoría.
  Future<void> insertarCategoria(Categoria categoria) async {
    final db = await _dbManager.database;
    await db.insert(nombreTabla, categoria.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Comentario: Actualiza una categoría existente.
  Future<void> actualizarCategoria(Categoria categoria) async {
    final db = await _dbManager.database;
    await db.update(
      nombreTabla,
      categoria.toMap(),
      where: 'idCategoria = ?',
      whereArgs: [categoria.idCategoria],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Comentario: Consulta todas las categorías de la base de datos.
  Future<List<Map<String, dynamic>>> consultarCategoriasMapas() async {
    final db = await _dbManager.database;
    return db.query(nombreTabla, orderBy: 'nombre ASC');
  }

  /// Comentario: Elimina una categoría por su ID.
  Future<void> eliminarCategoria(String id) async {
    final db = await _dbManager.database;
    await db.delete(
      nombreTabla,
      where: 'idCategoria = ?',
      whereArgs: [id],
    );
  }
}