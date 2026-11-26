import 'dart:math' as math;

import 'package:flutter/material.dart' hide Text;

import '../widgets/i18n_text.dart';
import '../data/impostor_data.dart';
import '../core/app_settings.dart';
import '../core/content_i18n.dart';
import '../core/impostor_i18n.dart';
import '../widgets/app_logo_button.dart';
import '../widgets/cubo_game_widgets.dart';
import '../widgets/cubo_secret_reveal.dart';
import '../widgets/cubo_setup_widgets.dart';

enum ImpostorMode { classic, roles, question, football }

enum ImpostorStep { modeSelection, setup, passPhone, finished }

class ImpostorScreen extends StatefulWidget {
  const ImpostorScreen({super.key});

  @override
  State<ImpostorScreen> createState() => _ImpostorScreenState();
}

class _ImpostorScreenState extends State<ImpostorScreen> {
  final math.Random _random = math.Random();

  ImpostorMode? selectedMode;
  ImpostorStep currentStep = ImpostorStep.modeSelection;

  final TextEditingController playerNameController = TextEditingController();

  static const int maxPlayers = 12;

  int impostorsCount = 1;

  final Set<FootballCategory> selectedFootballCategories = FootballCategory
      .values
      .toSet();

  int currentPlayerIndex = 0;
  bool showHints = true;

  /// Paso visible de la configuración (solo interfaz).
  int _setupStep = 0;

  /// El jugador actual ya ha levantado su carta secreta.
  bool _secretSeen = false;

  List<String> playerSecrets = [];
  List<int> impostorIndexes = [];

  /// Jugador que abre la ronda de preguntas.
  int _starterIndex = 0;

  /// Peso de un impostor al sortear quién empieza (los demás pesan 1):
  /// puede empezar, pero es poco probable.
  static const double _impostorStarterWeight = 0.2;
  List<String> playerNames = [];

  int get playersCount => playerNames.length;

