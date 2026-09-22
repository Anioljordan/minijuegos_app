import 'app_settings.dart';
import 'i18n_catalog.dart';
import 'yo_nunca_i18n.dart';
import 'prueba_verdad_i18n.dart';
import 'impostor_i18n.dart';
import 'ui_extra_i18n.dart';
import 'dynamic_i18n.dart';

String tr(String text) => AppI18n.translate(text);

class AppI18n {
  static String get language => AppSettings.instance.language;

  static String translate(String text) {
    final lang = language;
    if (lang == 'es' || text.trim().isEmpty) return text;

    final exact = (lang == 'ca' ? uiCaExact : uiEnExact)[text] ??
        (lang == 'ca' ? yoNuncaCaExact : yoNuncaEnExact)[text] ??
        (lang == 'ca' ? pruebaVerdadCaExact : pruebaVerdadEnExact)[text] ??
        (lang == 'ca' ? impostorQuestionCaExact : impostorQuestionEnExact)[text] ??
        (lang == 'ca' ? impostorFactCaExact : impostorFactEnExact)[text] ??
        (lang == 'ca' ? impostorTermCaExact : impostorTermEnExact)[text] ??
        (lang == 'ca' ? caExactCatalog : enExactCatalog)[text] ??
        (lang == 'ca' ? _caExact : _enExact)[text];
    if (exact != null) return exact;

    final dynamic = translateDynamicText(text, lang);
    if (dynamic != null) return dynamic;

    return lang == 'ca' ? _translateCatalan(text) : _translateEnglish(text);
  }

  static String _preserveCase(String original, String translated) {
    if (original.toUpperCase() == original && RegExp(r'[A-ZÁÉÍÓÚÑ]').hasMatch(original)) {
      return translated.toUpperCase();
    }
    if (original.isNotEmpty && original[0].toUpperCase() == original[0]) {
      return translated.isEmpty ? translated : translated[0].toUpperCase() + translated.substring(1);
    }
    return translated;
  }

  static String _replaceWords(String input, Map<String, String> dictionary) {
    var out = input;
    final keys = dictionary.keys.toList()..sort((a, b) => b.length.compareTo(a.length));
    for (final key in keys) {
      final value = dictionary[key]!;
      final pattern = RegExp('(?<![A-Za-zÀ-ÿ])${RegExp.escape(key)}(?![A-Za-zÀ-ÿ])', caseSensitive: false, unicode: true);
      out = out.replaceAllMapped(pattern, (m) => _preserveCase(m.group(0)!, value));
    }
    return out;
  }

  static String _translateCatalan(String text) {
    var out = text;
    for (final entry in caPhraseCatalog.entries) {
      out = out.replaceAll(entry.key, entry.value);
    }
    for (final entry in _caPhrases.entries) {
      out = out.replaceAll(entry.key, entry.value);
    }
    out = _replaceWords(out, caWordCatalog);
    out = _replaceWords(out, _caWords);
    return out;
  }

  static String _translateEnglish(String text) {
    var out = text;
    for (final entry in enPhraseCatalog.entries) {
      out = out.replaceAll(entry.key, entry.value);
    }
    for (final entry in _enPhrases.entries) {
      out = out.replaceAll(entry.key, entry.value);
    }
    out = _replaceWords(out, enWordCatalog);
    out = _replaceWords(out, _enWords);
    out = out
        .replaceAll('¿', '')
        .replaceAll('¡', '')
        .replaceAll('  ', ' ');
    return out;
  }

