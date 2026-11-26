import 'i18n_catalog.dart';
import 'content_i18n.dart';
import 'impostor_i18n.dart';

String? translateDynamicText(String text, String language) {
  if (language == 'es') return text;
  final ca = language == 'ca';

  String embedded(String value) {
    final mapValue = contentExact(value, language) ??
        (ca
        ? (impostorQuestionCaExact[value] ??
            impostorFactCaExact[value] ??
            impostorTermCaExact[value] ??
            caExactCatalog[value])
        : (impostorQuestionEnExact[value] ??
            impostorFactEnExact[value] ??
            impostorTermEnExact[value] ??
            enExactCatalog[value]));
    return mapValue ?? value;
  }

  String role(String value) {
    const caRoles = {
      'Asesino': 'Assassí',
      'Agente': 'Agent',
      'Invitado': 'Convidat',
      'Izquierda': 'Esquerra',
      'Derecha': 'Dreta',
      'Líder Oculto': 'Líder Ocult',
    };
    const enRoles = {
      'Asesino': 'Killer',
      'Agente': 'Agent',
      'Invitado': 'Guest',
      'Izquierda': 'Left',
      'Derecha': 'Right',
      'Líder Oculto': 'Hidden Leader',
    };
    return (ca ? caRoles : enRoles)[value] ?? value;
  }

  RegExpMatch? m;

  m = RegExp(r'^Jugador (\d+)$').firstMatch(text);
  if (m != null) return ca ? 'Jugador ${m.group(1)}' : 'Player ${m.group(1)}';
  m = RegExp(r'^jugador (\d+)$').firstMatch(text);
  if (m != null) return ca ? 'jugador ${m.group(1)}' : 'player ${m.group(1)}';
  m = RegExp(r'^Equipo (\d+)$').firstMatch(text);
  if (m != null) return ca ? 'Equip ${m.group(1)}' : 'Team ${m.group(1)}';
  m = RegExp(r'^Equipo (\d+) · (.+)$').firstMatch(text);
  if (m != null) return ca ? 'Equip ${m.group(1)} · ${m.group(2)}' : 'Team ${m.group(1)} · ${m.group(2)}';

  m = RegExp(r'^El máximo es de (\d+) jugadores\.?$').firstMatch(text);
  if (m != null) return ca ? 'El màxim és de ${m.group(1)} jugadors.' : 'The maximum is ${m.group(1)} players.';
  m = RegExp(r'^Añade al menos (\d+) jugadores\.?$').firstMatch(text);
  if (m != null) return ca ? 'Afegeix almenys ${m.group(1)} jugadors.' : 'Add at least ${m.group(1)} players.';
  m = RegExp(r'^La Asamblea necesita entre (\d+) y (\d+) jugadores$').firstMatch(text);
  if (m != null) return ca ? 'L’Assemblea necessita entre ${m.group(1)} i ${m.group(2)} jugadors' : 'The Assembly needs between ${m.group(1)} and ${m.group(2)} players';
  m = RegExp(r'^(\d+) y (\d+) jugadores$').firstMatch(text);
  if (m != null) return ca ? '${m.group(1)} i ${m.group(2)} jugadors' : '${m.group(1)} to ${m.group(2)} players';

  m = RegExp(r'^RONDA (\d+) DE (\d+)$').firstMatch(text);
  if (m != null) return ca ? 'RONDA ${m.group(1)} DE ${m.group(2)}' : 'ROUND ${m.group(1)} OF ${m.group(2)}';
  m = RegExp(r'^Turno de (.+)$').firstMatch(text);
  if (m != null) return ca ? 'Torn de ${m.group(1)}' : '${m.group(1)}’s turn';
  m = RegExp(r'^PRECISIÓN: (\d+)%$').firstMatch(text);
  if (m != null) return ca ? 'PRECISIÓ: ${m.group(1)}%' : 'ACCURACY: ${m.group(1)}%';
  m = RegExp(r'^Ganador: (.+)$').firstMatch(text);
  if (m != null) return ca ? 'Guanyador: ${m.group(1)}' : 'Winner: ${m.group(1)}';
  m = RegExp(r'^(\d+) pts$').firstMatch(text);
  if (m != null) return ca ? '${m.group(1)} punts' : '${m.group(1)} pts';

  m = RegExp(r'^(.+) es (Izquierda|Derecha|Líder Oculto)$').firstMatch(text);
  if (m != null) return ca ? '${m.group(1)} és ${role(m.group(2)!)}' : '${m.group(1)} is ${role(m.group(2)!)}';
  m = RegExp(r'^(.+) ha sido seleccionado\.$').firstMatch(text);
  if (m != null) return ca ? '${m.group(1)} ha estat seleccionat.' : '${m.group(1)} has been selected.';
  m = RegExp(r'^(.+) \(eliminado\)$').firstMatch(text);
  if (m != null) return ca ? '${m.group(1)} (eliminat)' : '${m.group(1)} (eliminated)';

  m = RegExp(r'^Ha salido el número (\d+)$').firstMatch(text);
  if (m != null) return ca ? 'Ha sortit el número ${m.group(1)}' : 'Number ${m.group(1)} came up';
  m = RegExp(r'^número (\d+)$').firstMatch(text);
  if (m != null) return ca ? 'número ${m.group(1)}' : 'number ${m.group(1)}';

  m = RegExp(r'^CARA (\d+)%  ·  CRUZ (\d+)%$').firstMatch(text);
  if (m != null) return ca ? 'CARA ${m.group(1)}%  ·  CREU ${m.group(2)}%' : 'HEADS ${m.group(1)}%  ·  TAILS ${m.group(2)}%';

  m = RegExp(r'^JUGADOR (\d+) DE (\d+)$').firstMatch(text);
  if (m != null) return ca ? 'JUGADOR ${m.group(1)} DE ${m.group(2)}' : 'PLAYER ${m.group(1)} OF ${m.group(2)}';
  m = RegExp(r'^Lugar: (.+)\n\nRol: (.+)$', dotAll: true).firstMatch(text);
  if (m != null) return ca ? 'Lloc: ${m.group(1)}\n\nRol: ${role(m.group(2)!)}' : 'Place: ${m.group(1)}\n\nRole: ${role(m.group(2)!)}';
  m = RegExp(r'^Pista: (.+)$', dotAll: true).firstMatch(text);
  if (m != null) {
    final value = embedded(m.group(1)!);
    return ca ? 'Pista: $value' : 'Hint: $value';
  }
  m = RegExp(r'^Impostor\(es\): (.+)$').firstMatch(text);
  if (m != null) return ca ? 'Impostor(s): ${m.group(1)}' : 'Impostor(s): ${m.group(1)}';

  m = RegExp(r'^FALTAN (\d+) JUGADORES$').firstMatch(text);
  if (m != null) return ca ? 'FALTEN ${m.group(1)} JUGADORS' : '${m.group(1)} PLAYERS NEEDED';
  m = RegExp(r'^Lote (\d+) de (\d+) · las pujas son secretas\.$').firstMatch(text);
  if (m != null) return ca ? 'Lot ${m.group(1)} de ${m.group(2)} · les licitacions són secretes.' : 'Lot ${m.group(1)} of ${m.group(2)} · bids are secret.';
  m = RegExp(r'^Valor real: (\d+)€$').firstMatch(text);
  if (m != null) return ca ? 'Valor real: ${m.group(1)}€' : 'Real value: €${m.group(1)}';
  m = RegExp(r'^pasa el móvil a\n(.+)$', dotAll: true).firstMatch(text);
  if (m != null) return ca ? 'passa el mòbil a\n${m.group(1)}' : 'pass the phone to\n${m.group(1)}';
  m = RegExp(r'^Disponible: (\d+)€$').firstMatch(text);
  if (m != null) return ca ? 'Disponible: ${m.group(1)}€' : 'Available: €${m.group(1)}';
  m = RegExp(r'^(\d+)€ de fortuna total$').firstMatch(text);
  if (m != null) return ca ? '${m.group(1)}€ de fortuna total' : '€${m.group(1)} total wealth';
  m = RegExp(r'^(.+) · (Asesino|Agente|Invitado) · (\d+)€ efectivo · (\d+)€ bienes$').firstMatch(text);
  if (m != null) return ca ? '${m.group(1)} · ${role(m.group(2)!)} · ${m.group(3)}€ efectiu · ${m.group(4)}€ béns' : '${m.group(1)} · ${role(m.group(2)!)} · €${m.group(3)} cash · €${m.group(4)} goods';
  m = RegExp(r'^(Asesino|Agente|Invitado) · (\d+)€ efectivo · (\d+)€ bienes$').firstMatch(text);
  if (m != null) return ca ? '${role(m.group(1)!)} · ${m.group(2)}€ efectiu · ${m.group(3)}€ béns' : '${role(m.group(1)!)} · €${m.group(2)} cash · €${m.group(3)} goods';
  m = RegExp(r'^(\d+)€ efectivo$').firstMatch(text);
  if (m != null) return ca ? '${m.group(1)}€ efectiu' : '€${m.group(1)} cash';
  m = RegExp(r'^(\d+)€ bienes$').firstMatch(text);
  if (m != null) return ca ? '${m.group(1)}€ béns' : '€${m.group(1)} goods';
  m = RegExp(r'^(\d+)€ total$').firstMatch(text);
  if (m != null) return ca ? '${m.group(1)}€ total' : '€${m.group(1)} total';
  m = RegExp(r'^(.+) · (Asesino|Agente|Invitado)$').firstMatch(text);
  if (m != null) return '${m.group(1)} · ${role(m.group(2)!)}';
  m = RegExp(r'^No puede asesinar durante (\d+):(\d+)$').firstMatch(text);
  if (m != null) return ca ? 'No pot assassinar durant ${m.group(1)}:${m.group(2)}' : 'Cannot kill for ${m.group(1)}:${m.group(2)}';
  m = RegExp(r'^Cantidad · disponible (\d+)€$').firstMatch(text);
  if (m != null) return ca ? 'Quantitat · disponible ${m.group(1)}€' : 'Amount · €${m.group(1)} available';
  m = RegExp(r'^(.+) · (\d+)€$').firstMatch(text);
  if (m != null) {
    final label = embedded(m.group(1)!);
    return ca ? '$label · ${m.group(2)}€' : '$label · €${m.group(2)}';
  }

  m = RegExp(r'^POSICIÓN (\d+)$').firstMatch(text);
  if (m != null) return ca ? 'POSICIÓ ${m.group(1)}' : 'POSITION ${m.group(1)}';
  m = RegExp(r'^Tu posición está (.+)\.$').firstMatch(text);
  if (m != null) {
    const caSides = {
      'muy hacia la izquierda': 'molt cap a l’esquerra',
      'tirando a la izquierda': 'tirant cap a l’esquerra',
      'bastante al centro': 'bastant al centre',
      'tirando a la derecha': 'tirant cap a la dreta',
      'muy hacia la derecha': 'molt cap a la dreta',
    };
    const enSides = {
      'muy hacia la izquierda': 'far to the left',
      'tirando a la izquierda': 'leaning left',
      'bastante al centro': 'around the middle',
      'tirando a la derecha': 'leaning right',
      'muy hacia la derecha': 'far to the right',
    };
    final side = (ca ? caSides : enSides)[m.group(1)] ?? m.group(1)!;
    return ca ? 'La teva posició és $side.' : 'Your position is $side.';
  }
  m = RegExp(r'^REAL: (\d+) · ADIVINADA: (\d+)$').firstMatch(text);
  if (m != null) return ca ? 'REAL: ${m.group(1)} · ENDEVINADA: ${m.group(2)}' : 'ACTUAL: ${m.group(1)} · GUESS: ${m.group(2)}';
  m = RegExp(r'^DIFERENCIA: (\d+)$').firstMatch(text);
  if (m != null) return ca ? 'DIFERÈNCIA: ${m.group(1)}' : 'DIFFERENCE: ${m.group(1)}';
  m = RegExp(r'^(\d+) puntos?$').firstMatch(text);
  if (m != null) {
    final singular = m.group(1) == '1';
    final unit = ca ? (singular ? 'punt' : 'punts') : (singular ? 'point' : 'points');
    return '${m.group(1)} $unit';
  }

  m = RegExp(r'^Verdades (\d+) · Pruebas (\d+)$').firstMatch(text);
  if (m != null) return ca ? 'Veritats ${m.group(1)} · Reptes ${m.group(2)}' : 'Truths ${m.group(1)} · Dares ${m.group(2)}';
  m = RegExp(r'^Quedan (\d+) palabras$').firstMatch(text);
  if (m != null) return ca ? 'Queden ${m.group(1)} paraules' : '${m.group(1)} words left';
  m = RegExp(r'^Ronda (\d+) completada$').firstMatch(text);
  if (m != null) return ca ? 'Ronda ${m.group(1)} completada' : 'Round ${m.group(1)} complete';
  m = RegExp(r'^(\d+) PUNTOS$').firstMatch(text);
  if (m != null) return ca ? '${m.group(1)} PUNTS' : '${m.group(1)} POINTS';


  m = RegExp(r'^(\d+) frase importada\.$').firstMatch(text);
  if (m != null) return ca ? '${m.group(1)} frase importada.' : '${m.group(1)} prompt imported.';
  m = RegExp(r'^(\d+) frases importadas\.$').firstMatch(text);
  if (m != null) return ca ? '${m.group(1)} frases importades.' : '${m.group(1)} prompts imported.';
  m = RegExp(r'^(\d+) carta importada\.$').firstMatch(text);
  if (m != null) return ca ? '${m.group(1)} carta importada.' : '${m.group(1)} card imported.';
  m = RegExp(r'^(\d+) cartas importadas\.$').firstMatch(text);
  if (m != null) return ca ? '${m.group(1)} cartes importades.' : '${m.group(1)} cards imported.';
  m = RegExp(r'^(\d+) acción importada\.$').firstMatch(text);
  if (m != null) return ca ? '${m.group(1)} acció importada.' : '${m.group(1)} action imported.';
  m = RegExp(r'^(\d+) acciones importadas\.$').firstMatch(text);
  if (m != null) return ca ? '${m.group(1)} accions importades.' : '${m.group(1)} actions imported.';

  m = RegExp(r'^Escribe una (verdad|prueba)\.$').firstMatch(text);
  if (m != null) {
    final isTruth = m.group(1) == 'verdad';
    final noun = ca ? (isTruth ? 'veritat' : 'repte') : (isTruth ? 'truth question' : 'dare');
    return ca ? 'Escriu una $noun.' : 'Write a $noun.';
  }
  m = RegExp(r'^Esta (verdad|prueba) ya está añadida\.$').firstMatch(text);
  if (m != null) {
    final isTruth = m.group(1) == 'verdad';
    final noun = ca ? (isTruth ? 'veritat' : 'repte') : (isTruth ? 'truth question' : 'dare');
    return ca ? 'Aquesta $noun ja està afegida.' : 'This $noun has already been added.';
  }
  m = RegExp(r'^IMPORTAR (VERDADES|PRUEBAS)$').firstMatch(text);
  if (m != null) {
    final isTruth = m.group(1) == 'VERDADES';
    final noun = ca ? (isTruth ? 'VERITATS' : 'REPTES') : (isTruth ? 'TRUTHS' : 'DARES');
    return ca ? 'IMPORTAR $noun' : 'IMPORT $noun';
  }
  m = RegExp(r'^Pega una (verdad|prueba) en cada línea\.$').firstMatch(text);
  if (m != null) {
    final isTruth = m.group(1) == 'verdad';
    final noun = ca ? (isTruth ? 'veritat' : 'repte') : (isTruth ? 'truth question' : 'dare');
    return ca ? 'Enganxa una $noun a cada línia.' : 'Paste one $noun per line.';
  }
  m = RegExp(r'^Todavía no has añadido (verdades|pruebas)$').firstMatch(text);
  if (m != null) {
    final isTruth = m.group(1) == 'verdades';
    final noun = ca ? (isTruth ? 'veritats' : 'reptes') : (isTruth ? 'truth questions' : 'dares');
    return ca ? 'Encara no has afegit $noun' : 'You have not added any $noun yet';
  }

  m = RegExp(r'^RONDA (\d+) · (.+)$').firstMatch(text);
  if (m != null) {
    const caRound = {'DESCRIBIR': 'DESCRIURE', 'MÍMICA': 'MÍMICA', 'SONIDOS': 'SONS'};
    const enRound = {'DESCRIBIR': 'DESCRIBE', 'MÍMICA': 'MIME', 'SONIDOS': 'SOUNDS'};
    final label = (ca ? caRound : enRound)[m.group(2)] ?? m.group(2)!;
    return ca ? 'RONDA ${m.group(1)} · $label' : 'ROUND ${m.group(1)} · $label';
  }

  m = RegExp(r'^Cada jugador debe decir su dato\. Después debatid quién se lo ha inventado\.\n\n(.+)$', dotAll: true).firstMatch(text);
  if (m != null) {
    final tail = translateDynamicText(m.group(1)!, language) ?? embedded(m.group(1)!);
    return ca
        ? 'Cada jugador ha de dir la seva dada. Després debateu qui se l’ha inventada.\n\n$tail'
        : 'Each player must say their fact. Then discuss who made theirs up.\n\n$tail';
  }

  m = RegExp(r'^(.+) no posee ningún bien\.$').firstMatch(text);
  if (m != null) return ca ? '${m.group(1)} no té cap bé.' : '${m.group(1)} does not own any goods.';

  // Dynamic Barcelona Midnight game-log messages.
  m = RegExp(r'^(.+) está eliminado y no puede asesinar\.$').firstMatch(text);
  if (m != null) return ca ? '${m.group(1)} està eliminat i no pot assassinar.' : '${m.group(1)} is eliminated and cannot kill.';
  m = RegExp(r'^(.+) sigue detenido y no puede asesinar todavía\.$').firstMatch(text);
  if (m != null) return ca ? '${m.group(1)} continua detingut i encara no pot assassinar.' : '${m.group(1)} is still detained and cannot kill yet.';
  m = RegExp(r'^(.+) ya está eliminado\.$').firstMatch(text);
  if (m != null) return ca ? '${m.group(1)} ja està eliminat.' : '${m.group(1)} has already been eliminated.';
  m = RegExp(r'^Cumpliste tu misión contra (.+) y recibiste (\d+)€\.$').firstMatch(text);
  if (m != null) return ca ? 'Has complert la missió contra ${m.group(1)} i has rebut ${m.group(2)}€.' : 'You completed your mission against ${m.group(1)} and received €${m.group(2)}.';
  m = RegExp(r'^(.+) ha sido eliminado y entrega (\d+)€ en efectivo\.$').firstMatch(text);
  if (m != null) return ca ? '${m.group(1)} ha estat eliminat i entrega ${m.group(2)}€ en efectiu.' : '${m.group(1)} has been eliminated and hands over €${m.group(2)} in cash.';
  m = RegExp(r'^(.+) está eliminado y no puede detener a nadie\.$').firstMatch(text);
  if (m != null) return ca ? '${m.group(1)} està eliminat i no pot detenir ningú.' : '${m.group(1)} is eliminated and cannot arrest anyone.';
  m = RegExp(r'^(.+) ya está fuera del juego\.$').firstMatch(text);
  if (m != null) return ca ? '${m.group(1)} ja és fora del joc.' : '${m.group(1)} is already out of the game.';
  m = RegExp(r'^Has sido detenido durante 10 minutos por (.+)\.$').firstMatch(text);
  if (m != null) return ca ? 'Has estat detingut durant 10 minuts per ${m.group(1)}.' : 'You have been detained for 10 minutes by ${m.group(1)}.';
  m = RegExp(r'^Detuviste correctamente a (.+) y recibiste (\d+)€\.$').firstMatch(text);
  if (m != null) return ca ? 'Has detingut correctament ${m.group(1)} i has rebut ${m.group(2)}€.' : 'You correctly arrested ${m.group(1)} and received €${m.group(2)}.';
  m = RegExp(r'^(.+) ha sido detenido durante 10 minutos\. Transfiere (\d+)€ al agente\.$').firstMatch(text);
  if (m != null) return ca ? '${m.group(1)} ha estat detingut durant 10 minuts. Transfereix ${m.group(2)}€ a l’agent.' : '${m.group(1)} has been detained for 10 minutes. Transfer €${m.group(2)} to the agent.';
  m = RegExp(r'^Acusación falsa contra (.+)\. Pagaste (\d+)€\.$').firstMatch(text);
  if (m != null) return ca ? 'Acusació falsa contra ${m.group(1)}. Has pagat ${m.group(2)}€.' : 'False accusation against ${m.group(1)}. You paid €${m.group(2)}.';
  m = RegExp(r'^Recibiste (\d+)€ por una acusación falsa\.$').firstMatch(text);
  if (m != null) return ca ? 'Has rebut ${m.group(1)}€ per una acusació falsa.' : 'You received €${m.group(1)} because of a false accusation.';
  m = RegExp(r'^La acusación contra (.+) era falsa\. El agente paga (\d+)€\.$').firstMatch(text);
  if (m != null) return ca ? 'L’acusació contra ${m.group(1)} era falsa. L’agent paga ${m.group(2)}€.' : 'The accusation against ${m.group(1)} was false. The agent pays €${m.group(2)}.';
  m = RegExp(r'^(.+) no tiene suficiente dinero\.$').firstMatch(text);
  if (m != null) return ca ? '${m.group(1)} no té prou diners.' : '${m.group(1)} does not have enough money.';
  m = RegExp(r'^(.+) transfiere (\d+)€ a (.+)\. Motivo: (.+)\.$').firstMatch(text);
  if (m != null) {
    final reason = embedded(m.group(4)!);
    return ca
        ? '${m.group(1)} transfereix ${m.group(2)}€ a ${m.group(3)}. Motiu: $reason.'
        : '${m.group(1)} transfers €${m.group(2)} to ${m.group(3)}. Reason: $reason.';
  }
  m = RegExp(r'^(.+) no posee ese bien\.$').firstMatch(text);
  if (m != null) return ca ? '${m.group(1)} no té aquest bé.' : '${m.group(1)} does not own that item.';
  m = RegExp(r'^(.+) entrega (.+) a (.+)\. Motivo: (.+)\.$').firstMatch(text);
  if (m != null) {
    final item = embedded(m.group(2)!);
    final reason = embedded(m.group(4)!);
    return ca
        ? '${m.group(1)} entrega $item a ${m.group(3)}. Motiu: $reason.'
        : '${m.group(1)} gives $item to ${m.group(3)}. Reason: $reason.';
  }
  m = RegExp(r'^Comienza la subasta final con (\d+) lotes\.$').firstMatch(text);
  if (m != null) return ca ? 'Comença la subhasta final amb ${m.group(1)} lots.' : 'The final auction starts with ${m.group(1)} lots.';
  m = RegExp(r'^Nadie ha pujado por (.+)\.$').firstMatch(text);
  if (m != null) {
    final item = embedded(m.group(1)!);
    return ca ? 'Ningú ha licitat per $item.' : 'Nobody bid on $item.';
  }
  m = RegExp(r'^(.+) gana el desempate y se lleva (.+) por (\d+)€\.$').firstMatch(text);
  if (m != null) {
    final item = embedded(m.group(2)!);
    return ca
        ? '${m.group(1)} guanya el desempat i s’emporta $item per ${m.group(3)}€.'
        : '${m.group(1)} wins the tiebreak and gets $item for €${m.group(3)}.';
  }
  m = RegExp(r'^(.+) se lleva (.+) por (\d+)€\.$').firstMatch(text);
  if (m != null) {
    final item = embedded(m.group(2)!);
    return ca
        ? '${m.group(1)} s’emporta $item per ${m.group(3)}€.'
        : '${m.group(1)} gets $item for €${m.group(3)}.';
  }
  m = RegExp(r'^Ganaste (.+) por (\d+)€\.$').firstMatch(text);
  if (m != null) {
    final item = embedded(m.group(1)!);
    return ca ? 'Has guanyat $item per ${m.group(2)}€.' : 'You won $item for €${m.group(2)}.';
  }

  return null;
}
