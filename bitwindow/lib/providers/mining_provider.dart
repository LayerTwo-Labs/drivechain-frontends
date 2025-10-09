import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

// Messages for isolate communication
class MiningTask {
  final SendPort sendPort;
  final Map<String, dynamic> blockTemplate;
  final int threadId;
  final int threadCount;
  final int hashingSpeed; // 1-100, where 100 = full speed

  MiningTask(this.sendPort, this.blockTemplate, this.threadId, this.threadCount, this.hashingSpeed);
}

class MiningResult {
  final String? blockData;
  final String bestHash;
  final int bestNonce;
  final int hashCount;
  final bool blockFound;

  MiningResult({
    this.blockData,
    required this.bestHash,
    required this.bestNonce,
    required this.hashCount,
    required this.blockFound,
  });
}

class MiningUpdate {
  final int nonce;
  final int hashCount;
  final String currentHash;

  MiningUpdate(this.nonce, this.hashCount, this.currentHash);
}

class SpeedChangeCommand {
  final int newSpeed;

  SpeedChangeCommand(this.newSpeed);
}

class IsolateReady {
  final SendPort isolateSendPort;

  IsolateReady(this.isolateSendPort);
}

// Top-level isolate entry point
void _miningIsolateEntryPoint(MiningTask task) {
  _runMiningInIsolate(task);
}

// Mining logic that runs in isolate
Future<void> _runMiningInIsolate(MiningTask task) async {
  final template = task.blockTemplate;
  final threadId = task.threadId;
  final threadCount = task.threadCount;
  final sendPort = task.sendPort;
  int currentHashingSpeed = task.hashingSpeed;

  // Create a ReceivePort for this isolate to receive commands
  final commandReceivePort = ReceivePort();

  // Send our SendPort back to main isolate so it can send us commands
  sendPort.send(IsolateReady(commandReceivePort.sendPort));

  // Listen for speed change commands
  commandReceivePort.listen((message) {
    if (message is SpeedChangeCommand) {
      currentHashingSpeed = message.newSpeed;
    }
  });

  final target = template['target'] as String? ?? '';
  if (target.isEmpty) {
    sendPort.send(
      MiningResult(
        bestHash: 'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff',
        bestNonce: 0,
        hashCount: 0,
        blockFound: false,
      ),
    );
    commandReceivePort.close();
    return;
  }

  String bestHash = 'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff';
  int bestNonce = 0;

  final blockHeader = _buildBlockHeader(template);
  if (blockHeader == null) {
    sendPort.send(MiningResult(bestHash: bestHash, bestNonce: 0, hashCount: 0, blockFound: false));
    commandReceivePort.close();
    return;
  }

  // Partition nonce space across threads
  final nonceRange = 0x100000000 ~/ threadCount;
  final nonceStart = threadId * nonceRange;
  final nonceEnd = threadId == threadCount - 1 ? 0xFFFFFFFF : (threadId + 1) * nonceRange - 1;

  int nonce = nonceStart;
  int hashCounter = 0;

  while (nonce <= nonceEnd) {
    _setNonceInHeader(blockHeader, nonce);

    final hash = _doubleSha256(blockHeader);
    final hashHex = _bytesToHex(Uint8List.fromList(hash.reversed.toList()));

    hashCounter++;

    // Calculate delay based on current hashing speed using cubic curve
    // This makes high speeds (100-80%) have minimal impact
    // while lower speeds progressively slow down more
    final normalized = (100 - currentHashingSpeed) / 100.0; // 0.0 to 0.99
    final delayMicros = (normalized * normalized * normalized * 1000).toInt();

    // Add delay to throttle hashing speed if not at full speed
    if (delayMicros > 0 && hashCounter % 100 == 0) {
      // Add small delays every 100 hashes to avoid too many context switches
      final sleepDuration = Duration(microseconds: delayMicros * 100);
      final start = DateTime.now();
      while (DateTime.now().difference(start) < sleepDuration) {
        // Busy wait (more accurate than sleep for small durations)
      }
    }

    // Send periodic updates to main isolate every 1000 hashes for responsive UI
    // Also yield to event loop to allow processing of speed change commands
    if (hashCounter % 1000 == 0) {
      sendPort.send(MiningUpdate(nonce, hashCounter, hashHex));
      hashCounter = 0; // Reset counter after reporting

      // Yield to event loop to process incoming messages (speed changes)
      await Future.delayed(Duration.zero);
    }

    if (_meetsTarget(hash, target)) {
      bestHash = hashHex;
      bestNonce = nonce;
      final blockData = _buildCompleteBlock(template, nonce);
      sendPort.send(
        MiningResult(
          blockData: blockData,
          bestHash: bestHash,
          bestNonce: bestNonce,
          hashCount: hashCounter,
          blockFound: true,
        ),
      );
      commandReceivePort.close();
      return;
    }

    if (_isHashLower(hashHex, bestHash)) {
      bestHash = hashHex;
      bestNonce = nonce;
    }

    nonce++;
  }

  // Exhausted nonce range without finding block
  sendPort.send(
    MiningResult(
      bestHash: bestHash,
      bestNonce: bestNonce,
      hashCount: hashCounter,
      blockFound: false,
    ),
  );
  commandReceivePort.close();
}

