import 'dart:math' as math;

import 'package:flutter/material.dart' hide Text;

import '../widgets/i18n_text.dart';
import '../data/impostor_data.dart';
import '../core/app_settings.dart';
import '../core/impostor_i18n.dart';
import '../widgets/app_logo_button.dart';
import '../widgets/cubo_game_widgets.dart';

enum ImpostorMode { classic, roles, question, football }

enum ImpostorStep { modeSelection, setup, passPhone, reveal, finished }

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

  bool secretCardOpen = false;
  double secretCardDragOffset = 0;

  final GlobalKey _secretCardKey = GlobalKey();
  bool _draggingRaisedSecretCard = false;

  double get secretRevealProgress {
    return (-secretCardDragOffset / 260).clamp(0.0, 1.0);
  }

  List<String> playerSecrets = [];
  List<int> impostorIndexes = [];
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
      secretCardOpen = false;
      secretCardDragOffset = 0;

      playerNameController.clear();

      playerSecrets = [];
      impostorIndexes = [];
      playerNames = [];

      selectedWord = '';
      selectedCategory = '';
      selectedHint = '';
    });
  }

  void _goBack() {
    if (currentStep == ImpostorStep.modeSelection) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      selectedMode = null;
      currentStep = ImpostorStep.modeSelection;
      currentPlayerIndex = 0;
      secretCardOpen = false;
      secretCardDragOffset = 0;

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
      selectedMode = mode;
      currentStep = ImpostorStep.setup;
      currentPlayerIndex = 0;
      secretCardOpen = false;
      secretCardDragOffset = 0;
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

  void _changePlayers(int change) {
    if (change > 0) {
      playerNameController.clear();
      _addPlayer();
      return;
    }

    if (playerNames.isEmpty) return;

    _removePlayer(playerNames.length - 1);
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
      secretCardOpen = false;
      secretCardDragOffset = 0;
      currentStep = ImpostorStep.passPhone;
    });
  }

  void setupClassicMode() {
    final categoryData =
        classicWordsData[_random.nextInt(classicWordsData.length)];

    final words = (categoryData['words'] as List)
        .map((item) => Map<String, String>.from(item as Map))
        .toList();

    final selectedData = words[_random.nextInt(words.length)];

    selectedCategory = categoryData['category'] as String;
    selectedWord = selectedData['word']!;
    selectedHint = selectedData['hint']!;

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
    selectedHint = localizeImpostorRoleValue(
      scenario['hint'] as String,
      language,
    );

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
    selectedHint = _footballText(
      selected.word.hintEs,
      selected.word.hintCa,
      selected.word.hintEn,
    );

    impostorIndexes = generateImpostorIndexes(playersCount, impostorsCount);
    playerSecrets = List.generate(playersCount, (index) {
      return impostorIndexes.contains(index) ? 'IMPOSTOR' : selectedWord;
    });
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

  List<int> generateImpostorIndexes(int totalPlayers, int totalImpostors) {
    final Set<int> indexes = {};

    while (indexes.length < totalImpostors) {
      indexes.add(_random.nextInt(totalPlayers));
    }

    return indexes.toList();
  }

  void revealRole() {
    setState(() {
      secretCardDragOffset = -260;
      secretCardOpen = true;
      currentStep = ImpostorStep.passPhone;
    });
  }

  void hideRole() {
    setState(() {
      secretCardDragOffset = 0;
      secretCardOpen = false;
      currentStep = ImpostorStep.passPhone;
    });
  }

  void _updateSecretCardDrag(DragUpdateDetails details) {
    setState(() {
      secretCardDragOffset = (secretCardDragOffset + details.delta.dy).clamp(
        -260.0,
        0.0,
      );
    });
  }

  void _finishSecretCardDrag(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;

    setState(() {
      // Swipe fuerte hacia arriba
      if (velocity < -500) {
        secretCardDragOffset = -260;
        secretCardOpen = true;
      }
      // Swipe fuerte hacia abajo
      else if (velocity > 500) {
        secretCardDragOffset = 0;
        secretCardOpen = false;
      }
      // Sin velocidad fuerte:
      // usamos la mitad del recorrido para decidir.
      else if (secretCardDragOffset <= -130) {
        secretCardDragOffset = -260;
        secretCardOpen = true;
      } else {
        secretCardDragOffset = 0;
        secretCardOpen = false;
      }
    });
  }

  bool _isPointInsideSecretCard(Offset globalPosition) {
    final context = _secretCardKey.currentContext;

    if (context == null) return false;

    final renderBox = context.findRenderObject();

    if (renderBox is! RenderBox) return false;

    final topLeft = renderBox.localToGlobal(Offset.zero);

    final bottomRight = renderBox.localToGlobal(
      Offset(renderBox.size.width, renderBox.size.height),
    );

    final rect = Rect.fromPoints(topLeft, bottomRight);

    return rect.contains(globalPosition);
  }

  void _globalSecretDragStart(DragStartDetails details) {
    if (!secretCardOpen) {
      _draggingRaisedSecretCard = false;
      return;
    }

    _draggingRaisedSecretCard = _isPointInsideSecretCard(
      details.globalPosition,
    );
  }

  void _globalSecretDragUpdate(DragUpdateDetails details) {
    if (!_draggingRaisedSecretCard) return;

    _updateSecretCardDrag(details);
  }

  void _globalSecretDragEnd(DragEndDetails details) {
    if (!_draggingRaisedSecretCard) return;

    _finishSecretCardDrag(details);

    _draggingRaisedSecretCard = false;
  }

  void nextPlayer() {
    if (currentPlayerIndex < playersCount - 1) {
      setState(() {
        currentPlayerIndex++;
        secretCardOpen = false;
        secretCardDragOffset = 0;
        currentStep = ImpostorStep.passPhone;
      });
    } else {
      setState(() {
        secretCardOpen = false;
        secretCardDragOffset = 0;
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
      case ImpostorStep.reveal:
        return playerNames[currentPlayerIndex].toLowerCase();
      case ImpostorStep.finished:
        return 'todo listo';
    }
  }

  Widget buildTopBar({required bool compact}) {
    final titleSize = compact ? 34.0 : 42.0;
    final titleHeight = compact ? 70.0 : 92.0;
    final lineTop = compact ? 40.0 : 60.0;
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
        if (currentStep == ImpostorStep.modeSelection) ...[
          SizedBox(height: compact ? 6 : 12),
          Padding(
            padding: EdgeInsets.only(right: compact ? 18 : 28),
            child: Align(
              alignment: Alignment.centerRight,
              child: CuboIllustration('impostor', size: compact ? 72 : 104),
            ),
          ),
          SizedBox(height: compact ? 2 : 6),
        ] else
          SizedBox(height: compact ? 14 : 24),
        Padding(
          padding: EdgeInsets.only(right: compact ? 18 : 28),
          child: SizedBox(
            width: double.infinity,
            height: titleHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  bottom: 10,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topRight,
                      child: Text(
                        currentTitle,
                        maxLines: 1,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: CuboColors.white,
                          fontSize: titleSize,
                          height: 1.4,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(top: lineTop, right: 0, child: const CuboPillBar()),
              ],
            ),
          ),
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

  Widget buildProgress({required bool compact}) {
    final current = currentPlayerIndex + 1;
    final total = playersCount;
    final progress = total == 0 ? 0.0 : current / total;

    return Column(
      children: [
        Row(
          children: [
            Text(
              'JUGADOR $current DE $total',
              style: TextStyle(
                color: CuboColors.white.withValues(alpha: 0.72),
                fontSize: compact ? 10.5 : 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
              ),
            ),
            const Spacer(),
            Text(
              '${(progress * 100).round()}%',
              style: TextStyle(
                color: CuboColors.white,
                fontSize: compact ? 12 : 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: compact ? 8 : 10,
          decoration: BoxDecoration(
            color: CuboColors.whiteA(0.14),
            borderRadius: BorderRadius.circular(99),
          ),
          clipBehavior: Clip.antiAlias,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(modeColor),
          ),
        ),
      ],
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
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool compact,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: CuboRadii.lgAll,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 13,
            vertical: compact ? 11 : 15,
          ),
          decoration: CuboDecorations.glassRaised(radius: CuboRadii.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: compact ? 54 : 66,
                height: compact ? 54 : 66,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(compact ? 18 : 22),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: CuboColors.blueInk,
                  size: compact ? 30 : 38,
                ),
              ),
              SizedBox(height: compact ? 8 : 11),
              Text(
                tr(title).toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: CuboColors.white,
                  fontSize: compact ? 12 : 14,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.35,
                ),
              ),
              SizedBox(height: compact ? 5 : 7),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: compact ? 3 : 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: CuboColors.white.withValues(alpha: 0.68),
                  fontSize: compact ? 10.2 : 11.5,
                  height: 1.22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildModeSelection({required bool compact}) {
    final cards = [
      (
        title: 'Clásico',
        subtitle: 'Todos tienen una palabra menos el impostor.',
        icon: Icons.visibility_off_rounded,
        color: CuboColors.fiesta,
        mode: ImpostorMode.classic,
      ),
      (
        title: 'Con roles',
        subtitle: 'Mismo lugar, roles distintos y alguien no sabe nada.',
        icon: Icons.theater_comedy_rounded,
        color: CuboColors.chill,
        mode: ImpostorMode.roles,
      ),
      (
        title: 'Pregunta distinta',
        subtitle: 'Uno recibe una pregunta parecida, pero diferente.',
        icon: Icons.quiz_rounded,
        color: CuboColors.fiesta,
        mode: ImpostorMode.question,
      ),
      (
        title: _footballText('Fútbol', 'Futbol', 'Football'),
        subtitle: _footballText(
          'Jugadores, leyendas, entrenadores y clubes.',
          'Jugadors, llegendes, entrenadors i clubs.',
          'Players, legends, coaches and clubs.',
        ),
        icon: Icons.sports_soccer_rounded,
        color: CuboColors.chill,
        mode: ImpostorMode.football,
      ),
    ];

    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: compact ? 9 : 12,
        mainAxisSpacing: compact ? 9 : 12,
        childAspectRatio: compact ? 0.88 : 0.82,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return CuboEntrance(
          index: index,
          child: buildModeCard(
            title: card.title,
            subtitle: card.subtitle,
            icon: card.icon,
            color: card.color,
            compact: compact,
            onTap: () => goToSetup(card.mode),
          ),
        );
      },
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

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool compact,
  }) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final veryNarrow = screenWidth < 350;

    final size = veryNarrow
        ? 34.0
        : compact
        ? 38.0
        : 44.0;

    return Material(
      color: CuboColors.whiteA(onTap == null ? 0.04 : 0.10),
      shape: RoundedRectangleBorder(
        borderRadius: CuboRadii.smAll,
        side: BorderSide(
          color: CuboColors.whiteA(onTap == null ? 0.12 : 0.35),
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: CuboColors.white.withValues(alpha: onTap == null ? 0.28 : 1),
            size: veryNarrow
                ? 19
                : compact
                ? 21
                : 24,
          ),
        ),
      ),
    );
  }

  Widget _buildCounter({
    required String title,
    required IconData icon,
    required int value,
    required VoidCallback? onMinus,
    required VoidCallback? onPlus,
    required bool compact,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final veryNarrow = constraints.maxWidth < 330;

        final iconSize = veryNarrow
            ? 34.0
            : compact
            ? 38.0
            : 44.0;

        final horizontalGap = veryNarrow ? 6.0 : 9.0;
        final valueWidth = veryNarrow
            ? 27.0
            : compact
            ? 33.0
            : 40.0;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(
            veryNarrow
                ? 8
                : compact
                ? 10
                : 12,
          ),
          decoration: CuboDecorations.glass(radius: CuboRadii.md),
          child: Row(
            children: [
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: modeColor.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: modeColor.withValues(alpha: 0.75),
                    width: 2,
                  ),
                ),
                child: Icon(
                  icon,
                  color: modeColor,
                  size: veryNarrow
                      ? 19
                      : compact
                      ? 21
                      : 24,
                ),
              ),

              SizedBox(width: horizontalGap),

              Expanded(
                child: _singleLineResponsiveText(
                  tr(title).toUpperCase(),
                  style: TextStyle(
                    color: CuboColors.white,
                    fontSize: veryNarrow
                        ? 10.5
                        : compact
                        ? 12
                        : 13.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: veryNarrow ? 0.1 : 0.4,
                  ),
                ),
              ),

              SizedBox(width: horizontalGap),

              _buildCounterButton(
                icon: Icons.remove_rounded,
                onTap: onMinus,
                compact: compact,
              ),

              SizedBox(
                width: valueWidth,
                child: Text(
                  '$value',
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: CuboColors.white,
                    fontSize: veryNarrow
                        ? 18
                        : compact
                        ? 20
                        : 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              _buildCounterButton(
                icon: Icons.add_rounded,
                onTap: onPlus,
                compact: compact,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlayersEditor({required bool compact}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCounter(
          title: 'Jugadores',
          icon: Icons.groups_rounded,
          value: playersCount,
          onMinus: playerNames.isEmpty ? null : () => _changePlayers(-1),
          onPlus: playerNames.length >= maxPlayers
              ? null
              : () => _changePlayers(1),
          compact: compact,
        ),

        SizedBox(height: compact ? 12 : 14),

        Align(
          alignment: Alignment.centerLeft,
          child: _singleLineResponsiveText(
            'AÑADIR JUGADOR',
            style: TextStyle(
              color: CuboColors.white.withValues(alpha: 0.70),
              fontSize: compact ? 10.5 : 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.7,
            ),
          ),
        ),

        const SizedBox(height: 8),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: playerNameController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _addPlayer(),
                style: const TextStyle(
                  color: CuboColors.white,
                  fontWeight: FontWeight.w700,
                ),
                cursorColor: CuboColors.white,
                decoration: inputDecoration('Nombre opcional'),
              ),
            ),

            const SizedBox(width: 9),

            SizedBox(
              width: compact ? 50 : 54,
              height: compact ? 50 : 54,
              child: ElevatedButton(
                onPressed: playerNames.length >= maxPlayers ? null : _addPlayer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: modeColor,
                  foregroundColor: CuboColors.blueInk,
                  disabledBackgroundColor: CuboColors.white.withValues(
                    alpha: 0.18,
                  ),
                  disabledForegroundColor: CuboColors.white.withValues(
                    alpha: 0.42,
                  ),
                  elevation: 0,

                  // Esto centra correctamente el +
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  alignment: Alignment.center,

                  shape: const RoundedRectangleBorder(
                    borderRadius: CuboRadii.inputAll,
                  ),
                ),
                child: const Center(child: Icon(Icons.add_rounded, size: 29)),
              ),
            ),
          ],
        ),

        SizedBox(height: compact ? 12 : 14),

        if (playerNames.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: compact ? 16 : 20,
            ),
            decoration: BoxDecoration(
              color: CuboColors.whiteA(0.05),
              borderRadius: CuboRadii.mdAll,
              border: Border.all(color: CuboColors.whiteA(0.18), width: 1.3),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.person_add_alt_1_rounded,
                  color: CuboColors.white.withValues(alpha: 0.48),
                  size: compact ? 28 : 34,
                ),

                const SizedBox(height: 8),

                Text(
                  'Todavía no has añadido jugadores',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: CuboColors.white.withValues(alpha: 0.66),
                    fontSize: compact ? 12 : 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),
              ],
            ),
          )
        else
          Column(
            children: playerNames.asMap().entries.map((entry) {
              final index = entry.key;
              final name = entry.value;

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.fromLTRB(
                  compact ? 9 : 11,
                  compact ? 7 : 8,
                  5,
                  compact ? 7 : 8,
                ),
                decoration: CuboDecorations.glass(radius: CuboRadii.md),
                child: Row(
                  children: [
                    Container(
                      width: compact ? 31 : 35,
                      height: compact ? 31 : 35,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: modeColor.withValues(alpha: 0.16),
                        border: Border.all(color: modeColor, width: 1.6),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: CuboColors.white,
                          fontSize: compact ? 12 : 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: CuboColors.white,
                          fontSize: compact ? 14 : 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),

                    IconButton(
                      tooltip: tr('Eliminar jugador'),
                      onPressed: () => _removePlayer(index),
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: CuboColors.white.withValues(alpha: 0.78),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
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

    return SingleChildScrollView(
      child: buildPanel(
        padding: EdgeInsets.all(compact ? 13 : 17),
        borderColor: modeColor.withValues(alpha: 0.65),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: compact ? 50 : 60,
                  height: compact ? 50 : 60,
                  decoration: BoxDecoration(
                    color: modeColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: modeColor, width: 2.2),
                  ),
                  child: Icon(
                    modeIcon,
                    color: modeColor,
                    size: compact ? 28 : 34,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _singleLineResponsiveText(
                    getModeTitle(mode),
                    style: TextStyle(
                      color: CuboColors.white,
                      fontSize: compact ? 20 : 25,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
            if (mode == ImpostorMode.football) ...[
              SizedBox(height: compact ? 16 : 20),
              _buildFootballCategories(compact: compact),
            ],
            SizedBox(height: compact ? 16 : 20),
            _buildPlayersEditor(compact: compact),

            SizedBox(height: compact ? 14 : 17),

            _buildCounter(
              title: 'Impostores',
              icon: Icons.visibility_off_rounded,
              value: impostorsCount,
              onMinus: impostorsCount <= 1 ? null : () => _changeImpostors(-1),
              onPlus: playersCount < 2 || impostorsCount >= playersCount - 1
                  ? null
                  : () => _changeImpostors(1),
              compact: compact,
            ),
            if (showHintSwitch) ...[
              SizedBox(height: compact ? 13 : 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: CuboDecorations.glass(radius: CuboRadii.md),
                child: Material(
                  type: MaterialType.transparency,
                  child: SwitchListTile(
                    value: showHints,
                    onChanged: (value) => setState(() => showHints = value),
                    contentPadding: EdgeInsets.zero,
                    activeColor: modeColor,
                    title: const Text(
                      'Pista para el impostor',
                      style: TextStyle(
                        color: CuboColors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            SizedBox(height: compact ? 14 : 18),
            buildActionButton(
              icon: Icons.play_arrow_rounded,
              label: 'EMPEZAR PARTIDA',
              backgroundColor: modeColor,
              foregroundColor: CuboColors.blueInk,
              onTap:
                  mode == ImpostorMode.football &&
                      selectedFootballCategories.isEmpty
                  ? null
                  : startGame,
              compact: compact,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSecretContent({required bool compact}) {
    final secret = getPlayerSecretDisplay();
    final isImpostor = currentPlayerIsImpostor();
    final secretColor = isImpostor ? CuboColors.alert : modeColor;
    final progress = secretRevealProgress;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 120),
      opacity: 0.08 + (progress * 0.92),
      child: Transform.scale(
        scale: 0.96 + (progress * 0.04),
        child: Center(
          child: CuboCardSwitcher(
            child: KeyedSubtree(
              key: ValueKey('secret-$currentPlayerIndex'),
              child: buildSecretHeroCard(
                compact: compact,
                secret: secret,
                isImpostor: isImpostor,
                secretColor: secretColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Tarjeta blanca con la palabra/rol secreto del jugador actual.
  Widget buildSecretHeroCard({
    required bool compact,
    required String secret,
    required bool isImpostor,
    required Color secretColor,
  }) {
    return CuboHeroCard(
      chip: isImpostor ? 'TU PAPEL' : selectedCategory,
      padding: EdgeInsets.fromLTRB(
        compact ? 16 : 22,
        compact ? 16 : 20,
        compact ? 16 : 22,
        compact ? 20 : 26,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 64 : 78,
            height: compact ? 64 : 78,
            decoration: BoxDecoration(
              color: secretColor.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(color: secretColor, width: 2.5),
            ),
            child: Icon(
              isImpostor ? Icons.visibility_off_rounded : modeIcon,
              color: CuboColors.blueInk,
              size: compact ? 32 : 40,
            ),
          ),
          SizedBox(height: compact ? 14 : 18),
          Text(
            secret,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: CuboColors.blueInk,
              fontSize: compact ? 24 : 30,
              height: 1.15,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          if (showHints && selectedHint.isNotEmpty && isImpostor) ...[
            SizedBox(height: compact ? 14 : 18),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(compact ? 11 : 14),
              decoration: BoxDecoration(
                color: CuboColors.fiesta.withValues(alpha: 0.16),
                borderRadius: CuboRadii.mdAll,
                border: Border.all(
                  color: CuboColors.fiesta.withValues(alpha: 0.70),
                  width: 1.4,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_rounded, color: CuboColors.fiesta),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Pista: $selectedHint',
                      style: TextStyle(
                        color: CuboColors.blueInk,
                        fontSize: compact ? 13 : 15,
                        height: 1.3,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildSecretCover({required bool compact, required String playerName}) {
    final progress = secretRevealProgress;

    return AnimatedSlide(
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOutCubic,

      // Deja una pequeña parte de la tarjeta visible arriba
      // para poder agarrarla y volver a bajarla.
      offset: Offset(0, -0.88 * progress),

      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: _updateSecretCardDrag,
        onVerticalDragEnd: _finishSecretCardDrag,

        child: Container(
          key: _secretCardKey,
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 16 : 22,
            vertical: compact ? 18 : 24,
          ),
          decoration: BoxDecoration(
            color: CuboColors.blue,
            borderRadius: CuboRadii.xlAll,
            border: Border.all(
              color: modeColor.withValues(alpha: 0.85),
              width: 2.4,
            ),
            boxShadow: [
              BoxShadow(
                color: modeColor.withValues(alpha: 0.22),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: compact ? 78 : 96,
                height: compact ? 78 : 96,
                decoration: BoxDecoration(
                  color: modeColor.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border: Border.all(color: modeColor, width: 2.6),
                ),
                child: Icon(
                  Icons.lock_rounded,
                  color: modeColor,
                  size: compact ? 39 : 48,
                ),
              ),

              SizedBox(height: compact ? 18 : 24),

              Text(
                'TARJETA SECRETA',
                style: TextStyle(
                  color: CuboColors.white.withValues(alpha: 0.58),
                  fontSize: compact ? 11 : 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 9),

              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  playerName.toLowerCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: CuboColors.white,
                    fontSize: compact ? 40 : 52,
                    height: 0.95,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.2,
                  ),
                ),
              ),

              SizedBox(height: compact ? 20 : 26),

              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 12 : 15,
                  vertical: compact ? 12 : 14,
                ),
                decoration: CuboDecorations.glass(radius: CuboRadii.md),
                child: Column(
                  children: [
                    Icon(
                      Icons.keyboard_double_arrow_up_rounded,
                      color: CuboColors.white.withValues(alpha: 0.88),
                      size: compact ? 30 : 34,
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'ARRASTRA DESDE AQUÍ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: CuboColors.white,
                        fontSize: compact ? 13 : 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'sube para revelar · baja para ocultar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: CuboColors.white.withValues(alpha: 0.62),
                        fontSize: compact ? 11.5 : 12.5,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPassPhone({required bool compact}) {
    final playerName = playerNames[currentPlayerIndex];

    return Column(
      children: [
        buildProgress(compact: compact),

        SizedBox(height: compact ? 10 : 14),

        Expanded(
          child: buildPanel(
            padding: EdgeInsets.all(compact ? 10 : 14),
            borderColor: modeColor.withValues(alpha: 0.65),
            child: Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 8 : 12,
                      vertical: compact ? 10 : 14,
                    ),
                    child: SizedBox(
                      height: compact ? 430 : 500,
                      child: buildSecretContent(compact: compact),
                    ),
                  ),
                ),

                Positioned.fill(
                  child: buildSecretCover(
                    compact: compact,
                    playerName: playerName,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: compact ? 10 : 14),

        buildActionButton(
          icon: currentPlayerIndex == playersCount - 1
              ? Icons.flag_rounded
              : Icons.arrow_forward_rounded,
          label: currentPlayerIndex == playersCount - 1
              ? 'FINALIZAR'
              : 'SIGUIENTE JUGADOR',
          backgroundColor: modeColor,
          foregroundColor: CuboColors.blueInk,
          onTap: nextPlayer,
          compact: compact,
        ),
      ],
    );
  }

  Widget buildReveal({required bool compact}) {
    final secret = getPlayerSecretDisplay();
    final isImpostor = currentPlayerIsImpostor();
    final secretColor = isImpostor ? CuboColors.alert : modeColor;

    return Column(
      children: [
        buildProgress(compact: compact),
        SizedBox(height: compact ? 10 : 14),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: CuboCardSwitcher(
                child: KeyedSubtree(
                  key: ValueKey('reveal-$currentPlayerIndex-$secret'),
                  child: buildSecretHeroCard(
                    compact: compact,
                    secret: secret,
                    isImpostor: isImpostor,
                    secretColor: secretColor,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: compact ? 10 : 14),
        Row(
          children: [
            Expanded(
              child: buildActionButton(
                icon: Icons.visibility_off_rounded,
                label: 'OCULTAR',
                backgroundColor: CuboColors.blue,
                foregroundColor: CuboColors.white,
                onTap: hideRole,
                compact: compact,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: buildActionButton(
                icon: currentPlayerIndex == playersCount - 1
                    ? Icons.flag_rounded
                    : Icons.arrow_forward_rounded,
                label: currentPlayerIndex == playersCount - 1
                    ? 'FINALIZAR'
                    : 'SIGUIENTE',
                backgroundColor: modeColor,
                foregroundColor: CuboColors.blueInk,
                onTap: nextPlayer,
                compact: compact,
              ),
            ),
          ],
        ),
      ],
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
      case ImpostorStep.reveal:
        return buildReveal(compact: compact);
      case ImpostorStep.finished:
        return buildFinished(compact: compact);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CuboColors.blue,

      body: GestureDetector(
        behavior: HitTestBehavior.translucent,

        // Cuando la tarjeta está abierta, capturamos también
        // el arrastre de la parte que queda fuera del panel.
        onVerticalDragStart:
            currentStep == ImpostorStep.passPhone && secretCardOpen
            ? _globalSecretDragStart
            : null,

        onVerticalDragUpdate:
            currentStep == ImpostorStep.passPhone && secretCardOpen
            ? _globalSecretDragUpdate
            : null,

        onVerticalDragEnd:
            currentStep == ImpostorStep.passPhone && secretCardOpen
            ? _globalSecretDragEnd
            : null,

        child: CuboGameBackground(
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
      ),
    );
  }
}