  static const Map<String, String> _caExact = {
    '¿A qué quieres jugar hoy?': 'A què vols jugar avui?',
    'Elige el mood y empieza la partida.': 'Tria el mood i comença la partida.',
    'Juegos de fiesta': 'Jocs de festa',
    'Retos, alcohol, risas y caos.': 'Reptes, alcohol, rialles i caos.',
    'Juegos de chill': 'Jocs chill',
    'Palabras, estrategia y diversión tranquila.': 'Paraules, estratègia i diversió tranquil·la.',
    'Cómo se juega': 'Com es juga',
    'Cerrar': 'Tancar',
    'Siguiente': 'Següent',
    'SIGUIENTE': 'SEGÜENT',
    'Reiniciar': 'Reiniciar',
    'REINICIAR': 'REINICIAR',
    'Empezar': 'Començar',
    'EMPEZAR': 'COMENÇAR',
    'Ajustes': 'Configuració',
    'Idioma': 'Idioma',
    'Volumen': 'Volum',
    'Sonidos': 'Sons',
    'Vibración': 'Vibració',
    'Acerca de la app': 'Sobre l’app',
    'Español': 'Espanyol',
    'Català': 'Català',
    'English': 'English',
    'Yo Nunca Nunca': 'Jo Mai Mai',
    'Yo Nunca Chill': 'Jo Mai Chill',
    'Yo Nunca Mix': 'Jo Mai Mix',
    'Yo Nunca Erótico': 'Jo Mai Eròtic',
    'Elige el modo de juego': 'Tria el mode de joc',
    'Modo Chill': 'Mode Chill',
    'Modo Mix': 'Mode Mix',
    'Modo Erótico': 'Mode Eròtic',
    'Prueba o Verdad': 'Repte o Veritat',
    'VERDAD': 'VERITAT',
    'PRUEBA': 'REPTE',
    'Verdad': 'Veritat',
    'Prueba': 'Repte',
    'Señala y bebe': 'Assenyala i beu',
    'Animales Profesionales': 'Animals Professionals',
    'Describe la palabra': 'Descriu la paraula',
    'La Asamblea': 'L’Assemblea',
    'Reparto de roles': 'Repartiment de rols',
    'Barcelona Medianoche': 'Barcelona Mitjanit',
    'Memoria Fotografica': 'Memòria Fotogràfica',
    '4 en raya': '4 en ratlla',
    'Jugador 1': 'Jugador 1',
    'Jugador 2': 'Jugador 2',
    'Resultado': 'Resultat',
    'EMPATE': 'EMPAT',
    'VICTORIA': 'VICTÒRIA',
    'Empate': 'Empat',
    'Revancha': 'Revenja',
    'Reset total': 'Reinici total',
    'Turno del rojo': 'Torn del vermell',
    'Turno del amarillo': 'Torn del groc',
    'Ha ganado el rojo': 'Ha guanyat el vermell',
    'Ha ganado el amarillo': 'Ha guanyat el groc',
    'Pulsa siguiente para empezar': 'Prem següent per començar',
    'Pulsa empezar para jugar': 'Prem començar per jugar',
    'Pulsa GENERAR para empezar': 'Prem GENERAR per començar',
    'GENERAR': 'GENERAR',
    'MOSTRAR': 'MOSTRAR',
    'OCULTAR': 'AMAGAR',
    'Contenido oculto': 'Contingut ocult',
    'Pasa el móvil al siguiente jugador': 'Passa el mòbil al jugador següent',
    'Pasa el móvil a:': 'Passa el mòbil a:',
    'Ver rol': 'Veure rol',
    'Siguiente jugador': 'Jugador següent',
    'Terminar reparto': 'Acabar repartiment',
    'Izquierda': 'Esquerra',
    'Derecha': 'Dreta',
    'Líder Oculto': 'Líder Ocult',
    'Ley de Izquierda': 'Llei d’Esquerra',
    'Ley de Derecha': 'Llei de Dreta',
    'Ley aleatoria aprobada': 'Llei aleatòria aprovada',
    'Continuar jugando': 'Continuar jugant',
    'Salir al menú': 'Sortir al menú',
    'Reiniciar partida': 'Reiniciar partida',
    'Nueva partida con últimos jugadores': 'Nova partida amb els últims jugadors',
    'Empezar desde cero': 'Començar des de zero',
    'Continuar partida': 'Continuar partida',
    'Añade los jugadores': 'Afegeix els jugadors',
    'Nombre del jugador': 'Nom del jugador',
    'Añadir': 'Afegir',
    'Todavía no hay jugadores': 'Encara no hi ha jugadors',
    'Empezar partida': 'Començar partida',
    'Cargar última partida': 'Carregar última partida',
    'Vaciar lista': 'Buidar llista',
    'Gira la ruleta y acepta el reto': 'Gira la ruleta i accepta el repte',
    'Pulsa PARAR cuando quieras': 'Prem PARAR quan vulguis',
    'La ruleta está frenando...': 'La ruleta està frenant...',
    'Girando...': 'Girant...',
    'Te ha tocado': 'T’ha tocat',
    'PARAR': 'PARAR',
    'GIRAR': 'GIRAR',
    'CASTIGO': 'CÀSTIG',
    'Preguntas restantes:': 'Preguntes restants:',
    'Frases restantes:': 'Frases restants:',
    'Restantes:': 'Restants:',
    'Impostor clásico': 'Impostor clàssic',
    'Impostor con roles': 'Impostor amb rols',
    'Pregunta distinta': 'Pregunta diferent',
    'Dato falso': 'Dada falsa',
    'Eres el impostor': 'Ets l’impostor',
    'Lugar': 'Lloc',
    'Pregunta': 'Pregunta',
    'Datos curiosos': 'Dades curioses',
    'Reglas rápidas': 'Regles ràpides',
    'Jugadores': 'Jugadors',
    'Acciones': 'Accions',
    'Estado de los jugadores': 'Estat dels jugadors',
    'Preparar partida': 'Preparar partida',
    'Comenzar reparto secreto': 'Començar repartiment secret',
    'Faltan jugadores': 'Falten jugadors',
    'Empezar la noche': 'Començar la nit',
    'Registrar asesinato': 'Registrar assassinat',
    'Registrar detención': 'Registrar detenció',
    'Abrir subasta': 'Obrir subhasta',
    'Registro de la noche': 'Registre de la nit',
    'Asesino': 'Assassí',
    'Agente': 'Agent',
    'Invitado': 'Convidat',
  };

