//
//  Generated code. Do not modify.
//  source: cusf/mainchain/v1/validator.proto
//

import "package:connectrpc/connect.dart" as connect;
import "validator.pb.dart" as cusfmainchainv1validator;

abstract final class ValidatorService {
  /// Fully-qualified name of the ValidatorService service.
  static const name = 'cusf.mainchain.v1.ValidatorService';

  /// Fetches information about a specific mainchain block header.
  static const getBlockHeaderInfo = connect.Spec(
    '/$name/GetBlockHeaderInfo',
    connect.StreamType.unary,
    cusfmainchainv1validator.GetBlockHeaderInfoRequest.new,
    cusfmainchainv1validator.GetBlockHeaderInfoResponse.new,
  );

  /// Fetches information about a specific mainchain block, and how it pertains
  /// to events happening on a specific sidechain.
  static const getBlockInfo = connect.Spec(
    '/$name/GetBlockInfo',
    connect.StreamType.unary,
    cusfmainchainv1validator.GetBlockInfoRequest.new,
    cusfmainchainv1validator.GetBlockInfoResponse.new,
  );

  static const getBmmHStarCommitment = connect.Spec(
    '/$name/GetBmmHStarCommitment',
    connect.StreamType.unary,
    cusfmainchainv1validator.GetBmmHStarCommitmentRequest.new,
    cusfmainchainv1validator.GetBmmHStarCommitmentResponse.new,
  );

  static const getChainInfo = connect.Spec(
    '/$name/GetChainInfo',
    connect.StreamType.unary,
    cusfmainchainv1validator.GetChainInfoRequest.new,
    cusfmainchainv1validator.GetChainInfoResponse.new,
  );

  static const getChainTip = connect.Spec(
    '/$name/GetChainTip',
    connect.StreamType.unary,
    cusfmainchainv1validator.GetChainTipRequest.new,
    cusfmainchainv1validator.GetChainTipResponse.new,
  );

  static const getCoinbasePSBT = connect.Spec(
    '/$name/GetCoinbasePSBT',
    connect.StreamType.unary,
    cusfmainchainv1validator.GetCoinbasePSBTRequest.new,
    cusfmainchainv1validator.GetCoinbasePSBTResponse.new,
  );

  static const getCtip = connect.Spec(
    '/$name/GetCtip',
    connect.StreamType.unary,
    cusfmainchainv1validator.GetCtipRequest.new,
    cusfmainchainv1validator.GetCtipResponse.new,
  );

  static const getSidechainProposals = connect.Spec(
    '/$name/GetSidechainProposals',
    connect.StreamType.unary,
    cusfmainchainv1validator.GetSidechainProposalsRequest.new,
    cusfmainchainv1validator.GetSidechainProposalsResponse.new,
  );

  static const getSidechains = connect.Spec(
    '/$name/GetSidechains',
    connect.StreamType.unary,
    cusfmainchainv1validator.GetSidechainsRequest.new,
    cusfmainchainv1validator.GetSidechainsResponse.new,
  );

  static const getTwoWayPegData = connect.Spec(
    '/$name/GetTwoWayPegData',
    connect.StreamType.unary,
    cusfmainchainv1validator.GetTwoWayPegDataRequest.new,
    cusfmainchainv1validator.GetTwoWayPegDataResponse.new,
  );

  static const subscribeEvents = connect.Spec(
    '/$name/SubscribeEvents',
    connect.StreamType.server,
    cusfmainchainv1validator.SubscribeEventsRequest.new,
    cusfmainchainv1validator.SubscribeEventsResponse.new,
  );
}