// Helper functions for isolate (must be top-level or static)
Uint8List? _buildBlockHeader(Map<String, dynamic> template) {
  try {
    final version = template['version'] as int? ?? 1;
    final previousBlockHash = template['previousblockhash'] as String? ?? '';
    final merkleRoot = _calculateMerkleRoot(template);
    final timestamp = template['curtime'] as int? ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000);
    final bits = template['bits'] as String? ?? '';

    if (merkleRoot.isEmpty || previousBlockHash.isEmpty || bits.isEmpty) {
      return null;
    }

    final header = BytesBuilder();
    header.add(_intToBytes(version, 4));
    header.add(_hexToBytes(previousBlockHash).reversed.toList());
    header.add(_hexToBytes(merkleRoot).reversed.toList());
    header.add(_intToBytes(timestamp, 4));
    header.add(_intToBytes(int.parse(bits, radix: 16), 4));
    header.add(_intToBytes(0, 4));

    return Uint8List.fromList(header.toBytes());
  } catch (e) {
    return null;
  }
}

void _setNonceInHeader(Uint8List header, int nonce) {
  final nonceBytes = _intToBytes(nonce, 4);
  for (int i = 0; i < 4; i++) {
    header[76 + i] = nonceBytes[i];
  }
}

Uint8List _doubleSha256(Uint8List data) {
  final firstHash = sha256.convert(data).bytes;
  final secondHash = sha256.convert(firstHash).bytes;
  return Uint8List.fromList(secondHash);
}

bool _meetsTarget(Uint8List hash, String targetHex) {
  try {
    final target = _hexToBytes(targetHex);
    final hashBigEndian = hash.reversed.toList();

    for (int i = 0; i < 32; i++) {
      if (hashBigEndian[i] < target[i]) return true;
      if (hashBigEndian[i] > target[i]) return false;
    }
    return true;
  } catch (e) {
    return false;
  }
}

bool _isHashLower(String hash1, String hash2) {
  final len = hash1.length.clamp(0, 64);
  for (int i = 0; i < len; i++) {
    final c1 = hash1[i].toLowerCase();
    final c2 = hash2[i].toLowerCase();
    if (c1 != c2) {
      final v1 = int.parse(c1, radix: 16);
      final v2 = int.parse(c2, radix: 16);
      return v1 < v2;
    }
  }
  return false;
}