  String selectedWord = '';
  String selectedCategory = '';
  String selectedHint = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
    });
  }

  @override
  void dispose() {
    playerNameController.dispose();
    super.dispose();
  }

  bool currentPlayerIsImpostor() {
    return impostorIndexes.contains(currentPlayerIndex);
  }

  void resetGame() {
    setState(() {
      selectedMode = null;
      currentStep = ImpostorStep.modeSelection;
      impostorsCount = 1;
      currentPlayerIndex = 0;
      showHints = true;
      _secretSeen = false;

      playerNameController.clear();

      playerSecrets = [];
      impostorIndexes = [];
      playerNames = [];

      selectedWord = '';
      selectedCategory = '';
      selectedHint = '';
    });
  }

  void goToSetup(ImpostorMode mode) {
    setState(() {
      _setupStep = 0;
      selectedMode = mode;
      currentStep = ImpostorStep.setup;
      currentPlayerIndex = 0;
      _secretSeen = false;
      playerSecrets = [];
      impostorIndexes = [];
      playerNames = [];
      selectedWord = '';
      selectedCategory = '';
      selectedHint = '';
    });
  }

  String _nextAutomaticPlayerName() {
    int number = 1;

    while (playerNames.any((name) => name.toLowerCase() == 'jugador $number')) {
      number++;
    }

    return 'Jugador $number';
  }

  void _addPlayer() {
    if (playerNames.length >= maxPlayers) {
      showCustomSnackBar('El máximo es de $maxPlayers jugadores');
      return;
    }

    final typedName = playerNameController.text.trim();

    final newName = typedName.isEmpty ? _nextAutomaticPlayerName() : typedName;

    final duplicated = playerNames.any(
      (name) => name.toLowerCase() == newName.toLowerCase(),
    );

    if (duplicated) {
      showCustomSnackBar('Ese jugador ya está añadido');
      return;
    }

    setState(() {
      playerNames.add(newName);
      playerNameController.clear();

      if (impostorsCount >= playerNames.length) {
        impostorsCount = math.max(1, playerNames.length - 1);
      }
    });
  }

  void _removePlayer(int index) {
    if (index < 0 || index >= playerNames.length) return;

    setState(() {
      playerNames.removeAt(index);

      final maxImpostors = math.max(1, playerNames.length - 1);

      impostorsCount = impostorsCount.clamp(1, maxImpostors).toInt();
    });
  }

  void _changeImpostors(int change) {
    if (playerNames.length < 2) {
      showCustomSnackBar('Añade jugadores antes de cambiar los impostores');
      return;
    }

    final maxImpostors = playerNames.length - 1;

    setState(() {
      impostorsCount = (impostorsCount + change).clamp(1, maxImpostors).toInt();
    });
  }

  void startGame() {
    if (playersCount < 3) {
      showCustomSnackBar('Tiene que haber al menos 3 jugadores');
      return;
    }

    if (impostorsCount < 1) {
      showCustomSnackBar('Tiene que haber al menos 1 impostor');
      return;
    }

    if (impostorsCount >= playersCount) {
      showCustomSnackBar('No puede haber tantos impostores como jugadores');
      return;
    }

    if (selectedMode == ImpostorMode.football &&
        selectedFootballCategories.isEmpty) {
      showCustomSnackBar(
        _footballText(
          'Marca al menos una categoría de fútbol',
          'Marca com a mínim una categoria de futbol',
          'Select at least one football category',
        ),
      );
      return;
    }

    switch (selectedMode!) {
      case ImpostorMode.classic:
        setupClassicMode();
        break;

      case ImpostorMode.roles:
        setupRolesMode();
        break;

      case ImpostorMode.question:
        setupQuestionMode();
        break;

      case ImpostorMode.football:
        setupFootballMode();
        break;
    }

    setState(() {
      currentPlayerIndex = 0;
      _secretSeen = false;
      currentStep = ImpostorStep.passPhone;
    });
  }

  void setupClassicMode() {
    final categoryData =
        classicWordsData[_random.nextInt(classicWordsData.length)];

    final words = (categoryData['words'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();

    final selectedData = words[_random.nextInt(words.length)];

    selectedCategory = categoryData['category'] as String;
    selectedWord = selectedData['word'] as String;
    selectedHint = _pickHint(selectedWord, selectedData['hints'] as List);

    impostorIndexes = generateImpostorIndexes(playersCount, impostorsCount);

    playerSecrets = List.generate(playersCount, (index) {
      return impostorIndexes.contains(index) ? 'IMPOSTOR' : selectedWord;
    });
  }

  void setupRolesMode() {
    final scenario =
        rolesScenariosData[_random.nextInt(rolesScenariosData.length)];

    final language = AppSettings.instance.language;
    final placeSource = scenario['place'] as String;
    final place = localizeImpostorRoleValue(placeSource, language);
    final roles =
        List<String>.from(scenario['roles'])
            .map(
              (role) => localizeImpostorRoleValue(role, language, isRole: true),
            )
            .toList()
          ..shuffle(_random);

    selectedCategory = 'Lugar';
    selectedWord = place;
    selectedHint = _pickHint(placeSource, scenario['hints'] as List);

    impostorIndexes = generateImpostorIndexes(playersCount, impostorsCount);

    int roleCursor = 0;
    playerSecrets = List.generate(playersCount, (index) {
      if (impostorIndexes.contains(index)) return 'IMPOSTOR';

      final role = roles[roleCursor % roles.length];
      roleCursor++;
      return '$place|$role';
    });
  }

  void setupQuestionMode() {
    final pair = questionPairsData[_random.nextInt(questionPairsData.length)];

    selectedCategory = 'Pregunta';
    selectedWord = pair['normal']!;
    selectedHint = '';

    impostorIndexes = generateImpostorIndexes(playersCount, impostorsCount);

    playerSecrets = List.generate(playersCount, (index) {
      return impostorIndexes.contains(index)
          ? pair['impostor']!
          : pair['normal']!;
    });
  }

  void setupFootballMode() {
    final pool = buildFootballPool(selectedFootballCategories);
    final selected = pool[_random.nextInt(pool.length)];

    selectedCategory = _footballCategoryLabel(selected.category);
    selectedWord = selected.word.name;
    selectedHint = _pickHint(selected.word.name, selected.word.hints);

    impostorIndexes = generateImpostorIndexes(playersCount, impostorsCount);
    playerSecrets = List.generate(playersCount, (index) {
      return impostorIndexes.contains(index) ? 'IMPOSTOR' : selectedWord;
    });
  }

  /// Cada palabra tiene varias pistas genéricas: en cada partida sale una al
  /// azar. Algunas pistas cambian de sentido según la palabra (por ejemplo,
  /// «Muñeca» en Barbie o en Reloj), así que se traducen con su contexto.
  String _pickHint(String word, List hints) {
    if (hints.isEmpty) return '';
    final hint = hints[_random.nextInt(hints.length)] as String;
    return localizeContentHint(word, hint, AppSettings.instance.language);
  }

  // Los textos nuevos siguen el idioma elegido en los ajustes de Cubo.
  String _footballText(String es, String ca, String en) {
    final language = AppSettings.instance.language
        .toString()
        .split('.')
        .last
        .toLowerCase()
        .split(RegExp('[-_]'))
        .first;
    switch (language) {
      case 'ca':
        return ca;
      case 'en':
        return en;
      default:
        return es;
    }
  }

  String _footballCategoryLabel(FootballCategory category) {
    switch (category) {
      case FootballCategory.currentPlayers:
        return _footballText(
          'Jugadores actuales',
          'Jugadors actuals',
          'Current players',
        );
      case FootballCategory.historicPlayers:
        return _footballText(
          'Jugadores históricos',
          'Jugadors històrics',
          'Historic players',
        );
      case FootballCategory.coaches:
        return _footballText('Entrenadores', 'Entrenadors', 'Coaches');
      case FootballCategory.clubs:
        return _footballText('Clubes', 'Clubs', 'Clubs');
    }
  }

  /// Sorteo ponderado de quién empieza: un impostor tiene
  /// [_impostorStarterWeight] veces la probabilidad de un jugador normal.
  int pickStarter() {
    double weightOf(int i) =>
        impostorIndexes.contains(i) ? _impostorStarterWeight : 1.0;
    final total = List.generate(
      playersCount,
      weightOf,
    ).fold(0.0, (a, b) => a + b);
    var roll = _random.nextDouble() * total;
    for (var i = 0; i < playersCount; i++) {
      roll -= weightOf(i);
      if (roll <= 0) return i;
    }
    return playersCount - 1;
  }

  List<int> generateImpostorIndexes(int totalPlayers, int totalImpostors) {
    final Set<int> indexes = {};

    while (indexes.length < totalImpostors) {
      indexes.add(_random.nextInt(totalPlayers));
    }

    return indexes.toList();
  }

  void nextPlayer() {
    if (currentPlayerIndex < playersCount - 1) {
      setState(() {
        currentPlayerIndex++;
        _secretSeen = false;
        currentStep = ImpostorStep.passPhone;
      });
    } else {
      setState(() {
        _secretSeen = false;
        _starterIndex = pickStarter();
        currentStep = ImpostorStep.finished;
      });
    }
  }

  void showCustomSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: CuboColors.blue,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  String getModeTitle(ImpostorMode mode) {
    switch (mode) {
      case ImpostorMode.classic:
        return 'Impostor clásico';
      case ImpostorMode.roles:
        return 'Impostor con roles';
      case ImpostorMode.question:
        return 'Pregunta distinta';
      case ImpostorMode.football:
        return _footballText(
          'Impostor fútbol',
          'Impostor futbol',
          'Football impostor',
        );
    }
  }

  String getPlayerSecretDisplay() {
    final secret = playerSecrets[currentPlayerIndex];

    if (selectedMode == ImpostorMode.classic ||
        selectedMode == ImpostorMode.football) {
      return secret == 'IMPOSTOR' ? 'Eres el impostor' : secret;
    }

    if (selectedMode == ImpostorMode.roles) {
      if (secret == 'IMPOSTOR') return 'Eres el impostor';

      final parts = secret.split('|');
      if (parts.length == 2) {
        return 'Lugar: ${parts[0]}\n\nRol: ${parts[1]}';
      }
    }

    return secret;
  }

  Color get modeColor {
    switch (selectedMode) {
      case ImpostorMode.classic:
        return CuboColors.fiesta;
      case ImpostorMode.roles:
        return CuboColors.chill;
      case ImpostorMode.question:
        return CuboColors.fiesta;
      case ImpostorMode.football:
        return CuboColors.chill;
      case null:
        return CuboColors.fiesta;
    }
  }

  IconData get modeIcon {
    switch (selectedMode) {
      case ImpostorMode.classic:
        return Icons.visibility_off_rounded;
      case ImpostorMode.roles:
        return Icons.theater_comedy_rounded;
      case ImpostorMode.question:
        return Icons.quiz_rounded;
      case ImpostorMode.football:
        return Icons.sports_soccer_rounded;
      case null:
        return Icons.person_search_rounded;
    }
  }

  ButtonStyle mainButtonStyle({Color? background, Color? foreground}) {
    if (background == null) {
      return CuboButtons.primary(
        foreground: foreground ?? CuboColors.blue,
        padding: EdgeInsets.zero,
      );
    }
    return ElevatedButton.styleFrom(
      backgroundColor: background,
      foregroundColor: foreground ?? CuboColors.blue,
      disabledBackgroundColor: CuboColors.whiteA(0.18),
      disabledForegroundColor: CuboColors.whiteA(0.42),
      elevation: 0,
      shape: const StadiumBorder(),
    );
  }

  ButtonStyle secondaryButtonStyle() {
    return CuboButtons.secondary(padding: EdgeInsets.zero);
  }

  Widget circleButton({
    required Widget child,
    required VoidCallback onTap,
    required bool compact,
  }) {
    final size = compact ? 44.0 : 50.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: CuboColors.white.withValues(alpha: 0.85),
            width: 2.2,
          ),
        ),
        child: Center(child: child),
      ),
    );
  }

  String get currentTitle {
    switch (currentStep) {
      case ImpostorStep.modeSelection:
        return 'juego del impostor';
      case ImpostorStep.setup:
        return tr(getModeTitle(selectedMode!)).toLowerCase();
      case ImpostorStep.passPhone:
        return 'pasa el móvil';
      case ImpostorStep.finished:
        return 'todo listo';
    }
  }

  Widget buildTopBar({required bool compact}) {
    final showReset = currentStep != ImpostorStep.modeSelection;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppLogoButton(
              compact: compact,
              onTap: () => Navigator.pop(context),
            ),
            Row(
              children: [
                if (showReset) ...[SizedBox(width: compact ? 9 : 12)],
                circleButton(
                  compact: compact,
                  onTap: showRulesDialog,
                  child: Icon(
                    Icons.question_mark_rounded,
                    color: CuboColors.white,
                    size: compact ? 23 : 27,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: compact ? 6 : 12),
        CuboGameTitle(
          currentTitle,
          side: CuboTitleSide.chill,
          illustration: currentStep == ImpostorStep.modeSelection
              ? 'impostor'
              : null,
          compact: compact,
        ),
      ],
    );
  }

  Widget buildPanel({
    required Widget child,
    EdgeInsets? padding,
    Color? borderColor,
  }) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: borderColor == null
          ? CuboDecorations.glassRaised(radius: CuboRadii.card)
          : BoxDecoration(
              color: CuboColors.whiteA(0.08),
              borderRadius: CuboRadii.lgAll,
              border: Border.all(color: borderColor, width: 1.4),
            ),
      child: child,
    );
  }

  Widget buildActionButton({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color foregroundColor,
    required VoidCallback? onTap,
    required bool compact,
  }) {
    final disabled = onTap == null;
    final outlined = backgroundColor == CuboColors.blue;
    final fg = outlined ? CuboColors.white : CuboColors.blueInk;
    final fgColor = fg.withValues(alpha: disabled ? 0.45 : 1);

    return SizedBox(
      height: compact ? 54 : 62,
      child: Material(
        color: outlined
            ? CuboColors.whiteA(0.08)
            : (disabled ? CuboColors.whiteA(0.35) : CuboColors.white),
        shape: StadiumBorder(
          side: outlined
              ? BorderSide(color: CuboColors.whiteA(0.55), width: 1.4)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: fgColor, size: compact ? 24 : 28),
                const SizedBox(width: 8),
                Flexible(
                  child: _singleLineResponsiveText(
                    label,
                    alignment: Alignment.center,
                    style: TextStyle(
                      color: fgColor,
                      fontSize: compact ? 12.5 : 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.35,
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

  InputDecoration inputDecoration(String hint) {
    return CuboInputs.decoration(hintText: tr(hint));
  }

  Widget rulesItem({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return CuboRulesItem(icon: icon, title: title, text: text);
  }

  void showRulesDialog() {
    final generic = selectedMode == null;
    final title = generic ? 'Juego del impostor' : getModeTitle(selectedMode!);
    final List<Map<String, dynamic>> rules = [];

    if (generic) {
      rules.addAll([
        {
          'icon': Icons.videogame_asset_rounded,
          'title': 'Elige modo',
          'text': _footballText(
            'Escoge entre clásico, roles, pregunta distinta o fútbol.',
            'Tria entre clàssic, rols, pregunta diferent o futbol.',
            'Choose classic, roles, different question or football.',
          ),
        },
        {
          'icon': Icons.groups_rounded,
          'title': 'Configura',
          'text': 'Indica jugadores, impostores y nombres antes de empezar.',
        },
        {
          'icon': Icons.phone_android_rounded,
          'title': 'Pasa el móvil',
          'text': 'Cada jugador mira su información en secreto.',
        },
        {
          'icon': Icons.visibility_off_rounded,
          'title': 'Disimula',
          'text':
              'El impostor debe evitar que lo descubran durante la conversación.',
        },
        {
          'icon': Icons.how_to_vote_rounded,
          'title': 'Votad',
          'text': 'Al final debatís y votáis quién creéis que es el impostor.',
        },
      ]);
    } else {
      switch (selectedMode!) {
        case ImpostorMode.classic:
          rules.addAll([
            {
              'icon': Icons.text_fields_rounded,
              'title': 'Palabra secreta',
              'text': 'Todos reciben la misma palabra menos el impostor.',
            },
            {
              'icon': Icons.visibility_off_rounded,
              'title': 'Impostor',
              'text': 'El impostor no sabe la palabra y debe disimular.',
            },
            {
              'icon': Icons.question_answer_rounded,
              'title': 'Preguntas',
              'text': 'Haced preguntas sin decir la palabra exacta.',
            },
            {
              'icon': Icons.how_to_vote_rounded,
              'title': 'Votación',
              'text': 'Después votáis quién creéis que es el impostor.',
            },
          ]);
          break;
        case ImpostorMode.roles:
          rules.addAll([
            {
              'icon': Icons.location_on_rounded,
              'title': 'Lugar común',
              'text': 'Todos comparten el mismo lugar.',
            },
            {
              'icon': Icons.theater_comedy_rounded,
              'title': 'Roles',
              'text': 'Cada jugador normal recibe un rol distinto.',
            },
            {
              'icon': Icons.visibility_off_rounded,
              'title': 'Impostor',
              'text': 'El impostor no conoce ni el lugar ni el rol.',
            },
            {
              'icon': Icons.search_rounded,
              'title': 'Detectad',
              'text': 'Descubrid quién responde de forma extraña.',
            },
          ]);
          break;
        case ImpostorMode.question:
          rules.addAll([
            {
              'icon': Icons.quiz_rounded,
              'title': 'Pregunta',
              'text': 'Todos reciben una pregunta.',
            },
            {
              'icon': Icons.compare_arrows_rounded,
              'title': 'Distinta',
              'text': 'Uno o varios reciben una parecida, pero diferente.',
            },
            {
              'icon': Icons.record_voice_over_rounded,
              'title': 'Responded',
              'text': 'Responded con naturalidad sin enseñar la pantalla.',
            },
            {
              'icon': Icons.search_rounded,
              'title': 'Detectad',
              'text': 'Encontrad quién parece estar contestando otra cosa.',
            },
          ]);
          break;
        case ImpostorMode.football:
          rules.addAll([
            {
              'icon': Icons.check_box_rounded,
              'title': _footballText(
                'Elige categorías',
                'Tria categories',
                'Choose categories',
              ),
              'text': _footballText(
                'Marca jugadores actuales, históricos, entrenadores o clubes. Puedes combinarlos todos.',
                'Marca jugadors actuals, històrics, entrenadors o clubs. Els pots combinar tots.',
                'Select current players, historic players, coaches or clubs. Combine any or all of them.',
              ),
            },
            {
              'icon': Icons.sports_soccer_rounded,
              'title': _footballText(
                'Nombre secreto',
                'Nom secret',
                'Secret name',
              ),
              'text': _footballText(
                'Todos reciben el mismo nombre salvo los impostores.',
                'Tothom rep el mateix nom excepte els impostors.',
                'Everyone receives the same name except the impostors.',
              ),
            },
            {
              'icon': Icons.lightbulb_rounded,
              'title': _footballText(
                'Pista opcional',
                'Pista opcional',
                'Optional hint',
              ),
              'text': _footballText(
                'Si activas las pistas, los impostores reciben una palabra de ayuda.',
                'Si actives les pistes, els impostors reben una paraula d’ajuda.',
                'When hints are enabled, impostors receive a one-word clue.',
              ),
            },
            {
              'icon': Icons.how_to_vote_rounded,
              'title': 'Votad',
              'text': _footballText(
                'Dad pistas sin decir el nombre y votad quién está disimulando.',
                'Doneu pistes sense dir el nom i voteu qui està dissimulant.',
                'Give clues without saying the name, then vote for whoever is bluffing.',
              ),
            },
          ]);
          break;
      }
    }

    showCuboDialog(
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
                    tr(title).toUpperCase(),
                    style: const TextStyle(
                      color: CuboColors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...rules.map(
                    (rule) => rulesItem(
                      icon: rule['icon'] as IconData,
                      title: rule['title'] as String,
                      text: rule['text'] as String,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: mainButtonStyle(),
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

  Widget buildModeCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool compact,
  }) {
    final tile = compact ? 68.0 : 84.0;
    return CuboPressable(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 14),
        decoration: CuboDecorations.glassRaised(radius: CuboRadii.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: tile,
              height: tile,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(tile / 3),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(icon, color: CuboColors.blueInk, size: tile * 0.55),
            ),
            SizedBox(height: compact ? 12 : 16),
            // Una sola línea en todas las cartas para que los iconos queden
            // a la misma altura.
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                tr(title).toUpperCase(),
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  color: CuboColors.white,
                  fontSize: compact ? 14 : 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildModeSelection({required bool compact}) {
    final cards = [
      (
        title: 'Clásico',
        icon: Icons.visibility_off_rounded,
        color: CuboColors.fiesta,
        mode: ImpostorMode.classic,
      ),
      (
        title: 'Con roles',
        icon: Icons.theater_comedy_rounded,
        color: CuboColors.chill,
        mode: ImpostorMode.roles,
      ),
      (
        title: 'Pregunta distinta',
        icon: Icons.quiz_rounded,
        color: CuboColors.fiesta,
        mode: ImpostorMode.question,
      ),
      (
        title: _footballText('Fútbol', 'Futbol', 'Football'),
        icon: Icons.sports_soccer_rounded,
        color: CuboColors.chill,
        mode: ImpostorMode.football,
      ),
    ];

    // Pegados abajo, cerca del pulgar.
    return Align(
      alignment: Alignment.bottomCenter,
      child: GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: compact ? 9 : 12,
          mainAxisSpacing: compact ? 9 : 12,
          childAspectRatio: compact ? 1.0 : 0.95,
        ),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          return CuboEntrance(
            index: index,
            child: buildModeCard(
              title: card.title,
              icon: card.icon,
              color: card.color,
              compact: compact,
              onTap: () => goToSetup(card.mode),
            ),
          );
        },
      ),
    );
  }

  Widget _singleLineResponsiveText(
    String text, {
    required TextStyle style,
    Alignment alignment = Alignment.centerLeft,
  }) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: alignment,
      child: Text(text, maxLines: 1, softWrap: false, style: style),
    );
  }

  Widget _buildFootballCategories({required bool compact}) {
    final allSelected =
        selectedFootballCategories.length == FootballCategory.values.length;
    final noneSelected = selectedFootballCategories.isEmpty;
    final availableNames = buildFootballPool(selectedFootballCategories).length;

    Widget categoryCheckbox({
      required String keyName,
      required String title,
      required bool? value,
      required ValueChanged<bool?> onChanged,
      bool tristate = false,
    }) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: CuboColors.whiteA(value == false ? 0.04 : 0.08),
          borderRadius: CuboRadii.mdAll,
          border: Border.all(
            color: value == false
                ? CuboColors.white.withValues(alpha: 0.22)
                : modeColor.withValues(alpha: 0.65),
            width: 1.3,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: CheckboxListTile(
            key: ValueKey(keyName),
            value: value,
            tristate: tristate,
            onChanged: onChanged,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.symmetric(horizontal: compact ? 4 : 8),
            shape: const RoundedRectangleBorder(borderRadius: CuboRadii.mdAll),
            activeColor: modeColor,
            checkColor: CuboColors.blue,
            side: BorderSide(
              color: CuboColors.white.withValues(alpha: 0.65),
              width: 1.7,
            ),
            checkboxShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            title: Text(
              title,
              style: TextStyle(
                color: CuboColors.white,
                fontSize: compact ? 13 : 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _footballText(
            'CONTENIDO DE FÚTBOL',
            'CONTINGUT DE FUTBOL',
            'FOOTBALL CONTENT',
          ),
          style: TextStyle(
            color: CuboColors.white.withValues(alpha: 0.70),
            fontSize: compact ? 10.5 : 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          _footballText(
            'Combina las categorías que quieras.',
            'Combina les categories que vulguis.',
            'Combine any categories you like.',
          ),
          style: TextStyle(
            color: CuboColors.white.withValues(alpha: 0.68),
            fontSize: compact ? 12 : 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        categoryCheckbox(
          keyName: 'football-all',
          title: _footballText(
            'Marcar todas',
            'Marcar-les totes',
            'Select all',
          ),
          value: allSelected ? true : (noneSelected ? false : null),
          tristate: true,
          onChanged: (_) => setState(() {
            if (allSelected) {
              selectedFootballCategories.clear();
            } else {
              selectedFootballCategories.addAll(FootballCategory.values);
            }
          }),
        ),
        for (final category in FootballCategory.values)
          categoryCheckbox(
            keyName: 'football-${category.name}',
            title: _footballCategoryLabel(category),
            value: selectedFootballCategories.contains(category),
            onChanged: (checked) => setState(() {
              if (checked == true) {
                selectedFootballCategories.add(category);
              } else {
                selectedFootballCategories.remove(category);
              }
            }),
          ),
        const SizedBox(height: 10),
        Text(
          noneSelected
              ? _footballText(
                  'Marca al menos una categoría para empezar.',
                  'Marca com a mínim una categoria per començar.',
                  'Select at least one category to start.',
                )
              : _footballText(
                  '$availableNames nombres disponibles',
                  '$availableNames noms disponibles',
                  '$availableNames names available',
                ),
          style: TextStyle(
            color: noneSelected
                ? CuboColors.alert
                : CuboColors.white.withValues(alpha: 0.68),
            fontSize: compact ? 12 : 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget buildSetup({required bool compact}) {
    final mode = selectedMode!;
    final showHintSwitch =
        mode == ImpostorMode.classic ||
        mode == ImpostorMode.roles ||
        mode == ImpostorMode.football;

    return CuboSetupSteps(
      accent: modeColor,
      index: _setupStep,
      onStepChanged: (step) => setState(() => _setupStep = step),
      onStart:
          mode == ImpostorMode.football && selectedFootballCategories.isEmpty
          ? null
          : startGame,
      steps: [
        CuboSetupStep(
          title: 'JUGADORES',
          icon: Icons.groups_rounded,
          child: CuboPlayersEditor(
            players: playerNames,
            maxPlayers: maxPlayers,
            controller: playerNameController,
            onAdd: _addPlayer,
            onRemove: _removePlayer,
            accent: modeColor,
          ),
        ),
        CuboSetupStep(
          title: 'CONFIGURACIÓN',
          icon: modeIcon,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CuboLightCounter(
                title: 'Impostores',
                icon: Icons.visibility_off_rounded,
                value: '$impostorsCount',
                accent: modeColor,
                onMinus: impostorsCount <= 1
                    ? null
                    : () => _changeImpostors(-1),
                onPlus: playersCount < 2 || impostorsCount >= playersCount - 1
                    ? null
                    : () => _changeImpostors(1),
              ),
              if (showHintSwitch) ...[
                const SizedBox(height: 12),
                CuboLightSwitch(
                  title: 'Pista para el impostor',
                  icon: Icons.lightbulb_rounded,
                  value: showHints,
                  accent: modeColor,
                  onChanged: (value) => setState(() => showHints = value),
                ),
              ],
              if (mode == ImpostorMode.football) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: CuboColors.whiteA(0.08),
                    borderRadius: const BorderRadius.all(Radius.circular(22)),
                  ),
                  child: _buildFootballCategories(compact: compact),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget buildPassPhone({required bool compact}) {
    final isImpostor = currentPlayerIsImpostor();
    final isLast = currentPlayerIndex == playersCount - 1;

    return Column(
      children: [
        CuboRevealProgress(
          current: currentPlayerIndex + 1,
          total: playersCount,
        ),
        SizedBox(height: compact ? 10 : 14),
        Expanded(
          child: CuboSecretReveal(
            revealKey: currentPlayerIndex,
            playerName: playerNames[currentPlayerIndex],
            onRevealed: () {
              if (!_secretSeen) setState(() => _secretSeen = true);
            },
            face: CuboSecretFace(
              icon: isImpostor ? Icons.visibility_off_rounded : modeIcon,
              color: isImpostor ? CuboColors.alert : modeColor,
              label: isImpostor ? 'TU PAPEL' : selectedCategory,
              title: getPlayerSecretDisplay(),
              extra: showHints && selectedHint.isNotEmpty && isImpostor
                  ? buildImpostorHint()
                  : null,
            ),
          ),
        ),
        SizedBox(height: compact ? 10 : 14),
        CuboRevealNextButton(
          enabled: _secretSeen,
          isLast: isLast,
          lastLabel: 'FINALIZAR',
          lastIcon: Icons.flag_rounded,
          onTap: nextPlayer,
        ),
      ],
    );
  }

  Widget buildImpostorHint() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CuboColors.whiteA(0.12),
        borderRadius: CuboRadii.mdAll,
        border: Border.all(color: CuboColors.fiesta, width: 1.4),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_rounded, color: CuboColors.fiesta),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Pista: $selectedHint',
              style: const TextStyle(
                color: CuboColors.white,
                fontSize: 15,
                height: 1.3,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Carta destacada con el jugador que empieza a preguntar.
  Widget buildStarterCard({required bool compact}) {
    final name = playerNames.isEmpty ? '' : playerNames[_starterIndex];
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 18,
        vertical: compact ? 14 : 18,
      ),
      decoration: BoxDecoration(
        color: CuboColors.fiesta,
        borderRadius: CuboRadii.mdAll,
        boxShadow: CuboShadows.soft,
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 44 : 52,
            height: compact ? 44 : 52,
            decoration: const BoxDecoration(
              color: CuboColors.blue,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.record_voice_over_rounded,
              color: CuboColors.white,
              size: compact ? 22 : 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'EMPIEZA',
                  style: TextStyle(
                    color: CuboColors.blueInk,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.9,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    name,
                    style: TextStyle(
                      color: CuboColors.blueInk,
                      fontSize: compact ? 26 : 30,
                      height: 1.05,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFinished({required bool compact}) {
    String summaryText;

    switch (selectedMode!) {
      case ImpostorMode.classic:
        summaryText =
            'Todos conocen su palabra. Haced preguntas sin decirla exactamente y votad quién es el impostor.';
        break;
      case ImpostorMode.roles:
        summaryText =
            'Todos conocen su lugar y su rol. El impostor debe disimular y descubrir el lugar.';
        break;
      case ImpostorMode.question:
        summaryText =
            'Las preguntas ya están repartidas. Responded y descubrid quién recibió la pregunta distinta.';
        break;
      case ImpostorMode.football:
        summaryText = _footballText(
          'Todos tienen su papel. Dad pistas sobre el nombre secreto sin decirlo y votad quién es el impostor.',
          'Tothom té el seu paper. Doneu pistes sobre el nom secret sense dir-lo i voteu qui és l’impostor.',
          'Everyone has their role. Give clues about the secret name without saying it, then vote for the impostor.',
        );
        break;
    }

    return Column(
      children: [
        Expanded(
          child: buildPanel(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 18 : 24,
              vertical: compact ? 18 : 28,
            ),
            borderColor: CuboColors.chill.withValues(alpha: 0.75),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CuboIllustration(
                      'impostor',
                      size: compact ? 92 : 120,
                      popIn: true,
                    ),
                    SizedBox(height: compact ? 18 : 24),
                    Text(
                      'EMPEZAD A JUGAR',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: CuboColors.white,
                        fontSize: compact ? 28 : 36,
                        height: 0.95,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                      ),
                    ),
                    SizedBox(height: compact ? 16 : 20),
                    buildStarterCard(compact: compact),
                    SizedBox(height: compact ? 12 : 14),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(compact ? 13 : 16),
                      decoration: CuboDecorations.glass(radius: CuboRadii.md),
                      child: Text(
                        summaryText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: CuboColors.white.withValues(alpha: 0.84),
                          fontSize: compact ? 14 : 16,
                          height: 1.4,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: compact ? 10 : 14),
        buildActionButton(
          icon: Icons.replay_rounded,
          label: 'NUEVA PARTIDA',
          backgroundColor: CuboColors.chill,
          foregroundColor: CuboColors.blue,
          onTap: resetGame,
          compact: compact,
        ),
      ],
    );
  }

  Widget buildCurrentStep({required bool compact}) {
    switch (currentStep) {
      case ImpostorStep.modeSelection:
        return buildModeSelection(compact: compact);
      case ImpostorStep.setup:
        return buildSetup(compact: compact);
      case ImpostorStep.passPhone:
        return buildPassPhone(compact: compact);
      case ImpostorStep.finished:
        return buildFinished(compact: compact);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CuboColors.blue,

      body: CuboGameBackground(
        accent: CuboColors.chill,
        halo: CuboHalo.topLeft,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 380;

              final veryNarrow = constraints.maxWidth < 340;

              final compact = constraints.maxHeight < 740 || narrow;

              final horizontalPadding = veryNarrow
                  ? 8.0
                  : compact
                  ? 12.0
                  : 18.0;

              final verticalPadding = compact ? 10.0 : 18.0;

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  verticalPadding,
                  horizontalPadding,
                  compact ? 11 : 16,
                ),

                child: Column(
                  children: [
                    buildTopBar(compact: compact),

                    SizedBox(height: compact ? 10 : 14),

                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),

                        child: KeyedSubtree(
                          key: ValueKey(currentStep),

                          child: buildCurrentStep(compact: compact),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
