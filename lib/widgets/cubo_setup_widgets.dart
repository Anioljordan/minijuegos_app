import 'package:flutter/material.dart' hide Text;
import 'package:flutter/material.dart' as m show Text;

import 'cubo_game_widgets.dart';
import 'i18n_text.dart';

/// Un paso de la configuración por pasos: título (clave de traducción),
/// icono del chip y contenido de la carta.
class CuboSetupStep {
  final String title;
  final IconData icon;
  final Widget child;

  const CuboSetupStep({
    required this.title,
    required this.icon,
    required this.child,
  });
}

/// Configuración de partida en pasos: barra de progreso arriba, una carta
/// blanca por paso y, abajo, atrás + SIGUIENTE (o EMPEZAR PARTIDA en el
/// último paso). [index] lo guarda la pantalla.
class CuboSetupSteps extends StatelessWidget {
  final List<CuboSetupStep> steps;
  final int index;
  final ValueChanged<int> onStepChanged;
  final VoidCallback? onStart;
  final Color accent;

  const CuboSetupSteps({
    super.key,
    required this.steps,
    required this.index,
    required this.onStepChanged,
    required this.onStart,
    this.accent = CuboColors.chill,
  });

  bool get _isLast => index >= steps.length - 1;

  @override
  Widget build(BuildContext context) {
    final step = steps[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _progress(),
        const SizedBox(height: 14),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0.06, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: _card(step, key: ValueKey(index)),
          ),
        ),
        const SizedBox(height: 14),
        _actions(),
      ],
    );
  }

  Widget _progress() {
    return Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              height: 6,
              decoration: BoxDecoration(
                color: i <= index ? accent : CuboColors.whiteA(0.22),
                borderRadius: const BorderRadius.all(Radius.circular(999)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _card(CuboSetupStep step, {required Key key}) {
    return Container(
      key: key,
      width: double.infinity,
      decoration: CuboDecorations.playCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              children: [
                CuboStatusChip(step.title, icon: step.icon, light: true),
                const Spacer(),
                m.Text(
                  '${index + 1} / ${steps.length}',
                  style: const TextStyle(
                    color: CuboColors.blueLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
              child: step.child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actions() {
    final primary = _isLast ? onStart : () => onStepChanged(index + 1);
    return SizedBox(
      height: 64,
      child: Row(
        children: [
          if (index > 0) ...[
            CuboPressable(
              onTap: () => onStepChanged(index - 1),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CuboColors.whiteA(0.10),
                  border: Border.all(color: CuboColors.whiteA(0.5), width: 1.4),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: CuboColors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: _PrimaryPill(
              label: _isLast ? 'EMPEZAR PARTIDA' : 'SIGUIENTE',
              icon: _isLast
                  ? Icons.play_arrow_rounded
                  : Icons.arrow_forward_rounded,
              background: _isLast ? accent : CuboColors.white,
              onTap: primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color background;
  final VoidCallback? onTap;

  const _PrimaryPill({
    required this.label,
    required this.icon,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return CuboPressable(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1 : 0.45,
        child: Container(
          decoration: BoxDecoration(
            color: background,
            borderRadius: const BorderRadius.all(Radius.circular(999)),
            boxShadow: CuboShadows.float,
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: CuboColors.blueInk),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: const TextStyle(
                      color: CuboColors.blueInk,
                      fontSize: 17,
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
    );
  }
}

/// Fila clara (para cartas blancas) con icono, título y − valor +.
class CuboLightCounter extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;
  final Color accent;

  const CuboLightCounter({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
    required this.onMinus,
    required this.onPlus,
    this.accent = CuboColors.chill,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
      decoration: const BoxDecoration(
        color: CuboColors.blueTint,
        borderRadius: BorderRadius.all(Radius.circular(22)),
      ),
      child: Row(
        children: [
          _AccentIcon(icon: icon, accent: accent),
          const SizedBox(width: 12),
          Expanded(
            child: m.Text(
              tr(title).toUpperCase(),
              maxLines: 2,
              style: const TextStyle(
                color: CuboColors.blueInk,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.4,
              ),
            ),
          ),
          _RoundButton(icon: Icons.remove_rounded, onTap: onMinus),
          SizedBox(
            width: 52,
            child: m.Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: CuboColors.blueInk,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          _RoundButton(icon: Icons.add_rounded, onTap: onPlus),
        ],
      ),
    );
  }
}

/// Fila clara con título e interruptor.
class CuboLightSwitch extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color accent;

  const CuboLightSwitch({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
    required this.onChanged,
    this.accent = CuboColors.chill,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: const BoxDecoration(
        color: CuboColors.blueTint,
        borderRadius: BorderRadius.all(Radius.circular(22)),
      ),
      child: Row(
        children: [
          _AccentIcon(icon: icon, accent: accent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: CuboColors.blueInk,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: CuboColors.blue,
            activeTrackColor: accent,
          ),
        ],
      ),
    );
  }
}

/// Editor de jugadores para carta blanca: campo + botón de añadir y los
/// jugadores como fichas con inicial que se quitan con la ✕.
class CuboPlayersEditor extends StatelessWidget {
  final List<String> players;
  final int maxPlayers;
  final TextEditingController controller;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final Color accent;

  const CuboPlayersEditor({
    super.key,
    required this.players,
    required this.maxPlayers,
    required this.controller,
    required this.onAdd,
    required this.onRemove,
    this.accent = CuboColors.chill,
  });

  @override
  Widget build(BuildContext context) {
    final full = players.length >= maxPlayers;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: !full,
                textCapitalization: TextCapitalization.words,
                onSubmitted: (_) => onAdd(),
                style: const TextStyle(
                  color: CuboColors.blueInk,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  hintText: tr('Nombre opcional'),
                  hintStyle: const TextStyle(
                    color: CuboColors.blueLight,
                    fontWeight: FontWeight.w600,
                  ),
                  filled: true,
                  fillColor: CuboColors.blueTint,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            CuboPressable(
              onTap: full ? null : onAdd,
              child: Opacity(
                opacity: full ? 0.4 : 1,
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: CuboColors.blueInk,
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: m.Text(
            '${players.length} / $maxPlayers',
            style: const TextStyle(
              color: CuboColors.blueLight,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (players.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 26),
            child: Column(
              children: [
                Icon(
                  Icons.person_add_alt_1_rounded,
                  color: CuboColors.blueLight,
                  size: 40,
                ),
                SizedBox(height: 10),
                Text(
                  'Todavía no has añadido jugadores',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: CuboColors.blueLight,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < players.length; i++)
                _PlayerChip(
                  name: players[i],
                  accent: accent,
                  onRemove: () => onRemove(i),
                ),
            ],
          ),
      ],
    );
  }
}

class _PlayerChip extends StatelessWidget {
  final String name;
  final Color accent;
  final VoidCallback onRemove;

  const _PlayerChip({
    required this.name,
    required this.accent,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.isEmpty ? '?' : name.characters.first.toUpperCase();
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 5, 4, 5),
      decoration: const BoxDecoration(
        color: CuboColors.blueTint,
        borderRadius: BorderRadius.all(Radius.circular(999)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: accent,
            child: m.Text(
              initial,
              style: const TextStyle(
                color: CuboColors.blueInk,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: CuboColors.blueInk,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            onPressed: onRemove,
            visualDensity: VisualDensity.compact,
            icon: const Icon(
              Icons.close_rounded,
              color: CuboColors.blueLight,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccentIcon extends StatelessWidget {
  final IconData icon;
  final Color accent;

  const _AccentIcon({required this.icon, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: accent,
        borderRadius: const BorderRadius.all(Radius.circular(14)),
      ),
      child: Icon(icon, color: CuboColors.blueInk, size: 22),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _RoundButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CuboPressable(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.35 : 1,
        child: Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: CuboColors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: CuboColors.blue, size: 24),
        ),
      ),
    );
  }
}