String _buildCompleteBlock(Map<String, dynamic> template, int nonce) {
  try {
    final version = template['version'] as int? ?? 1;
    final previousBlockHash = template['previousblockhash'] as String? ?? '';
    final merkleRoot = _calculateMerkleRoot(template);
    final timestamp = template['curtime'] as int? ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000);
    final bits = template['bits'] as String? ?? '';
    final transactions = template['transactions'] as List? ?? [];

    if (merkleRoot.isEmpty) {
      return '';
    }

    final block = BytesBuilder();

    block.add(_intToBytes(version, 4));
    block.add(_hexToBytes(previousBlockHash).reversed.toList());
    block.add(_hexToBytes(merkleRoot).reversed.toList());
    block.add(_intToBytes(timestamp, 4));
    final bitsInt = int.parse(bits, radix: 16);
    block.add(_intToBytes(bitsInt, 4));
    block.add(_intToBytes(nonce, 4));

    final txCount = transactions.length + 1;
    block.add(_encodeVarInt(txCount));

    final coinbaseTx = _buildProperCoinbaseTransaction(template);
    block.add(coinbaseTx);

    for (final tx in transactions) {
      final txData = tx['data'] as String? ?? '';
      if (txData.isNotEmpty) {
        block.add(_hexToBytes(txData));
      }
    }

    final blockHex = _bytesToHex(block.toBytes());
    return blockHex;
  } catch (e) {
    return '';
  }
}

Uint8List _buildProperCoinbaseTransaction(Map<String, dynamic> template) {
  final tx = BytesBuilder();

  final blockHeight = template['height'] as int? ?? 0;
  final coinbaseValue = template['coinbasevalue'] as int? ?? 0;
  final coinbaseAux = template['coinbaseaux'] as Map<String, dynamic>? ?? {};
  final defaultWitnessCommitment = template['default_witness_commitment'] as String?;

  final version = template['version'] as int? ?? 1;
  tx.add(_intToBytes(version >= 2 ? 2 : 1, 4));

  final hasWitness = defaultWitnessCommitment != null;
  if (hasWitness) {
    tx.add([0x00, 0x01]);
  }

  tx.add(_encodeVarInt(1));
  tx.add(List.filled(32, 0));
  tx.add([0xff, 0xff, 0xff, 0xff]);

  final scriptSig = _buildCoinbaseScriptSig(blockHeight, coinbaseAux);
  tx.add(_encodeVarInt(scriptSig.length));
  tx.add(scriptSig);

  tx.add([0xff, 0xff, 0xff, 0xff]);

  final outputCount = hasWitness ? 2 : 1;
  tx.add(_encodeVarInt(outputCount));

  tx.add(_intToBytes(coinbaseValue, 8));

  final outputScript = _getDefaultMinerScript();
  tx.add(_encodeVarInt(outputScript.length));
  tx.add(outputScript);

  if (hasWitness) {
    tx.add(_intToBytes(0, 8));

    final witnessScript = _hexToBytes(defaultWitnessCommitment);
    tx.add(_encodeVarInt(witnessScript.length));
    tx.add(witnessScript);
  }

  if (hasWitness) {
    tx.add([0x01]);
    tx.add([0x20]);
    tx.add(List.filled(32, 0));
  }

  tx.add(_intToBytes(0, 4));

  return Uint8List.fromList(tx.toBytes());
}

