import 'dart:math';

enum BmRole {
  asesino,
  agente,
  invitado,
}

enum BmPhase {
  setup,
  reveal,
  playing,
  auction,
  ended,
}

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
  final String id;
  final String name;
  final int value;

  const AuctionLot({
    required this.id,
    required this.name,
    required this.value,
  });
}

class AuctionBid {
  final String playerId;
  final int amount;

  const AuctionBid({
    required this.playerId,
    required this.amount,
  });
}

class BmPlayer {
  final String id;
  String name;
  BmRole role;
  bool isAlive;
  DateTime? detainedUntil;
  int money;
  List<AuctionLot> goods;
  String? currentTargetId;
  String? currentRoom;
  String? currentWeapon;
  List<String> history;

  BmPlayer({
    required this.id,
    required this.name,
    this.role = BmRole.invitado,
    this.isAlive = true,
    this.detainedUntil,
    this.money = 100,
    List<AuctionLot>? goods,
    this.currentTargetId,
    this.currentRoom,
    this.currentWeapon,
    List<String>? history,
  })  : goods = goods ?? [],
        history = history ?? [];

  int get goodsValue => goods.fold(0, (sum, lot) => sum + lot.value);

  int get totalWealth => money + goodsValue;

  bool get isDetained {
    final until = detainedUntil;
    return isAlive && until != null && until.isAfter(DateTime.now());
  }

  bool get canKill => isAlive && !isDetained;

  bool get canParticipate => isAlive;

  Duration get detentionRemaining {
    if (!isDetained) return Duration.zero;
    return detainedUntil!.difference(DateTime.now());
  }
}

class BarcelonaMedianocheGame {
  final Random _random = Random();

  BmPhase phase = BmPhase.setup;
  List<BmPlayer> players = [];
  List<String> log = [];

  int revealIndex = 0;
  bool revealRoleVisible = false;

  static const List<String> defaultRooms = [
    'Biblioteca',
    'Salón Rojo',
    'Jardín Interior',
    'Bodega',
    'Despacho',
    'Galería',
    'Comedor',
    'Suite Principal',
  ];

  static const List<String> defaultWeapons = [
    'Copa envenenada',
    'Abrecartas',
    'Candelabro',
    'Bufanda de seda',
    'Pistola antigua',
    'Estatuilla',
    'Jeringa',
    'Reloj roto',
  ];

  List<String> rooms = List<String>.from(defaultRooms);
  List<String> weapons = List<String>.from(defaultWeapons);

  bool get hasValidMissionOptions => rooms.isNotEmpty && weapons.isNotEmpty;

  void setMissionOptions({
    required List<String> roomNames,
    required List<String> weaponNames,
  }) {
    rooms = _cleanMissionOptions(roomNames);
    weapons = _cleanMissionOptions(weaponNames);
  }

  List<String> _cleanMissionOptions(List<String> values) {
    final result = <String>[];
    final seen = <String>{};

    for (final raw in values) {
      final value = raw.trim();
      if (value.isEmpty) continue;

      final normalized = value.toLowerCase();
      if (seen.add(normalized)) {
        result.add(value);
      }
    }

    return result;
  }

  final List<AuctionLot> lotPool = const [
    AuctionLot(id: 'rubies', name: 'Collar de rubíes', value: 35),
    AuctionLot(id: 'escrituras', name: 'Escrituras ocultas', value: 50),
    AuctionLot(id: 'cuadro', name: 'Cuadro maldito', value: 45),
    AuctionLot(id: 'reloj', name: 'Reloj de oro', value: 25),
    AuctionLot(id: 'anillo', name: 'Anillo familiar', value: 30),
    AuctionLot(id: 'acciones', name: 'Acciones secretas', value: 40),
    AuctionLot(id: 'diamante', name: 'Diamante negro', value: 55),
    AuctionLot(id: 'caja', name: 'Caja fuerte', value: 60),
  ];

  List<AuctionLot> finalAuctionLots = [];
  int currentLotIndex = 0;
  int currentBidderIndex = 0;
  List<AuctionBid> currentBids = [];
  bool auctionRoundResolved = false;
  String lastAuctionResult = '';

  void setPlayersFromNames(List<String> names) {
    final cleanNames = names
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    players = List.generate(
      cleanNames.length,
          (index) => BmPlayer(
        id: 'p$index',
        name: cleanNames[index],
      ),
    );

    phase = BmPhase.setup;
    revealIndex = 0;
    revealRoleVisible = false;
    log.clear();
    finalAuctionLots.clear();
    currentLotIndex = 0;
    currentBidderIndex = 0;
    currentBids.clear();
    auctionRoundResolved = false;
    lastAuctionResult = '';
  }

