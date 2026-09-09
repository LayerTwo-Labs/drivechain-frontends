import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sidechain_core/mocks/mocks.dart';
import 'package:sidechain_core/providers/binaries/binary_provider.dart';

void main() {
  setUpAll(() {
    GetIt.I.registerLazySingleton<BinaryProvider>(() => MockBinaryProvider());
  });

  test('a chain that signs names no refusal', () {
    final rpc = MockBitnamesRPC();
    rpc.walletCanSpend = true;

    expect(rpc.spendUnavailable, isNull);
  });

  test('a light chain with no spend path names its refusal', () {
    final rpc = MockBitnamesRPC();
    rpc.walletCanSpend = false;

    expect(rpc.spendUnavailable, contains('cannot sign a transaction'));
  });

  test('a chain reads as able to spend before a status arrives', () {
    expect(MockBitnamesRPC().walletCanSpend, isTrue);
  });
}