Uint8List _buildCoinbaseScriptSig(int blockHeight, Map<String, dynamic> coinbaseAux) {
  final script = BytesBuilder();

  final heightBytes = _encodeScriptNumber(blockHeight);

  if (blockHeight >= 65536 && blockHeight <= 16777215) {
    script.add([0x03]);
    script.add([blockHeight & 0xff]);
    script.add([(blockHeight >> 8) & 0xff]);
    script.add([(blockHeight >> 16) & 0xff]);
  } else {
    if (heightBytes.isEmpty) {
      script.add([0x00]);
    } else {
      script.add([heightBytes.length]);
      script.add(heightBytes);
    }
  }

  final flags = coinbaseAux['flags'] as String? ?? '';
  if (flags.isNotEmpty) {
    final flagBytes = _hexToBytes(flags);
    if (script.toBytes().length + flagBytes.length + 1 <= 98) {
      script.add([flagBytes.length]);
      script.add(flagBytes);
    }
  }

  final minerText = utf8.encode('/BitWindow/');
  final currentLength = script.toBytes().length;
  if (currentLength + minerText.length + 1 <= 98) {
    script.add([minerText.length]);
    script.add(minerText);
  }

  final scriptBytes = script.toBytes();
  if (scriptBytes.length < 2) {
    script.add([0x00]);
  } else if (scriptBytes.length > 100) {
    return Uint8List.fromList(scriptBytes.sublist(0, 100));
  }

  return Uint8List.fromList(script.toBytes());
}

Uint8List _encodeScriptNumber(int value) {
  if (value == 0) return Uint8List.fromList([]);

  final bytes = <int>[];
  final negative = value < 0;
  var absValue = negative ? -value : value;

  while (absValue > 0) {
    bytes.add(absValue & 0xff);
    absValue >>= 8;
  }

  if (bytes.last >= 0x80) {
    bytes.add(negative ? 0x80 : 0);
  } else if (negative) {
    bytes[bytes.length - 1] |= 0x80;
  }

  return Uint8List.fromList(bytes);
}

Uint8List _getDefaultMinerScript() {
  final pubkeyHash = _hexToBytes('759d6677091e973b9e9d99f19c68fbf43e3f05f9');

  final script = BytesBuilder();
  script.add([0x76]);
  script.add([0xa9]);
  script.add([0x14]);
  script.add(pubkeyHash);
  script.add([0x88]);
  script.add([0xac]);

  return Uint8List.fromList(script.toBytes());
}

Uint8List _intToBytes(int value, int bytes) {
  final result = Uint8List(bytes);
  for (int i = 0; i < bytes; i++) {
    result[i] = (value >> (i * 8)) & 0xff;
  }
  return result;
}