  bool get canStart => players.length >= 4;

  bool get hasDuplicateNames {
    final normalized = players.map((p) => p.name.toLowerCase()).toList();
    return normalized.toSet().length != normalized.length;
  }

  int _agentCountForPlayers(int count) {
    if (count <= 6) return 1;
    if (count <= 9) return 2;
    return 3;
  }

  int _killerCountForPlayers(int count) {
    if (count <= 6) return 1;
    if (count <= 9) return 2;
    return 3;
  }

  void startGame() {
    if (!canStart || !hasValidMissionOptions) return;

    final totalPlayers = players.length;
    final killerCount = _killerCountForPlayers(totalPlayers);
    final agentCount = _agentCountForPlayers(totalPlayers);

    final indices = List<int>.generate(totalPlayers, (i) => i)
      ..shuffle(_random);

    final killerIndices = indices.take(killerCount).toSet();
    final agentIndices = indices
        .skip(killerCount)
        .take(agentCount)
        .toSet();

    for (int i = 0; i < players.length; i++) {
      final player = players[i];

      if (killerIndices.contains(i)) {
        player.role = BmRole.asesino;
      } else if (agentIndices.contains(i)) {
        player.role = BmRole.agente;
      } else {
        player.role = BmRole.invitado;
      }

      player.money = 100;
      player.goods.clear();
      player.isAlive = true;
      player.detainedUntil = null;
      player.currentTargetId = null;
      player.currentRoom = null;
      player.currentWeapon = null;
      player.history.clear();
    }

    _assignInitialKillerMissions();

    revealIndex = 0;
    revealRoleVisible = false;
    log = [
      'La noche comienza. Todos reciben 100€ y las identidades quedan ocultas.',
    ];

    finalAuctionLots.clear();
    currentLotIndex = 0;
    currentBidderIndex = 0;
    currentBids.clear();
    auctionRoundResolved = false;
    lastAuctionResult = '';

    phase = BmPhase.reveal;
  }

  void _assignInitialKillerMissions() {
    final usedTargets = <String>{};

    for (final killer in killers) {
      _assignMissionFor(
        killer,
        avoidTargetIds: usedTargets,
      );

      if (killer.currentTargetId != null) {
        usedTargets.add(killer.currentTargetId!);
      }
    }
  }