  static const Map<String, String> _enExact = {
    '¿A qué quieres jugar hoy?': 'What do you want to play today?',
    'Elige el mood y empieza la partida.': 'Pick a mood and start playing.',
    'Juegos de fiesta': 'Party games',
    'Retos, alcohol, risas y caos.': 'Challenges, drinks, laughs and chaos.',
    'Juegos de chill': 'Chill games',
    'Palabras, estrategia y diversión tranquila.': 'Words, strategy and relaxed fun.',
    'Cómo se juega': 'How to play',
    'Cerrar': 'Close',
    'Siguiente': 'Next',
    'SIGUIENTE': 'NEXT',
    'Reiniciar': 'Reset',
    'REINICIAR': 'RESET',
    'Empezar': 'Start',
    'EMPEZAR': 'START',
    'Ajustes': 'Settings',
    'Idioma': 'Language',
    'Volumen': 'Volume',
    'Sonidos': 'Sound',
    'Vibración': 'Vibration',
    'Acerca de la app': 'About the app',
    'Español': 'Spanish',
    'Català': 'Catalan',
    'English': 'English',
    'Yo Nunca Nunca': 'Never Have I Ever',
    'Yo Nunca Chill': 'Never Have I Ever · Chill',
    'Yo Nunca Mix': 'Never Have I Ever · Mix',
    'Yo Nunca Erótico': 'Never Have I Ever · Spicy',
    'Elige el modo de juego': 'Choose a game mode',
    'Modo Chill': 'Chill Mode',
    'Modo Mix': 'Mix Mode',
    'Modo Erótico': 'Spicy Mode',
    'Prueba o Verdad': 'Truth or Dare',
    'VERDAD': 'TRUTH',
    'PRUEBA': 'DARE',
    'Verdad': 'Truth',
    'Prueba': 'Dare',
    'Señala y bebe': 'Point & Drink',
    'Animales Profesionales': 'Professional Animals',
    'Describe la palabra': 'Describe the Word',
    'La Asamblea': 'The Assembly',
    'Reparto de roles': 'Role Assignment',
    'Barcelona Medianoche': 'Barcelona Midnight',
    'Memoria Fotografica': 'Photo Memory',
    '4 en raya': 'Connect Four',
    'Resultado': 'Result',
    'EMPATE': 'DRAW',
    'VICTORIA': 'VICTORY',
    'Empate': 'Draw',
    'Revancha': 'Rematch',
    'Reset total': 'Reset all',
    'Turno del rojo': 'Red’s turn',
    'Turno del amarillo': 'Yellow’s turn',
    'Ha ganado el rojo': 'Red wins',
    'Ha ganado el amarillo': 'Yellow wins',
    'Pulsa siguiente para empezar': 'Tap next to start',
    'Pulsa empezar para jugar': 'Tap start to play',
    'Pulsa GENERAR para empezar': 'Tap GENERATE to start',
    'GENERAR': 'GENERATE',
    'MOSTRAR': 'SHOW',
    'OCULTAR': 'HIDE',
    'Contenido oculto': 'Hidden content',
    'Pasa el móvil al siguiente jugador': 'Pass the phone to the next player',
    'Pasa el móvil a:': 'Pass the phone to:',
    'Ver rol': 'Reveal role',
    'Siguiente jugador': 'Next player',
    'Terminar reparto': 'Finish assignment',
    'Izquierda': 'Left',
    'Derecha': 'Right',
    'Líder Oculto': 'Hidden Leader',
    'Ley de Izquierda': 'Left Law',
    'Ley de Derecha': 'Right Law',
    'Ley aleatoria aprobada': 'Random law passed',
    'Continuar jugando': 'Keep playing',
    'Salir al menú': 'Exit to menu',
    'Reiniciar partida': 'Restart game',
    'Nueva partida con últimos jugadores': 'New game with last players',
    'Empezar desde cero': 'Start from scratch',
    'Continuar partida': 'Continue game',
    'Añade los jugadores': 'Add players',
    'Nombre del jugador': 'Player name',
    'Añadir': 'Add',
    'Todavía no hay jugadores': 'No players yet',
    'Empezar partida': 'Start game',
    'Cargar última partida': 'Load last game',
    'Vaciar lista': 'Clear list',
    'Gira la ruleta y acepta el reto': 'Spin the wheel and take the challenge',
    'Pulsa PARAR cuando quieras': 'Tap STOP whenever you want',
    'La ruleta está frenando...': 'The wheel is slowing down...',
    'Girando...': 'Spinning...',
    'Te ha tocado': 'You got',
    'PARAR': 'STOP',
    'GIRAR': 'SPIN',
    'CASTIGO': 'PENALTY',
    'Preguntas restantes:': 'Questions left:',
    'Frases restantes:': 'Prompts left:',
    'Restantes:': 'Left:',
    'Impostor clásico': 'Classic Impostor',
    'Impostor con roles': 'Roles Impostor',
    'Pregunta distinta': 'Different Question',
    'Dato falso': 'Fake Fact',
    'Eres el impostor': 'You are the impostor',
    'Lugar': 'Place',
    'Pregunta': 'Question',
    'Datos curiosos': 'Fun facts',
    'Reglas rápidas': 'Quick rules',
    'Jugadores': 'Players',
    'Acciones': 'Actions',
    'Estado de los jugadores': 'Player status',
    'Preparar partida': 'Prepare game',
    'Comenzar reparto secreto': 'Start secret assignment',
    'Faltan jugadores': 'Not enough players',
    'Empezar la noche': 'Start the night',
    'Registrar asesinato': 'Record murder',
    'Registrar detención': 'Record arrest',
    'Abrir subasta': 'Open auction',
    'Registro de la noche': 'Night log',
    'Asesino': 'Killer',
    'Agente': 'Agent',
    'Invitado': 'Guest',
  };

