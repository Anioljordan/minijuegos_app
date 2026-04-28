import 'dart:math';

class BmPlayer {
  final String id;
  String name;
  BmRole role;
  bool isAlive;
  bool isArrested;
  int arrestTurns;
  int money;
  int goodsValue;
  String? currentTargetId;
  String? currentRoom;
  String? currentWeapon;
  List<String> history;

  BmPlayer({
    required this.id,
    required this.name,
    this.role = BmRole.invitado,
    this.isAlive = true,
    this.isArrested = false,
    this.arrestTurns = 0,
    this.money = 100,
    this.goodsValue = 0,
    this.currentTargetId,
    this.currentRoom,
    this.currentWeapon,
    List<String>? history,
  }) : history = history ?? [];

  int get totalWealth => money + goodsValue;

  bool get canAct => isAlive && !isArrested;

  BmPlayer copyWith({
    String? id,
    String? name,
    BmRole? role,
    bool? isAlive,
    bool? isArrested,
    int? arrestTurns,
    int? money,
    int? goodsValue,
    String? currentTargetId,
    String? currentRoom,
    String? currentWeapon,
    List<String>? history,
  }) {
    return BmPlayer(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      isAlive: isAlive ?? this.isAlive,
      isArrested: isArrested ?? this.isArrested,
      arrestTurns: arrestTurns ?? this.arrestTurns,
      money: money ?? this.money,
      goodsValue: goodsValue ?? this.goodsValue,
      currentTargetId: currentTargetId ?? this.currentTargetId,
      currentRoom: currentRoom ?? this.currentRoom,
      currentWeapon: currentWeapon ?? this.currentWeapon,
      history: history ?? List<String>.from(this.history),
    );
  }
}

enum BmRole { asesino, agente, invitado }

enum BmPhase { setup, reveal, playing, ended }

extension BmRoleX on BmRole {
  String get label {
    switch (this) {
      case BmRole.asesino:
        return 'Asesino';
      case BmRole.agente:
        return 'Agente';
      case BmRole.invitado:
        return 'Invitado';
    }
  }
}

class AuctionLot {
  final String name;
  final int value;

  const AuctionLot({required this.name, required this.value});
}

class AuctionBid {
  final String playerId;
  final int amount;

  const AuctionBid({required this.playerId, required this.amount});
}

class BarcelonaMedianocheGame {
  final Random _random = Random();

  BmPhase phase = BmPhase.setup;
  List<BmPlayer> players = [];
  List<String> log = [];

  int revealIndex = 0;
  bool revealRoleVisible = false;

  final List<String> rooms = const [
    'Biblioteca',
    'Salón Rojo',
    'Jardín Interior',
    'Bodega',
    'Despacho',
    'Galería',
    'Comedor',
    'Suite Principal',
  ];

  final List<String> weapons = const [
    'Copa envenenada',
    'Abrecartas',
    'Candelabro',
    'Bufanda de seda',
    'Pistola antigua',
    'Estatuilla',
    'Jeringa',
    'Reloj roto',
  ];

  final List<AuctionLot> lotPool = const [
    AuctionLot(name: 'Collar de rubíes', value: 35),
    AuctionLot(name: 'Escrituras ocultas', value: 50),
    AuctionLot(name: 'Cuadro maldito', value: 45),
    AuctionLot(name: 'Reloj de oro', value: 25),
    AuctionLot(name: 'Anillo familiar', value: 30),
    AuctionLot(name: 'Acciones secretas', value: 40),
    AuctionLot(name: 'Diamante negro', value: 55),
    AuctionLot(name: 'Caja fuerte', value: 60),
  ];

  AuctionLot? currentLot;
  List<AuctionBid> currentBids = [];

  void setPlayersFromNames(List<String> names) {
    final cleanNames = names
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    players = List.generate(
      cleanNames.length,
          (index) => BmPlayer(id: 'p$index', name: cleanNames[index]),
    );
    log.clear();
    phase = BmPhase.setup;
    revealIndex = 0;
    revealRoleVisible = false;
    currentLot = null;
    currentBids = [];
  }

  bool get canStart => players.length >= 4;

  int _agentCountForPlayers(int count) {
    if (count <= 5) return 1;
    if (count <= 8) return 2;
    return 3;
  }

  int _killerCountForPlayers(int count) {
    if (count <= 5) return 1;
    if (count <= 8) return 2;
    return 3;
  }

