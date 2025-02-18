//
//  Generated code. Do not modify.
//  source: cusf/mainchain/v1/validator.proto
//

import "package:connectrpc/connect.dart" as connect;
import "validator.pb.dart" as cusfmainchainv1validator;
import "validator.connect.spec.dart" as specs;

extension type ValidatorServiceClient (connect.Transport _transport) {
  /// Fetches information about a specific mainchain block header.
  Future<cusfmainchainv1validator.GetBlockHeaderInfoResponse> getBlockHeaderInfo(
    cusfmainchainv1validator.GetBlockHeaderInfoRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ValidatorService.getBlockHeaderInfo,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Fetches information about a specific mainchain block, and how it pertains
  /// to events happening on a specific sidechain.
  Future<cusfmainchainv1validator.GetBlockInfoResponse> getBlockInfo(
    cusfmainchainv1validator.GetBlockInfoRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ValidatorService.getBlockInfo,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<cusfmainchainv1validator.GetBmmHStarCommitmentResponse> getBmmHStarCommitment(
    cusfmainchainv1validator.GetBmmHStarCommitmentRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ValidatorService.getBmmHStarCommitment,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<cusfmainchainv1validator.GetChainInfoResponse> getChainInfo(
    cusfmainchainv1validator.GetChainInfoRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ValidatorService.getChainInfo,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<cusfmainchainv1validator.GetChainTipResponse> getChainTip(
    cusfmainchainv1validator.GetChainTipRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ValidatorService.getChainTip,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<cusfmainchainv1validator.GetCoinbasePSBTResponse> getCoinbasePSBT(
    cusfmainchainv1validator.GetCoinbasePSBTRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ValidatorService.getCoinbasePSBT,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<cusfmainchainv1validator.GetCtipResponse> getCtip(
    cusfmainchainv1validator.GetCtipRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ValidatorService.getCtip,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<cusfmainchainv1validator.GetSidechainProposalsResponse> getSidechainProposals(
    cusfmainchainv1validator.GetSidechainProposalsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ValidatorService.getSidechainProposals,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<cusfmainchainv1validator.GetSidechainsResponse> getSidechains(
    cusfmainchainv1validator.GetSidechainsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ValidatorService.getSidechains,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<cusfmainchainv1validator.GetTwoWayPegDataResponse> getTwoWayPegData(
    cusfmainchainv1validator.GetTwoWayPegDataRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ValidatorService.getTwoWayPegData,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Stream<cusfmainchainv1validator.SubscribeEventsResponse> subscribeEvents(
    cusfmainchainv1validator.SubscribeEventsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.ValidatorService.subscribeEvents,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
