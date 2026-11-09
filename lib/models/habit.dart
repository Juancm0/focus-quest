/// Modelo de un hábito / misión diaria.
///
/// Un hábito se puede completar como máximo una vez al día. Cada
/// compleción suma [xpPorCompletar] al XP total y alimenta la racha.
class Habit {
  const Habit({
    required this.id,
    required this.nombre,
    required this.icono,
    required this.color,
    this.xpPorCompletar = 20,
    this.racha = 0,
    this.totalCompletados = 0,
    this.ultimaFecha,
    this.historial = const [],
  });

  /// Identificador único (uuid simple generado en la app).
  final String id;

  /// Nombre que le puso el usuario, p. ej. "Leer 20 min".
  final String nombre;

  /// Nombre del icono de Material Icons (ver [habitIcons] en
  /// habit_form_screen.dart). Se guarda como texto para persistirlo en JSON.
  final String icono;

  /// Color principal en formato ARGB entero (Color(...).toARGB32()).
  final int color;

  /// XP que otorga cada compleción.
  final int xpPorCompletar;

  /// Días seguidos completando el hábito.
  final int racha;

  /// Veces totales que se ha completado.
  final int totalCompletados;

  /// Último día completado (solo fecha, sin hora) o null si nunca.
  final DateTime? ultimaFecha;

  /// Días completados (solo fecha, sin hora), para el resumen semanal.
  final List<DateTime> historial;

  /// Fecha de hoy sin la hora, para comparar días.
  static DateTime soloFecha(DateTime fecha) =>
      DateTime(fecha.year, fecha.month, fecha.day);

  bool completadoHoy([DateTime? hoy]) {
    if (ultimaFecha == null) return false;
    return soloFecha(ultimaFecha!) == soloFecha(hoy ?? DateTime.now());
  }

  /// Devuelve una copia con la compleción de [fecha] aplicada.
  ///
  /// Si ya estaba completado ese día, devuelve el hábito sin cambios.
  /// La racha sube en 1 si el día anterior también se completó,
  /// vuelve a 1 si hubo un hueco, y empieza en 1 la primera vez.
  Habit completar([DateTime? fecha]) {
    final dia = soloFecha(fecha ?? DateTime.now());
    if (ultimaFecha != null && soloFecha(ultimaFecha!) == dia) return this;

    final ayer = dia.subtract(const Duration(days: 1));
    final sigueRacha =
        ultimaFecha != null && soloFecha(ultimaFecha!) == ayer;
    return copyWith(
      racha: sigueRacha ? racha + 1 : 1,
      totalCompletados: totalCompletados + 1,
      ultimaFecha: dia,
      historial: [...historial, dia],
    );
  }

  /// Cuántas veces se completó en los últimos 7 días (incluido [hoy]).
  Map<DateTime, int> resumenSemanal([DateTime? hoy]) {
    final referencia = soloFecha(hoy ?? DateTime.now());
    final resultado = <DateTime, int>{
      for (var i = 6; i >= 0; i--)
        referencia.subtract(Duration(days: i)): 0,
    };
    for (final dia in historial) {
      final d = soloFecha(dia);
      if (resultado.containsKey(d)) resultado[d] = resultado[d]! + 1;
    }
    return resultado;
  }

  Habit copyWith({
    String? id,
    String? nombre,
    String? icono,
    int? color,
    int? xpPorCompletar,
    int? racha,
    int? totalCompletados,
    DateTime? ultimaFecha,
    List<DateTime>? historial,
  }) {
    return Habit(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      icono: icono ?? this.icono,
      color: color ?? this.color,
      xpPorCompletar: xpPorCompletar ?? this.xpPorCompletar,
      racha: racha ?? this.racha,
      totalCompletados: totalCompletados ?? this.totalCompletados,
      ultimaFecha: ultimaFecha ?? this.ultimaFecha,
      historial: historial ?? this.historial,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'icono': icono,
    'color': color,
    'xpPorCompletar': xpPorCompletar,
    'racha': racha,
    'totalCompletados': totalCompletados,
    'ultimaFecha': ultimaFecha?.toIso8601String(),
    'historial': historial.map((d) => d.toIso8601String()).toList(),
  };

  factory Habit.fromJson(Map<String, dynamic> json) {
    DateTime? parseFecha(dynamic valor) =>
        valor == null ? null : DateTime.parse(valor as String);
    return Habit(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      icono: json['icono'] as String? ?? 'flag',
      color: json['color'] as int? ?? 0xFFFFB020,
      xpPorCompletar: json['xpPorCompletar'] as int? ?? 20,
      racha: json['racha'] as int? ?? 0,
      totalCompletados: json['totalCompletados'] as int? ?? 0,
      ultimaFecha: parseFecha(json['ultimaFecha']),
      historial: (json['historial'] as List<dynamic>? ?? [])
          .map((e) => DateTime.parse(e as String))
          .toList(),
    );
  }
}
