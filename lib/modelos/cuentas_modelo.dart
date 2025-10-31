// Archivo: lib/modelos/cuentas_modelo.dart
// Contiene la definición del modelo de datos Cuenta y el DAO (Data Access Object)
// para interactuar con la tabla de Cuentas en la BD (SQLite).

import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';
// ⭐ CORRECCIÓN: Usamos BaseDatosManager
import 'base_datos.dart'; 

// Comentario: Enum para diferenciar el tipo de cuenta (Efectivo o Transferencia).
enum TipoCuenta { efectivo, transferencia }

/// Comentario: Clase modelo para la entidad Cuenta.
class Cuenta {
  final String idCuenta;
  final String nombre;
  final TipoCuenta tipo;
  final double saldoInicial;
  final double saldoActual;
  final String color;

  // Comentario: Constructor principal
  Cuenta({
    required this.idCuenta,
    required this.nombre,
    required this.tipo,
    required this.saldoInicial,
    required this.saldoActual,
    required this.color,
  });

  // Comentario: Constructor para crear una nueva cuenta (genera ID y usa saldo inicial).
  factory Cuenta.nueva({
    required String nombre,
    required TipoCuenta tipo,
    required double saldoInicial,
    required String color,
  }) {
    const uuid = Uuid();
    final id = uuid.v4(); // Genera un ID universal único
    return Cuenta(
      idCuenta: id,
      nombre: nombre,
      tipo: tipo,
      saldoInicial: saldoInicial,
      saldoActual: saldoInicial, // Al inicio, el saldo actual es igual al inicial
      color: color,
    );
  }

  // Comentario: Convierte un objeto Cuenta a un Map (para inserción en BD)
  Map<String, dynamic> toMap() {
    return {
      'idCuenta': idCuenta,
      'nombre': nombre,
      'tipo': tipo == TipoCuenta.efectivo ? 0 : 1, // 0 para Efectivo, 1 para Transferencia
      'saldoInicial': saldoInicial,
      'saldoActual': saldoActual,
      'color': color,
    };
  }

  // Comentario: Crea un objeto Cuenta desde un Map (leído de la BD)
  factory Cuenta.fromMap(Map<String, dynamic> map) {
    return Cuenta(
      idCuenta: map['idCuenta'] as String,
      nombre: map['nombre'] as String,
      tipo: (map['tipo'] as int) == 0 ? TipoCuenta.efectivo : TipoCuenta.transferencia,
      saldoInicial: map['saldoInicial'] as double,
      saldoActual: map['saldoActual'] as double,
      color: map['color'] as String,
    );
  }
}

/// Comentario: Data Access Object (DAO) para la gestión de la tabla de Cuentas.
class CuentaBD {
  // ⭐ CORRECCIÓN: Usamos BaseDatosManager
  final BaseDatosManager _dbManager;
  final String nombreTabla = 'cuentas';

  // ⭐ CORRECCIÓN: El constructor usa BaseDatosManager
  CuentaBD(this._dbManager);

  // Comentario: Define la estructura de la tabla de Cuentas (Schema).
  static String get crearTabla => '''
    CREATE TABLE cuentas(
      idCuenta TEXT PRIMARY KEY,
      nombre TEXT,
      tipo INTEGER,
      saldoInicial REAL,
      saldoActual REAL,
      color TEXT
    )
  ''';

  /// Comentario: Inserta una nueva cuenta en la base de datos.
  Future<void> insertarCuenta(Cuenta cuenta) async {
    final db = await _dbManager.database;
    await db.insert(
      nombreTabla,
      cuenta.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Comentario: Consulta todas las cuentas de la base de datos.
  Future<List<Cuenta>> consultarCuentas() async {
    final db = await _dbManager.database;
    final List<Map<String, dynamic>> maps = await db.query(nombreTabla);

    return List.generate(maps.length, (i) {
      return Cuenta.fromMap(maps[i]);
    });
  }

  /// Comentario: Actualiza una cuenta existente.
  Future<void> actualizarCuenta(Cuenta cuenta) async {
    final db = await _dbManager.database;
    await db.update(
      nombreTabla,
      cuenta.toMap(),
      where: 'idCuenta = ?',
      whereArgs: [cuenta.idCuenta],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Comentario: Elimina una cuenta por su ID.
  Future<void> eliminarCuenta(String idCuenta) async {
    final db = await _dbManager.database;
    await db.delete(
      nombreTabla,
      where: 'idCuenta = ?',
      whereArgs: [idCuenta],
    );
  }
}