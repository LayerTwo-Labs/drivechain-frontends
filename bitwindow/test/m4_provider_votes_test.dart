import 'package:bitwindow/providers/m4_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/m4/v1/m4.pb.dart' as m4pb;

import 'mocks/api_mock.dart';

class _FakeM4API extends MockM4API {
  m4pb.VotePolicy policy = m4pb.VotePolicy.VOTE_POLICY_UPVOTE_KNOWN;
  final Map<int, String> upvotes = {};
  Object? setError;
  List<Duration> readDelays = [];
  List<Duration> writeDelays = [];

  @override
  Future<m4pb.GetVotesResponse> getVotes() async {
    final votes = m4pb.GetVotesResponse(
      policy: policy,
      upvotes: upvotes.entries.map((e) => m4pb.BundleUpvote(sidechainSlot: e.key, m6id: e.value)),
    );
    if (readDelays.isNotEmpty) {
      await Future<void>.delayed(readDelays.removeAt(0));
    }
    return votes;
  }

  @override
  Future<void> setBundleUpvote({required int sidechainSlot, String? m6id}) async {
    if (writeDelays.isNotEmpty) {
      await Future<void>.delayed(writeDelays.removeAt(0));
    }
    if (setError != null) {
      throw setError!;
    }
    if (m6id == null) {
      upvotes.remove(sidechainSlot);
    } else {
      upvotes[sidechainSlot] = m6id;
    }
  }

  @override
  Future<void> setVotePolicy(m4pb.VotePolicy policy) async {
    this.policy = policy;
  }
}

class _FakeConf extends ChangeNotifier implements BitcoinConfProvider {
  @override
  bool get drivechainFeaturesAvailable => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _API extends MockAPI {
  _API() : super(binaryType: BinaryType.BINARY_TYPE_BITWINDOWD);

  final _FakeM4API fakeM4 = _FakeM4API();

  @override
  _FakeM4API get m4 => fakeM4;
}

void main() {
  late _API rpc;

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    rpc = _API();
    GetIt.I.registerSingleton<BitwindowRPC>(rpc);
    GetIt.I.registerSingleton<SyncProvider>(SyncProvider(startTimer: false));
    GetIt.I.registerSingleton<BitcoinConfProvider>(_FakeConf());
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  test('an upvote reads back from the enforcer', () async {
    final provider = M4Provider();

    await provider.setBundleUpvote(sidechainSlot: 9, m6id: 'aa');

    expect(provider.upvotes, {9: 'aa'});
    expect(provider.votePolicy, m4pb.VotePolicy.VOTE_POLICY_UPVOTE_KNOWN);
  });

  test('the last of two quick upvotes wins', () async {
    rpc.m4.writeDelays = [Duration.zero, const Duration(milliseconds: 20)];
    rpc.m4.readDelays = [const Duration(milliseconds: 50), Duration.zero];
    final provider = M4Provider();

    await Future.wait([
      provider.setBundleUpvote(sidechainSlot: 9, m6id: 'aa'),
      provider.setBundleUpvote(sidechainSlot: 9, m6id: 'bb'),
    ]);

    expect(provider.upvotes, {9: 'bb'});
  });

  test('a refresh that started first keeps the newer upvote', () async {
    rpc.m4.writeDelays = [const Duration(milliseconds: 10)];
    rpc.m4.readDelays = [const Duration(milliseconds: 50), Duration.zero];
    final provider = M4Provider();

    final refresh = provider.fetchAll();
    await provider.setBundleUpvote(sidechainSlot: 9, m6id: 'aa');
    await refresh;

    expect(provider.upvotes, {9: 'aa'});
  });

  test('a cleared upvote leaves the sidechain to the default vote', () async {
    rpc.m4.upvotes[9] = 'aa';
    final provider = M4Provider();

    await provider.setBundleUpvote(sidechainSlot: 9);

    expect(provider.upvotes, isEmpty);
  });

  test('the default vote reads back from the enforcer', () async {
    final provider = M4Provider();

    await provider.setVotePolicy(m4pb.VotePolicy.VOTE_POLICY_ALARM);

    expect(provider.votePolicy, m4pb.VotePolicy.VOTE_POLICY_ALARM);
  });

  test('a failed upvote returns the error and keeps the old votes', () async {
    rpc.m4.upvotes[9] = 'aa';
    final provider = M4Provider();
    await provider.setVotePolicy(m4pb.VotePolicy.VOTE_POLICY_ABSTAIN);
    rpc.m4.setError = Exception('enforcer is down');

    await expectLater(provider.setBundleUpvote(sidechainSlot: 9, m6id: 'bb'), throwsException);

    expect(provider.upvotes, {9: 'aa'});
  });
}