  void startGame() {
    if (!canStart) return;

    final totalPlayers = players.length;
    final killerCount = _killerCountForPlayers(totalPlayers);
    final agentCount = _agentCountForPlayers(totalPlayers);

    final indices = List<int>.generate(totalPlayers, (i) => i)..shuffle(_random);
    final killerIndices = indices.take(killerCount).toSet();
    final agentIndices = indices.skip(killerCount).take(agentCount).toSet();

    for (int i = 0; i < players.length; i++) {
      if (killerIndices.contains(i)) {
        players[i].role = BmRole.asesino;
      } else if (agentIndices.contains(i)) {
        players[i].role = BmRole.agente;
      } else {
        players[i].role = BmRole.invitado;
      }
      players[i].money = 100;
      players[i].goodsValue = 0;
      players[i].isAlive = true;
      players[i].isArrested = false;
      players[i].arrestTurns = 0;
      players[i].history.clear();
      players[i].currentTargetId = null;
      players[i].currentRoom = null;
      players[i].currentWeapon = null;
    }

    _assignKillerMissions();
    revealIndex = 0;
    revealRoleVisible = false;
    log = ['La noche comienza. Las identidades ya han sido repartidas.'];
    phase = BmPhase.reveal;
  }

  void _assignKillerMissions() {
    final alivePool = players.where((p) => p.isAlive).toList();
    final killers = alivePool.where((p) => p.role == BmRole.asesino).toList();

    for (final killer in killers) {
      final possibleTargets = alivePool
          .where((p) => p.id != killer.id && p.role != BmRole.agente)
          .toList();

      if (possibleTargets.isEmpty) {
        killer.currentTargetId = null;
        killer.currentRoom = null;
        killer.currentWeapon = null;
        continue;
      }

      possibleTargets.shuffle(_random);
      killer.currentTargetId = possibleTargets.first.id;
      killer.currentRoom = rooms[_random.nextInt(rooms.length)];
      killer.currentWeapon = weapons[_random.nextInt(weapons.length)];
    }
  }

  BmPlayer get revealedPlayer => players[revealIndex];

  bool get isLastReveal => revealIndex >= players.length - 1;

  void nextReveal() {
    if (phase != BmPhase.reveal) return;

    revealRoleVisible = false;
    if (isLastReveal) {
      phase = BmPhase.playing;
      return;
    }
    revealIndex++;
  }

