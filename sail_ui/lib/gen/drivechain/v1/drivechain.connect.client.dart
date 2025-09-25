//
//  Generated code. Do not modify.
//  source: drivechain/v1/drivechain.proto
//

import "package:connectrpc/connect.dart" as connect;
import "drivechain.pb.dart" as drivechainv1drivechain;
import "drivechain.connect.spec.dart" as specs;

extension type DrivechainServiceClient(connect.Transport _transport) {
  Future<drivechainv1drivechain.ListSidechainsResponse> listSidechains(
    drivechainv1drivechain.ListSidechainsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.DrivechainService.listSidechains,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<drivechainv1drivechain.ListSidechainProposalsResponse> listSidechainProposals(
    drivechainv1drivechain.ListSidechainProposalsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.DrivechainService.listSidechainProposals,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
