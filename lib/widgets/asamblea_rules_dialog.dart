import 'package:flutter/material.dart' hide Text;
import 'i18n_text.dart';

const Color _appBlue = Color(0xFF2F4F9C);
const Color _appWhite = Color(0xFFF7F7F7);
const Color _leftBlue = Color(0xFF60A5FA);
const Color _rightRed = Color(0xFFE63946);
const Color _leaderGold = Color(0xFFFFD166);

ButtonStyle _mainButtonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: _appWhite,
    foregroundColor: _appBlue,
    elevation: 0,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.zero,
    ),
  );
}

Widget _rulesItem({
  required IconData icon,
  required String title,
  required String text,
  required Color color,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
    decoration: BoxDecoration(
      color: _appWhite.withOpacity(0.08),
      border: Border.all(
        color: _appWhite.withOpacity(0.26),
        width: 1.4,
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: _appWhite,
          size: 22,
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr(title).toUpperCase(),
                style: const TextStyle(
                  color: _appWhite,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                text,
                style: TextStyle(
                  color: _appWhite.withOpacity(0.72),
                  fontSize: 12.5,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Future<void> showAsambleaRulesDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        decoration: BoxDecoration(
          color: _appBlue,
          border: Border.all(
            color: _appWhite.withOpacity(0.75),
            width: 2.2,
          ),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.78,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _appWhite.withOpacity(0.85),
                          width: 2.1,
                        ),
                      ),
                      child: const Icon(
                        Icons.question_mark_rounded,
                        color: _appWhite,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'normas',
                        style: TextStyle(
                          color: _appWhite,
                          fontSize: 38,
                          height: 0.9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Container(
                  height: 3,
                  color: _appWhite.withOpacity(0.58),
                ),

                const SizedBox(height: 18),

                const Text(
                  'LA ASAMBLEA',
                  style: TextStyle(
                    color: _appWhite,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 14),

                _rulesItem(
                  icon: Icons.groups_rounded,
                  title: 'Roles secretos',
                  text:
                  'Cada jugador mira su rol en secreto. Puede ser Izquierda, Derecha o Líder Oculto.',
                  color: _leaderGold,
                ),

                _rulesItem(
                  icon: Icons.balance_rounded,
                  title: 'Izquierda',
                  text:
                  'La izquierda gana aprobando 5 leyes de izquierda o eliminando al Líder Oculto.',
                  color: _leftBlue,
                ),

                _rulesItem(
                  icon: Icons.gavel_rounded,
                  title: 'Derecha',
                  text:
                  'La derecha gana aprobando 6 leyes de derecha o haciendo que el Líder Oculto llegue al poder.',
                  color: _rightRed,
                ),

                _rulesItem(
                  icon: Icons.account_balance_rounded,
                  title: 'Presidente y portavoz',
                  text:
                  'Cada turno hay un presidente. Puede elegir un portavoz, aunque no es obligatorio para jugar el turno.',
                  color: _appWhite,
                ),

                _rulesItem(
                  icon: Icons.style_rounded,
                  title: 'Leyes',
                  text:
                  'El presidente roba 3 leyes y descarta 1. Después el portavoz recibe 2 y aprueba 1.',
                  color: _appWhite,
                ),

                _rulesItem(
                  icon: Icons.flash_on_rounded,
                  title: 'Poderes',
                  text:
                  'Al aprobar leyes de derecha pueden activarse poderes como investigar, ver leyes, eliminar o elegir presidente.',
                  color: _leaderGold,
                ),

                _rulesItem(
                  icon: Icons.visibility_off_rounded,
                  title: 'Ocultar cartas',
                  text:
                  'Cuando haya que pasar el móvil, usa el botón del ojo para ocultar las cartas.',
                  color: _appWhite,
                ),

                _rulesItem(
                  icon: Icons.casino_rounded,
                  title: 'Ley aleatoria',
                  text:
                  'También puedes sacar una ley aleatoria sin votación ni contador de gobiernos fallidos.',
                  color: _appWhite,
                ),

                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: _mainButtonStyle(),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        'ENTENDIDO',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}