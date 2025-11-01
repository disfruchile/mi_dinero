// Archivo: lib/vistas/pantalla_principal.dart
// Contiene la vista principal de la aplicación con la estructura de botones y balance.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; 
import 'package:collection/collection.dart';

// Lógica de Categorías
import '../logica/categorias_logica.dart';
import 'categorias_vistas.dart';
// Importaciones de Cuentas
import '../logica/cuentas_logica.dart';
import '../modelos/cuentas_modelo.dart'; 
import 'cuentas_vistas.dart'; 
// ⭐ NUEVO: Importaciones de Operaciones
import '../logica/operaciones_logica.dart';
import '../modelos/operaciones_modelo.dart';
import 'operaciones_vistas.dart'; // Para navegar a la lista y el formulario



/// Comentario: Pantalla principal de la aplicación.
class PantallaPrincipal extends StatelessWidget {
  const PantallaPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    // USAMOS Consumer3: Para observar los cambios en CategoriaGestion, CuentaGestion y OperacionesGestion.
    return Consumer3<CategoriaGestion, CuentaGestion, OperacionesGestion>(
      builder: (context, categoriaGestion, cuentaGestion, operacionesGestion, child) {
        
        // 1. Mostrar pantalla de carga si CuentaGestion no está listo.
        if (!cuentaGestion.isInitialized) {
          return Scaffold(
            appBar: AppBar(title: const Text('Mi Dinero')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Cálculo de saldos
        final double saldoTotal = cuentaGestion.cuentas.fold(0.0, (sum, cuenta) => sum + cuenta.saldoActual);
        final double saldoEfectivo = cuentaGestion.cuentas
            .where((c) => c.tipo == TipoCuenta.efectivo)
            .fold(0.0, (sum, cuenta) => sum + cuenta.saldoActual);
        final double saldoTransferencia = cuentaGestion.cuentas
            .where((c) => c.tipo == TipoCuenta.transferencia)
            .fold(0.0, (sum, cuenta) => sum + cuenta.saldoActual);
            
        // Formato de moneda.
        final formatter = NumberFormat.currency(locale: 'es_CL', symbol: '\$', decimalDigits: 0);
        
        return Scaffold(
          appBar: AppBar( 
            title: const Text('Mi Dinero'),
            actions: [
              // Botón de Cuentas
              IconButton(
                icon: const Icon(Icons.account_balance_wallet_outlined),
                tooltip: 'Gestionar Cuentas',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const VistaGestionCuentas(),
                    ),
                  );
                },
              ),
              // Botón de Categorías
              IconButton(
                icon: const Icon(Icons.category),
                tooltip: 'Gestionar Categorías',
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
                // Sección de Balance Total (Actualizada)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0), 
                  child: Column(
                    children: [
                      const Text('Balance Total:', style: TextStyle(fontSize: 24)),
                      Text(
                        formatter.format(saldoTotal), 
                        style: TextStyle(
                          fontSize: 48, 
                          fontWeight: FontWeight.bold, 
                          color: saldoTotal >= 0 ? Colors.green.shade700 : Colors.red.shade700
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Contenedores de Efectivo y Transferencia (Actualizados con saldos)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Caja de Efectivo
                      Expanded(
                        child: _buildFondoBox(
                          context,
                          Colors.green.shade100,
                          'Efectivo',
                          formatter.format(saldoEfectivo),
                          // Botones de Efectivo
                          Column(
                            children: [
                              _buildOperacionButton(context, TipoOperacion.ingreso, TipoCuenta.efectivo),
                              const SizedBox(height: 5),
                              _buildOperacionButton(context, TipoOperacion.gasto, TipoCuenta.efectivo),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Caja de Transferencia
                      Expanded(
                        child: _buildFondoBox(
                          context,
                          Colors.blue.shade100,
                          'Transferencia',
                          formatter.format(saldoTransferencia),
                          // Botones de Transferencia
                          Column(
                            children: [
                              _buildOperacionButton(context, TipoOperacion.ingreso, TipoCuenta.transferencia),
                              const SizedBox(height: 5),
                              _buildOperacionButton(context, TipoOperacion.gasto, TipoCuenta.transferencia),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                
                // ⭐ NUEVO: Lista de Últimas Operaciones
                const Padding(
                  padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Últimas Operaciones:', style: TextStyle(fontSize: 20)),
                  ),
                ),
                Expanded(
                  child: operacionesGestion.operaciones.isEmpty
                      ? const Center(child: Text('No hay operaciones recientes.'))
                      : ListView.builder(
                          itemCount: operacionesGestion.operaciones.length > 5 
                            ? 5 // Mostrar solo las últimas 5
                            : operacionesGestion.operaciones.length,
                          itemBuilder: (context, index) {
                            final operacion = operacionesGestion.operaciones[index];
                            return OperacionItem(operacion: operacion); // <-- EL CAMBIO ESTÁ AQUÍ
                          },
                        ),
                ),
              ],
            ),
          ),
          // FAB sin Hero duplicado, para añadir una operación
          floatingActionButton: FloatingActionButton(
            heroTag: 'añadirOperacionFAB',
            onPressed: () {
               showDialog(
                 context: context,
                 builder: (context) => OperacionFormDialog(
                   cuentaId: '',
                 ),
               );
            },
            tooltip: 'Añadir nueva operación',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  /// Comentario: Widget auxiliar para construir las cajas de Efectivo/Transferencia.
  Widget _buildFondoBox(BuildContext context, Color color, String titulo, String saldo, Widget botones) {
    final double saldoValor = double.tryParse(saldo.replaceAll(RegExp(r'[^\d,-]'), '').replaceAll(',', '.')) ?? 0.0;
    final Color saldoColor = saldoValor >= 0 ? Colors.black87 : Colors.red.shade700;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(titulo, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(saldo, style: TextStyle(fontSize: 24, color: saldoColor, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          botones,
        ],
      ),
    );
  }

  /// Comentario: Widget auxiliar para construir los botones de Entrada/Salida.
  Widget _buildOperacionButton(BuildContext context, TipoOperacion tipo, TipoCuenta tipoCuenta) {
    final cuentaGestion = Provider.of<CuentaGestion>(context, listen: false);
    final primeraCuenta = cuentaGestion.cuentas.firstWhereOrNull((c) => c.tipo == tipoCuenta);

    if (primeraCuenta == null) {
      // Si no hay ninguna cuenta de este tipo, no se muestra el botón.
      return const SizedBox();
    }

    String textoBoton = tipo == TipoOperacion.ingreso ? 'Entrada' : 'Salida';
    Color colorIcono = tipo == TipoOperacion.ingreso ? Colors.green : Colors.red;
    IconData icono = tipo == TipoOperacion.ingreso ? Icons.add : Icons.remove;

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: colorIcono,
        minimumSize: const Size(double.infinity, 36),
      ),
      icon: Icon(icono),
      label: Text(textoBoton),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => OperacionFormDialog(
            cuentaId: primeraCuenta.idCuenta,
            operacion: Operacion(
              idCuenta: primeraCuenta.idCuenta,
              tipo: tipo,
              monto: 0,
              fecha: DateTime.now(),
              descripcion: '',
              idCategoria: '',
            ),
          ),
        );
      },
    );
  }
}
