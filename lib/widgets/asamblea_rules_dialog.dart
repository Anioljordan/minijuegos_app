import 'package:flutter/material.dart' hide Text;
import 'cubo_game_widgets.dart';
import 'i18n_text.dart';

const Color _appWhite = CuboColors.white;
const Color _leftBlue = Color(0xFF60A5FA);
const Color _rightRed = Color(0xFFE63946);
const Color _leaderGold = Color(0xFFFFD166);

Widget _rulesItem({
  required IconData icon,
  required String title,
  required String text,
  required Color color,
}) {
  return CuboRulesItem(
    icon: icon,
    title: title,
    text: text,
    color: color,
  );
}

Future<void> showAsambleaRulesDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        decoration: CuboDecorations.dialog(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.78,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CuboDialogHeader(),

                const SizedBox(height: 18),

                Text(
                  'LA ASAMBLEA',
                  style: CuboText.chip(size: 13),
                ),

                const SizedBox(height: 12),

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
                    style: CuboButtons.primary(),
                    child: const Text(
                      'ENTENDIDO',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
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
