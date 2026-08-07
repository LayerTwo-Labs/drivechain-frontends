//
//  Generated code. Do not modify.
//  source: bitassets/v1/bitassets.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'bitassets.pb.dart' as $0;
import 'bitassets.pbjson.dart';

export 'bitassets.pb.dart';

abstract class BitAssetsServiceBase extends $pb.GeneratedService {
  $async.Future<$0.GetBalanceResponse> getBalance($pb.ServerContext ctx, $0.GetBalanceRequest request);
  $async.Future<$0.GetBlockCountResponse> getBlockCount($pb.ServerContext ctx, $0.GetBlockCountRequest request);
  $async.Future<$0.StopResponse> stop($pb.ServerContext ctx, $0.StopRequest request);
  $async.Future<$0.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $0.GetNewAddressRequest request);
  $async.Future<$0.WithdrawResponse> withdraw($pb.ServerContext ctx, $0.WithdrawRequest request);
  $async.Future<$0.TransferResponse> transfer($pb.ServerContext ctx, $0.TransferRequest request);
  $async.Future<$0.GetSidechainWealthResponse> getSidechainWealth(
      $pb.ServerContext ctx, $0.GetSidechainWealthRequest request);
  $async.Future<$0.CreateDepositResponse> createDeposit($pb.ServerContext ctx, $0.CreateDepositRequest request);
  $async.Future<$0.GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle(
      $pb.ServerContext ctx, $0.GetPendingWithdrawalBundleRequest request);
  $async.Future<$0.ConnectPeerResponse> connectPeer($pb.ServerContext ctx, $0.ConnectPeerRequest request);
  $async.Future<$0.ForgetPeerResponse> forgetPeer($pb.ServerContext ctx, $0.ForgetPeerRequest request);
  $async.Future<$0.ListPeersResponse> listPeers($pb.ServerContext ctx, $0.ListPeersRequest request);
  $async.Future<$0.MineResponse> mine($pb.ServerContext ctx, $0.MineRequest request);
  $async.Future<$0.GetBlockResponse> getBlock($pb.ServerContext ctx, $0.GetBlockRequest request);
  $async.Future<$0.GetBestMainchainBlockHashResponse> getBestMainchainBlockHash(
      $pb.ServerContext ctx, $0.GetBestMainchainBlockHashRequest request);
  $async.Future<$0.GetBestSidechainBlockHashResponse> getBestSidechainBlockHash(
      $pb.ServerContext ctx, $0.GetBestSidechainBlockHashRequest request);
  $async.Future<$0.GetBmmInclusionsResponse> getBmmInclusions(
      $pb.ServerContext ctx, $0.GetBmmInclusionsRequest request);
  $async.Future<$0.GetWalletUtxosResponse> getWalletUtxos($pb.ServerContext ctx, $0.GetWalletUtxosRequest request);
  $async.Future<$0.ListUtxosResponse> listUtxos($pb.ServerContext ctx, $0.ListUtxosRequest request);
  $async.Future<$0.RemoveFromMempoolResponse> removeFromMempool(
      $pb.ServerContext ctx, $0.RemoveFromMempoolRequest request);
  $async.Future<$0.GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight(
      $pb.ServerContext ctx, $0.GetLatestFailedWithdrawalBundleHeightRequest request);
  $async.Future<$0.GenerateMnemonicResponse> generateMnemonic(
      $pb.ServerContext ctx, $0.GenerateMnemonicRequest request);
  $async.Future<$0.SetSeedFromMnemonicResponse> setSeedFromMnemonic(
      $pb.ServerContext ctx, $0.SetSeedFromMnemonicRequest request);
  $async.Future<$0.CallRawResponse> callRaw($pb.ServerContext ctx, $0.CallRawRequest request);
  $async.Future<$0.GetBitAssetDataResponse> getBitAssetData($pb.ServerContext ctx, $0.GetBitAssetDataRequest request);
  $async.Future<$0.ListBitAssetsResponse> listBitAssets($pb.ServerContext ctx, $0.ListBitAssetsRequest request);
  $async.Future<$0.RegisterBitAssetResponse> registerBitAsset(
      $pb.ServerContext ctx, $0.RegisterBitAssetRequest request);
  $async.Future<$0.ReserveBitAssetResponse> reserveBitAsset($pb.ServerContext ctx, $0.ReserveBitAssetRequest request);
  $async.Future<$0.TransferBitAssetResponse> transferBitAsset(
      $pb.ServerContext ctx, $0.TransferBitAssetRequest request);
  $async.Future<$0.GetNewEncryptionKeyResponse> getNewEncryptionKey(
      $pb.ServerContext ctx, $0.GetNewEncryptionKeyRequest request);
  $async.Future<$0.GetNewVerifyingKeyResponse> getNewVerifyingKey(
      $pb.ServerContext ctx, $0.GetNewVerifyingKeyRequest request);
  $async.Future<$0.DecryptMsgResponse> decryptMsg($pb.ServerContext ctx, $0.DecryptMsgRequest request);
  $async.Future<$0.EncryptMsgResponse> encryptMsg($pb.ServerContext ctx, $0.EncryptMsgRequest request);
  $async.Future<$0.SignArbitraryMsgResponse> signArbitraryMsg(
      $pb.ServerContext ctx, $0.SignArbitraryMsgRequest request);
  $async.Future<$0.SignArbitraryMsgAsAddrResponse> signArbitraryMsgAsAddr(
      $pb.ServerContext ctx, $0.SignArbitraryMsgAsAddrRequest request);
  $async.Future<$0.VerifySignatureResponse> verifySignature($pb.ServerContext ctx, $0.VerifySignatureRequest request);
  $async.Future<$0.GetWalletAddressesResponse> getWalletAddresses(
      $pb.ServerContext ctx, $0.GetWalletAddressesRequest request);
  $async.Future<$0.MyUnconfirmedUtxosResponse> myUnconfirmedUtxos(
      $pb.ServerContext ctx, $0.MyUnconfirmedUtxosRequest request);
  $async.Future<$0.OpenapiSchemaResponse> openapiSchema($pb.ServerContext ctx, $0.OpenapiSchemaRequest request);
  $async.Future<$0.AmmBurnResponse> ammBurn($pb.ServerContext ctx, $0.AmmBurnRequest request);
  $async.Future<$0.AmmMintResponse> ammMint($pb.ServerContext ctx, $0.AmmMintRequest request);
  $async.Future<$0.AmmSwapResponse> ammSwap($pb.ServerContext ctx, $0.AmmSwapRequest request);
  $async.Future<$0.GetAmmPoolStateResponse> getAmmPoolState($pb.ServerContext ctx, $0.GetAmmPoolStateRequest request);
  $async.Future<$0.GetAmmPriceResponse> getAmmPrice($pb.ServerContext ctx, $0.GetAmmPriceRequest request);
  $async.Future<$0.DutchAuctionBidResponse> dutchAuctionBid($pb.ServerContext ctx, $0.DutchAuctionBidRequest request);
  $async.Future<$0.DutchAuctionCollectResponse> dutchAuctionCollect(
      $pb.ServerContext ctx, $0.DutchAuctionCollectRequest request);
  $async.Future<$0.DutchAuctionCreateResponse> dutchAuctionCreate(
      $pb.ServerContext ctx, $0.DutchAuctionCreateRequest request);
  $async.Future<$0.DutchAuctionsResponse> dutchAuctions($pb.ServerContext ctx, $0.DutchAuctionsRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBalance':
        return $0.GetBalanceRequest();
      case 'GetBlockCount':
        return $0.GetBlockCountRequest();
      case 'Stop':
        return $0.StopRequest();
      case 'GetNewAddress':
        return $0.GetNewAddressRequest();
      case 'Withdraw':
        return $0.WithdrawRequest();
      case 'Transfer':
        return $0.TransferRequest();
      case 'GetSidechainWealth':
        return $0.GetSidechainWealthRequest();
      case 'CreateDeposit':
        return $0.CreateDepositRequest();
      case 'GetPendingWithdrawalBundle':
        return $0.GetPendingWithdrawalBundleRequest();
      case 'ConnectPeer':
        return $0.ConnectPeerRequest();
      case 'ForgetPeer':
        return $0.ForgetPeerRequest();
      case 'ListPeers':
        return $0.ListPeersRequest();
      case 'Mine':
        return $0.MineRequest();
      case 'GetBlock':
        return $0.GetBlockRequest();
      case 'GetBestMainchainBlockHash':
        return $0.GetBestMainchainBlockHashRequest();
      case 'GetBestSidechainBlockHash':
        return $0.GetBestSidechainBlockHashRequest();
      case 'GetBmmInclusions':
        return $0.GetBmmInclusionsRequest();
      case 'GetWalletUtxos':
        return $0.GetWalletUtxosRequest();
      case 'ListUtxos':
        return $0.ListUtxosRequest();
      case 'RemoveFromMempool':
        return $0.RemoveFromMempoolRequest();
      case 'GetLatestFailedWithdrawalBundleHeight':
        return $0.GetLatestFailedWithdrawalBundleHeightRequest();
      case 'GenerateMnemonic':
        return $0.GenerateMnemonicRequest();
      case 'SetSeedFromMnemonic':
        return $0.SetSeedFromMnemonicRequest();
      case 'CallRaw':
        return $0.CallRawRequest();
      case 'GetBitAssetData':
        return $0.GetBitAssetDataRequest();
      case 'ListBitAssets':
        return $0.ListBitAssetsRequest();
      case 'RegisterBitAsset':
        return $0.RegisterBitAssetRequest();
      case 'ReserveBitAsset':
        return $0.ReserveBitAssetRequest();
      case 'TransferBitAsset':
        return $0.TransferBitAssetRequest();
      case 'GetNewEncryptionKey':
        return $0.GetNewEncryptionKeyRequest();
      case 'GetNewVerifyingKey':
        return $0.GetNewVerifyingKeyRequest();
      case 'DecryptMsg':
        return $0.DecryptMsgRequest();
      case 'EncryptMsg':
        return $0.EncryptMsgRequest();
      case 'SignArbitraryMsg':
        return $0.SignArbitraryMsgRequest();
      case 'SignArbitraryMsgAsAddr':
        return $0.SignArbitraryMsgAsAddrRequest();
      case 'VerifySignature':
        return $0.VerifySignatureRequest();
      case 'GetWalletAddresses':
        return $0.GetWalletAddressesRequest();
      case 'MyUnconfirmedUtxos':
        return $0.MyUnconfirmedUtxosRequest();
      case 'OpenapiSchema':
        return $0.OpenapiSchemaRequest();
      case 'AmmBurn':
        return $0.AmmBurnRequest();
      case 'AmmMint':
        return $0.AmmMintRequest();
      case 'AmmSwap':
        return $0.AmmSwapRequest();
      case 'GetAmmPoolState':
        return $0.GetAmmPoolStateRequest();
      case 'GetAmmPrice':
        return $0.GetAmmPriceRequest();
      case 'DutchAuctionBid':
        return $0.DutchAuctionBidRequest();
      case 'DutchAuctionCollect':
        return $0.DutchAuctionCollectRequest();
      case 'DutchAuctionCreate':
        return $0.DutchAuctionCreateRequest();
      case 'DutchAuctions':
        return $0.DutchAuctionsRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall(
      $pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBalance':
        return this.getBalance(ctx, request as $0.GetBalanceRequest);
      case 'GetBlockCount':
        return this.getBlockCount(ctx, request as $0.GetBlockCountRequest);
      case 'Stop':
        return this.stop(ctx, request as $0.StopRequest);
      case 'GetNewAddress':
        return this.getNewAddress(ctx, request as $0.GetNewAddressRequest);
      case 'Withdraw':
        return this.withdraw(ctx, request as $0.WithdrawRequest);
      case 'Transfer':
        return this.transfer(ctx, request as $0.TransferRequest);
      case 'GetSidechainWealth':
        return this.getSidechainWealth(ctx, request as $0.GetSidechainWealthRequest);
      case 'CreateDeposit':
        return this.createDeposit(ctx, request as $0.CreateDepositRequest);
      case 'GetPendingWithdrawalBundle':
        return this.getPendingWithdrawalBundle(ctx, request as $0.GetPendingWithdrawalBundleRequest);
      case 'ConnectPeer':
        return this.connectPeer(ctx, request as $0.ConnectPeerRequest);
      case 'ForgetPeer':
        return this.forgetPeer(ctx, request as $0.ForgetPeerRequest);
      case 'ListPeers':
        return this.listPeers(ctx, request as $0.ListPeersRequest);
      case 'Mine':
        return this.mine(ctx, request as $0.MineRequest);
      case 'GetBlock':
        return this.getBlock(ctx, request as $0.GetBlockRequest);
      case 'GetBestMainchainBlockHash':
        return this.getBestMainchainBlockHash(ctx, request as $0.GetBestMainchainBlockHashRequest);
      case 'GetBestSidechainBlockHash':
        return this.getBestSidechainBlockHash(ctx, request as $0.GetBestSidechainBlockHashRequest);
      case 'GetBmmInclusions':
        return this.getBmmInclusions(ctx, request as $0.GetBmmInclusionsRequest);
      case 'GetWalletUtxos':
        return this.getWalletUtxos(ctx, request as $0.GetWalletUtxosRequest);
      case 'ListUtxos':
        return this.listUtxos(ctx, request as $0.ListUtxosRequest);
      case 'RemoveFromMempool':
        return this.removeFromMempool(ctx, request as $0.RemoveFromMempoolRequest);
      case 'GetLatestFailedWithdrawalBundleHeight':
        return this
            .getLatestFailedWithdrawalBundleHeight(ctx, request as $0.GetLatestFailedWithdrawalBundleHeightRequest);
      case 'GenerateMnemonic':
        return this.generateMnemonic(ctx, request as $0.GenerateMnemonicRequest);
      case 'SetSeedFromMnemonic':
        return this.setSeedFromMnemonic(ctx, request as $0.SetSeedFromMnemonicRequest);
      case 'CallRaw':
        return this.callRaw(ctx, request as $0.CallRawRequest);
      case 'GetBitAssetData':
        return this.getBitAssetData(ctx, request as $0.GetBitAssetDataRequest);
      case 'ListBitAssets':
        return this.listBitAssets(ctx, request as $0.ListBitAssetsRequest);
      case 'RegisterBitAsset':
        return this.registerBitAsset(ctx, request as $0.RegisterBitAssetRequest);
      case 'ReserveBitAsset':
        return this.reserveBitAsset(ctx, request as $0.ReserveBitAssetRequest);
      case 'TransferBitAsset':
        return this.transferBitAsset(ctx, request as $0.TransferBitAssetRequest);
      case 'GetNewEncryptionKey':
        return this.getNewEncryptionKey(ctx, request as $0.GetNewEncryptionKeyRequest);
      case 'GetNewVerifyingKey':
        return this.getNewVerifyingKey(ctx, request as $0.GetNewVerifyingKeyRequest);
      case 'DecryptMsg':
        return this.decryptMsg(ctx, request as $0.DecryptMsgRequest);
      case 'EncryptMsg':
        return this.encryptMsg(ctx, request as $0.EncryptMsgRequest);
      case 'SignArbitraryMsg':
        return this.signArbitraryMsg(ctx, request as $0.SignArbitraryMsgRequest);
      case 'SignArbitraryMsgAsAddr':
        return this.signArbitraryMsgAsAddr(ctx, request as $0.SignArbitraryMsgAsAddrRequest);
      case 'VerifySignature':
        return this.verifySignature(ctx, request as $0.VerifySignatureRequest);
      case 'GetWalletAddresses':
        return this.getWalletAddresses(ctx, request as $0.GetWalletAddressesRequest);
      case 'MyUnconfirmedUtxos':
        return this.myUnconfirmedUtxos(ctx, request as $0.MyUnconfirmedUtxosRequest);
      case 'OpenapiSchema':
        return this.openapiSchema(ctx, request as $0.OpenapiSchemaRequest);
      case 'AmmBurn':
        return this.ammBurn(ctx, request as $0.AmmBurnRequest);
      case 'AmmMint':
        return this.ammMint(ctx, request as $0.AmmMintRequest);
      case 'AmmSwap':
        return this.ammSwap(ctx, request as $0.AmmSwapRequest);
      case 'GetAmmPoolState':
        return this.getAmmPoolState(ctx, request as $0.GetAmmPoolStateRequest);
      case 'GetAmmPrice':
        return this.getAmmPrice(ctx, request as $0.GetAmmPriceRequest);
      case 'DutchAuctionBid':
        return this.dutchAuctionBid(ctx, request as $0.DutchAuctionBidRequest);
      case 'DutchAuctionCollect':
        return this.dutchAuctionCollect(ctx, request as $0.DutchAuctionCollectRequest);
      case 'DutchAuctionCreate':
        return this.dutchAuctionCreate(ctx, request as $0.DutchAuctionCreateRequest);
      case 'DutchAuctions':
        return this.dutchAuctions(ctx, request as $0.DutchAuctionsRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => BitAssetsServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => BitAssetsServiceBase$messageJson;
}