  static const Map<String, String> _caPhrases = {
    'Yo nunca nunca': 'Jo mai mai',
    'Yo nunca': 'Jo mai',
    '¿Quién es más probable que': 'Qui és més probable que',
    'Señala a quien': 'Assenyala qui',
    'Pasa el móvil a': 'Passa el mòbil a',
    'Pulsa para': 'Prem per',
    'Pulsa ': 'Prem ',
    'Si no lo haces': 'Si no ho fas',
    'Si alguna vez lo has hecho': 'Si alguna vegada ho has fet',
    'Reparte ': 'Reparteix ',
    'Bebe ': 'Beu ',
    'Elige ': 'Tria ',
    'Jugador ': 'Jugador ',
    'Equipo ': 'Equip ',
    'Ronda ': 'Ronda ',
    'Turno ': 'Torn ',
    'Nueva partida': 'Nova partida',
    'partida nueva': 'partida nova',
    'siguiente jugador': 'jugador següent',
    'última partida': 'última partida',
  };

  static const Map<String, String> _enPhrases = {
    'Yo nunca nunca': 'Never have I ever',
    'Yo nunca': 'Never have I ever',
    '¿Quién es más probable que': 'Who is most likely to',
    'Señala a quien': 'Point to whoever',
    'Pasa el móvil a': 'Pass the phone to',
    'Pulsa para': 'Tap to',
    'Pulsa ': 'Tap ',
    'Si no lo haces': 'If you do not do it',
    'Si alguna vez lo has hecho': 'If you have ever done it',
    'Reparte ': 'Give out ',
    'Bebe ': 'Drink ',
    'Elige ': 'Choose ',
    'Jugador ': 'Player ',
    'Equipo ': 'Team ',
    'Ronda ': 'Round ',
    'Turno ': 'Turn ',
    'Nueva partida': 'New game',
    'partida nueva': 'new game',
    'siguiente jugador': 'next player',
    'última partida': 'last game',
  };

