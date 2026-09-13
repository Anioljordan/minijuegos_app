import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_settings.dart';
import '../widgets/app_logo_button.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppSettingsButton extends StatelessWidget {
  final Color blue;
  final Color white;

  const AppSettingsButton({
    super.key,
    required this.blue,
    required this.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppSettingsSheet.show(
        context,
        blue: blue,
        white: white,
      ),
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: white.withOpacity(0.85),
            width: 2.2,
          ),
        ),
        child: Icon(
          Icons.settings_rounded,
          color: white,
          size: 30,
        ),
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
            insetPadding: EdgeInsets.symmetric(
              horizontal: narrow ? 18 : 28,
            ),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              padding: EdgeInsets.fromLTRB(
                narrow ? 18 : 24,
                24,
                narrow ? 18 : 24,
                20,
              ),
              decoration: BoxDecoration(
                color: blue,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: white.withOpacity(0.55),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 30,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // CERRAR
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () =>
                          Navigator.pop(dialogContext),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: white.withOpacity(0.08),
                          border: Border.all(
                            color: white.withOpacity(0.24),
                          ),
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

                  const SizedBox(height: 22),

                  Container(
                    height: 2,
                    width: double.infinity,
                    color: white.withOpacity(0.28),
                  ),

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
                      border: Border.all(
                        color: white.withOpacity(0.20),
                      ),
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
                    'anioldev.com',
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
                      onPressed: () =>
                          Navigator.pop(dialogContext),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: white,
                        foregroundColor: blue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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
      builder: (_) {
        return AnimatedBuilder(
          animation: settings,
          builder: (context, _) {
            return Container(
              margin: const EdgeInsets.all(14),
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
              decoration: BoxDecoration(
                color: blue,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: white.withOpacity(0.45),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 30,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.settings_rounded,
                          color: white,
                          size: 30,
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
                              style: TextStyle(
                                color: white,
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close_rounded,
                            color: white,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),


                    _settingsSwitch(
                      settings: settings,
                      white: white,
                      icon: Icons.volume_up_rounded,
                      title: settings.t('sound'),
                      value: settings.soundEnabled,
                      onChanged: settings.setSoundEnabled,
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Icon(
                          Icons.graphic_eq_rounded,
                          color: white,
                          size: 26,
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
                              style: TextStyle(
                                color: white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          '${(settings.volume * 100).round()}%',
                          style: TextStyle(
                            color: white.withOpacity(0.75),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    Slider(
                      value: settings.volume,
                      min: 0,
                      max: 1,
                      divisions: 10,
                      activeColor: white,
                      inactiveColor: white.withOpacity(0.25),
                      onChanged: settings.soundEnabled
                          ? settings.setVolume
                          : null,
                    ),

                    const SizedBox(height: 10),

                    _settingsSwitch(
                      settings: settings,
                      white: white,
                      icon: Icons.vibration_rounded,
                      title: settings.t('vibration'),
                      value: settings.vibrationEnabled,
                      onChanged: settings.setVibrationEnabled,
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

                    const SizedBox(height: 16),

                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Cubo está creado por',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: white.withOpacity(0.52),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            'ANIOL DEV',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: white.withOpacity(0.88),
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            'anioldev.com',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: white.withOpacity(0.42),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _languageButton({
    required AppSettings settings,
    required Color blue,
    required Color white,
    required String label,
    required String value,
  }) {
    final selected = settings.language == value;

    return Semantics(
      selected: selected,
      button: true,
      label: label,
      child: Material(
        color: selected ? white : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () async {
            if (selected) return;
            await settings.setLanguage(value);
          },
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected
                    ? white
                    : white.withOpacity(0.65),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (selected) ...[
                  Icon(
                    Icons.check_rounded,
                    color: blue,
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
        Icon(
          icon,
          color: white,
          size: 26,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  color: white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
        Switch(
          value: value,
          activeColor: white,
          activeTrackColor: white.withOpacity(0.35),
          inactiveThumbColor: white.withOpacity(0.75),
          inactiveTrackColor: white.withOpacity(0.18),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        decoration: BoxDecoration(
          color: white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: white.withOpacity(0.18),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: white.withOpacity(0.65),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
  static Future<void> _openAniolDev(
      BuildContext context,
      ) async {
    final uri = Uri.parse(
      'https://anioldev.com/cubo',
    );

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'No se ha podido abrir la web.',
            ),
          ),
        );
    }
  }
}