//
//  Generated code. Do not modify.
//  source: drivechain/v1/drivechain.proto
//

import 'package:connectrpc/connect.dart' as connect;
import 'package:sail_ui/gen/drivechain/v1/drivechain.pb.dart' as drivechainv1drivechain;

abstract final class DrivechainService {
  /// Fully-qualified name of the DrivechainService service.
  static const name = 'drivechain.v1.DrivechainService';

  static const listSidechains = connect.Spec(
    '/$name/ListSidechains',
    connect.StreamType.unary,
    drivechainv1drivechain.ListSidechainsRequest.new,
    drivechainv1drivechain.ListSidechainsResponse.new,
  );

  static const listSidechainProposals = connect.Spec(
    '/$name/ListSidechainProposals',
    connect.StreamType.unary,
    drivechainv1drivechain.ListSidechainProposalsRequest.new,
    drivechainv1drivechain.ListSidechainProposalsResponse.new,
  );
}
