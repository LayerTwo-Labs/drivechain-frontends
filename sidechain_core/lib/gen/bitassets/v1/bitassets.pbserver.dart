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

import 'bitassets.pb.dart' as $1;
import 'bitassets.pbjson.dart';

export 'bitassets.pb.dart';

abstract class BitAssetsServiceBase extends $pb.GeneratedService {
  $async.Future<$1.GetBalanceResponse> getBalance($pb.ServerContext ctx, $1.GetBalanceRequest request);
  $async.Future<$1.GetBlockCountResponse> getBlockCount($pb.ServerContext ctx, $1.GetBlockCountRequest request);
  $async.Future<$1.StopResponse> stop($pb.ServerContext ctx, $1.StopRequest request);
  $async.Future<$1.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $1.GetNewAddressRequest request);
  $async.Future<$1.WithdrawResponse> withdraw($pb.ServerContext ctx, $1.WithdrawRequest request);
  $async.Future<$1.TransferResponse> transfer($pb.ServerContext ctx, $1.TransferRequest request);
  $async.Future<$1.GetSidechainWealthResponse> getSidechainWealth($pb.ServerContext ctx, $1.GetSidechainWealthRequest request);
  $async.Future<$1.CreateDepositResponse> createDeposit($pb.ServerContext ctx, $1.CreateDepositRequest request);
  $async.Future<$1.GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle($pb.ServerContext ctx, $1.GetPendingWithdrawalBundleRequest request);
  $async.Future<$1.ConnectPeerResponse> connectPeer($pb.ServerContext ctx, $1.ConnectPeerRequest request);
  $async.Future<$1.ForgetPeerResponse> forgetPeer($pb.ServerContext ctx, $1.ForgetPeerRequest request);
  $async.Future<$1.ListPeersResponse> listPeers($pb.ServerContext ctx, $1.ListPeersRequest request);
  $async.Future<$1.MineResponse> mine($pb.ServerContext ctx, $1.MineRequest request);
  $async.Future<$1.GetBlockResponse> getBlock($pb.ServerContext ctx, $1.GetBlockRequest request);
  $async.Future<$1.GetBestMainchainBlockHashResponse> getBestMainchainBlockHash($pb.ServerContext ctx, $1.GetBestMainchainBlockHashRequest request);
  $async.Future<$1.GetBestSidechainBlockHashResponse> getBestSidechainBlockHash($pb.ServerContext ctx, $1.GetBestSidechainBlockHashRequest request);
  $async.Future<$1.GetBmmInclusionsResponse> getBmmInclusions($pb.ServerContext ctx, $1.GetBmmInclusionsRequest request);
  $async.Future<$1.GetWalletUtxosResponse> getWalletUtxos($pb.ServerContext ctx, $1.GetWalletUtxosRequest request);
  $async.Future<$1.ListUtxosResponse> listUtxos($pb.ServerContext ctx, $1.ListUtxosRequest request);
  $async.Future<$1.RemoveFromMempoolResponse> removeFromMempool($pb.ServerContext ctx, $1.RemoveFromMempoolRequest request);
  $async.Future<$1.GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight($pb.ServerContext ctx, $1.GetLatestFailedWithdrawalBundleHeightRequest request);
  $async.Future<$1.GenerateMnemonicResponse> generateMnemonic($pb.ServerContext ctx, $1.GenerateMnemonicRequest request);
  $async.Future<$1.SetSeedFromMnemonicResponse> setSeedFromMnemonic($pb.ServerContext ctx, $1.SetSeedFromMnemonicRequest request);
  $async.Future<$1.CallRawResponse> callRaw($pb.ServerContext ctx, $1.CallRawRequest request);
  $async.Future<$1.GetBitAssetDataResponse> getBitAssetData($pb.ServerContext ctx, $1.GetBitAssetDataRequest request);
  $async.Future<$1.ListBitAssetsResponse> listBitAssets($pb.ServerContext ctx, $1.ListBitAssetsRequest request);
  $async.Future<$1.RegisterBitAssetResponse> registerBitAsset($pb.ServerContext ctx, $1.RegisterBitAssetRequest request);
  $async.Future<$1.ReserveBitAssetResponse> reserveBitAsset($pb.ServerContext ctx, $1.ReserveBitAssetRequest request);
  $async.Future<$1.TransferBitAssetResponse> transferBitAsset($pb.ServerContext ctx, $1.TransferBitAssetRequest request);
  $async.Future<$1.GetNewEncryptionKeyResponse> getNewEncryptionKey($pb.ServerContext ctx, $1.GetNewEncryptionKeyRequest request);
  $async.Future<$1.GetNewVerifyingKeyResponse> getNewVerifyingKey($pb.ServerContext ctx, $1.GetNewVerifyingKeyRequest request);
  $async.Future<$1.DecryptMsgResponse> decryptMsg($pb.ServerContext ctx, $1.DecryptMsgRequest request);
  $async.Future<$1.EncryptMsgResponse> encryptMsg($pb.ServerContext ctx, $1.EncryptMsgRequest request);
  $async.Future<$1.SignArbitraryMsgResponse> signArbitraryMsg($pb.ServerContext ctx, $1.SignArbitraryMsgRequest request);
  $async.Future<$1.SignArbitraryMsgAsAddrResponse> signArbitraryMsgAsAddr($pb.ServerContext ctx, $1.SignArbitraryMsgAsAddrRequest request);
  $async.Future<$1.VerifySignatureResponse> verifySignature($pb.ServerContext ctx, $1.VerifySignatureRequest request);
  $async.Future<$1.GetWalletAddressesResponse> getWalletAddresses($pb.ServerContext ctx, $1.GetWalletAddressesRequest request);
  $async.Future<$1.MyUnconfirmedUtxosResponse> myUnconfirmedUtxos($pb.ServerContext ctx, $1.MyUnconfirmedUtxosRequest request);
  $async.Future<$1.OpenapiSchemaResponse> openapiSchema($pb.ServerContext ctx, $1.OpenapiSchemaRequest request);
  $async.Future<$1.AmmBurnResponse> ammBurn($pb.ServerContext ctx, $1.AmmBurnRequest request);
  $async.Future<$1.AmmMintResponse> ammMint($pb.ServerContext ctx, $1.AmmMintRequest request);
  $async.Future<$1.AmmSwapResponse> ammSwap($pb.ServerContext ctx, $1.AmmSwapRequest request);
  $async.Future<$1.GetAmmPoolStateResponse> getAmmPoolState($pb.ServerContext ctx, $1.GetAmmPoolStateRequest request);
  $async.Future<$1.GetAmmPriceResponse> getAmmPrice($pb.ServerContext ctx, $1.GetAmmPriceRequest request);
  $async.Future<$1.DutchAuctionBidResponse> dutchAuctionBid($pb.ServerContext ctx, $1.DutchAuctionBidRequest request);
  $async.Future<$1.DutchAuctionCollectResponse> dutchAuctionCollect($pb.ServerContext ctx, $1.DutchAuctionCollectRequest request);
  $async.Future<$1.DutchAuctionCreateResponse> dutchAuctionCreate($pb.ServerContext ctx, $1.DutchAuctionCreateRequest request);
  $async.Future<$1.DutchAuctionsResponse> dutchAuctions($pb.ServerContext ctx, $1.DutchAuctionsRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBalance': return $1.GetBalanceRequest();
      case 'GetBlockCount': return $1.GetBlockCountRequest();
      case 'Stop': return $1.StopRequest();
      case 'GetNewAddress': return $1.GetNewAddressRequest();
      case 'Withdraw': return $1.WithdrawRequest();
      case 'Transfer': return $1.TransferRequest();
      case 'GetSidechainWealth': return $1.GetSidechainWealthRequest();
      case 'CreateDeposit': return $1.CreateDepositRequest();
      case 'GetPendingWithdrawalBundle': return $1.GetPendingWithdrawalBundleRequest();
      case 'ConnectPeer': return $1.ConnectPeerRequest();
      case 'ForgetPeer': return $1.ForgetPeerRequest();
      case 'ListPeers': return $1.ListPeersRequest();
      case 'Mine': return $1.MineRequest();
      case 'GetBlock': return $1.GetBlockRequest();
      case 'GetBestMainchainBlockHash': return $1.GetBestMainchainBlockHashRequest();
      case 'GetBestSidechainBlockHash': return $1.GetBestSidechainBlockHashRequest();
      case 'GetBmmInclusions': return $1.GetBmmInclusionsRequest();
      case 'GetWalletUtxos': return $1.GetWalletUtxosRequest();
      case 'ListUtxos': return $1.ListUtxosRequest();
      case 'RemoveFromMempool': return $1.RemoveFromMempoolRequest();
      case 'GetLatestFailedWithdrawalBundleHeight': return $1.GetLatestFailedWithdrawalBundleHeightRequest();
      case 'GenerateMnemonic': return $1.GenerateMnemonicRequest();
      case 'SetSeedFromMnemonic': return $1.SetSeedFromMnemonicRequest();
      case 'CallRaw': return $1.CallRawRequest();
      case 'GetBitAssetData': return $1.GetBitAssetDataRequest();
      case 'ListBitAssets': return $1.ListBitAssetsRequest();
      case 'RegisterBitAsset': return $1.RegisterBitAssetRequest();
      case 'ReserveBitAsset': return $1.ReserveBitAssetRequest();
      case 'TransferBitAsset': return $1.TransferBitAssetRequest();
      case 'GetNewEncryptionKey': return $1.GetNewEncryptionKeyRequest();
      case 'GetNewVerifyingKey': return $1.GetNewVerifyingKeyRequest();
      case 'DecryptMsg': return $1.DecryptMsgRequest();
      case 'EncryptMsg': return $1.EncryptMsgRequest();
      case 'SignArbitraryMsg': return $1.SignArbitraryMsgRequest();
      case 'SignArbitraryMsgAsAddr': return $1.SignArbitraryMsgAsAddrRequest();
      case 'VerifySignature': return $1.VerifySignatureRequest();
      case 'GetWalletAddresses': return $1.GetWalletAddressesRequest();
      case 'MyUnconfirmedUtxos': return $1.MyUnconfirmedUtxosRequest();
      case 'OpenapiSchema': return $1.OpenapiSchemaRequest();
      case 'AmmBurn': return $1.AmmBurnRequest();
      case 'AmmMint': return $1.AmmMintRequest();
      case 'AmmSwap': return $1.AmmSwapRequest();
      case 'GetAmmPoolState': return $1.GetAmmPoolStateRequest();
      case 'GetAmmPrice': return $1.GetAmmPriceRequest();
      case 'DutchAuctionBid': return $1.DutchAuctionBidRequest();
      case 'DutchAuctionCollect': return $1.DutchAuctionCollectRequest();
      case 'DutchAuctionCreate': return $1.DutchAuctionCreateRequest();
      case 'DutchAuctions': return $1.DutchAuctionsRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBalance': return this.getBalance(ctx, request as $1.GetBalanceRequest);
      case 'GetBlockCount': return this.getBlockCount(ctx, request as $1.GetBlockCountRequest);
      case 'Stop': return this.stop(ctx, request as $1.StopRequest);
      case 'GetNewAddress': return this.getNewAddress(ctx, request as $1.GetNewAddressRequest);
      case 'Withdraw': return this.withdraw(ctx, request as $1.WithdrawRequest);
      case 'Transfer': return this.transfer(ctx, request as $1.TransferRequest);
      case 'GetSidechainWealth': return this.getSidechainWealth(ctx, request as $1.GetSidechainWealthRequest);
      case 'CreateDeposit': return this.createDeposit(ctx, request as $1.CreateDepositRequest);
      case 'GetPendingWithdrawalBundle': return this.getPendingWithdrawalBundle(ctx, request as $1.GetPendingWithdrawalBundleRequest);
      case 'ConnectPeer': return this.connectPeer(ctx, request as $1.ConnectPeerRequest);
      case 'ForgetPeer': return this.forgetPeer(ctx, request as $1.ForgetPeerRequest);
      case 'ListPeers': return this.listPeers(ctx, request as $1.ListPeersRequest);
      case 'Mine': return this.mine(ctx, request as $1.MineRequest);
      case 'GetBlock': return this.getBlock(ctx, request as $1.GetBlockRequest);
      case 'GetBestMainchainBlockHash': return this.getBestMainchainBlockHash(ctx, request as $1.GetBestMainchainBlockHashRequest);
      case 'GetBestSidechainBlockHash': return this.getBestSidechainBlockHash(ctx, request as $1.GetBestSidechainBlockHashRequest);
      case 'GetBmmInclusions': return this.getBmmInclusions(ctx, request as $1.GetBmmInclusionsRequest);
      case 'GetWalletUtxos': return this.getWalletUtxos(ctx, request as $1.GetWalletUtxosRequest);
      case 'ListUtxos': return this.listUtxos(ctx, request as $1.ListUtxosRequest);
      case 'RemoveFromMempool': return this.removeFromMempool(ctx, request as $1.RemoveFromMempoolRequest);
      case 'GetLatestFailedWithdrawalBundleHeight': return this.getLatestFailedWithdrawalBundleHeight(ctx, request as $1.GetLatestFailedWithdrawalBundleHeightRequest);
      case 'GenerateMnemonic': return this.generateMnemonic(ctx, request as $1.GenerateMnemonicRequest);
      case 'SetSeedFromMnemonic': return this.setSeedFromMnemonic(ctx, request as $1.SetSeedFromMnemonicRequest);
      case 'CallRaw': return this.callRaw(ctx, request as $1.CallRawRequest);
      case 'GetBitAssetData': return this.getBitAssetData(ctx, request as $1.GetBitAssetDataRequest);
      case 'ListBitAssets': return this.listBitAssets(ctx, request as $1.ListBitAssetsRequest);
      case 'RegisterBitAsset': return this.registerBitAsset(ctx, request as $1.RegisterBitAssetRequest);
      case 'ReserveBitAsset': return this.reserveBitAsset(ctx, request as $1.ReserveBitAssetRequest);
      case 'TransferBitAsset': return this.transferBitAsset(ctx, request as $1.TransferBitAssetRequest);
      case 'GetNewEncryptionKey': return this.getNewEncryptionKey(ctx, request as $1.GetNewEncryptionKeyRequest);
      case 'GetNewVerifyingKey': return this.getNewVerifyingKey(ctx, request as $1.GetNewVerifyingKeyRequest);
      case 'DecryptMsg': return this.decryptMsg(ctx, request as $1.DecryptMsgRequest);
      case 'EncryptMsg': return this.encryptMsg(ctx, request as $1.EncryptMsgRequest);
      case 'SignArbitraryMsg': return this.signArbitraryMsg(ctx, request as $1.SignArbitraryMsgRequest);
      case 'SignArbitraryMsgAsAddr': return this.signArbitraryMsgAsAddr(ctx, request as $1.SignArbitraryMsgAsAddrRequest);
      case 'VerifySignature': return this.verifySignature(ctx, request as $1.VerifySignatureRequest);
      case 'GetWalletAddresses': return this.getWalletAddresses(ctx, request as $1.GetWalletAddressesRequest);
      case 'MyUnconfirmedUtxos': return this.myUnconfirmedUtxos(ctx, request as $1.MyUnconfirmedUtxosRequest);
      case 'OpenapiSchema': return this.openapiSchema(ctx, request as $1.OpenapiSchemaRequest);
      case 'AmmBurn': return this.ammBurn(ctx, request as $1.AmmBurnRequest);
      case 'AmmMint': return this.ammMint(ctx, request as $1.AmmMintRequest);
      case 'AmmSwap': return this.ammSwap(ctx, request as $1.AmmSwapRequest);
      case 'GetAmmPoolState': return this.getAmmPoolState(ctx, request as $1.GetAmmPoolStateRequest);
      case 'GetAmmPrice': return this.getAmmPrice(ctx, request as $1.GetAmmPriceRequest);
      case 'DutchAuctionBid': return this.dutchAuctionBid(ctx, request as $1.DutchAuctionBidRequest);
      case 'DutchAuctionCollect': return this.dutchAuctionCollect(ctx, request as $1.DutchAuctionCollectRequest);
      case 'DutchAuctionCreate': return this.dutchAuctionCreate(ctx, request as $1.DutchAuctionCreateRequest);
      case 'DutchAuctions': return this.dutchAuctions(ctx, request as $1.DutchAuctionsRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => BitAssetsServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => BitAssetsServiceBase$messageJson;
}

