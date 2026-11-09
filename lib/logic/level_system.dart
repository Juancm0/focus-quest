/// Sistema de niveles, XP y rangos del avatar.
///
/// El XP necesario para subir de un nivel al siguiente crece con el nivel:
/// nivel 1 -> 2 cuesta 100 XP, nivel 2 -> 3 cuesta 150 XP, y así
/// (100 + (nivel - 1) * 50). Todo es función pura del XP total, así que
/// es fácil de probar y de razonar.
class LevelSystem {
  /// XP que cuesta pasar del [nivel] al siguiente.
  static int xpParaSubirDeNivel(int nivel) => 100 + (nivel - 1) * 50;

  /// XP total acumulado necesario para llegar al [nivel].
  static int xpTotalParaNivel(int nivel) {
    var total = 0;
    for (var n = 1; n < nivel; n++) {
      total += xpParaSubirDeNivel(n);
    }
    return total;
  }

  /// Nivel que corresponde a [xpTotal] (empieza en 1).
  static int nivelParaXp(int xpTotal) {
    if (xpTotal <= 0) return 1;
    var nivel = 1;
    var acumulado = 0;
    while (true) {
      final costo = xpParaSubirDeNivel(nivel);
      if (xpTotal < acumulado + costo) return nivel;
      acumulado += costo;
      nivel++;
    }
  }

  /// XP ya ganado dentro del nivel actual.
  static int xpEnNivelActual(int xpTotal) =>
      xpTotal - xpTotalParaNivel(nivelParaXp(xpTotal));

  /// XP que falta para el siguiente nivel (o que costaba el nivel actual).
  static int xpNecesarioEnNivelActual(int xpTotal) =>
      xpParaSubirDeNivel(nivelParaXp(xpTotal));

  /// Progreso dentro del nivel actual, de 0.0 a 1.0.
  static double progresoNivel(int xpTotal) {
    final necesario = xpNecesarioEnNivelActual(xpTotal);
    if (necesario <= 0) return 1;
    return (xpEnNivelActual(xpTotal) / necesario).clamp(0.0, 1.0);
  }
}

/// Rango del avatar según el nivel.
enum Rango {
  novato,
  aventurero,
  caballero,
  heroe,
  leyenda,
}

extension RangoInfo on Rango {
  String get nombre {
    switch (this) {
      case Rango.novato:
        return 'Novato';
      case Rango.aventurero:
        return 'Aventurero';
      case Rango.caballero:
        return 'Caballero';
      case Rango.heroe:
        return 'Héroe';
      case Rango.leyenda:
        return 'Leyenda';
    }
  }

  String get descripcion {
    switch (this) {
      case Rango.novato:
        return 'Tu aventura apenas comienza.';
      case Rango.aventurero:
        return 'Ya recorres el camino con confianza.';
      case Rango.caballero:
        return 'Tu disciplina es tu armadura.';
      case Rango.heroe:
        return 'Tus hábitos inspiran a otros.';
      case Rango.leyenda:
        return 'Pocos llegan tan lejos. Eres leyenda.';
    }
  }

  /// Nivel mínimo para alcanzar este rango.
  int get nivelMinimo {
    switch (this) {
      case Rango.novato:
        return 1;
      case Rango.aventurero:
        return 3;
      case Rango.caballero:
        return 5;
      case Rango.heroe:
        return 8;
      case Rango.leyenda:
        return 10;
    }
  }
}

/// Rango que corresponde a un [nivel].
Rango rangoParaNivel(int nivel) {
  if (nivel >= 10) return Rango.leyenda;
  if (nivel >= 8) return Rango.heroe;
  if (nivel >= 5) return Rango.caballero;
  if (nivel >= 3) return Rango.aventurero;
  return Rango.novato;
}