  void _assignMissionFor(
      BmPlayer killer, {
        Set<String> avoidTargetIds = const {},
      }) {
    var candidates = players
        .where((p) => p.isAlive && p.id != killer.id)
        .toList();

    final preferred = candidates
        .where((p) => !avoidTargetIds.contains(p.id))
        .toList();

    if (preferred.isNotEmpty) {
      candidates = preferred;
    }

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

  List<BmPlayer> get alivePlayers =>
      players.where((p) => p.isAlive).toList();

  List<BmPlayer> get killers =>
      players.where((p) => p.role == BmRole.asesino).toList();

  List<BmPlayer> get aliveKillers => players
      .where((p) => p.role == BmRole.asesino && p.isAlive)
      .toList();

  List<BmPlayer> get aliveAgents => players
      .where((p) => p.role == BmRole.agente && p.isAlive)
      .toList();

  void addLog(String text) {
    log.insert(0, text);
  }

  String killTarget({
    required String killerId,
    required String victimId,
    required bool correctRoom,
    required bool weaponPresent,
    required bool noLivingWitnesses,
  }) {
    final killer = findPlayerById(killerId);
    final victim = findPlayerById(victimId);

    if (killer == null || victim == null) {
      return 'Acción no válida.';
    }

    if (killer.role != BmRole.asesino) {
      return 'Este jugador no tiene una misión de asesinato.';
    }

    if (!killer.isAlive) {
      return '${killer.name} está eliminado y no puede asesinar.';
    }

    if (killer.isDetained) {
      return '${killer.name} sigue detenido y no puede asesinar todavía.';
    }

    if (!victim.isAlive) {
      return '${victim.name} ya está eliminado.';
    }

    if (killer.id == victim.id) {
      return 'No puedes atacarte a ti mismo.';
    }

    if (killer.currentTargetId != victim.id) {
      return 'La víctima no coincide con tu objetivo actual.';
    }

    if (!correctRoom) {
      return 'El asesinato no es válido: no estáis en la habitación asignada.';
    }

    if (!weaponPresent) {
      return 'El asesinato no es válido: falta el objeto asignado.';
    }

    if (!noLivingWitnesses) {
      return 'El asesinato no es válido: hay un testigo vivo presente.';
    }

    final stolenMoney = victim.money;

    victim.money = 0;
    victim.isAlive = false;
    victim.detainedUntil = null;
    killer.money += stolenMoney;

    victim.history.add('Has sido eliminado durante la velada.');
    killer.history.add(
      'Cumpliste tu misión contra ${victim.name} y recibiste $stolenMoney€.',
    );

    final killersToReassign = aliveKillers
        .where((p) => p.currentTargetId == victim.id)
        .toList();

    final alreadyTargeted = aliveKillers
        .where((p) => !killersToReassign.contains(p))
        .map((p) => p.currentTargetId)
        .whereType<String>()
        .toSet();

    for (final player in killersToReassign) {
      _assignMissionFor(
        player,
        avoidTargetIds: alreadyTargeted,
      );

      if (player.currentTargetId != null) {
        alreadyTargeted.add(player.currentTargetId!);
      }
    }

    final message =
        '${victim.name} ha sido eliminado y entrega $stolenMoney€ en efectivo.';

    addLog(message);
    return message;
  }

  String arrestPlayer({
    required String agentId,
    required String suspectId,
    required bool hasClearProof,
  }) {
    final agent = findPlayerById(agentId);
    final suspect = findPlayerById(suspectId);

    if (agent == null || suspect == null) {
      return 'Acción no válida.';
    }

    if (agent.role != BmRole.agente) {
      return 'Este jugador no es un agente.';
    }

    if (!agent.isAlive) {
      return '${agent.name} está eliminado y no puede detener a nadie.';
    }

    if (!suspect.isAlive) {
      return '${suspect.name} ya está fuera del juego.';
    }

    if (agent.id == suspect.id) {
      return 'No puedes detenerte a ti mismo.';
    }

    final correctAccusation =
        hasClearProof && suspect.role == BmRole.asesino;

    if (correctAccusation) {
      final transferred = min(40, suspect.money);

      suspect.money -= transferred;
      agent.money += transferred;
      suspect.detainedUntil = DateTime.now().add(
        const Duration(minutes: 10),
      );

      suspect.history.add(
        'Has sido detenido durante 10 minutos por ${agent.name}.',
      );
      agent.history.add(
        'Detuviste correctamente a ${suspect.name} y recibiste $transferred€.',
      );

      final message =
          '${suspect.name} ha sido detenido durante 10 minutos. Transfiere $transferred€ al agente.';

      addLog(message);
      return message;
    }

    final transferred = min(40, agent.money);

    agent.money -= transferred;
    suspect.money += transferred;

    agent.history.add(
      'Acusación falsa contra ${suspect.name}. Pagaste $transferred€.',
    );
    suspect.history.add(
      'Recibiste $transferred€ por una acusación falsa.',
    );

    final message =
        'La acusación contra ${suspect.name} era falsa. El agente paga $transferred€.';

    addLog(message);
    return message;
  }

  String transferMoney({
    required String fromPlayerId,
    required String toPlayerId,
    required int amount,
    String reason = 'Trato privado',
  }) {
    final from = findPlayerById(fromPlayerId);
    final to = findPlayerById(toPlayerId);

    if (from == null || to == null) return 'Jugadores no válidos.';
    if (!from.isAlive || !to.isAlive) {
      return 'Solo los jugadores vivos pueden transferir fortuna.';
    }
    if (from.id == to.id) return 'Elige dos jugadores distintos.';
    if (amount <= 0) return 'La cantidad debe ser mayor que 0.';
    if (amount > from.money) return '${from.name} no tiene suficiente dinero.';

    from.money -= amount;
    to.money += amount;

    final message =
        '${from.name} transfiere $amount€ a ${to.name}. Motivo: $reason.';

    addLog(message);
    return message;
  }

  String transferGood({
    required String fromPlayerId,
    required String toPlayerId,
    required String lotId,
    String reason = 'Trato privado',
  }) {
    final from = findPlayerById(fromPlayerId);
    final to = findPlayerById(toPlayerId);

    if (from == null || to == null) return 'Jugadores no válidos.';
    if (!from.isAlive || !to.isAlive) {
      return 'Solo los jugadores vivos pueden transferir bienes.';
    }
    if (from.id == to.id) return 'Elige dos jugadores distintos.';

    AuctionLot? lot;
    for (final item in from.goods) {
      if (item.id == lotId) {
        lot = item;
        break;
      }
    }

    if (lot == null) return '${from.name} no posee ese bien.';

    from.goods.remove(lot);
    to.goods.add(lot);

    final message =
        '${from.name} entrega ${lot.name} a ${to.name}. Motivo: $reason.';

    addLog(message);
    return message;
  }

  void startFinalAuction({int lotCount = 5}) {
    if (phase != BmPhase.playing) return;
    if (alivePlayers.isEmpty) return;

    final shuffled = [...lotPool]..shuffle(_random);

    finalAuctionLots = shuffled.take(min(lotCount, shuffled.length)).toList();
    currentLotIndex = 0;
    currentBidderIndex = 0;
    currentBids.clear();
    auctionRoundResolved = false;
    lastAuctionResult = '';
    phase = BmPhase.auction;

    addLog('Comienza la subasta final con ${finalAuctionLots.length} lotes.');
  }

  AuctionLot? get currentAuctionLot {
    if (finalAuctionLots.isEmpty) return null;
    if (currentLotIndex < 0 || currentLotIndex >= finalAuctionLots.length) {
      return null;
    }
    return finalAuctionLots[currentLotIndex];
  }

  List<BmPlayer> get auctionBidders => alivePlayers;

  BmPlayer? get currentBidder {
    final bidders = auctionBidders;
    if (bidders.isEmpty) return null;
    if (currentBidderIndex < 0 || currentBidderIndex >= bidders.length) {
      return null;
    }
    return bidders[currentBidderIndex];
  }

  bool get isLastAuctionLot =>
      finalAuctionLots.isNotEmpty &&
          currentLotIndex >= finalAuctionLots.length - 1;

  String submitSecretBid(int amount) {
    if (phase != BmPhase.auction) return 'La subasta no está activa.';
    if (auctionRoundResolved) return 'Este lote ya está resuelto.';

    final bidder = currentBidder;
    final lot = currentAuctionLot;

    if (bidder == null || lot == null) return 'No hay puja activa.';
    if (amount < 0) return 'La puja no puede ser negativa.';
    if (amount > bidder.money) {
      return '${bidder.name} no tiene suficiente dinero.';
    }

    currentBids.removeWhere((bid) => bid.playerId == bidder.id);

    if (amount > 0) {
      currentBids.add(
        AuctionBid(
          playerId: bidder.id,
          amount: amount,
        ),
      );
    }

    currentBidderIndex++;

    if (currentBidderIndex >= auctionBidders.length) {
      _resolveCurrentAuctionLot();
    }

    return 'Puja guardada.';
  }

  void _resolveCurrentAuctionLot() {
    final lot = currentAuctionLot;
    if (lot == null) return;

    if (currentBids.isEmpty) {
      lastAuctionResult = 'Nadie ha pujado por ${lot.name}.';
      addLog(lastAuctionResult);
      auctionRoundResolved = true;
      return;
    }

    final highestAmount = currentBids
        .map((bid) => bid.amount)
        .reduce(max);

    final tiedBids = currentBids
        .where((bid) => bid.amount == highestAmount)
        .toList();

    final winnerBid = tiedBids[_random.nextInt(tiedBids.length)];
    final winner = findPlayerById(winnerBid.playerId)!;

    winner.money -= winnerBid.amount;
    winner.goods.add(lot);

    lastAuctionResult = tiedBids.length > 1
        ? '${winner.name} gana el desempate y se lleva ${lot.name} por ${winnerBid.amount}€.'
        : '${winner.name} se lleva ${lot.name} por ${winnerBid.amount}€.';

    winner.history.add(
      'Ganaste ${lot.name} por ${winnerBid.amount}€.',
    );

    addLog(lastAuctionResult);
    auctionRoundResolved = true;
  }

  void nextAuctionLotOrFinish() {
    if (phase != BmPhase.auction || !auctionRoundResolved) return;

    if (isLastAuctionLot) {
      finishGame();
      return;
    }

    currentLotIndex++;
    currentBidderIndex = 0;
    currentBids.clear();
    auctionRoundResolved = false;
    lastAuctionResult = '';
  }

  void finishGame() {
    phase = BmPhase.ended;
    addLog('La noche termina. Se recuentan el efectivo y los bienes.');
  }

  List<BmPlayer> get ranking {
    final sorted = players.where((p) => p.isAlive).toList();
    sorted.sort((a, b) => b.totalWealth.compareTo(a.totalWealth));
    return sorted;
  }

  List<BmPlayer> get eliminatedPlayers =>
      players.where((p) => !p.isAlive).toList();
}