  BmPlayer? findPlayerById(String? id) {
    if (id == null) return null;
    try {
      return players.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<BmPlayer> get alivePlayers => players.where((p) => p.isAlive).toList();
  List<BmPlayer> get activePlayers => players.where((p) => p.canAct).toList();
  List<BmPlayer> get killers => players.where((p) => p.role == BmRole.asesino).toList();
  List<BmPlayer> get aliveKillers => players.where((p) => p.role == BmRole.asesino && p.isAlive).toList();
  List<BmPlayer> get aliveAgents => players.where((p) => p.role == BmRole.agente && p.isAlive).toList();

  void addLog(String text) {
    log.insert(0, text);
  }

  String killTarget({required String killerId, required String victimId}) {
    final killer = findPlayerById(killerId);
    final victim = findPlayerById(victimId);

    if (killer == null || victim == null) return 'Acción no válida.';
    if (!killer.canAct) return '${killer.name} no puede actuar ahora.';
    if (!victim.isAlive) return '${victim.name} ya está fuera de juego.';
    if (killer.role != BmRole.asesino) return '${killer.name} no es asesino.';
    if (killer.id == victim.id) return 'No puedes atacarte a ti mismo.';

    final stolenMoney = victim.money;
    victim.money = 0;
    victim.isAlive = false;
    killer.money += stolenMoney;

    final oldTarget = victim.currentTargetId;
    final oldRoom = victim.currentRoom;
    final oldWeapon = victim.currentWeapon;

    victim.history.add('Has sido eliminado por ${killer.name}.');
    killer.history.add('Eliminaste a ${victim.name} y robaste $stolenMoney€');

    if (oldTarget != null && killer.currentTargetId == victim.id) {
      killer.currentTargetId = oldTarget == killer.id ? null : oldTarget;
      killer.currentRoom = oldRoom;
      killer.currentWeapon = oldWeapon;
    } else if (killer.currentTargetId == victim.id) {
      _reassignMissionFor(killer);
    }

    for (final p in players.where((p) => p.role == BmRole.asesino && p.isAlive)) {
      if (p.currentTargetId == victim.id) {
        _reassignMissionFor(p);
      }
    }

    final message =
        '${killer.name} ha eliminado a ${victim.name}. Se queda con ${stolenMoney}€.';
    addLog(message);
    _advanceTurnEffects();
    _checkEndGame();
    return message;
  }

  void _reassignMissionFor(BmPlayer killer) {
    final candidates = players
        .where((p) => p.isAlive && p.id != killer.id && p.role != BmRole.agente)
        .toList();

    if (candidates.isEmpty) {
      killer.currentTargetId = null;
      killer.currentRoom = null;
      killer.currentWeapon = null;
      return;
    }

    candidates.shuffle(_random);
    killer.currentTargetId = candidates.first.id;
    killer.currentRoom = rooms[_random.nextInt(rooms.length)];
    killer.currentWeapon = weapons[_random.nextInt(weapons.length)];
  }

  String arrestPlayer({required String agentId, required String suspectId, required bool witnessed}) {
    final agent = findPlayerById(agentId);
    final suspect = findPlayerById(suspectId);

    if (agent == null || suspect == null) return 'Acción no válida.';
    if (!agent.canAct) return '${agent.name} no puede actuar ahora.';
    if (!suspect.isAlive) return '${suspect.name} ya no está en juego.';
    if (agent.role != BmRole.agente) return '${agent.name} no es agente.';
    if (agent.id == suspect.id) return 'No puedes detenerte a ti mismo.';

    if (witnessed && suspect.role == BmRole.asesino) {
      suspect.isArrested = true;
      suspect.arrestTurns = 1;
      suspect.money = max(0, suspect.money - 40);
      agent.money += 40;
      final message =
          '${agent.name} detuvo correctamente a ${suspect.name}. Penalización de 40€.';
      addLog(message);
      _advanceTurnEffects();
      _checkEndGame();
      return message;
    }

    agent.money = max(0, agent.money - 40);
    suspect.money += 40;
    final message =
        '${agent.name} acusó falsamente a ${suspect.name}. ${agent.name} paga 40€.';
    addLog(message);
    _advanceTurnEffects();
    return message;
  }

  void _advanceTurnEffects() {
    for (final p in players.where((p) => p.isArrested)) {
      p.arrestTurns -= 1;
      if (p.arrestTurns <= 0) {
        p.isArrested = false;
        p.arrestTurns = 0;
      }
    }
  }

  AuctionLot drawAuctionLot() {
    currentLot = lotPool[_random.nextInt(lotPool.length)];
    currentBids = [];
    addLog('Nuevo lote en subasta: ${currentLot!.name} (${currentLot!.value}€ de valor).');
    return currentLot!;
  }

  String placeBid({required String playerId, required int amount}) {
    final player = findPlayerById(playerId);
    if (player == null) return 'Jugador no encontrado.';
    if (!player.isAlive) return '${player.name} no puede pujar.';
    if (currentLot == null) return 'No hay subasta activa.';
    if (amount < 0) return 'La puja no es válida.';
    if (amount > player.money) return '${player.name} no tiene suficiente dinero.';

    currentBids.removeWhere((b) => b.playerId == playerId);
    currentBids.add(AuctionBid(playerId: playerId, amount: amount));
    currentBids.sort((a, b) => b.amount.compareTo(a.amount));

    final message = '${player.name} ha pujado ${amount}€ por ${currentLot!.name}.';
    addLog(message);
    return message;
  }

  String resolveAuction() {
    if (currentLot == null) return 'No hay subasta activa.';
    if (currentBids.isEmpty) {
      final noBid = 'Nadie ha pujado por ${currentLot!.name}.';
      addLog(noBid);
      currentLot = null;
      return noBid;
    }

    final winnerBid = currentBids.first;
    final winner = findPlayerById(winnerBid.playerId)!;
    winner.money -= winnerBid.amount;
    winner.goodsValue += currentLot!.value;

    final message =
        '${winner.name} gana ${currentLot!.name} por ${winnerBid.amount}€ y suma ${currentLot!.value}€ en bienes.';
    addLog(message);
    currentLot = null;
    currentBids = [];
    _checkEndGame();
    return message;
  }

  void finishGame() {
    phase = BmPhase.ended;
    addLog('La noche termina. Se recuentan fortunas y herencias.');
  }

  void _checkEndGame() {
    final killersAliveAndFree = players.where(
          (p) => p.role == BmRole.asesino && p.isAlive && !p.isArrested,
    );
    final civiliansAlive = players.where(
          (p) => p.isAlive && p.role != BmRole.asesino,
    );

    if (civiliansAlive.isEmpty || killersAliveAndFree.isEmpty) {
      finishGame();
    }
  }

  List<BmPlayer> get ranking {
    final sorted = [...players];
    sorted.sort((a, b) => b.totalWealth.compareTo(a.totalWealth));
    return sorted;
  }
}
