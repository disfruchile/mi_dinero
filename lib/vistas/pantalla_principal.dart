// Archivo: lib/vistas/pantalla_principal.dart
// Contiene la vista principal de la aplicación con la estructura de botones y balance.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; 
// Lógica de Categorías
import '../logica/categorias_logica.dart';
import 'categorias_vistas.dart';
// Importaciones de Cuentas
import '../logica/cuentas_logica.dart';
import '../modelos/cuentas_modelo.dart'; 
import 'cuentas_vistas.dart'; 

/// Comentario: Pantalla principal de la aplicación.
class PantallaPrincipal extends StatelessWidget {
  const PantallaPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    // USAMOS Consumer2: Para observar los cambios en CategoriaGestion y CuentaGestion.
    return Consumer2<CategoriaGestion, CuentaGestion>(
      builder: (context, categoriaGestion, cuentaGestion, child) {
        
        // 1. Mostrar pantalla de carga si CuentaGestion no está listo.
        if (!cuentaGestion.isInitialized) {
          return Scaffold(
            appBar: AppBar(title: Text('Mi Dinero')),
            body: Center(child: CircularProgressIndicator()),
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
          // ⭐ CORREGIDO: AppBar sin const.
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
                      // Texto dinámico: no puede ser const
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
                          Colors.green.shade100,
                          'Efectivo',
                          formatter.format(saldoEfectivo),
                          // Botones de Efectivo
                          Column(
                            children: [
                              _buildOperacionButton(Colors.green, Icons.add, 'Entrada', () {/* Lógica Transacción Efectivo Ingreso */}),
                              const SizedBox(height: 5),
                              _buildOperacionButton(Colors.red, Icons.remove, 'Salida', () {/* Lógica Transacción Efectivo Gasto */}),
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
                          formatter.format(saldoTransferencia),
                          // Botones de Transferencia
                          Column(
                            children: [
                              _buildOperacionButton(Colors.green, Icons.add, 'Entrada', () {/* Lógica Transacción Transferencia Ingreso */}),
                              const SizedBox(height: 5),
                              _buildOperacionButton(Colors.red, Icons.remove, 'Salida', () {/* Lógica Transacción Transferencia Gasto */}),
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
                    // Texto dinámico: no puede ser const
                    child: Text('Lista de operaciones aquí (${categoriaGestion.categorias.length} categorías cargadas)'), 
                  ),
                ),
              ],
            ),
          ),
          // FAB sin Hero duplicado, para añadir una operación
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
  Widget _buildFondoBox(Color color, String titulo, String saldo, Widget botones) {
    // Usamos el color del saldo del total consolidado para el saldo del box
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
  Widget _buildOperacionButton(Color color, IconData icon, String texto, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
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