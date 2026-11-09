import 'package:flutter_test/flutter_test.dart';
import 'package:focus_quest/logic/level_system.dart';

void main() {
  group('LevelSystem', () {
    test('empieza en nivel 1 con 0 XP', () {
      expect(LevelSystem.nivelParaXp(0), 1);
      expect(LevelSystem.nivelParaXp(99), 1);
    });

    test('100 XP suben al nivel 2', () {
      expect(LevelSystem.nivelParaXp(100), 2);
      expect(LevelSystem.nivelParaXp(249), 2);
    });

    test('el costo por nivel crece 50 XP cada nivel', () {
      expect(LevelSystem.xpParaSubirDeNivel(1), 100);
      expect(LevelSystem.xpParaSubirDeNivel(2), 150);
      expect(LevelSystem.xpParaSubirDeNivel(3), 200);
      expect(LevelSystem.xpParaSubirDeNivel(4), 250);
    });

    test('XP total acumulado para cada nivel', () {
      expect(LevelSystem.xpTotalParaNivel(1), 0);
      expect(LevelSystem.xpTotalParaNivel(2), 100);
      expect(LevelSystem.xpTotalParaNivel(3), 250);
      expect(LevelSystem.xpTotalParaNivel(4), 450);
      expect(LevelSystem.xpTotalParaNivel(5), 700);
    });

    test('nivel 5 con 700 XP y nivel 10 con 2700 XP', () {
      expect(LevelSystem.nivelParaXp(700), 5);
      expect(LevelSystem.nivelParaXp(699), 4);
      expect(LevelSystem.nivelParaXp(2700), 10);
      expect(LevelSystem.nivelParaXp(2699), 9);
    });

    test('progreso dentro del nivel va de 0 a 1', () {
      expect(LevelSystem.progresoNivel(0), 0);
      expect(LevelSystem.progresoNivel(50), 0.5);
      expect(LevelSystem.progresoNivel(100), 0);
      expect(LevelSystem.progresoNivel(175), 0.5);
      expect(LevelSystem.xpEnNivelActual(175), 75);
      expect(LevelSystem.xpNecesarioEnNivelActual(175), 150);
    });

    test('rangos por nivel', () {
      expect(rangoParaNivel(1), Rango.novato);
      expect(rangoParaNivel(2), Rango.novato);
      expect(rangoParaNivel(3), Rango.aventurero);
      expect(rangoParaNivel(5), Rango.caballero);
      expect(rangoParaNivel(7), Rango.caballero);
      expect(rangoParaNivel(8), Rango.heroe);
      expect(rangoParaNivel(10), Rango.leyenda);
      expect(rangoParaNivel(15), Rango.leyenda);
    });

    test('cada rango tiene nombre y nivel mínimo', () {
      expect(Rango.novato.nombre, 'Novato');
      expect(Rango.aventurero.nombre, 'Aventurero');
      expect(Rango.caballero.nombre, 'Caballero');
      expect(Rango.heroe.nombre, 'Héroe');
      expect(Rango.leyenda.nombre, 'Leyenda');
      expect(Rango.leyenda.nivelMinimo, 10);
    });
  });
}