  static const Map<String, String> _caWords = {
    'y': 'i', 'o': 'o', 'de': 'de', 'del': 'del', 'la': 'la', 'el': 'el', 'los': 'els', 'las': 'les',
    'un': 'un', 'una': 'una', 'unos': 'uns', 'unas': 'unes', 'con': 'amb', 'sin': 'sense', 'para': 'per',
    'jugadores': 'jugadors', 'jugador': 'jugador', 'preguntas': 'preguntes', 'pregunta': 'pregunta',
    'frases': 'frases', 'frase': 'frase', 'palabras': 'paraules', 'palabra': 'paraula', 'reto': 'repte', 'retos': 'reptes',
    'verdad': 'veritat', 'prueba': 'repte', 'pruebas': 'reptes', 'modo': 'mode', 'juego': 'joc', 'juegos': 'jocs',
    'partida': 'partida', 'equipo': 'equip', 'equipos': 'equips', 'ronda': 'ronda', 'rondas': 'rondes',
    'tiempo': 'temps', 'segundos': 'segons', 'segundo': 'segon', 'puntos': 'punts', 'punto': 'punt',
    'ganador': 'guanyador', 'ganadora': 'guanyadora', 'gana': 'guanya', 'ganado': 'guanyat', 'resultado': 'resultat',
    'rojo': 'vermell', 'amarillo': 'groc', 'verde': 'verd', 'azul': 'blau', 'color': 'color', 'colores': 'colors',
    'izquierda': 'esquerra', 'derecha': 'dreta', 'centro': 'centre', 'arriba': 'amunt', 'abajo': 'avall',
    'móvil': 'mòbil', 'oculto': 'ocult', 'oculta': 'oculta', 'mostrar': 'mostrar', 'ocultar': 'amagar',
    'añadir': 'afegir', 'eliminar': 'eliminar', 'guardar': 'desar', 'cargar': 'carregar', 'continuar': 'continuar',
    'empezar': 'començar', 'comenzar': 'començar', 'terminar': 'acabar', 'siguiente': 'següent', 'anterior': 'anterior',
    'volver': 'tornar', 'cerrar': 'tancar', 'aceptar': 'acceptar', 'cancelar': 'cancel·lar', 'elegir': 'triar',
    'nombre': 'nom', 'nombres': 'noms', 'lista': 'llista', 'listas': 'llistes', 'último': 'últim', 'últimos': 'últims',
    'reglas': 'regles', 'normas': 'normes', 'acción': 'acció', 'acciones': 'accions', 'castigo': 'càstig',
    'bebes': 'beus', 'bebe': 'beu', 'beber': 'beure', 'tragos': 'glops', 'trago': 'glop', 'repartes': 'reparteixes', 'reparte': 'reparteix',
    'fiesta': 'festa', 'noche': 'nit', 'día': 'dia', 'persona': 'persona', 'personas': 'persones',
    'todos': 'tots', 'todas': 'totes', 'alguien': 'algú', 'nadie': 'ningú', 'más': 'més', 'menos': 'menys',
    'muy': 'molt', 'nada': 'gens', 'ahora': 'ara', 'antes': 'abans', 'después': 'després', 'primero': 'primer',
    'secreto': 'secret', 'secreta': 'secreta', 'rol': 'rol', 'roles': 'rols', 'líder': 'líder', 'ley': 'llei', 'leyes': 'lleis',
    'presidente': 'president', 'portavoz': 'portaveu', 'investigar': 'investigar', 'ver': 'veure', 'tres': 'tres',
    'asesino': 'assassí', 'asesinos': 'assassins', 'agente': 'agent', 'agentes': 'agents', 'invitado': 'convidat',
    'habitación': 'habitació', 'arma': 'arma', 'armas': 'armes', 'dinero': 'diners', 'subasta': 'subhasta',
    'animal': 'animal', 'animales': 'animals', 'profesión': 'professió', 'profesiones': 'professions',
    'perro': 'gos', 'gato': 'gat', 'caballo': 'cavall', 'pájaro': 'ocell', 'pez': 'peix', 'tiburón': 'tauró',
    'médico': 'metge', 'profesor': 'professor', 'cocinero': 'cuiner', 'camarero': 'cambrer', 'bombero': 'bomber',
    'policía': 'policia', 'abogado': 'advocat', 'juez': 'jutge', 'programador': 'programador',
    'comida': 'menjar', 'mala': 'dolenta', 'rico': 'bo', 'barato': 'barat', 'caro': 'car', 'divertido': 'divertit',
    'aburrido': 'avorrit', 'romántico': 'romàntic', 'útil': 'útil', 'inútil': 'inútil',
  };

