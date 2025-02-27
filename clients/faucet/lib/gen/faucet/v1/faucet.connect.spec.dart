//
//  Generated code. Do not modify.
//  source: faucet/v1/faucet.proto
//

import "package:connectrpc/connect.dart" as connect;
import "faucet.pb.dart" as faucetv1faucet;

abstract final class FaucetService {
  /// Fully-qualified name of the FaucetService service.
  static const name = 'faucet.v1.FaucetService';

  static const dispenseCoins = connect.Spec(
    '/$name/DispenseCoins',
    connect.StreamType.unary,
    faucetv1faucet.DispenseCoinsRequest.new,
    faucetv1faucet.DispenseCoinsResponse.new,
  );

  static const listClaims = connect.Spec(
    '/$name/ListClaims',
    connect.StreamType.unary,
    faucetv1faucet.ListClaimsRequest.new,
    faucetv1faucet.ListClaimsResponse.new,
  );
}
