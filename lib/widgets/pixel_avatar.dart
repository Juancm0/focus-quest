import 'package:flutter/material.dart';

import '../logic/level_system.dart';

/// Avatar pixelado dibujado solo con widgets (sin assets de imagen).
///
/// El casco cambia de color y la corona aparece según el rango:
/// Novato (verde) -> Aventurero (azul) -> Caballero (plata) ->
/// Héroe (oro) -> Leyenda (violeta con corona).
class PixelAvatar extends StatelessWidget {
  const PixelAvatar({super.key, required this.rango, this.size = 120});

  final Rango rango;
  final double size;

  Color get _colorCasco {
    switch (rango) {
      case Rango.novato:
        return const Color(0xFF4CAF50);
      case Rango.aventurero:
        return const Color(0xFF42A5F5);
      case Rango.caballero:
        return const Color(0xFFB0BEC5);
      case Rango.heroe:
        return const Color(0xFFFFB020);
      case Rango.leyenda:
        return const Color(0xFF8B5CF6);
    }
  }

  Color get _colorAcento {
    switch (rango) {
      case Rango.novato:
        return const Color(0xFF2E7D32);
      case Rango.aventurero:
        return const Color(0xFF1565C0);
      case Rango.caballero:
        return const Color(0xFFFFB020);
      case Rango.heroe:
        return const Color(0xFFE65100);
      case Rango.leyenda:
        return const Color(0xFFFFD54F);
    }
  }

  static const _cara = [
    '..........',
    '.HHHHHHHH.',
    'HHHHHHHHHH',
    'HHSSSSSSHH',
    'HSSEESSESH',
    'HSSSSSSSSH',
    'HSSMMMMSSH',
    '.SSSSSSSS.',
    '..SSSSSS..',
    '.AAAAAAAA.',
  ];

  String get _corona {
    switch (rango) {
      case Rango.leyenda:
        return '..CCCCCC..';
      case Rango.heroe:
        return '...C..C...';
      case Rango.caballero:
      case Rango.aventurero:
      case Rango.novato:
        return '..........';
    }
  }

  @override
  Widget build(BuildContext context) {
    // El borde quita 2 px por lado al área interior: el píxel se calcula
    // sobre el ancho interior para que las 10 columnas quepan exactas.
    const borderWidth = 2.0;
    final pixel = (size - borderWidth * 2) / 10;
    final filas = [_corona, ..._cara];
    const piel = Color(0xFFF2C29B);
    const oscuro = Color(0xFF1A1D29);

    Color? colorDe(String c) {
      switch (c) {
        case 'H':
          return _colorCasco;
        case 'S':
          return piel;
        case 'E':
          return oscuro;
        case 'M':
          return const Color(0xFF8D4A2F);
        case 'A':
          return _colorAcento;
        case 'C':
          return const Color(0xFFFFD54F);
        default:
          return null;
      }
    }

    return Container(
      width: size,
      height: size + pixel,
      decoration: BoxDecoration(
        color: const Color(0xFF232839),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _colorCasco.withValues(alpha: 0.5),
          width: borderWidth,
        ),
      ),
      // Sin padding: cada fila mide exactamente 10 píxeles de ancho,
      // así no hay desbordamiento.
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: filas.map((fila) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: fila.split('').map((c) {
              final color = colorDe(c);
              return Container(
                width: pixel * 0.92,
                height: pixel * 0.92,
                margin: EdgeInsets.all(pixel * 0.04),
                decoration: BoxDecoration(
                  color: color ?? Colors.transparent,
                  borderRadius: BorderRadius.circular(pixel * 0.2),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