Uint8List _hexToBytes(String hex) {
  if (hex.length % 2 != 0) hex = '0$hex';
  final result = Uint8List(hex.length ~/ 2);
  for (int i = 0; i < result.length; i++) {
    result[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return result;
}

String _bytesToHex(Uint8List bytes) {
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

Uint8List _encodeVarInt(int value) {
  if (value < 0xfd) {
    return Uint8List.fromList([value]);
  } else if (value <= 0xffff) {
    return Uint8List.fromList([0xfd, value & 0xff, (value >> 8) & 0xff]);
  } else if (value <= 0xffffffff) {
    return Uint8List.fromList([0xfe, value & 0xff, (value >> 8) & 0xff, (value >> 16) & 0xff, (value >> 24) & 0xff]);
  } else {
    return Uint8List.fromList([
      0xff,
      value & 0xff,
      (value >> 8) & 0xff,
      (value >> 16) & 0xff,
      (value >> 24) & 0xff,
      (value >> 32) & 0xff,
      (value >> 40) & 0xff,
      (value >> 48) & 0xff,
      (value >> 56) & 0xff,
    ]);
  }
}

String _calculateMerkleRoot(Map<String, dynamic> template) {
  try {
    final transactions = template['transactions'] as List? ?? [];

    final coinbaseTx = _buildProperCoinbaseTransaction(template);
    final coinbaseTxId = _doubleSha256(coinbaseTx);

    final List<Uint8List> txIds = [];
    txIds.add(coinbaseTxId);

    for (final tx in transactions) {
      final txid = tx['txid'] as String? ?? '';
      if (txid.isNotEmpty) {
        final txIdBytes = _hexToBytes(txid).reversed.toList();
        txIds.add(Uint8List.fromList(txIdBytes));
      }
    }

    final merkleRoot = _calculateMerkleTreeRoot(txIds);
    final merkleRootHex = _bytesToHex(merkleRoot);

    return merkleRootHex;
  } catch (e) {
    return '';
  }
}

Uint8List _calculateMerkleTreeRoot(List<Uint8List> txIds) {
  if (txIds.isEmpty) {
    return Uint8List(32);
  }

  if (txIds.length == 1) {
    return txIds[0];
  }

  List<Uint8List> currentLevel = List.from(txIds);

  while (currentLevel.length > 1) {
    final nextLevel = <Uint8List>[];

    for (int i = 0; i < currentLevel.length; i += 2) {
      Uint8List left = currentLevel[i];
      Uint8List right;

      if (i + 1 >= currentLevel.length) {
        right = left;
      } else {
        right = currentLevel[i + 1];
      }

      final combined = BytesBuilder();
      combined.add(left);
      combined.add(right);

      final pairHash = _doubleSha256(Uint8List.fromList(combined.toBytes()));
      nextLevel.add(pairHash);
    }

    currentLevel = nextLevel;
  }

  return currentLevel[0];
}

class MiningProvider extends ChangeNotifier {
  MainchainRPC get _rpc => GetIt.I.get<MainchainRPC>();
  EnforcerRPC get _enforcer => GetIt.I.get<EnforcerRPC>();
  Logger get log => GetIt.I.get<Logger>();

  Timer? _pollTimer;
  Timer? _miningOutputTimer;
  Timer? _templateRefreshTimer;
  Map<String, dynamic>? _currentTemplate;
  int _currentTemplateHeight = 0;

  bool _isMining = false;
  bool _blockFound = false;
  bool _abandonFailedBMM = false;
  bool _isSignet = false;
  int _threadCount = 1;
  int _hashingSpeed = 100; // 1-100, where 100 = full speed

  // Isolate management
  final List<Isolate> _miningIsolates = [];
  final List<ReceivePort> _receivePorts = [];
  final List<SendPort> _sendPorts = [];

  int _currentHeight = 0;
  int _blockWeight = 0;
  int _blockTxns = 0;
  double _difficulty = 0;
  double _networkHashPs = 0;
  int _pooledTxns = 0;
  String _warnings = '';

  String _targetHash = '';
  String _currentHash = '';
  String _bestHash = '';
  int _nonce = 0;
  int _bestNonce = 0;
  int _totalHashes = 0;
  DateTime? _hashRateStartTime;
  double _hashRate = 0;

  bool get isMining => _isMining;
  bool get blockFound => _blockFound;
  bool get abandonFailedBMM => _abandonFailedBMM;
  bool get isSignet => _isSignet;
  int get threadCount => _threadCount;
  int get hashingSpeed => _hashingSpeed;

  int get currentHeight => _currentHeight;
  int get blockWeight => _blockWeight;
  int get blockTxns => _blockTxns;
  double get difficulty => _difficulty;
  double get networkHashPs => _networkHashPs;
  int get pooledTxns => _pooledTxns;
  String get warnings => _warnings;

  String get targetHash => _targetHash;
  String get currentHash => _currentHash;
  String get bestHash => _bestHash;
  int get nonce => _nonce;
  int get bestNonce => _bestNonce;
  double get hashRate => _hashRate;

  MiningProvider() {
    log.i('Mining provider initialized');
    _startPolling();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => _updateMiningInfo());
    _updateMiningInfo();
  }

  Future<void> _updateMiningInfo() async {
    try {
      final blockchainInfo = await _enforcer.getBlockchainInfo();
      _currentHeight = blockchainInfo.blocks;
      _isSignet = blockchainInfo.chain.toLowerCase().contains('signet');

      // Fetch real mining info from mainchain RPC
      try {
        final miningInfo = await _rpc.getMiningInfo();
        _difficulty = miningInfo.difficulty;
        _networkHashPs = miningInfo.networkHashPs;
        _pooledTxns = miningInfo.pooledTx;
        _warnings = miningInfo.warnings.isNotEmpty ? miningInfo.warnings.first : '';
        _blockWeight = miningInfo.currentBlockWeight;
        _blockTxns = miningInfo.currentBlockTx;
      } catch (e) {
        // Fallback values if mining info unavailable
        _difficulty = 0.001127;
        _networkHashPs = 0;
        _pooledTxns = 0;
        _warnings = '';
        _blockWeight = 0;
        _blockTxns = 0;
      }

      notifyListeners();
    } catch (e) {
      log.e('Failed to update mining info: $e');
    }
  }

  Future<void> _updateMiningOutput() async {
    try {
      final blockchainInfo = await _enforcer.getBlockchainInfo();
      _currentHeight = blockchainInfo.blocks;

      notifyListeners();
    } catch (e) {
      // Ignore errors - mining output update is non-critical
    }
  }

  Future<void> startMining(int threads) async {
    try {
      if (_isSignet) {
        throw Exception('CPU mining is not available on signet networks. Please connect to testnet or mainnet.');
      }

      log.i('CPU mining started with $threads thread${threads > 1 ? 's' : ''}');
      _threadCount = threads;
      _isMining = true;
      _blockFound = false;
      _targetHash = '';
      _currentHash = '';
      _bestHash = '';
      _bestNonce = 0;
      _totalHashes = 0;
      _hashRate = 0;
      _hashRateStartTime = DateTime.now();

      _miningOutputTimer?.cancel();
      _miningOutputTimer = Timer.periodic(const Duration(milliseconds: 200), (_) => _updateMiningOutput());

      // Refresh block template every 60 seconds
      _templateRefreshTimer?.cancel();
      _templateRefreshTimer = Timer.periodic(const Duration(seconds: 60), (_) => _refreshTemplate());

      for (int i = 0; i < threads; i++) {
        unawaited(_startMiningThread(i));
      }

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to start mining: $e');
    }
  }

  Future<void> stopMining() async {
    try {
      _isMining = false;
      _blockFound = false;

      _miningOutputTimer?.cancel();
      _miningOutputTimer = null;

      _templateRefreshTimer?.cancel();
      _templateRefreshTimer = null;

      _currentTemplate = null;

      // Kill all mining isolates
      for (final isolate in _miningIsolates) {
        isolate.kill(priority: Isolate.immediate);
      }
      _miningIsolates.clear();

      // Close all receive ports
      for (final port in _receivePorts) {
        port.close();
      }
      _receivePorts.clear();
      _sendPorts.clear();

      log.i('Mining stopped');
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to stop mining: $e');
    }
  }

  Future<void> _startMiningThread(int threadId) async {
    try {
      log.i('Mining thread $threadId starting...');

      // Get block template
      final blockTemplate = await _getBlockTemplate();
      if (blockTemplate == null) {
        log.e('Failed to get block template for thread $threadId');
        return;
      }

      log.d('block template is ${blockTemplate.toString()}');

      // Create receive port for this isolate
      final receivePort = ReceivePort();
      _receivePorts.add(receivePort);

      // Spawn the isolate
      final isolate = await Isolate.spawn(
        _miningIsolateEntryPoint,
        MiningTask(receivePort.sendPort, blockTemplate, threadId, _threadCount, _hashingSpeed),
      );
      _miningIsolates.add(isolate);

      log.i('Mining thread $threadId isolate spawned');

      // Listen for messages from the isolate
      receivePort.listen((message) async {
        if (message is IsolateReady) {
          // Store the isolate's SendPort so we can send commands to it
          _sendPorts.add(message.isolateSendPort);
          log.i('Mining thread $threadId ready, SendPort received');
        } else if (message is MiningUpdate) {
          _nonce = message.nonce;
          _currentHash = message.currentHash;
          _totalHashes += message.hashCount;

          // Update hash rate
          if (_hashRateStartTime != null) {
            final elapsed = DateTime.now().difference(_hashRateStartTime!).inSeconds;
            if (elapsed > 0) {
              _hashRate = _totalHashes / elapsed;
            }
          }
          notifyListeners();
        } else if (message is MiningResult) {
          if (message.blockFound && message.blockData != null) {
            log.i('BLOCK FOUND by thread $threadId! Submitting...');
            _blockFound = true;
            _isMining = false;
            _bestHash = message.bestHash;
            _bestNonce = message.bestNonce;
            notifyListeners();

            await _submitBlock(message.blockData!);
            await stopMining();
          } else {
            // Update best hash if this thread found a better one
            if (_isHashLower(message.bestHash, _bestHash)) {
              _bestHash = message.bestHash;
              _bestNonce = message.bestNonce;
            }
          }
        }
      });
    } catch (e) {
      log.e('Failed to start mining thread $threadId: $e');
    }
  }

  Future<Map<String, dynamic>?> _getBlockTemplate() async {
    try {
      // Use cached template if available and fresh
      if (_currentTemplate != null && _currentTemplateHeight == _currentHeight) {
        return _currentTemplate;
      }

      // Fetch new template
      final template = await _enforcer.getBlockTemplate();
      _currentTemplate = template;
      _currentTemplateHeight = template['height'] as int? ?? _currentHeight;

      // Update target hash from template
      _targetHash = template['target'] as String? ?? '';

      log.d('New block template fetched for height $_currentTemplateHeight');
      notifyListeners();
      return template;
    } catch (e) {
      log.e('Failed to get block template: $e');
      return null;
    }
  }

  Future<void> _refreshTemplate() async {
    if (!_isMining) return;

    log.d('Refreshing block template...');
    final template = await _enforcer.getBlockTemplate();
    _currentTemplate = template;
    _currentTemplateHeight = template['height'] as int? ?? _currentHeight;

    // Update target hash from refreshed template
    _targetHash = template['target'] as String? ?? '';

    log.d('Block template refreshed for height $_currentTemplateHeight');
    notifyListeners();
  }

  Future<void> _submitBlock(String blockData) async {
    try {
      // Use standard submitblock RPC via mainchain for non-signet networks
      await _rpc.submitBlock(blockData);
      log.i('Block successfully submitted to network!');
    } catch (e) {
      log.e('Block submission failed: $e');
    }
  }

  void setAbandonFailedBMM(bool value) {
    _abandonFailedBMM = value;
    notifyListeners();

    if (value) {
      _abandonFailedBMMTask();
    }
  }

  void setHashingSpeed(int value) {
    _hashingSpeed = value.clamp(1, 100);

    // Send speed change command to all running isolates
    if (_isMining && _sendPorts.isNotEmpty) {
      for (final sendPort in _sendPorts) {
        sendPort.send(SpeedChangeCommand(_hashingSpeed));
      }
      log.d('Speed changed to $_hashingSpeed%, sent to ${_sendPorts.length} isolates');
    }

    notifyListeners();
  }

  Future<void> _abandonFailedBMMTask() async {
    if (!_abandonFailedBMM) return;

    try {
      await _rpc.callRAW('abandonbmmrequests');
    } catch (e) {
      debugPrint('Failed to abandon BMM requests: $e');
    }

    if (_abandonFailedBMM) {
      Future.delayed(const Duration(minutes: 10), _abandonFailedBMMTask);
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _miningOutputTimer?.cancel();
    _templateRefreshTimer?.cancel();

    // Kill all mining isolates
    for (final isolate in _miningIsolates) {
      isolate.kill(priority: Isolate.immediate);
    }
    _miningIsolates.clear();

    // Close all receive ports
    for (final port in _receivePorts) {
      port.close();
    }
    _receivePorts.clear();
    _sendPorts.clear();

    super.dispose();
  }
}
