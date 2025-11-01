// Archivo: lib/logica/operaciones_logica.dart

import 'package:flutter/material.dart';
import '../modelos/base_datos.dart';
import '../modelos/operaciones_modelo.dart';
import 'cuentas_logica.dart'; // Necesario para actualizar saldos.

/// Comentario: Clase para gestionar el estado y la persistencia de las Operaciones.
class OperacionesGestion extends ChangeNotifier {
  final BaseDatosManager _dbManager;
  final CuentaGestion _cuentasGestion;
  late OperacionBD _operacionBD;

  List<Operacion> _operaciones = [];
  bool _estaCargando = false;
  bool _isInicializado = false;

  OperacionesGestion(this._dbManager, this._cuentasGestion) {
    _operacionBD = OperacionBD(_dbManager);
    // ⭐ El constructor ya no llama a la carga, lo hacemos desde main.dart.
  }

  List<Operacion> get operaciones => _operaciones;
  bool get estaCargando => _estaCargando;
  bool get isInicializado => _isInicializado;

  // ⭐ MÉTODO PÚBLICO AGREGADO: Carga todas las operaciones desde la base de datos (Sqflite).
  Future<void> cargarOperaciones() async {
    _estaCargando = true;
    notifyListeners();

    try {
      final operacionesMapas = await _operacionBD.consultarOperacionesMapas();
      _operaciones = operacionesMapas
          .map((mapa) => Operacion.fromMap(mapa))
          .toList();
    } catch (e) {
      print('Error al cargar operaciones: $e');
      _operaciones = [];
    }

    _estaCargando = false;
    _isInicializado = true;
    notifyListeners();
  }

  /// Comentario: Lógica central para manejar la actualización de saldos de las cuentas
  /// involucradas en una operación.
  void _actualizarSaldos({
    required Operacion operacion,
    double montoOriginal = 0,
  }) {
    if (montoOriginal != 0) {
      _revertirImpacto(operacion: operacion, monto: montoOriginal);
    }
    
    double montoAjustado = operacion.monto;

    switch (operacion.tipo) {
      case TipoOperacion.ingreso:
        _cuentasGestion.ajustarSaldo(operacion.idCuenta, montoAjustado);
        break;
      case TipoOperacion.gasto:
        _cuentasGestion.ajustarSaldo(operacion.idCuenta, -montoAjustado);
        break;
      case TipoOperacion.transferencia:
        _cuentasGestion.ajustarSaldo(operacion.idCuenta, -montoAjustado);
        if (operacion.idCuentaDestino != null) {
          _cuentasGestion.ajustarSaldo(operacion.idCuentaDestino!, montoAjustado);
        }
        break;
    }
  }

  /// Comentario: Revisa el impacto de una operación antigua para revertirlo.
  void _revertirImpacto({required Operacion operacion, required double monto}) {
      switch (operacion.tipo) {
        case TipoOperacion.ingreso:
          _cuentasGestion.ajustarSaldo(operacion.idCuenta, -monto);
          break;
        case TipoOperacion.gasto:
          _cuentasGestion.ajustarSaldo(operacion.idCuenta, monto);
          break;
        case TipoOperacion.transferencia:
          _cuentasGestion.ajustarSaldo(operacion.idCuenta, monto);
          if (operacion.idCuentaDestino != null) {
            _cuentasGestion.ajustarSaldo(operacion.idCuentaDestino!, -monto);
          }
          break;
      }
  }

  // Métodos CRUD

  // Función: Agrega una nueva operación y actualiza el saldo de las cuentas.
  Future<void> agregarOperacion(Operacion operacion) async {
    try {
      await _operacionBD.insertarOperacion(operacion);
      _operaciones.insert(0, operacion);
      _actualizarSaldos(operacion: operacion);
      notifyListeners();
    } catch (e) {
      print('Error al agregar operación: $e');
    }
  }

  // Función: Actualiza una operación existente y ajusta los saldos de las cuentas.
  Future<void> actualizarOperacion(Operacion operacion) async {
    try {
      final index = _operaciones.indexWhere((o) => o.idOperacion == operacion.idOperacion);
      if (index != -1) {
        final Operacion operacionOriginal = _operaciones[index];
        final double montoOriginal = operacionOriginal.monto;
        await _operacionBD.actualizarOperacion(operacion);
        _operaciones[index] = operacion;
        _actualizarSaldos(operacion: operacion, montoOriginal: montoOriginal);
        notifyListeners();
      }
    } catch (e) {
      print('Error al actualizar operación: $e');
    }
  }

  // Función: Elimina una operación y revierte su impacto en los saldos.
  Future<void> eliminarOperacion(String idOperacion) async {
    try {
      final index = _operaciones.indexWhere((o) => o.idOperacion == idOperacion);
      if (index != -1) {
        final Operacion operacion = _operaciones[index];
        await _operacionBD.eliminarOperacion(idOperacion);
        _revertirImpacto(operacion: operacion, monto: operacion.monto);
        _operaciones.removeAt(index);
        notifyListeners();
      }
    } catch (e) {
      print('Error al eliminar operación: $e');
    }
  }
}