  static const Map<String, String> _enWords = {
    'y': 'and', 'o': 'or', 'de': 'of', 'del': 'of the', 'la': 'the', 'el': 'the', 'los': 'the', 'las': 'the',
    'un': 'a', 'una': 'a', 'unos': 'some', 'unas': 'some', 'con': 'with', 'sin': 'without', 'para': 'for',
    'que': 'that', 'qué': 'what', 'quién': 'who', 'quienes': 'who', 'cuando': 'when', 'donde': 'where', 'cómo': 'how',
    'jugadores': 'players', 'jugador': 'player', 'preguntas': 'questions', 'pregunta': 'question',
    'frases': 'prompts', 'frase': 'prompt', 'palabras': 'words', 'palabra': 'word', 'reto': 'challenge', 'retos': 'challenges',
    'verdad': 'truth', 'prueba': 'dare', 'pruebas': 'dares', 'modo': 'mode', 'juego': 'game', 'juegos': 'games',
    'partida': 'game', 'equipo': 'team', 'equipos': 'teams', 'ronda': 'round', 'rondas': 'rounds',
    'tiempo': 'time', 'segundos': 'seconds', 'segundo': 'second', 'puntos': 'points', 'punto': 'point',
    'ganador': 'winner', 'ganadora': 'winner', 'gana': 'wins', 'ganado': 'won', 'resultado': 'result',
    'rojo': 'red', 'amarillo': 'yellow', 'verde': 'green', 'azul': 'blue', 'color': 'color', 'colores': 'colors',
    'izquierda': 'left', 'derecha': 'right', 'centro': 'center', 'arriba': 'up', 'abajo': 'down',
    'móvil': 'phone', 'movil': 'phone', 'oculto': 'hidden', 'oculta': 'hidden', 'mostrar': 'show', 'ocultar': 'hide',
    'añadir': 'add', 'eliminar': 'remove', 'guardar': 'save', 'cargar': 'load', 'continuar': 'continue',
    'empezar': 'start', 'comenzar': 'start', 'terminar': 'finish', 'siguiente': 'next', 'anterior': 'previous',
    'volver': 'back', 'cerrar': 'close', 'aceptar': 'accept', 'cancelar': 'cancel', 'elegir': 'choose', 'elige': 'choose',
    'nombre': 'name', 'nombres': 'names', 'lista': 'list', 'listas': 'lists', 'último': 'last', 'últimos': 'last',
    'reglas': 'rules', 'normas': 'rules', 'acción': 'action', 'acciones': 'actions', 'castigo': 'penalty',
    'bebes': 'drink', 'bebe': 'drink', 'beber': 'drink', 'tragos': 'sips', 'trago': 'sip', 'repartes': 'give out', 'reparte': 'give out',
    'fiesta': 'party', 'noche': 'night', 'día': 'day', 'persona': 'person', 'personas': 'people',
    'todos': 'everyone', 'todas': 'everyone', 'alguien': 'someone', 'nadie': 'nobody', 'más': 'more', 'menos': 'less',
    'muy': 'very', 'nada': 'not at all', 'ahora': 'now', 'antes': 'before', 'después': 'after', 'primero': 'first',
    'secreto': 'secret', 'secreta': 'secret', 'rol': 'role', 'roles': 'roles', 'líder': 'leader', 'ley': 'law', 'leyes': 'laws',
    'presidente': 'president', 'portavoz': 'speaker', 'investigar': 'investigate', 'ver': 'see', 'tres': 'three',
    'asesino': 'killer', 'asesinos': 'killers', 'agente': 'agent', 'agentes': 'agents', 'invitado': 'guest',
    'habitación': 'room', 'arma': 'weapon', 'armas': 'weapons', 'dinero': 'money', 'subasta': 'auction',
    'animal': 'animal', 'animales': 'animals', 'profesión': 'profession', 'profesiones': 'professions',
    'perro': 'dog', 'gato': 'cat', 'mono': 'monkey', 'gallina': 'chicken', 'vaca': 'cow', 'caballo': 'horse',
    'cerdo': 'pig', 'pato': 'duck', 'león': 'lion', 'tigre': 'tiger', 'elefante': 'elephant', 'jirafa': 'giraffe',
    'canguro': 'kangaroo', 'pingüino': 'penguin', 'oso': 'bear', 'rana': 'frog', 'tortuga': 'turtle', 'pulpo': 'octopus',
    'delfín': 'dolphin', 'tiburón': 'shark', 'búho': 'owl', 'lobo': 'wolf', 'zorro': 'fox', 'conejo': 'rabbit',
    'ratón': 'mouse', 'oveja': 'sheep', 'cabra': 'goat', 'burro': 'donkey', 'camello': 'camel', 'cebra': 'zebra',
    'gorila': 'gorilla', 'panda': 'panda', 'murciélago': 'bat', 'ciervo': 'deer', 'águila': 'eagle', 'serpiente': 'snake',
    'araña': 'spider', 'abeja': 'bee', 'mariposa': 'butterfly', 'mosca': 'fly', 'mosquito': 'mosquito',
    'bombero': 'firefighter', 'médico': 'doctor', 'profesor': 'teacher', 'policía': 'police officer', 'cocinero': 'cook',
    'camarero': 'waiter', 'peluquero': 'hairdresser', 'dentista': 'dentist', 'veterinario': 'vet', 'astronauta': 'astronaut',
    'pintor': 'painter', 'mecánico': 'mechanic', 'electricista': 'electrician', 'panadero': 'baker', 'granjero': 'farmer',
    'jardinero': 'gardener', 'actor': 'actor', 'cantante': 'singer', 'bailarín': 'dancer', 'piloto': 'pilot',
    'enfermero': 'nurse', 'carpintero': 'carpenter', 'periodista': 'journalist', 'abogado': 'lawyer', 'juez': 'judge',
    'detective': 'detective', 'programador': 'programmer', 'fotógrafo': 'photographer', 'modelo': 'model',
    'comida': 'food', 'mala': 'bad', 'rica': 'tasty', 'rico': 'tasty', 'barato': 'cheap', 'caro': 'expensive',
    'divertido': 'fun', 'aburrido': 'boring', 'romántico': 'romantic', 'útil': 'useful', 'inútil': 'useless',
    'casa': 'home', 'coche': 'car', 'avión': 'plane', 'playa': 'beach', 'montaña': 'mountain', 'cerveza': 'beer',
    'discoteca': 'club', 'helado': 'ice cream', 'guitarra': 'guitar', 'bicicleta': 'bike', 'hospital': 'hospital',
    'zapato': 'shoe', 'ordenador': 'computer', 'restaurante': 'restaurant', 'patata': 'potato', 'escalera': 'stairs',
  };
}
