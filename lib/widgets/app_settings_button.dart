import 'package:flutter/material.dart' hide Text;
import 'i18n_text.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_settings.dart';
import '../widgets/app_logo_button.dart';
import 'cubo_game_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppSettingsButton extends StatelessWidget {
  final Color blue;
  final Color white;

  const AppSettingsButton({super.key, required this.blue, required this.white});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppSettingsSheet.show(context, blue: blue, white: white),
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: white.withValues(alpha: 0.08),
          border: Border.all(color: white.withValues(alpha: 0.85), width: 2.2),
        ),
        child: Icon(Icons.settings_rounded, color: white, size: 30),
      ),
    );
  }
}

class AppSettingsSheet {
  static Future<void> show(
    BuildContext context, {
    required Color blue,
    required Color white,
  }) async {
    final settings = AppSettings.instance;
    await settings.load();

    Future<void> _showCuboAboutDialog(
      BuildContext context, {
      required Color blue,
      required Color white,
    }) {
      return showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.55),
        builder: (dialogContext) {
          final size = MediaQuery.sizeOf(dialogContext);
          final narrow = size.width < 380;

          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: narrow ? 18 : 28),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 420),
              padding: EdgeInsets.fromLTRB(
                narrow ? 18 : 24,
                24,
                narrow ? 18 : 24,
                20,
              ),
              decoration: _panelDecoration(
                blue: blue,
                white: white,
                borderRadius: CuboRadii.xlAll,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // CERRAR
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(dialogContext),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: white.withOpacity(0.08),
                          border: Border.all(color: white.withOpacity(0.24)),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  // ICONO CUBO
                  const SizedBox(height: 2),

                  SizedBox(
                    width: double.infinity,
                    height: narrow ? 100 : 125,
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/images/CUBO0white.svg',
                        width: narrow ? 100 : 125,
                        height: narrow ? 100 : 125,
                        fit: BoxFit.contain,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFFF7F7F7),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'cubo',
                      maxLines: 1,
                      style: TextStyle(
                        color: white,
                        fontSize: narrow ? 62 : 74,
                        height: 0.85,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'JUEGOS PARA CUALQUIER MOMENTO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: white.withOpacity(0.55),
                      fontSize: narrow ? 9.5 : 10.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const CuboPillBar(),

                  const SizedBox(height: 18),

                  // VERSION
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: white.withOpacity(0.09),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: white.withOpacity(0.20)),
                    ),
                    child: Text(
                      'VERSIÓN 1.0.5',
                      maxLines: 1,
                      style: TextStyle(
                        color: white.withOpacity(0.72),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Creado y desarrollado por',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: white.withOpacity(0.55),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'ANIOL DEV',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.6,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'cubo.anioldev.com',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: white.withOpacity(0.42),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: CuboButtons.primary(foreground: blue).copyWith(
                        backgroundColor: WidgetStatePropertyAll(white),
                      ),
                      child: const Text(
                        'VOLVER A CUBO',
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    '© 2026 Aniol Dev',
                    style: TextStyle(
                      color: white.withOpacity(0.32),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: CuboRadii.sheetTop),
      builder: (_) {
        return AnimatedBuilder(
          animation: settings,
          builder: (context, _) {
            final maxHeight = MediaQuery.sizeOf(context).height * 0.92;
            return Container(
              constraints: BoxConstraints(maxHeight: maxHeight),
              decoration: _panelDecoration(
                blue: blue,
                white: white,
                borderRadius: CuboRadii.sheetTop,
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: white.withValues(alpha: 0.40),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          CuboIconCircle(
                            icon: Icons.settings_rounded,
                            size: 46,
                            color: white,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                settings.t('settings'),
                                maxLines: 1,
                                softWrap: false,
                                style: CuboText.title(size: 34, color: white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          CuboCircleButton(
                            icon: Icons.close_rounded,
                            size: 40,
                            onTap: () => Navigator.pop(context),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: CuboPillBar(),
                      ),

                      const SizedBox(height: 20),

                      _sectionLabel(settings.t('language'), white),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: white.withValues(alpha: 0.22),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            for (final lang in const [
                              ('spanish', 'es'),
                              ('catalan', 'ca'),
                              ('english', 'en'),
                            ])
                              Expanded(
                                child: _languageButton(
                                  settings: settings,
                                  blue: blue,
                                  white: white,
                                  label: settings.t(lang.$1),
                                  value: lang.$2,
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      _sectionLabel(settings.t('menuStyle'), white),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: white.withValues(alpha: 0.22),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            for (final option in const [
                              ('menuGrid', 'grid', Icons.grid_view_rounded),
                              ('menuList', 'list', Icons.view_list_rounded),
                              (
                                'menuCarousel',
                                'carousel',
                                Icons.view_carousel_rounded,
                              ),
                            ])
                              Expanded(
                                child: _segmentButton(
                                  blue: blue,
                                  white: white,
                                  label: settings.t(option.$1),
                                  icon: option.$3,
                                  selected: settings.menuStyle == option.$2,
                                  onSelect: () =>
                                      settings.setMenuStyle(option.$2),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      Container(
                        padding: const EdgeInsets.fromLTRB(14, 10, 8, 4),
                        decoration: CuboDecorations.glass(radius: CuboRadii.lg),
                        child: Column(
                          children: [
                            _settingsSwitch(
                              settings: settings,
                              white: white,
                              icon: Icons.volume_up_rounded,
                              title: settings.t('sound'),
                              value: settings.soundEnabled,
                              onChanged: settings.setSoundEnabled,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                CuboIconCircle(
                                  icon: Icons.graphic_eq_rounded,
                                  size: 38,
                                  color: white,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      settings.t('volume'),
                                      maxLines: 1,
                                      softWrap: false,
                                      style: CuboText.label(
                                        size: 17,
                                        color: white,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: white.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '${(settings.volume * 100).round()}%',
                                    style: TextStyle(
                                      color: white.withValues(alpha: 0.85),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 6,
                                overlayShape: SliderComponentShape.noOverlay,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 12,
                                ),
                                child: Slider(
                                  value: settings.volume,
                                  min: 0,
                                  max: 1,
                                  divisions: 10,
                                  activeColor: white,
                                  inactiveColor: white.withValues(alpha: 0.25),
                                  onChanged: settings.soundEnabled
                                      ? settings.setVolume
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
                        decoration: CuboDecorations.glass(radius: CuboRadii.lg),
                        child: _settingsSwitch(
                          settings: settings,
                          white: white,
                          icon: Icons.vibration_rounded,
                          title: settings.t('vibration'),
                          value: settings.vibrationEnabled,
                          onChanged: settings.setVibrationEnabled,
                        ),
                      ),

                      const SizedBox(height: 10),

                      _settingsAction(
                        white: white,
                        icon: Icons.info_outline_rounded,
                        title: settings.t('about'),
                        onTap: () {
                          _showCuboAboutDialog(
                            context,
                            blue: blue,
                            white: white,
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      _settingsAction(
                        white: white,
                        icon: Icons.language_rounded,
                        title: 'Web de Cubo',
                        onTap: () {
                          _openAniolDev(context);
                        },
                      ),

                      const SizedBox(height: 18),

                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Cubo está creado por',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: white.withValues(alpha: 0.52),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 3),

                            Text(
                              'ANIOL DEV',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: white.withValues(alpha: 0.88),
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.1,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              'cubo.anioldev.com',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: white.withValues(alpha: 0.42),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Panel azul con degradado suave, borde blanco translúcido y sombra.
  static BoxDecoration _panelDecoration({
    required Color blue,
    required Color white,
    required BorderRadius borderRadius,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color.lerp(blue, Colors.white, 0.08)!, blue],
      ),
      borderRadius: borderRadius,
      border: Border.all(color: white.withValues(alpha: 0.30), width: 1.2),
      boxShadow: CuboShadows.soft,
    );
  }

  static Widget _sectionLabel(String text, Color white) {
    return Text(
      text.toUpperCase(),
      style: CuboText.chip(color: white.withValues(alpha: 0.72), size: 12),
    );
  }

  static Widget _languageButton({
    required AppSettings settings,
    required Color blue,
    required Color white,
    required String label,
    required String value,
  }) {
    return _segmentButton(
      blue: blue,
      white: white,
      label: label,
      selected: settings.language == value,
      onSelect: () => settings.setLanguage(value),
    );
  }

  static Widget _segmentButton({
    required Color blue,
    required Color white,
    required String label,
    required bool selected,
    required Future<void> Function() onSelect,
    IconData? icon,
  }) {
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      child: Material(
        color: selected ? white : Colors.transparent,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () async {
            if (selected) return;
            await onSelect();
          },
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (selected || icon != null) ...[
                  Icon(
                    selected ? Icons.check_rounded : icon,
                    color: selected ? blue : white,
                    size: 17,
                  ),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                        color: selected ? blue : white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _settingsSwitch({
    required AppSettings settings,
    required Color white,
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        CuboIconCircle(icon: icon, size: 38, color: white),
        const SizedBox(width: 12),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              maxLines: 1,
              softWrap: false,
              style: CuboText.label(size: 17, color: white),
            ),
          ),
        ),
        Switch(
          value: value,
          activeThumbColor: white,
          activeTrackColor: white.withValues(alpha: 0.35),
          inactiveThumbColor: white.withValues(alpha: 0.75),
          inactiveTrackColor: white.withValues(alpha: 0.18),
          onChanged: onChanged,
        ),
      ],
    );
  }

  static Widget _settingsAction({
    required Color white,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return CuboPressable(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 11, 12, 11),
        decoration: CuboDecorations.glass(radius: CuboRadii.md),
        child: Row(
          children: [
            CuboIconCircle(icon: icon, size: 38, color: white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: CuboText.label(size: 16, color: white)),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: white.withValues(alpha: 0.70),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _openAniolDev(BuildContext context) async {
    final uri = Uri.parse('https://cubo.anioldev.com');

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('No se ha podido abrir la web.')),
        );
    }
  }
}
