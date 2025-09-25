//
//  Generated code. Do not modify.
//  source: bitcoin/bitcoind/v1alpha/bitcoin.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

import '../../../google/protobuf/duration.pbjson.dart' as $1;
import '../../../google/protobuf/empty.pbjson.dart' as $3;
import '../../../google/protobuf/timestamp.pbjson.dart' as $0;
import '../../../google/protobuf/wrappers.pbjson.dart' as $2;

@$core.Deprecated('Use getBlockchainInfoRequestDescriptor instead')
const GetBlockchainInfoRequest$json = {
  '1': 'GetBlockchainInfoRequest',
};

/// Descriptor for `GetBlockchainInfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlockchainInfoRequestDescriptor =
    $convert.base64Decode('ChhHZXRCbG9ja2NoYWluSW5mb1JlcXVlc3Q=');

@$core.Deprecated('Use getBlockchainInfoResponseDescriptor instead')
const GetBlockchainInfoResponse$json = {
  '1': 'GetBlockchainInfoResponse',
  '2': [
    {'1': 'best_block_hash', '3': 1, '4': 1, '5': 9, '10': 'bestBlockHash'},
    {'1': 'blocks', '3': 5, '4': 1, '5': 13, '10': 'blocks'},
    {'1': 'headers', '3': 6, '4': 1, '5': 13, '10': 'headers'},
    {'1': 'chain', '3': 2, '4': 1, '5': 9, '10': 'chain'},
    {'1': 'chain_work', '3': 3, '4': 1, '5': 9, '10': 'chainWork'},
    {'1': 'initial_block_download', '3': 4, '4': 1, '5': 8, '10': 'initialBlockDownload'},
    {'1': 'verification_progress', '3': 7, '4': 1, '5': 1, '10': 'verificationProgress'},
  ],
};

/// Descriptor for `GetBlockchainInfoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlockchainInfoResponseDescriptor =
    $convert.base64Decode('ChlHZXRCbG9ja2NoYWluSW5mb1Jlc3BvbnNlEiYKD2Jlc3RfYmxvY2tfaGFzaBgBIAEoCVINYm'
        'VzdEJsb2NrSGFzaBIWCgZibG9ja3MYBSABKA1SBmJsb2NrcxIYCgdoZWFkZXJzGAYgASgNUgdo'
        'ZWFkZXJzEhQKBWNoYWluGAIgASgJUgVjaGFpbhIdCgpjaGFpbl93b3JrGAMgASgJUgljaGFpbl'
        'dvcmsSNAoWaW5pdGlhbF9ibG9ja19kb3dubG9hZBgEIAEoCFIUaW5pdGlhbEJsb2NrRG93bmxv'
        'YWQSMwoVdmVyaWZpY2F0aW9uX3Byb2dyZXNzGAcgASgBUhR2ZXJpZmljYXRpb25Qcm9ncmVzcw'
        '==');

@$core.Deprecated('Use getPeerInfoRequestDescriptor instead')
const GetPeerInfoRequest$json = {
  '1': 'GetPeerInfoRequest',
};

/// Descriptor for `GetPeerInfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPeerInfoRequestDescriptor = $convert.base64Decode('ChJHZXRQZWVySW5mb1JlcXVlc3Q=');

@$core.Deprecated('Use peerDescriptor instead')
const Peer$json = {
  '1': 'Peer',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'addr', '3': 2, '4': 1, '5': 9, '10': 'addr'},
    {'1': 'addr_bind', '3': 3, '4': 1, '5': 9, '10': 'addrBind'},
    {'1': 'addr_local', '3': 4, '4': 1, '5': 9, '10': 'addrLocal'},
    {'1': 'network', '3': 5, '4': 1, '5': 14, '6': '.bitcoin.bitcoind.v1alpha.Peer.Network', '10': 'network'},
    {'1': 'mapped_as', '3': 6, '4': 1, '5': 3, '10': 'mappedAs'},
    {'1': 'services', '3': 7, '4': 1, '5': 9, '10': 'services'},
    {'1': 'services_names', '3': 8, '4': 3, '5': 9, '10': 'servicesNames'},
    {'1': 'relay_transactions', '3': 9, '4': 1, '5': 8, '10': 'relayTransactions'},
    {'1': 'last_send_at', '3': 10, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'lastSendAt'},
    {'1': 'last_recv_at', '3': 11, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'lastRecvAt'},
    {
      '1': 'last_transaction_at',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'lastTransactionAt'
    },
    {'1': 'last_block_at', '3': 13, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'lastBlockAt'},
    {'1': 'bytes_sent', '3': 14, '4': 1, '5': 4, '10': 'bytesSent'},
    {'1': 'bytes_received', '3': 15, '4': 1, '5': 4, '10': 'bytesReceived'},
    {'1': 'connected_at', '3': 16, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'connectedAt'},
    {'1': 'time_offset', '3': 17, '4': 1, '5': 11, '6': '.google.protobuf.Duration', '10': 'timeOffset'},
    {'1': 'ping_time', '3': 18, '4': 1, '5': 11, '6': '.google.protobuf.Duration', '10': 'pingTime'},
    {'1': 'min_ping', '3': 19, '4': 1, '5': 11, '6': '.google.protobuf.Duration', '10': 'minPing'},
    {'1': 'ping_wait', '3': 20, '4': 1, '5': 11, '6': '.google.protobuf.Duration', '10': 'pingWait'},
    {'1': 'version', '3': 21, '4': 1, '5': 13, '10': 'version'},
    {'1': 'subver', '3': 22, '4': 1, '5': 9, '10': 'subver'},
    {'1': 'inbound', '3': 23, '4': 1, '5': 8, '10': 'inbound'},
    {'1': 'bip152_hb_to', '3': 24, '4': 1, '5': 8, '10': 'bip152HbTo'},
    {'1': 'bip152_hb_from', '3': 25, '4': 1, '5': 8, '10': 'bip152HbFrom'},
    {'1': 'starting_height', '3': 26, '4': 1, '5': 5, '10': 'startingHeight'},
    {'1': 'presynced_headers', '3': 27, '4': 1, '5': 5, '10': 'presyncedHeaders'},
    {'1': 'synced_headers', '3': 28, '4': 1, '5': 5, '10': 'syncedHeaders'},
    {'1': 'synced_blocks', '3': 29, '4': 1, '5': 5, '10': 'syncedBlocks'},
    {'1': 'inflight', '3': 30, '4': 3, '5': 5, '10': 'inflight'},
    {'1': 'addr_relay_enabled', '3': 31, '4': 1, '5': 8, '10': 'addrRelayEnabled'},
    {'1': 'addr_processed', '3': 32, '4': 1, '5': 3, '10': 'addrProcessed'},
    {'1': 'addr_rate_limited', '3': 33, '4': 1, '5': 3, '10': 'addrRateLimited'},
    {'1': 'permissions', '3': 34, '4': 3, '5': 9, '10': 'permissions'},
    {'1': 'min_fee_filter', '3': 35, '4': 1, '5': 1, '10': 'minFeeFilter'},
    {
      '1': 'bytes_sent_per_msg',
      '3': 36,
      '4': 3,
      '5': 11,
      '6': '.bitcoin.bitcoind.v1alpha.Peer.BytesSentPerMsgEntry',
      '10': 'bytesSentPerMsg'
    },
    {
      '1': 'bytes_received_per_msg',
      '3': 37,
      '4': 3,
      '5': 11,
      '6': '.bitcoin.bitcoind.v1alpha.Peer.BytesReceivedPerMsgEntry',
      '10': 'bytesReceivedPerMsg'
    },
    {
      '1': 'connection_type',
      '3': 38,
      '4': 1,
      '5': 14,
      '6': '.bitcoin.bitcoind.v1alpha.Peer.ConnectionType',
      '10': 'connectionType'
    },
    {
      '1': 'transport_protocol',
      '3': 39,
      '4': 1,
      '5': 14,
      '6': '.bitcoin.bitcoind.v1alpha.Peer.TransportProtocol',
      '10': 'transportProtocol'
    },
    {'1': 'session_id', '3': 40, '4': 1, '5': 9, '10': 'sessionId'},
  ],
  '3': [Peer_BytesSentPerMsgEntry$json, Peer_BytesReceivedPerMsgEntry$json],
  '4': [Peer_Network$json, Peer_ConnectionType$json, Peer_TransportProtocol$json],
};

@$core.Deprecated('Use peerDescriptor instead')
const Peer_BytesSentPerMsgEntry$json = {
  '1': 'BytesSentPerMsgEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 3, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use peerDescriptor instead')
const Peer_BytesReceivedPerMsgEntry$json = {
  '1': 'BytesReceivedPerMsgEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 3, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use peerDescriptor instead')
const Peer_Network$json = {
  '1': 'Network',
  '2': [
    {'1': 'NETWORK_UNSPECIFIED', '2': 0},
    {'1': 'NETWORK_IPV4', '2': 1},
    {'1': 'NETWORK_IPV6', '2': 2},
    {'1': 'NETWORK_ONION', '2': 3},
    {'1': 'NETWORK_I2P', '2': 4},
    {'1': 'NETWORK_CJDNS', '2': 5},
    {'1': 'NETWORK_NOT_PUBLICLY_ROUTABLE', '2': 6},
  ],
};

@$core.Deprecated('Use peerDescriptor instead')
const Peer_ConnectionType$json = {
  '1': 'ConnectionType',
  '2': [
    {'1': 'CONNECTION_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'CONNECTION_TYPE_OUTBOUND_FULL_RELAY', '2': 1},
    {'1': 'CONNECTION_TYPE_BLOCK_RELAY_ONLY', '2': 2},
    {'1': 'CONNECTION_TYPE_INBOUND', '2': 3},
    {'1': 'CONNECTION_TYPE_MANUAL', '2': 4},
    {'1': 'CONNECTION_TYPE_ADDR_FETCH', '2': 5},
    {'1': 'CONNECTION_TYPE_FEEDER', '2': 6},
  ],
};

@$core.Deprecated('Use peerDescriptor instead')
const Peer_TransportProtocol$json = {
  '1': 'TransportProtocol',
  '2': [
    {'1': 'TRANSPORT_PROTOCOL_UNSPECIFIED', '2': 0},
    {'1': 'TRANSPORT_PROTOCOL_DETECTING', '2': 1},
    {'1': 'TRANSPORT_PROTOCOL_V1', '2': 2},
    {'1': 'TRANSPORT_PROTOCOL_V2', '2': 3},
  ],
};

/// Descriptor for `Peer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List peerDescriptor =
    $convert.base64Decode('CgRQZWVyEg4KAmlkGAEgASgFUgJpZBISCgRhZGRyGAIgASgJUgRhZGRyEhsKCWFkZHJfYmluZB'
        'gDIAEoCVIIYWRkckJpbmQSHQoKYWRkcl9sb2NhbBgEIAEoCVIJYWRkckxvY2FsEkAKB25ldHdv'
        'cmsYBSABKA4yJi5iaXRjb2luLmJpdGNvaW5kLnYxYWxwaGEuUGVlci5OZXR3b3JrUgduZXR3b3'
        'JrEhsKCW1hcHBlZF9hcxgGIAEoA1IIbWFwcGVkQXMSGgoIc2VydmljZXMYByABKAlSCHNlcnZp'
        'Y2VzEiUKDnNlcnZpY2VzX25hbWVzGAggAygJUg1zZXJ2aWNlc05hbWVzEi0KEnJlbGF5X3RyYW'
        '5zYWN0aW9ucxgJIAEoCFIRcmVsYXlUcmFuc2FjdGlvbnMSPAoMbGFzdF9zZW5kX2F0GAogASgL'
        'MhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIKbGFzdFNlbmRBdBI8CgxsYXN0X3JlY3ZfYX'
        'QYCyABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgpsYXN0UmVjdkF0EkoKE2xhc3Rf'
        'dHJhbnNhY3Rpb25fYXQYDCABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUhFsYXN0VH'
        'JhbnNhY3Rpb25BdBI+Cg1sYXN0X2Jsb2NrX2F0GA0gASgLMhouZ29vZ2xlLnByb3RvYnVmLlRp'
        'bWVzdGFtcFILbGFzdEJsb2NrQXQSHQoKYnl0ZXNfc2VudBgOIAEoBFIJYnl0ZXNTZW50EiUKDm'
        'J5dGVzX3JlY2VpdmVkGA8gASgEUg1ieXRlc1JlY2VpdmVkEj0KDGNvbm5lY3RlZF9hdBgQIAEo'
        'CzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSC2Nvbm5lY3RlZEF0EjoKC3RpbWVfb2Zmc2'
        'V0GBEgASgLMhkuZ29vZ2xlLnByb3RvYnVmLkR1cmF0aW9uUgp0aW1lT2Zmc2V0EjYKCXBpbmdf'
        'dGltZRgSIAEoCzIZLmdvb2dsZS5wcm90b2J1Zi5EdXJhdGlvblIIcGluZ1RpbWUSNAoIbWluX3'
        'BpbmcYEyABKAsyGS5nb29nbGUucHJvdG9idWYuRHVyYXRpb25SB21pblBpbmcSNgoJcGluZ193'
        'YWl0GBQgASgLMhkuZ29vZ2xlLnByb3RvYnVmLkR1cmF0aW9uUghwaW5nV2FpdBIYCgd2ZXJzaW'
        '9uGBUgASgNUgd2ZXJzaW9uEhYKBnN1YnZlchgWIAEoCVIGc3VidmVyEhgKB2luYm91bmQYFyAB'
        'KAhSB2luYm91bmQSIAoMYmlwMTUyX2hiX3RvGBggASgIUgpiaXAxNTJIYlRvEiQKDmJpcDE1Ml'
        '9oYl9mcm9tGBkgASgIUgxiaXAxNTJIYkZyb20SJwoPc3RhcnRpbmdfaGVpZ2h0GBogASgFUg5z'
        'dGFydGluZ0hlaWdodBIrChFwcmVzeW5jZWRfaGVhZGVycxgbIAEoBVIQcHJlc3luY2VkSGVhZG'
        'VycxIlCg5zeW5jZWRfaGVhZGVycxgcIAEoBVINc3luY2VkSGVhZGVycxIjCg1zeW5jZWRfYmxv'
        'Y2tzGB0gASgFUgxzeW5jZWRCbG9ja3MSGgoIaW5mbGlnaHQYHiADKAVSCGluZmxpZ2h0EiwKEm'
        'FkZHJfcmVsYXlfZW5hYmxlZBgfIAEoCFIQYWRkclJlbGF5RW5hYmxlZBIlCg5hZGRyX3Byb2Nl'
        'c3NlZBggIAEoA1INYWRkclByb2Nlc3NlZBIqChFhZGRyX3JhdGVfbGltaXRlZBghIAEoA1IPYW'
        'RkclJhdGVMaW1pdGVkEiAKC3Blcm1pc3Npb25zGCIgAygJUgtwZXJtaXNzaW9ucxIkCg5taW5f'
        'ZmVlX2ZpbHRlchgjIAEoAVIMbWluRmVlRmlsdGVyEmAKEmJ5dGVzX3NlbnRfcGVyX21zZxgkIA'
        'MoCzIzLmJpdGNvaW4uYml0Y29pbmQudjFhbHBoYS5QZWVyLkJ5dGVzU2VudFBlck1zZ0VudHJ5'
        'Ug9ieXRlc1NlbnRQZXJNc2cSbAoWYnl0ZXNfcmVjZWl2ZWRfcGVyX21zZxglIAMoCzI3LmJpdG'
        'NvaW4uYml0Y29pbmQudjFhbHBoYS5QZWVyLkJ5dGVzUmVjZWl2ZWRQZXJNc2dFbnRyeVITYnl0'
        'ZXNSZWNlaXZlZFBlck1zZxJWCg9jb25uZWN0aW9uX3R5cGUYJiABKA4yLS5iaXRjb2luLmJpdG'
        'NvaW5kLnYxYWxwaGEuUGVlci5Db25uZWN0aW9uVHlwZVIOY29ubmVjdGlvblR5cGUSXwoSdHJh'
        'bnNwb3J0X3Byb3RvY29sGCcgASgOMjAuYml0Y29pbi5iaXRjb2luZC52MWFscGhhLlBlZXIuVH'
        'JhbnNwb3J0UHJvdG9jb2xSEXRyYW5zcG9ydFByb3RvY29sEh0KCnNlc3Npb25faWQYKCABKAlS'
        'CXNlc3Npb25JZBpCChRCeXRlc1NlbnRQZXJNc2dFbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCg'
        'V2YWx1ZRgCIAEoA1IFdmFsdWU6AjgBGkYKGEJ5dGVzUmVjZWl2ZWRQZXJNc2dFbnRyeRIQCgNr'
        'ZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoA1IFdmFsdWU6AjgBIqABCgdOZXR3b3JrEhcKE0'
        '5FVFdPUktfVU5TUEVDSUZJRUQQABIQCgxORVRXT1JLX0lQVjQQARIQCgxORVRXT1JLX0lQVjYQ'
        'AhIRCg1ORVRXT1JLX09OSU9OEAMSDwoLTkVUV09SS19JMlAQBBIRCg1ORVRXT1JLX0NKRE5TEA'
        'USIQodTkVUV09SS19OT1RfUFVCTElDTFlfUk9VVEFCTEUQBiL1AQoOQ29ubmVjdGlvblR5cGUS'
        'HwobQ09OTkVDVElPTl9UWVBFX1VOU1BFQ0lGSUVEEAASJwojQ09OTkVDVElPTl9UWVBFX09VVE'
        'JPVU5EX0ZVTExfUkVMQVkQARIkCiBDT05ORUNUSU9OX1RZUEVfQkxPQ0tfUkVMQVlfT05MWRAC'
        'EhsKF0NPTk5FQ1RJT05fVFlQRV9JTkJPVU5EEAMSGgoWQ09OTkVDVElPTl9UWVBFX01BTlVBTB'
        'AEEh4KGkNPTk5FQ1RJT05fVFlQRV9BRERSX0ZFVENIEAUSGgoWQ09OTkVDVElPTl9UWVBFX0ZF'
        'RURFUhAGIo8BChFUcmFuc3BvcnRQcm90b2NvbBIiCh5UUkFOU1BPUlRfUFJPVE9DT0xfVU5TUE'
        'VDSUZJRUQQABIgChxUUkFOU1BPUlRfUFJPVE9DT0xfREVURUNUSU5HEAESGQoVVFJBTlNQT1JU'
        'X1BST1RPQ09MX1YxEAISGQoVVFJBTlNQT1JUX1BST1RPQ09MX1YyEAM=');

@$core.Deprecated('Use getPeerInfoResponseDescriptor instead')
const GetPeerInfoResponse$json = {
  '1': 'GetPeerInfoResponse',
  '2': [
    {'1': 'peers', '3': 1, '4': 3, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.Peer', '10': 'peers'},
  ],
};

/// Descriptor for `GetPeerInfoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPeerInfoResponseDescriptor =
    $convert.base64Decode('ChNHZXRQZWVySW5mb1Jlc3BvbnNlEjQKBXBlZXJzGAEgAygLMh4uYml0Y29pbi5iaXRjb2luZC'
        '52MWFscGhhLlBlZXJSBXBlZXJz');

@$core.Deprecated('Use getNewAddressRequestDescriptor instead')
const GetNewAddressRequest$json = {
  '1': 'GetNewAddressRequest',
  '2': [
    {'1': 'label', '3': 1, '4': 1, '5': 9, '10': 'label'},
    {'1': 'address_type', '3': 2, '4': 1, '5': 9, '10': 'addressType'},
    {'1': 'wallet', '3': 3, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `GetNewAddressRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNewAddressRequestDescriptor =
    $convert.base64Decode('ChRHZXROZXdBZGRyZXNzUmVxdWVzdBIUCgVsYWJlbBgBIAEoCVIFbGFiZWwSIQoMYWRkcmVzc1'
        '90eXBlGAIgASgJUgthZGRyZXNzVHlwZRIWCgZ3YWxsZXQYAyABKAlSBndhbGxldA==');

@$core.Deprecated('Use getNewAddressResponseDescriptor instead')
const GetNewAddressResponse$json = {
  '1': 'GetNewAddressResponse',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
  ],
};

/// Descriptor for `GetNewAddressResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNewAddressResponseDescriptor =
    $convert.base64Decode('ChVHZXROZXdBZGRyZXNzUmVzcG9uc2USGAoHYWRkcmVzcxgBIAEoCVIHYWRkcmVzcw==');

@$core.Deprecated('Use getWalletInfoRequestDescriptor instead')
const GetWalletInfoRequest$json = {
  '1': 'GetWalletInfoRequest',
  '2': [
    {'1': 'wallet', '3': 1, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `GetWalletInfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getWalletInfoRequestDescriptor =
    $convert.base64Decode('ChRHZXRXYWxsZXRJbmZvUmVxdWVzdBIWCgZ3YWxsZXQYASABKAlSBndhbGxldA==');

@$core.Deprecated('Use getWalletInfoResponseDescriptor instead')
const GetWalletInfoResponse$json = {
  '1': 'GetWalletInfoResponse',
  '2': [
    {'1': 'wallet_name', '3': 1, '4': 1, '5': 9, '10': 'walletName'},
    {'1': 'wallet_version', '3': 2, '4': 1, '5': 3, '10': 'walletVersion'},
    {'1': 'format', '3': 3, '4': 1, '5': 9, '10': 'format'},
    {'1': 'tx_count', '3': 7, '4': 1, '5': 3, '10': 'txCount'},
    {'1': 'key_pool_size', '3': 8, '4': 1, '5': 3, '10': 'keyPoolSize'},
    {'1': 'key_pool_size_hd_internal', '3': 9, '4': 1, '5': 3, '10': 'keyPoolSizeHdInternal'},
    {'1': 'pay_tx_fee', '3': 10, '4': 1, '5': 1, '10': 'payTxFee'},
    {'1': 'private_keys_enabled', '3': 11, '4': 1, '5': 8, '10': 'privateKeysEnabled'},
    {'1': 'avoid_reuse', '3': 12, '4': 1, '5': 8, '10': 'avoidReuse'},
    {'1': 'scanning', '3': 13, '4': 1, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.WalletScan', '10': 'scanning'},
    {'1': 'descriptors', '3': 14, '4': 1, '5': 8, '10': 'descriptors'},
    {'1': 'external_signer', '3': 15, '4': 1, '5': 8, '10': 'externalSigner'},
  ],
};

/// Descriptor for `GetWalletInfoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getWalletInfoResponseDescriptor =
    $convert.base64Decode('ChVHZXRXYWxsZXRJbmZvUmVzcG9uc2USHwoLd2FsbGV0X25hbWUYASABKAlSCndhbGxldE5hbW'
        'USJQoOd2FsbGV0X3ZlcnNpb24YAiABKANSDXdhbGxldFZlcnNpb24SFgoGZm9ybWF0GAMgASgJ'
        'UgZmb3JtYXQSGQoIdHhfY291bnQYByABKANSB3R4Q291bnQSIgoNa2V5X3Bvb2xfc2l6ZRgIIA'
        'EoA1ILa2V5UG9vbFNpemUSOAoZa2V5X3Bvb2xfc2l6ZV9oZF9pbnRlcm5hbBgJIAEoA1IVa2V5'
        'UG9vbFNpemVIZEludGVybmFsEhwKCnBheV90eF9mZWUYCiABKAFSCHBheVR4RmVlEjAKFHByaX'
        'ZhdGVfa2V5c19lbmFibGVkGAsgASgIUhJwcml2YXRlS2V5c0VuYWJsZWQSHwoLYXZvaWRfcmV1'
        'c2UYDCABKAhSCmF2b2lkUmV1c2USQAoIc2Nhbm5pbmcYDSABKAsyJC5iaXRjb2luLmJpdGNvaW'
        '5kLnYxYWxwaGEuV2FsbGV0U2NhblIIc2Nhbm5pbmcSIAoLZGVzY3JpcHRvcnMYDiABKAhSC2Rl'
        'c2NyaXB0b3JzEicKD2V4dGVybmFsX3NpZ25lchgPIAEoCFIOZXh0ZXJuYWxTaWduZXI=');

@$core.Deprecated('Use getBalancesRequestDescriptor instead')
const GetBalancesRequest$json = {
  '1': 'GetBalancesRequest',
  '2': [
    {'1': 'wallet', '3': 1, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `GetBalancesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBalancesRequestDescriptor =
    $convert.base64Decode('ChJHZXRCYWxhbmNlc1JlcXVlc3QSFgoGd2FsbGV0GAEgASgJUgZ3YWxsZXQ=');

@$core.Deprecated('Use getBalancesResponseDescriptor instead')
const GetBalancesResponse$json = {
  '1': 'GetBalancesResponse',
  '2': [
    {'1': 'mine', '3': 1, '4': 1, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.GetBalancesResponse.Mine', '10': 'mine'},
    {
      '1': 'watchonly',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.bitcoin.bitcoind.v1alpha.GetBalancesResponse.Watchonly',
      '10': 'watchonly'
    },
  ],
  '3': [GetBalancesResponse_Mine$json, GetBalancesResponse_Watchonly$json],
};

@$core.Deprecated('Use getBalancesResponseDescriptor instead')
const GetBalancesResponse_Mine$json = {
  '1': 'Mine',
  '2': [
    {'1': 'trusted', '3': 1, '4': 1, '5': 1, '10': 'trusted'},
    {'1': 'untrusted_pending', '3': 2, '4': 1, '5': 1, '10': 'untrustedPending'},
    {'1': 'immature', '3': 3, '4': 1, '5': 1, '10': 'immature'},
    {'1': 'used', '3': 4, '4': 1, '5': 1, '10': 'used'},
  ],
};

@$core.Deprecated('Use getBalancesResponseDescriptor instead')
const GetBalancesResponse_Watchonly$json = {
  '1': 'Watchonly',
  '2': [
    {'1': 'trusted', '3': 1, '4': 1, '5': 1, '10': 'trusted'},
    {'1': 'untrusted_pending', '3': 2, '4': 1, '5': 1, '10': 'untrustedPending'},
    {'1': 'immature', '3': 3, '4': 1, '5': 1, '10': 'immature'},
  ],
};

/// Descriptor for `GetBalancesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBalancesResponseDescriptor =
    $convert.base64Decode('ChNHZXRCYWxhbmNlc1Jlc3BvbnNlEkYKBG1pbmUYASABKAsyMi5iaXRjb2luLmJpdGNvaW5kLn'
        'YxYWxwaGEuR2V0QmFsYW5jZXNSZXNwb25zZS5NaW5lUgRtaW5lElUKCXdhdGNob25seRgCIAEo'
        'CzI3LmJpdGNvaW4uYml0Y29pbmQudjFhbHBoYS5HZXRCYWxhbmNlc1Jlc3BvbnNlLldhdGNob2'
        '5seVIJd2F0Y2hvbmx5Gn0KBE1pbmUSGAoHdHJ1c3RlZBgBIAEoAVIHdHJ1c3RlZBIrChF1bnRy'
        'dXN0ZWRfcGVuZGluZxgCIAEoAVIQdW50cnVzdGVkUGVuZGluZxIaCghpbW1hdHVyZRgDIAEoAV'
        'IIaW1tYXR1cmUSEgoEdXNlZBgEIAEoAVIEdXNlZBpuCglXYXRjaG9ubHkSGAoHdHJ1c3RlZBgB'
        'IAEoAVIHdHJ1c3RlZBIrChF1bnRydXN0ZWRfcGVuZGluZxgCIAEoAVIQdW50cnVzdGVkUGVuZG'
        'luZxIaCghpbW1hdHVyZRgDIAEoAVIIaW1tYXR1cmU=');

@$core.Deprecated('Use walletScanDescriptor instead')
const WalletScan$json = {
  '1': 'WalletScan',
  '2': [
    {'1': 'duration', '3': 1, '4': 1, '5': 3, '10': 'duration'},
    {'1': 'progress', '3': 2, '4': 1, '5': 1, '10': 'progress'},
  ],
};

/// Descriptor for `WalletScan`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List walletScanDescriptor =
    $convert.base64Decode('CgpXYWxsZXRTY2FuEhoKCGR1cmF0aW9uGAEgASgDUghkdXJhdGlvbhIaCghwcm9ncmVzcxgCIA'
        'EoAVIIcHJvZ3Jlc3M=');

@$core.Deprecated('Use getTransactionRequestDescriptor instead')
const GetTransactionRequest$json = {
  '1': 'GetTransactionRequest',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'include_watchonly', '3': 2, '4': 1, '5': 8, '10': 'includeWatchonly'},
    {'1': 'verbose', '3': 3, '4': 1, '5': 8, '10': 'verbose'},
    {'1': 'wallet', '3': 4, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `GetTransactionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTransactionRequestDescriptor =
    $convert.base64Decode('ChVHZXRUcmFuc2FjdGlvblJlcXVlc3QSEgoEdHhpZBgBIAEoCVIEdHhpZBIrChFpbmNsdWRlX3'
        'dhdGNob25seRgCIAEoCFIQaW5jbHVkZVdhdGNob25seRIYCgd2ZXJib3NlGAMgASgIUgd2ZXJi'
        'b3NlEhYKBndhbGxldBgEIAEoCVIGd2FsbGV0');

@$core.Deprecated('Use getTransactionResponseDescriptor instead')
const GetTransactionResponse$json = {
  '1': 'GetTransactionResponse',
  '2': [
    {'1': 'amount', '3': 1, '4': 1, '5': 1, '10': 'amount'},
    {'1': 'fee', '3': 2, '4': 1, '5': 1, '10': 'fee'},
    {'1': 'confirmations', '3': 3, '4': 1, '5': 5, '10': 'confirmations'},
    {'1': 'block_hash', '3': 6, '4': 1, '5': 9, '10': 'blockHash'},
    {'1': 'block_index', '3': 8, '4': 1, '5': 13, '10': 'blockIndex'},
    {'1': 'block_time', '3': 9, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'blockTime'},
    {'1': 'txid', '3': 10, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'wallet_conflicts', '3': 12, '4': 3, '5': 9, '10': 'walletConflicts'},
    {'1': 'replaced_by_txid', '3': 13, '4': 1, '5': 9, '10': 'replacedByTxid'},
    {'1': 'replaces_txid', '3': 14, '4': 1, '5': 9, '10': 'replacesTxid'},
    {'1': 'time', '3': 17, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'time'},
    {'1': 'time_received', '3': 18, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'timeReceived'},
    {
      '1': 'bip125_replaceable',
      '3': 19,
      '4': 1,
      '5': 14,
      '6': '.bitcoin.bitcoind.v1alpha.GetTransactionResponse.Replaceable',
      '10': 'bip125Replaceable'
    },
    {
      '1': 'details',
      '3': 21,
      '4': 3,
      '5': 11,
      '6': '.bitcoin.bitcoind.v1alpha.GetTransactionResponse.Details',
      '10': 'details'
    },
    {'1': 'hex', '3': 22, '4': 1, '5': 9, '10': 'hex'},
  ],
  '3': [GetTransactionResponse_Details$json],
  '4': [GetTransactionResponse_Replaceable$json, GetTransactionResponse_Category$json],
};

@$core.Deprecated('Use getTransactionResponseDescriptor instead')
const GetTransactionResponse_Details$json = {
  '1': 'Details',
  '2': [
    {'1': 'involves_watch_only', '3': 1, '4': 1, '5': 8, '10': 'involvesWatchOnly'},
    {'1': 'address', '3': 2, '4': 1, '5': 9, '10': 'address'},
    {
      '1': 'category',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.bitcoin.bitcoind.v1alpha.GetTransactionResponse.Category',
      '10': 'category'
    },
    {'1': 'amount', '3': 4, '4': 1, '5': 1, '10': 'amount'},
    {'1': 'vout', '3': 6, '4': 1, '5': 13, '10': 'vout'},
    {'1': 'fee', '3': 7, '4': 1, '5': 1, '10': 'fee'},
  ],
};

@$core.Deprecated('Use getTransactionResponseDescriptor instead')
const GetTransactionResponse_Replaceable$json = {
  '1': 'Replaceable',
  '2': [
    {'1': 'REPLACEABLE_UNSPECIFIED', '2': 0},
    {'1': 'REPLACEABLE_YES', '2': 1},
    {'1': 'REPLACEABLE_NO', '2': 2},
  ],
};

@$core.Deprecated('Use getTransactionResponseDescriptor instead')
const GetTransactionResponse_Category$json = {
  '1': 'Category',
  '2': [
    {'1': 'CATEGORY_UNSPECIFIED', '2': 0},
    {'1': 'CATEGORY_SEND', '2': 1},
    {'1': 'CATEGORY_RECEIVE', '2': 2},
    {'1': 'CATEGORY_GENERATE', '2': 3},
    {'1': 'CATEGORY_IMMATURE', '2': 4},
    {'1': 'CATEGORY_ORPHAN', '2': 5},
  ],
};

/// Descriptor for `GetTransactionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTransactionResponseDescriptor =
    $convert.base64Decode('ChZHZXRUcmFuc2FjdGlvblJlc3BvbnNlEhYKBmFtb3VudBgBIAEoAVIGYW1vdW50EhAKA2ZlZR'
        'gCIAEoAVIDZmVlEiQKDWNvbmZpcm1hdGlvbnMYAyABKAVSDWNvbmZpcm1hdGlvbnMSHQoKYmxv'
        'Y2tfaGFzaBgGIAEoCVIJYmxvY2tIYXNoEh8KC2Jsb2NrX2luZGV4GAggASgNUgpibG9ja0luZG'
        'V4EjkKCmJsb2NrX3RpbWUYCSABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUglibG9j'
        'a1RpbWUSEgoEdHhpZBgKIAEoCVIEdHhpZBIpChB3YWxsZXRfY29uZmxpY3RzGAwgAygJUg93YW'
        'xsZXRDb25mbGljdHMSKAoQcmVwbGFjZWRfYnlfdHhpZBgNIAEoCVIOcmVwbGFjZWRCeVR4aWQS'
        'IwoNcmVwbGFjZXNfdHhpZBgOIAEoCVIMcmVwbGFjZXNUeGlkEi4KBHRpbWUYESABKAsyGi5nb2'
        '9nbGUucHJvdG9idWYuVGltZXN0YW1wUgR0aW1lEj8KDXRpbWVfcmVjZWl2ZWQYEiABKAsyGi5n'
        'b29nbGUucHJvdG9idWYuVGltZXN0YW1wUgx0aW1lUmVjZWl2ZWQSawoSYmlwMTI1X3JlcGxhY2'
        'VhYmxlGBMgASgOMjwuYml0Y29pbi5iaXRjb2luZC52MWFscGhhLkdldFRyYW5zYWN0aW9uUmVz'
        'cG9uc2UuUmVwbGFjZWFibGVSEWJpcDEyNVJlcGxhY2VhYmxlElIKB2RldGFpbHMYFSADKAsyOC'
        '5iaXRjb2luLmJpdGNvaW5kLnYxYWxwaGEuR2V0VHJhbnNhY3Rpb25SZXNwb25zZS5EZXRhaWxz'
        'UgdkZXRhaWxzEhAKA2hleBgWIAEoCVIDaGV4GugBCgdEZXRhaWxzEi4KE2ludm9sdmVzX3dhdG'
        'NoX29ubHkYASABKAhSEWludm9sdmVzV2F0Y2hPbmx5EhgKB2FkZHJlc3MYAiABKAlSB2FkZHJl'
        'c3MSVQoIY2F0ZWdvcnkYAyABKA4yOS5iaXRjb2luLmJpdGNvaW5kLnYxYWxwaGEuR2V0VHJhbn'
        'NhY3Rpb25SZXNwb25zZS5DYXRlZ29yeVIIY2F0ZWdvcnkSFgoGYW1vdW50GAQgASgBUgZhbW91'
        'bnQSEgoEdm91dBgGIAEoDVIEdm91dBIQCgNmZWUYByABKAFSA2ZlZSJTCgtSZXBsYWNlYWJsZR'
        'IbChdSRVBMQUNFQUJMRV9VTlNQRUNJRklFRBAAEhMKD1JFUExBQ0VBQkxFX1lFUxABEhIKDlJF'
        'UExBQ0VBQkxFX05PEAIikAEKCENhdGVnb3J5EhgKFENBVEVHT1JZX1VOU1BFQ0lGSUVEEAASEQ'
        'oNQ0FURUdPUllfU0VORBABEhQKEENBVEVHT1JZX1JFQ0VJVkUQAhIVChFDQVRFR09SWV9HRU5F'
        'UkFURRADEhUKEUNBVEVHT1JZX0lNTUFUVVJFEAQSEwoPQ0FURUdPUllfT1JQSEFOEAU=');

@$core.Deprecated('Use getRawTransactionRequestDescriptor instead')
const GetRawTransactionRequest$json = {
  '1': 'GetRawTransactionRequest',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'verbose', '3': 2, '4': 1, '5': 8, '10': 'verbose'},
  ],
};

/// Descriptor for `GetRawTransactionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRawTransactionRequestDescriptor =
    $convert.base64Decode('ChhHZXRSYXdUcmFuc2FjdGlvblJlcXVlc3QSEgoEdHhpZBgBIAEoCVIEdHhpZBIYCgd2ZXJib3'
        'NlGAIgASgIUgd2ZXJib3Nl');

@$core.Deprecated('Use scriptSigDescriptor instead')
const ScriptSig$json = {
  '1': 'ScriptSig',
  '2': [
    {'1': 'asm', '3': 1, '4': 1, '5': 9, '10': 'asm'},
    {'1': 'hex', '3': 2, '4': 1, '5': 9, '10': 'hex'},
  ],
};

/// Descriptor for `ScriptSig`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List scriptSigDescriptor =
    $convert.base64Decode('CglTY3JpcHRTaWcSEAoDYXNtGAEgASgJUgNhc20SEAoDaGV4GAIgASgJUgNoZXg=');

@$core.Deprecated('Use inputDescriptor instead')
const Input$json = {
  '1': 'Input',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'vout', '3': 2, '4': 1, '5': 13, '10': 'vout'},
    {'1': 'coinbase', '3': 3, '4': 1, '5': 9, '10': 'coinbase'},
    {'1': 'script_sig', '3': 4, '4': 1, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.ScriptSig', '10': 'scriptSig'},
    {'1': 'sequence', '3': 5, '4': 1, '5': 13, '10': 'sequence'},
    {'1': 'witness', '3': 6, '4': 3, '5': 9, '10': 'witness'},
  ],
};

/// Descriptor for `Input`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List inputDescriptor =
    $convert.base64Decode('CgVJbnB1dBISCgR0eGlkGAEgASgJUgR0eGlkEhIKBHZvdXQYAiABKA1SBHZvdXQSGgoIY29pbm'
        'Jhc2UYAyABKAlSCGNvaW5iYXNlEkIKCnNjcmlwdF9zaWcYBCABKAsyIy5iaXRjb2luLmJpdGNv'
        'aW5kLnYxYWxwaGEuU2NyaXB0U2lnUglzY3JpcHRTaWcSGgoIc2VxdWVuY2UYBSABKA1SCHNlcX'
        'VlbmNlEhgKB3dpdG5lc3MYBiADKAlSB3dpdG5lc3M=');

@$core.Deprecated('Use scriptPubKeyDescriptor instead')
const ScriptPubKey$json = {
  '1': 'ScriptPubKey',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 9, '10': 'type'},
    {'1': 'address', '3': 2, '4': 1, '5': 9, '10': 'address'},
    {'1': 'asm', '3': 3, '4': 1, '5': 9, '10': 'asm'},
    {'1': 'hex', '3': 4, '4': 1, '5': 9, '10': 'hex'},
    {'1': 'addresses', '3': 5, '4': 3, '5': 9, '10': 'addresses'},
    {'1': 'req_sigs', '3': 6, '4': 1, '5': 13, '10': 'reqSigs'},
  ],
};

/// Descriptor for `ScriptPubKey`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List scriptPubKeyDescriptor =
    $convert.base64Decode('CgxTY3JpcHRQdWJLZXkSEgoEdHlwZRgBIAEoCVIEdHlwZRIYCgdhZGRyZXNzGAIgASgJUgdhZG'
        'RyZXNzEhAKA2FzbRgDIAEoCVIDYXNtEhAKA2hleBgEIAEoCVIDaGV4EhwKCWFkZHJlc3NlcxgF'
        'IAMoCVIJYWRkcmVzc2VzEhkKCHJlcV9zaWdzGAYgASgNUgdyZXFTaWdz');

@$core.Deprecated('Use outputDescriptor instead')
const Output$json = {
  '1': 'Output',
  '2': [
    {'1': 'amount', '3': 1, '4': 1, '5': 1, '10': 'amount'},
    {'1': 'vout', '3': 2, '4': 1, '5': 13, '10': 'vout'},
    {
      '1': 'script_pub_key',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.bitcoin.bitcoind.v1alpha.ScriptPubKey',
      '10': 'scriptPubKey'
    },
    {'1': 'script_sig', '3': 4, '4': 1, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.ScriptSig', '10': 'scriptSig'},
  ],
};

/// Descriptor for `Output`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List outputDescriptor =
    $convert.base64Decode('CgZPdXRwdXQSFgoGYW1vdW50GAEgASgBUgZhbW91bnQSEgoEdm91dBgCIAEoDVIEdm91dBJMCg'
        '5zY3JpcHRfcHViX2tleRgDIAEoCzImLmJpdGNvaW4uYml0Y29pbmQudjFhbHBoYS5TY3JpcHRQ'
        'dWJLZXlSDHNjcmlwdFB1YktleRJCCgpzY3JpcHRfc2lnGAQgASgLMiMuYml0Y29pbi5iaXRjb2'
        'luZC52MWFscGhhLlNjcmlwdFNpZ1IJc2NyaXB0U2ln');

@$core.Deprecated('Use getRawTransactionResponseDescriptor instead')
const GetRawTransactionResponse$json = {
  '1': 'GetRawTransactionResponse',
  '2': [
    {'1': 'tx', '3': 1, '4': 1, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.RawTransaction', '10': 'tx'},
    {'1': 'txid', '3': 8, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'hash', '3': 9, '4': 1, '5': 9, '10': 'hash'},
    {'1': 'size', '3': 10, '4': 1, '5': 5, '10': 'size'},
    {'1': 'vsize', '3': 11, '4': 1, '5': 5, '10': 'vsize'},
    {'1': 'weight', '3': 12, '4': 1, '5': 5, '10': 'weight'},
    {'1': 'version', '3': 13, '4': 1, '5': 13, '10': 'version'},
    {'1': 'locktime', '3': 14, '4': 1, '5': 13, '10': 'locktime'},
    {'1': 'inputs', '3': 2, '4': 3, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.Input', '10': 'inputs'},
    {'1': 'outputs', '3': 3, '4': 3, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.Output', '10': 'outputs'},
    {'1': 'blockhash', '3': 4, '4': 1, '5': 9, '10': 'blockhash'},
    {'1': 'confirmations', '3': 5, '4': 1, '5': 13, '10': 'confirmations'},
    {'1': 'time', '3': 6, '4': 1, '5': 3, '10': 'time'},
    {'1': 'blocktime', '3': 7, '4': 1, '5': 3, '10': 'blocktime'},
  ],
};

/// Descriptor for `GetRawTransactionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRawTransactionResponseDescriptor =
    $convert.base64Decode('ChlHZXRSYXdUcmFuc2FjdGlvblJlc3BvbnNlEjgKAnR4GAEgASgLMiguYml0Y29pbi5iaXRjb2'
        'luZC52MWFscGhhLlJhd1RyYW5zYWN0aW9uUgJ0eBISCgR0eGlkGAggASgJUgR0eGlkEhIKBGhh'
        'c2gYCSABKAlSBGhhc2gSEgoEc2l6ZRgKIAEoBVIEc2l6ZRIUCgV2c2l6ZRgLIAEoBVIFdnNpem'
        'USFgoGd2VpZ2h0GAwgASgFUgZ3ZWlnaHQSGAoHdmVyc2lvbhgNIAEoDVIHdmVyc2lvbhIaCghs'
        'b2NrdGltZRgOIAEoDVIIbG9ja3RpbWUSNwoGaW5wdXRzGAIgAygLMh8uYml0Y29pbi5iaXRjb2'
        'luZC52MWFscGhhLklucHV0UgZpbnB1dHMSOgoHb3V0cHV0cxgDIAMoCzIgLmJpdGNvaW4uYml0'
        'Y29pbmQudjFhbHBoYS5PdXRwdXRSB291dHB1dHMSHAoJYmxvY2toYXNoGAQgASgJUglibG9ja2'
        'hhc2gSJAoNY29uZmlybWF0aW9ucxgFIAEoDVINY29uZmlybWF0aW9ucxISCgR0aW1lGAYgASgD'
        'UgR0aW1lEhwKCWJsb2NrdGltZRgHIAEoA1IJYmxvY2t0aW1l');

@$core.Deprecated('Use sendRequestDescriptor instead')
const SendRequest$json = {
  '1': 'SendRequest',
  '2': [
    {
      '1': 'destinations',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.bitcoin.bitcoind.v1alpha.SendRequest.DestinationsEntry',
      '10': 'destinations'
    },
    {'1': 'conf_target', '3': 2, '4': 1, '5': 13, '10': 'confTarget'},
    {'1': 'wallet', '3': 3, '4': 1, '5': 9, '10': 'wallet'},
    {'1': 'include_unsafe', '3': 4, '4': 1, '5': 8, '10': 'includeUnsafe'},
    {'1': 'subtract_fee_from_outputs', '3': 5, '4': 3, '5': 9, '10': 'subtractFeeFromOutputs'},
    {'1': 'add_to_wallet', '3': 6, '4': 1, '5': 11, '6': '.google.protobuf.BoolValue', '10': 'addToWallet'},
    {'1': 'fee_rate', '3': 7, '4': 1, '5': 1, '10': 'feeRate'},
  ],
  '3': [SendRequest_DestinationsEntry$json],
};

@$core.Deprecated('Use sendRequestDescriptor instead')
const SendRequest_DestinationsEntry$json = {
  '1': 'DestinationsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 1, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `SendRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendRequestDescriptor =
    $convert.base64Decode('CgtTZW5kUmVxdWVzdBJbCgxkZXN0aW5hdGlvbnMYASADKAsyNy5iaXRjb2luLmJpdGNvaW5kLn'
        'YxYWxwaGEuU2VuZFJlcXVlc3QuRGVzdGluYXRpb25zRW50cnlSDGRlc3RpbmF0aW9ucxIfCgtj'
        'b25mX3RhcmdldBgCIAEoDVIKY29uZlRhcmdldBIWCgZ3YWxsZXQYAyABKAlSBndhbGxldBIlCg'
        '5pbmNsdWRlX3Vuc2FmZRgEIAEoCFINaW5jbHVkZVVuc2FmZRI5ChlzdWJ0cmFjdF9mZWVfZnJv'
        'bV9vdXRwdXRzGAUgAygJUhZzdWJ0cmFjdEZlZUZyb21PdXRwdXRzEj4KDWFkZF90b193YWxsZX'
        'QYBiABKAsyGi5nb29nbGUucHJvdG9idWYuQm9vbFZhbHVlUgthZGRUb1dhbGxldBIZCghmZWVf'
        'cmF0ZRgHIAEoAVIHZmVlUmF0ZRo/ChFEZXN0aW5hdGlvbnNFbnRyeRIQCgNrZXkYASABKAlSA2'
        'tleRIUCgV2YWx1ZRgCIAEoAVIFdmFsdWU6AjgB');

@$core.Deprecated('Use sendResponseDescriptor instead')
const SendResponse$json = {
  '1': 'SendResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'complete', '3': 2, '4': 1, '5': 8, '10': 'complete'},
    {'1': 'tx', '3': 3, '4': 1, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.RawTransaction', '10': 'tx'},
  ],
};

/// Descriptor for `SendResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendResponseDescriptor =
    $convert.base64Decode('CgxTZW5kUmVzcG9uc2USEgoEdHhpZBgBIAEoCVIEdHhpZBIaCghjb21wbGV0ZRgCIAEoCFIIY2'
        '9tcGxldGUSOAoCdHgYAyABKAsyKC5iaXRjb2luLmJpdGNvaW5kLnYxYWxwaGEuUmF3VHJhbnNh'
        'Y3Rpb25SAnR4');

@$core.Deprecated('Use sendToAddressRequestDescriptor instead')
const SendToAddressRequest$json = {
  '1': 'SendToAddressRequest',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'amount', '3': 2, '4': 1, '5': 1, '10': 'amount'},
    {'1': 'comment', '3': 3, '4': 1, '5': 9, '10': 'comment'},
    {'1': 'comment_to', '3': 4, '4': 1, '5': 9, '10': 'commentTo'},
    {'1': 'wallet', '3': 5, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `SendToAddressRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendToAddressRequestDescriptor =
    $convert.base64Decode('ChRTZW5kVG9BZGRyZXNzUmVxdWVzdBIYCgdhZGRyZXNzGAEgASgJUgdhZGRyZXNzEhYKBmFtb3'
        'VudBgCIAEoAVIGYW1vdW50EhgKB2NvbW1lbnQYAyABKAlSB2NvbW1lbnQSHQoKY29tbWVudF90'
        'bxgEIAEoCVIJY29tbWVudFRvEhYKBndhbGxldBgFIAEoCVIGd2FsbGV0');

@$core.Deprecated('Use sendToAddressResponseDescriptor instead')
const SendToAddressResponse$json = {
  '1': 'SendToAddressResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `SendToAddressResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendToAddressResponseDescriptor =
    $convert.base64Decode('ChVTZW5kVG9BZGRyZXNzUmVzcG9uc2USEgoEdHhpZBgBIAEoCVIEdHhpZA==');

@$core.Deprecated('Use estimateSmartFeeRequestDescriptor instead')
const EstimateSmartFeeRequest$json = {
  '1': 'EstimateSmartFeeRequest',
  '2': [
    {'1': 'conf_target', '3': 1, '4': 1, '5': 3, '10': 'confTarget'},
    {
      '1': 'estimate_mode',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.bitcoin.bitcoind.v1alpha.EstimateSmartFeeRequest.EstimateMode',
      '10': 'estimateMode'
    },
  ],
  '4': [EstimateSmartFeeRequest_EstimateMode$json],
};

@$core.Deprecated('Use estimateSmartFeeRequestDescriptor instead')
const EstimateSmartFeeRequest_EstimateMode$json = {
  '1': 'EstimateMode',
  '2': [
    {'1': 'ESTIMATE_MODE_UNSPECIFIED', '2': 0},
    {'1': 'ESTIMATE_MODE_ECONOMICAL', '2': 1},
    {'1': 'ESTIMATE_MODE_CONSERVATIVE', '2': 2},
  ],
};

/// Descriptor for `EstimateSmartFeeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List estimateSmartFeeRequestDescriptor =
    $convert.base64Decode('ChdFc3RpbWF0ZVNtYXJ0RmVlUmVxdWVzdBIfCgtjb25mX3RhcmdldBgBIAEoA1IKY29uZlRhcm'
        'dldBJjCg1lc3RpbWF0ZV9tb2RlGAIgASgOMj4uYml0Y29pbi5iaXRjb2luZC52MWFscGhhLkVz'
        'dGltYXRlU21hcnRGZWVSZXF1ZXN0LkVzdGltYXRlTW9kZVIMZXN0aW1hdGVNb2RlImsKDEVzdG'
        'ltYXRlTW9kZRIdChlFU1RJTUFURV9NT0RFX1VOU1BFQ0lGSUVEEAASHAoYRVNUSU1BVEVfTU9E'
        'RV9FQ09OT01JQ0FMEAESHgoaRVNUSU1BVEVfTU9ERV9DT05TRVJWQVRJVkUQAg==');

@$core.Deprecated('Use estimateSmartFeeResponseDescriptor instead')
const EstimateSmartFeeResponse$json = {
  '1': 'EstimateSmartFeeResponse',
  '2': [
    {'1': 'fee_rate', '3': 1, '4': 1, '5': 1, '10': 'feeRate'},
    {'1': 'errors', '3': 2, '4': 3, '5': 9, '10': 'errors'},
    {'1': 'blocks', '3': 3, '4': 1, '5': 3, '10': 'blocks'},
  ],
};

/// Descriptor for `EstimateSmartFeeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List estimateSmartFeeResponseDescriptor =
    $convert.base64Decode('ChhFc3RpbWF0ZVNtYXJ0RmVlUmVzcG9uc2USGQoIZmVlX3JhdGUYASABKAFSB2ZlZVJhdGUSFg'
        'oGZXJyb3JzGAIgAygJUgZlcnJvcnMSFgoGYmxvY2tzGAMgASgDUgZibG9ja3M=');

@$core.Deprecated('Use decodeRawTransactionRequestDescriptor instead')
const DecodeRawTransactionRequest$json = {
  '1': 'DecodeRawTransactionRequest',
  '2': [
    {'1': 'tx', '3': 1, '4': 1, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.RawTransaction', '10': 'tx'},
  ],
};

/// Descriptor for `DecodeRawTransactionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List decodeRawTransactionRequestDescriptor =
    $convert.base64Decode('ChtEZWNvZGVSYXdUcmFuc2FjdGlvblJlcXVlc3QSOAoCdHgYASABKAsyKC5iaXRjb2luLmJpdG'
        'NvaW5kLnYxYWxwaGEuUmF3VHJhbnNhY3Rpb25SAnR4');

@$core.Deprecated('Use rawTransactionDescriptor instead')
const RawTransaction$json = {
  '1': 'RawTransaction',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 12, '10': 'data'},
    {'1': 'hex', '3': 2, '4': 1, '5': 9, '10': 'hex'},
  ],
};

/// Descriptor for `RawTransaction`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rawTransactionDescriptor =
    $convert.base64Decode('Cg5SYXdUcmFuc2FjdGlvbhISCgRkYXRhGAEgASgMUgRkYXRhEhAKA2hleBgCIAEoCVIDaGV4');

@$core.Deprecated('Use decodeRawTransactionResponseDescriptor instead')
const DecodeRawTransactionResponse$json = {
  '1': 'DecodeRawTransactionResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'hash', '3': 2, '4': 1, '5': 9, '10': 'hash'},
    {'1': 'size', '3': 3, '4': 1, '5': 13, '10': 'size'},
    {'1': 'virtual_size', '3': 4, '4': 1, '5': 13, '10': 'virtualSize'},
    {'1': 'weight', '3': 5, '4': 1, '5': 13, '10': 'weight'},
    {'1': 'version', '3': 6, '4': 1, '5': 13, '10': 'version'},
    {'1': 'locktime', '3': 7, '4': 1, '5': 13, '10': 'locktime'},
    {'1': 'inputs', '3': 8, '4': 3, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.Input', '10': 'inputs'},
    {'1': 'outputs', '3': 9, '4': 3, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.Output', '10': 'outputs'},
  ],
};

/// Descriptor for `DecodeRawTransactionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List decodeRawTransactionResponseDescriptor =
    $convert.base64Decode('ChxEZWNvZGVSYXdUcmFuc2FjdGlvblJlc3BvbnNlEhIKBHR4aWQYASABKAlSBHR4aWQSEgoEaG'
        'FzaBgCIAEoCVIEaGFzaBISCgRzaXplGAMgASgNUgRzaXplEiEKDHZpcnR1YWxfc2l6ZRgEIAEo'
        'DVILdmlydHVhbFNpemUSFgoGd2VpZ2h0GAUgASgNUgZ3ZWlnaHQSGAoHdmVyc2lvbhgGIAEoDV'
        'IHdmVyc2lvbhIaCghsb2NrdGltZRgHIAEoDVIIbG9ja3RpbWUSNwoGaW5wdXRzGAggAygLMh8u'
        'Yml0Y29pbi5iaXRjb2luZC52MWFscGhhLklucHV0UgZpbnB1dHMSOgoHb3V0cHV0cxgJIAMoCz'
        'IgLmJpdGNvaW4uYml0Y29pbmQudjFhbHBoYS5PdXRwdXRSB291dHB1dHM=');

@$core.Deprecated('Use importDescriptorsRequestDescriptor instead')
const ImportDescriptorsRequest$json = {
  '1': 'ImportDescriptorsRequest',
  '2': [
    {'1': 'wallet', '3': 1, '4': 1, '5': 9, '10': 'wallet'},
    {
      '1': 'requests',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.bitcoin.bitcoind.v1alpha.ImportDescriptorsRequest.Request',
      '10': 'requests'
    },
  ],
  '3': [ImportDescriptorsRequest_Request$json],
};

@$core.Deprecated('Use importDescriptorsRequestDescriptor instead')
const ImportDescriptorsRequest_Request$json = {
  '1': 'Request',
  '2': [
    {'1': 'descriptor', '3': 1, '4': 1, '5': 9, '10': 'descriptor'},
    {'1': 'active', '3': 2, '4': 1, '5': 8, '10': 'active'},
    {'1': 'range_start', '3': 3, '4': 1, '5': 13, '10': 'rangeStart'},
    {'1': 'range_end', '3': 4, '4': 1, '5': 13, '10': 'rangeEnd'},
    {'1': 'timestamp', '3': 5, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'timestamp'},
    {'1': 'internal', '3': 6, '4': 1, '5': 8, '10': 'internal'},
    {'1': 'label', '3': 7, '4': 1, '5': 9, '10': 'label'},
  ],
};

/// Descriptor for `ImportDescriptorsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importDescriptorsRequestDescriptor =
    $convert.base64Decode('ChhJbXBvcnREZXNjcmlwdG9yc1JlcXVlc3QSFgoGd2FsbGV0GAEgASgJUgZ3YWxsZXQSVgoIcm'
        'VxdWVzdHMYAiADKAsyOi5iaXRjb2luLmJpdGNvaW5kLnYxYWxwaGEuSW1wb3J0RGVzY3JpcHRv'
        'cnNSZXF1ZXN0LlJlcXVlc3RSCHJlcXVlc3RzGusBCgdSZXF1ZXN0Eh4KCmRlc2NyaXB0b3IYAS'
        'ABKAlSCmRlc2NyaXB0b3ISFgoGYWN0aXZlGAIgASgIUgZhY3RpdmUSHwoLcmFuZ2Vfc3RhcnQY'
        'AyABKA1SCnJhbmdlU3RhcnQSGwoJcmFuZ2VfZW5kGAQgASgNUghyYW5nZUVuZBI4Cgl0aW1lc3'
        'RhbXAYBSABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl0aW1lc3RhbXASGgoIaW50'
        'ZXJuYWwYBiABKAhSCGludGVybmFsEhQKBWxhYmVsGAcgASgJUgVsYWJlbA==');

@$core.Deprecated('Use importDescriptorsResponseDescriptor instead')
const ImportDescriptorsResponse$json = {
  '1': 'ImportDescriptorsResponse',
  '2': [
    {
      '1': 'responses',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.bitcoin.bitcoind.v1alpha.ImportDescriptorsResponse.Response',
      '10': 'responses'
    },
  ],
  '3': [ImportDescriptorsResponse_Error$json, ImportDescriptorsResponse_Response$json],
};

@$core.Deprecated('Use importDescriptorsResponseDescriptor instead')
const ImportDescriptorsResponse_Error$json = {
  '1': 'Error',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

@$core.Deprecated('Use importDescriptorsResponseDescriptor instead')
const ImportDescriptorsResponse_Response$json = {
  '1': 'Response',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'warnings', '3': 2, '4': 3, '5': 9, '10': 'warnings'},
    {
      '1': 'error',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.bitcoin.bitcoind.v1alpha.ImportDescriptorsResponse.Error',
      '10': 'error'
    },
  ],
};

/// Descriptor for `ImportDescriptorsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importDescriptorsResponseDescriptor =
    $convert.base64Decode('ChlJbXBvcnREZXNjcmlwdG9yc1Jlc3BvbnNlEloKCXJlc3BvbnNlcxgBIAMoCzI8LmJpdGNvaW'
        '4uYml0Y29pbmQudjFhbHBoYS5JbXBvcnREZXNjcmlwdG9yc1Jlc3BvbnNlLlJlc3BvbnNlUgly'
        'ZXNwb25zZXMaNQoFRXJyb3ISEgoEY29kZRgBIAEoBVIEY29kZRIYCgdtZXNzYWdlGAIgASgJUg'
        'dtZXNzYWdlGpEBCghSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEhoKCHdhcm5p'
        'bmdzGAIgAygJUgh3YXJuaW5ncxJPCgVlcnJvchgDIAEoCzI5LmJpdGNvaW4uYml0Y29pbmQudj'
        'FhbHBoYS5JbXBvcnREZXNjcmlwdG9yc1Jlc3BvbnNlLkVycm9yUgVlcnJvcg==');

@$core.Deprecated('Use getDescriptorInfoRequestDescriptor instead')
const GetDescriptorInfoRequest$json = {
  '1': 'GetDescriptorInfoRequest',
  '2': [
    {'1': 'descriptor', '3': 1, '4': 1, '5': 9, '10': 'descriptor'},
  ],
};

/// Descriptor for `GetDescriptorInfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDescriptorInfoRequestDescriptor =
    $convert.base64Decode('ChhHZXREZXNjcmlwdG9ySW5mb1JlcXVlc3QSHgoKZGVzY3JpcHRvchgBIAEoCVIKZGVzY3JpcH'
        'Rvcg==');

@$core.Deprecated('Use getDescriptorInfoResponseDescriptor instead')
const GetDescriptorInfoResponse$json = {
  '1': 'GetDescriptorInfoResponse',
  '2': [
    {'1': 'descriptor', '3': 1, '4': 1, '5': 9, '10': 'descriptor'},
    {'1': 'checksum', '3': 2, '4': 1, '5': 9, '10': 'checksum'},
    {'1': 'is_range', '3': 3, '4': 1, '5': 8, '10': 'isRange'},
    {'1': 'is_solvable', '3': 4, '4': 1, '5': 8, '10': 'isSolvable'},
    {'1': 'has_private_keys', '3': 5, '4': 1, '5': 8, '10': 'hasPrivateKeys'},
  ],
};

/// Descriptor for `GetDescriptorInfoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDescriptorInfoResponseDescriptor =
    $convert.base64Decode('ChlHZXREZXNjcmlwdG9ySW5mb1Jlc3BvbnNlEh4KCmRlc2NyaXB0b3IYASABKAlSCmRlc2NyaX'
        'B0b3ISGgoIY2hlY2tzdW0YAiABKAlSCGNoZWNrc3VtEhkKCGlzX3JhbmdlGAMgASgIUgdpc1Jh'
        'bmdlEh8KC2lzX3NvbHZhYmxlGAQgASgIUgppc1NvbHZhYmxlEigKEGhhc19wcml2YXRlX2tleX'
        'MYBSABKAhSDmhhc1ByaXZhdGVLZXlz');

@$core.Deprecated('Use getBlockRequestDescriptor instead')
const GetBlockRequest$json = {
  '1': 'GetBlockRequest',
  '2': [
    {'1': 'hash', '3': 1, '4': 1, '5': 9, '10': 'hash'},
    {'1': 'height', '3': 3, '4': 1, '5': 5, '9': 0, '10': 'height', '17': true},
    {
      '1': 'verbosity',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.bitcoin.bitcoind.v1alpha.GetBlockRequest.Verbosity',
      '10': 'verbosity'
    },
  ],
  '4': [GetBlockRequest_Verbosity$json],
  '8': [
    {'1': '_height'},
  ],
};

@$core.Deprecated('Use getBlockRequestDescriptor instead')
const GetBlockRequest_Verbosity$json = {
  '1': 'Verbosity',
  '2': [
    {'1': 'VERBOSITY_UNSPECIFIED', '2': 0},
    {'1': 'VERBOSITY_RAW_DATA', '2': 1},
    {'1': 'VERBOSITY_BLOCK_INFO', '2': 2},
    {'1': 'VERBOSITY_BLOCK_TX_INFO', '2': 3},
    {'1': 'VERBOSITY_BLOCK_TX_PREVOUT_INFO', '2': 4},
  ],
};

/// Descriptor for `GetBlockRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlockRequestDescriptor =
    $convert.base64Decode('Cg9HZXRCbG9ja1JlcXVlc3QSEgoEaGFzaBgBIAEoCVIEaGFzaBIbCgZoZWlnaHQYAyABKAVIAF'
        'IGaGVpZ2h0iAEBElEKCXZlcmJvc2l0eRgCIAEoDjIzLmJpdGNvaW4uYml0Y29pbmQudjFhbHBo'
        'YS5HZXRCbG9ja1JlcXVlc3QuVmVyYm9zaXR5Ugl2ZXJib3NpdHkimgEKCVZlcmJvc2l0eRIZCh'
        'VWRVJCT1NJVFlfVU5TUEVDSUZJRUQQABIWChJWRVJCT1NJVFlfUkFXX0RBVEEQARIYChRWRVJC'
        'T1NJVFlfQkxPQ0tfSU5GTxACEhsKF1ZFUkJPU0lUWV9CTE9DS19UWF9JTkZPEAMSIwofVkVSQk'
        '9TSVRZX0JMT0NLX1RYX1BSRVZPVVRfSU5GTxAEQgkKB19oZWlnaHQ=');

@$core.Deprecated('Use getBlockResponseDescriptor instead')
const GetBlockResponse$json = {
  '1': 'GetBlockResponse',
  '2': [
    {'1': 'hex', '3': 1, '4': 1, '5': 9, '10': 'hex'},
    {'1': 'hash', '3': 2, '4': 1, '5': 9, '10': 'hash'},
    {'1': 'confirmations', '3': 3, '4': 1, '5': 5, '10': 'confirmations'},
    {'1': 'height', '3': 4, '4': 1, '5': 13, '10': 'height'},
    {'1': 'version', '3': 5, '4': 1, '5': 5, '10': 'version'},
    {'1': 'version_hex', '3': 6, '4': 1, '5': 9, '10': 'versionHex'},
    {'1': 'merkle_root', '3': 7, '4': 1, '5': 9, '10': 'merkleRoot'},
    {'1': 'time', '3': 8, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'time'},
    {'1': 'nonce', '3': 9, '4': 1, '5': 13, '10': 'nonce'},
    {'1': 'bits', '3': 10, '4': 1, '5': 9, '10': 'bits'},
    {'1': 'difficulty', '3': 11, '4': 1, '5': 1, '10': 'difficulty'},
    {'1': 'previous_block_hash', '3': 12, '4': 1, '5': 9, '10': 'previousBlockHash'},
    {'1': 'next_block_hash', '3': 13, '4': 1, '5': 9, '10': 'nextBlockHash'},
    {'1': 'stripped_size', '3': 14, '4': 1, '5': 5, '10': 'strippedSize'},
    {'1': 'size', '3': 15, '4': 1, '5': 5, '10': 'size'},
    {'1': 'weight', '3': 16, '4': 1, '5': 5, '10': 'weight'},
    {'1': 'txids', '3': 17, '4': 3, '5': 9, '10': 'txids'},
  ],
};

/// Descriptor for `GetBlockResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlockResponseDescriptor =
    $convert.base64Decode('ChBHZXRCbG9ja1Jlc3BvbnNlEhAKA2hleBgBIAEoCVIDaGV4EhIKBGhhc2gYAiABKAlSBGhhc2'
        'gSJAoNY29uZmlybWF0aW9ucxgDIAEoBVINY29uZmlybWF0aW9ucxIWCgZoZWlnaHQYBCABKA1S'
        'BmhlaWdodBIYCgd2ZXJzaW9uGAUgASgFUgd2ZXJzaW9uEh8KC3ZlcnNpb25faGV4GAYgASgJUg'
        'p2ZXJzaW9uSGV4Eh8KC21lcmtsZV9yb290GAcgASgJUgptZXJrbGVSb290Ei4KBHRpbWUYCCAB'
        'KAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgR0aW1lEhQKBW5vbmNlGAkgASgNUgVub2'
        '5jZRISCgRiaXRzGAogASgJUgRiaXRzEh4KCmRpZmZpY3VsdHkYCyABKAFSCmRpZmZpY3VsdHkS'
        'LgoTcHJldmlvdXNfYmxvY2tfaGFzaBgMIAEoCVIRcHJldmlvdXNCbG9ja0hhc2gSJgoPbmV4dF'
        '9ibG9ja19oYXNoGA0gASgJUg1uZXh0QmxvY2tIYXNoEiMKDXN0cmlwcGVkX3NpemUYDiABKAVS'
        'DHN0cmlwcGVkU2l6ZRISCgRzaXplGA8gASgFUgRzaXplEhYKBndlaWdodBgQIAEoBVIGd2VpZ2'
        'h0EhQKBXR4aWRzGBEgAygJUgV0eGlkcw==');

@$core.Deprecated('Use bumpFeeRequestDescriptor instead')
const BumpFeeRequest$json = {
  '1': 'BumpFeeRequest',
  '2': [
    {'1': 'wallet', '3': 1, '4': 1, '5': 9, '10': 'wallet'},
    {'1': 'txid', '3': 2, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `BumpFeeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bumpFeeRequestDescriptor =
    $convert.base64Decode('Cg5CdW1wRmVlUmVxdWVzdBIWCgZ3YWxsZXQYASABKAlSBndhbGxldBISCgR0eGlkGAIgASgJUg'
        'R0eGlk');

@$core.Deprecated('Use bumpFeeResponseDescriptor instead')
const BumpFeeResponse$json = {
  '1': 'BumpFeeResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'original_fee', '3': 2, '4': 1, '5': 1, '10': 'originalFee'},
    {'1': 'new_fee', '3': 3, '4': 1, '5': 1, '10': 'newFee'},
    {'1': 'errors', '3': 4, '4': 3, '5': 9, '10': 'errors'},
  ],
};

/// Descriptor for `BumpFeeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bumpFeeResponseDescriptor =
    $convert.base64Decode('Cg9CdW1wRmVlUmVzcG9uc2USEgoEdHhpZBgBIAEoCVIEdHhpZBIhCgxvcmlnaW5hbF9mZWUYAi'
        'ABKAFSC29yaWdpbmFsRmVlEhcKB25ld19mZWUYAyABKAFSBm5ld0ZlZRIWCgZlcnJvcnMYBCAD'
        'KAlSBmVycm9ycw==');

@$core.Deprecated('Use listSinceBlockRequestDescriptor instead')
const ListSinceBlockRequest$json = {
  '1': 'ListSinceBlockRequest',
  '2': [
    {'1': 'wallet', '3': 1, '4': 1, '5': 9, '10': 'wallet'},
    {'1': 'hash', '3': 2, '4': 1, '5': 9, '10': 'hash'},
  ],
};

/// Descriptor for `ListSinceBlockRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSinceBlockRequestDescriptor =
    $convert.base64Decode('ChVMaXN0U2luY2VCbG9ja1JlcXVlc3QSFgoGd2FsbGV0GAEgASgJUgZ3YWxsZXQSEgoEaGFzaB'
        'gCIAEoCVIEaGFzaA==');

@$core.Deprecated('Use listSinceBlockResponseDescriptor instead')
const ListSinceBlockResponse$json = {
  '1': 'ListSinceBlockResponse',
  '2': [
    {
      '1': 'transactions',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.bitcoin.bitcoind.v1alpha.GetTransactionResponse',
      '10': 'transactions'
    },
  ],
};

/// Descriptor for `ListSinceBlockResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSinceBlockResponseDescriptor =
    $convert.base64Decode('ChZMaXN0U2luY2VCbG9ja1Jlc3BvbnNlElQKDHRyYW5zYWN0aW9ucxgBIAMoCzIwLmJpdGNvaW'
        '4uYml0Y29pbmQudjFhbHBoYS5HZXRUcmFuc2FjdGlvblJlc3BvbnNlUgx0cmFuc2FjdGlvbnM=');

@$core.Deprecated('Use getRawMempoolRequestDescriptor instead')
const GetRawMempoolRequest$json = {
  '1': 'GetRawMempoolRequest',
  '2': [
    {'1': 'verbose', '3': 1, '4': 1, '5': 8, '10': 'verbose'},
  ],
};

/// Descriptor for `GetRawMempoolRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRawMempoolRequestDescriptor =
    $convert.base64Decode('ChRHZXRSYXdNZW1wb29sUmVxdWVzdBIYCgd2ZXJib3NlGAEgASgIUgd2ZXJib3Nl');

@$core.Deprecated('Use mempoolEntryDescriptor instead')
const MempoolEntry$json = {
  '1': 'MempoolEntry',
  '2': [
    {'1': 'virtual_size', '3': 1, '4': 1, '5': 13, '10': 'virtualSize'},
    {'1': 'weight', '3': 2, '4': 1, '5': 13, '10': 'weight'},
    {'1': 'time', '3': 3, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'time'},
    {'1': 'descendant_count', '3': 4, '4': 1, '5': 13, '10': 'descendantCount'},
    {'1': 'descendant_size', '3': 5, '4': 1, '5': 13, '10': 'descendantSize'},
    {'1': 'ancestor_count', '3': 6, '4': 1, '5': 13, '10': 'ancestorCount'},
    {'1': 'ancestor_size', '3': 7, '4': 1, '5': 13, '10': 'ancestorSize'},
    {'1': 'witness_txid', '3': 8, '4': 1, '5': 9, '10': 'witnessTxid'},
    {'1': 'fees', '3': 9, '4': 1, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.MempoolEntry.Fees', '10': 'fees'},
    {'1': 'depends', '3': 10, '4': 3, '5': 9, '10': 'depends'},
    {'1': 'spent_by', '3': 11, '4': 3, '5': 9, '10': 'spentBy'},
    {'1': 'bip125_replaceable', '3': 12, '4': 1, '5': 8, '10': 'bip125Replaceable'},
    {'1': 'unbroadcast', '3': 13, '4': 1, '5': 8, '10': 'unbroadcast'},
  ],
  '3': [MempoolEntry_Fees$json],
};

@$core.Deprecated('Use mempoolEntryDescriptor instead')
const MempoolEntry_Fees$json = {
  '1': 'Fees',
  '2': [
    {'1': 'base', '3': 1, '4': 1, '5': 1, '10': 'base'},
    {'1': 'modified', '3': 2, '4': 1, '5': 1, '10': 'modified'},
    {'1': 'ancestor', '3': 3, '4': 1, '5': 1, '10': 'ancestor'},
    {'1': 'descendant', '3': 4, '4': 1, '5': 1, '10': 'descendant'},
  ],
};

/// Descriptor for `MempoolEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mempoolEntryDescriptor =
    $convert.base64Decode('CgxNZW1wb29sRW50cnkSIQoMdmlydHVhbF9zaXplGAEgASgNUgt2aXJ0dWFsU2l6ZRIWCgZ3ZW'
        'lnaHQYAiABKA1SBndlaWdodBIuCgR0aW1lGAMgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVz'
        'dGFtcFIEdGltZRIpChBkZXNjZW5kYW50X2NvdW50GAQgASgNUg9kZXNjZW5kYW50Q291bnQSJw'
        'oPZGVzY2VuZGFudF9zaXplGAUgASgNUg5kZXNjZW5kYW50U2l6ZRIlCg5hbmNlc3Rvcl9jb3Vu'
        'dBgGIAEoDVINYW5jZXN0b3JDb3VudBIjCg1hbmNlc3Rvcl9zaXplGAcgASgNUgxhbmNlc3Rvcl'
        'NpemUSIQoMd2l0bmVzc190eGlkGAggASgJUgt3aXRuZXNzVHhpZBI/CgRmZWVzGAkgASgLMisu'
        'Yml0Y29pbi5iaXRjb2luZC52MWFscGhhLk1lbXBvb2xFbnRyeS5GZWVzUgRmZWVzEhgKB2RlcG'
        'VuZHMYCiADKAlSB2RlcGVuZHMSGQoIc3BlbnRfYnkYCyADKAlSB3NwZW50QnkSLQoSYmlwMTI1'
        'X3JlcGxhY2VhYmxlGAwgASgIUhFiaXAxMjVSZXBsYWNlYWJsZRIgCgt1bmJyb2FkY2FzdBgNIA'
        'EoCFILdW5icm9hZGNhc3QacgoERmVlcxISCgRiYXNlGAEgASgBUgRiYXNlEhoKCG1vZGlmaWVk'
        'GAIgASgBUghtb2RpZmllZBIaCghhbmNlc3RvchgDIAEoAVIIYW5jZXN0b3ISHgoKZGVzY2VuZG'
        'FudBgEIAEoAVIKZGVzY2VuZGFudA==');

@$core.Deprecated('Use getRawMempoolResponseDescriptor instead')
const GetRawMempoolResponse$json = {
  '1': 'GetRawMempoolResponse',
  '2': [
    {'1': 'txids', '3': 1, '4': 3, '5': 9, '10': 'txids'},
    {
      '1': 'transactions',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.bitcoin.bitcoind.v1alpha.GetRawMempoolResponse.TransactionsEntry',
      '10': 'transactions'
    },
  ],
  '3': [GetRawMempoolResponse_TransactionsEntry$json],
};

@$core.Deprecated('Use getRawMempoolResponseDescriptor instead')
const GetRawMempoolResponse_TransactionsEntry$json = {
  '1': 'TransactionsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.MempoolEntry', '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `GetRawMempoolResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRawMempoolResponseDescriptor =
    $convert.base64Decode('ChVHZXRSYXdNZW1wb29sUmVzcG9uc2USFAoFdHhpZHMYASADKAlSBXR4aWRzEmUKDHRyYW5zYW'
        'N0aW9ucxgCIAMoCzJBLmJpdGNvaW4uYml0Y29pbmQudjFhbHBoYS5HZXRSYXdNZW1wb29sUmVz'
        'cG9uc2UuVHJhbnNhY3Rpb25zRW50cnlSDHRyYW5zYWN0aW9ucxpnChFUcmFuc2FjdGlvbnNFbn'
        'RyeRIQCgNrZXkYASABKAlSA2tleRI8CgV2YWx1ZRgCIAEoCzImLmJpdGNvaW4uYml0Y29pbmQu'
        'djFhbHBoYS5NZW1wb29sRW50cnlSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use getBlockHashRequestDescriptor instead')
const GetBlockHashRequest$json = {
  '1': 'GetBlockHashRequest',
  '2': [
    {'1': 'height', '3': 1, '4': 1, '5': 13, '10': 'height'},
  ],
};

/// Descriptor for `GetBlockHashRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlockHashRequestDescriptor =
    $convert.base64Decode('ChNHZXRCbG9ja0hhc2hSZXF1ZXN0EhYKBmhlaWdodBgBIAEoDVIGaGVpZ2h0');

@$core.Deprecated('Use getBlockHashResponseDescriptor instead')
const GetBlockHashResponse$json = {
  '1': 'GetBlockHashResponse',
  '2': [
    {'1': 'hash', '3': 1, '4': 1, '5': 9, '10': 'hash'},
  ],
};

/// Descriptor for `GetBlockHashResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlockHashResponseDescriptor =
    $convert.base64Decode('ChRHZXRCbG9ja0hhc2hSZXNwb25zZRISCgRoYXNoGAEgASgJUgRoYXNo');

@$core.Deprecated('Use listTransactionsRequestDescriptor instead')
const ListTransactionsRequest$json = {
  '1': 'ListTransactionsRequest',
  '2': [
    {'1': 'wallet', '3': 1, '4': 1, '5': 9, '10': 'wallet'},
    {'1': 'count', '3': 2, '4': 1, '5': 13, '10': 'count'},
    {'1': 'skip', '3': 3, '4': 1, '5': 13, '10': 'skip'},
  ],
};

/// Descriptor for `ListTransactionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTransactionsRequestDescriptor =
    $convert.base64Decode('ChdMaXN0VHJhbnNhY3Rpb25zUmVxdWVzdBIWCgZ3YWxsZXQYASABKAlSBndhbGxldBIUCgVjb3'
        'VudBgCIAEoDVIFY291bnQSEgoEc2tpcBgDIAEoDVIEc2tpcA==');

@$core.Deprecated('Use listTransactionsResponseDescriptor instead')
const ListTransactionsResponse$json = {
  '1': 'ListTransactionsResponse',
  '2': [
    {
      '1': 'transactions',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.bitcoin.bitcoind.v1alpha.GetTransactionResponse',
      '10': 'transactions'
    },
  ],
};

/// Descriptor for `ListTransactionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTransactionsResponseDescriptor =
    $convert.base64Decode('ChhMaXN0VHJhbnNhY3Rpb25zUmVzcG9uc2USVAoMdHJhbnNhY3Rpb25zGAEgAygLMjAuYml0Y2'
        '9pbi5iaXRjb2luZC52MWFscGhhLkdldFRyYW5zYWN0aW9uUmVzcG9uc2VSDHRyYW5zYWN0aW9u'
        'cw==');

@$core.Deprecated('Use listWalletsResponseDescriptor instead')
const ListWalletsResponse$json = {
  '1': 'ListWalletsResponse',
  '2': [
    {'1': 'wallets', '3': 1, '4': 3, '5': 9, '10': 'wallets'},
  ],
};

/// Descriptor for `ListWalletsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listWalletsResponseDescriptor =
    $convert.base64Decode('ChNMaXN0V2FsbGV0c1Jlc3BvbnNlEhgKB3dhbGxldHMYASADKAlSB3dhbGxldHM=');

@$core.Deprecated('Use listUnspentRequestDescriptor instead')
const ListUnspentRequest$json = {
  '1': 'ListUnspentRequest',
  '2': [
    {'1': 'wallet', '3': 1, '4': 1, '5': 9, '10': 'wallet'},
    {'1': 'minimum_confirmations', '3': 2, '4': 1, '5': 13, '9': 0, '10': 'minimumConfirmations', '17': true},
    {'1': 'maximum_confirmations', '3': 3, '4': 1, '5': 13, '9': 1, '10': 'maximumConfirmations', '17': true},
    {'1': 'addresses', '3': 4, '4': 3, '5': 9, '10': 'addresses'},
    {'1': 'include_unsafe', '3': 5, '4': 1, '5': 8, '10': 'includeUnsafe'},
    {'1': 'include_watch_only', '3': 6, '4': 1, '5': 8, '10': 'includeWatchOnly'},
  ],
  '8': [
    {'1': '_minimum_confirmations'},
    {'1': '_maximum_confirmations'},
  ],
};

/// Descriptor for `ListUnspentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listUnspentRequestDescriptor =
    $convert.base64Decode('ChJMaXN0VW5zcGVudFJlcXVlc3QSFgoGd2FsbGV0GAEgASgJUgZ3YWxsZXQSOAoVbWluaW11bV'
        '9jb25maXJtYXRpb25zGAIgASgNSABSFG1pbmltdW1Db25maXJtYXRpb25ziAEBEjgKFW1heGlt'
        'dW1fY29uZmlybWF0aW9ucxgDIAEoDUgBUhRtYXhpbXVtQ29uZmlybWF0aW9uc4gBARIcCglhZG'
        'RyZXNzZXMYBCADKAlSCWFkZHJlc3NlcxIlCg5pbmNsdWRlX3Vuc2FmZRgFIAEoCFINaW5jbHVk'
        'ZVVuc2FmZRIsChJpbmNsdWRlX3dhdGNoX29ubHkYBiABKAhSEGluY2x1ZGVXYXRjaE9ubHlCGA'
        'oWX21pbmltdW1fY29uZmlybWF0aW9uc0IYChZfbWF4aW11bV9jb25maXJtYXRpb25z');

@$core.Deprecated('Use unspentOutputDescriptor instead')
const UnspentOutput$json = {
  '1': 'UnspentOutput',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'vout', '3': 2, '4': 1, '5': 13, '10': 'vout'},
    {'1': 'address', '3': 3, '4': 1, '5': 9, '10': 'address'},
    {'1': 'script_pub_key', '3': 5, '4': 1, '5': 9, '10': 'scriptPubKey'},
    {'1': 'amount', '3': 6, '4': 1, '5': 1, '10': 'amount'},
    {'1': 'confirmations', '3': 7, '4': 1, '5': 13, '10': 'confirmations'},
    {'1': 'redeem_script', '3': 11, '4': 1, '5': 9, '10': 'redeemScript'},
    {'1': 'spendable', '3': 13, '4': 1, '5': 8, '10': 'spendable'},
  ],
};

/// Descriptor for `UnspentOutput`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unspentOutputDescriptor =
    $convert.base64Decode('Cg1VbnNwZW50T3V0cHV0EhIKBHR4aWQYASABKAlSBHR4aWQSEgoEdm91dBgCIAEoDVIEdm91dB'
        'IYCgdhZGRyZXNzGAMgASgJUgdhZGRyZXNzEiQKDnNjcmlwdF9wdWJfa2V5GAUgASgJUgxzY3Jp'
        'cHRQdWJLZXkSFgoGYW1vdW50GAYgASgBUgZhbW91bnQSJAoNY29uZmlybWF0aW9ucxgHIAEoDV'
        'INY29uZmlybWF0aW9ucxIjCg1yZWRlZW1fc2NyaXB0GAsgASgJUgxyZWRlZW1TY3JpcHQSHAoJ'
        'c3BlbmRhYmxlGA0gASgIUglzcGVuZGFibGU=');

@$core.Deprecated('Use listUnspentResponseDescriptor instead')
const ListUnspentResponse$json = {
  '1': 'ListUnspentResponse',
  '2': [
    {'1': 'unspent', '3': 1, '4': 3, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.UnspentOutput', '10': 'unspent'},
  ],
};

/// Descriptor for `ListUnspentResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listUnspentResponseDescriptor =
    $convert.base64Decode('ChNMaXN0VW5zcGVudFJlc3BvbnNlEkEKB3Vuc3BlbnQYASADKAsyJy5iaXRjb2luLmJpdGNvaW'
        '5kLnYxYWxwaGEuVW5zcGVudE91dHB1dFIHdW5zcGVudA==');

@$core.Deprecated('Use getAddressInfoRequestDescriptor instead')
const GetAddressInfoRequest$json = {
  '1': 'GetAddressInfoRequest',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'wallet', '3': 2, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `GetAddressInfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAddressInfoRequestDescriptor =
    $convert.base64Decode('ChVHZXRBZGRyZXNzSW5mb1JlcXVlc3QSGAoHYWRkcmVzcxgBIAEoCVIHYWRkcmVzcxIWCgZ3YW'
        'xsZXQYAiABKAlSBndhbGxldA==');

@$core.Deprecated('Use getAddressInfoResponseDescriptor instead')
const GetAddressInfoResponse$json = {
  '1': 'GetAddressInfoResponse',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'script_pub_key', '3': 2, '4': 1, '5': 9, '10': 'scriptPubKey'},
    {'1': 'is_mine', '3': 3, '4': 1, '5': 8, '10': 'isMine'},
    {'1': 'is_watch_only', '3': 4, '4': 1, '5': 8, '10': 'isWatchOnly'},
    {'1': 'solvable', '3': 5, '4': 1, '5': 8, '10': 'solvable'},
    {'1': 'is_script', '3': 6, '4': 1, '5': 8, '10': 'isScript'},
    {'1': 'is_change', '3': 7, '4': 1, '5': 8, '10': 'isChange'},
    {'1': 'is_witness', '3': 8, '4': 1, '5': 8, '10': 'isWitness'},
    {'1': 'witness_version', '3': 9, '4': 1, '5': 13, '10': 'witnessVersion'},
    {'1': 'witness_program', '3': 10, '4': 1, '5': 9, '10': 'witnessProgram'},
    {'1': 'script_type', '3': 11, '4': 1, '5': 9, '10': 'scriptType'},
    {'1': 'is_compressed', '3': 12, '4': 1, '5': 8, '10': 'isCompressed'},
  ],
};

/// Descriptor for `GetAddressInfoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAddressInfoResponseDescriptor =
    $convert.base64Decode('ChZHZXRBZGRyZXNzSW5mb1Jlc3BvbnNlEhgKB2FkZHJlc3MYASABKAlSB2FkZHJlc3MSJAoOc2'
        'NyaXB0X3B1Yl9rZXkYAiABKAlSDHNjcmlwdFB1YktleRIXCgdpc19taW5lGAMgASgIUgZpc01p'
        'bmUSIgoNaXNfd2F0Y2hfb25seRgEIAEoCFILaXNXYXRjaE9ubHkSGgoIc29sdmFibGUYBSABKA'
        'hSCHNvbHZhYmxlEhsKCWlzX3NjcmlwdBgGIAEoCFIIaXNTY3JpcHQSGwoJaXNfY2hhbmdlGAcg'
        'ASgIUghpc0NoYW5nZRIdCgppc193aXRuZXNzGAggASgIUglpc1dpdG5lc3MSJwoPd2l0bmVzc1'
        '92ZXJzaW9uGAkgASgNUg53aXRuZXNzVmVyc2lvbhInCg93aXRuZXNzX3Byb2dyYW0YCiABKAlS'
        'DndpdG5lc3NQcm9ncmFtEh8KC3NjcmlwdF90eXBlGAsgASgJUgpzY3JpcHRUeXBlEiMKDWlzX2'
        'NvbXByZXNzZWQYDCABKAhSDGlzQ29tcHJlc3NlZA==');

@$core.Deprecated('Use createWalletRequestDescriptor instead')
const CreateWalletRequest$json = {
  '1': 'CreateWalletRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'disable_private_keys', '3': 2, '4': 1, '5': 8, '10': 'disablePrivateKeys'},
    {'1': 'blank', '3': 3, '4': 1, '5': 8, '10': 'blank'},
    {'1': 'passphrase', '3': 4, '4': 1, '5': 9, '10': 'passphrase'},
    {'1': 'avoid_reuse', '3': 5, '4': 1, '5': 8, '10': 'avoidReuse'},
  ],
};

/// Descriptor for `CreateWalletRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createWalletRequestDescriptor =
    $convert.base64Decode('ChNDcmVhdGVXYWxsZXRSZXF1ZXN0EhIKBG5hbWUYASABKAlSBG5hbWUSMAoUZGlzYWJsZV9wcm'
        'l2YXRlX2tleXMYAiABKAhSEmRpc2FibGVQcml2YXRlS2V5cxIUCgVibGFuaxgDIAEoCFIFYmxh'
        'bmsSHgoKcGFzc3BocmFzZRgEIAEoCVIKcGFzc3BocmFzZRIfCgthdm9pZF9yZXVzZRgFIAEoCF'
        'IKYXZvaWRSZXVzZQ==');

@$core.Deprecated('Use createWalletResponseDescriptor instead')
const CreateWalletResponse$json = {
  '1': 'CreateWalletResponse',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'warning', '3': 2, '4': 1, '5': 9, '10': 'warning'},
  ],
};

/// Descriptor for `CreateWalletResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createWalletResponseDescriptor =
    $convert.base64Decode('ChRDcmVhdGVXYWxsZXRSZXNwb25zZRISCgRuYW1lGAEgASgJUgRuYW1lEhgKB3dhcm5pbmcYAi'
        'ABKAlSB3dhcm5pbmc=');

@$core.Deprecated('Use backupWalletRequestDescriptor instead')
const BackupWalletRequest$json = {
  '1': 'BackupWalletRequest',
  '2': [
    {'1': 'destination', '3': 1, '4': 1, '5': 9, '10': 'destination'},
    {'1': 'wallet', '3': 2, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `BackupWalletRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List backupWalletRequestDescriptor =
    $convert.base64Decode('ChNCYWNrdXBXYWxsZXRSZXF1ZXN0EiAKC2Rlc3RpbmF0aW9uGAEgASgJUgtkZXN0aW5hdGlvbh'
        'IWCgZ3YWxsZXQYAiABKAlSBndhbGxldA==');

@$core.Deprecated('Use backupWalletResponseDescriptor instead')
const BackupWalletResponse$json = {
  '1': 'BackupWalletResponse',
};

/// Descriptor for `BackupWalletResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List backupWalletResponseDescriptor = $convert.base64Decode('ChRCYWNrdXBXYWxsZXRSZXNwb25zZQ==');

@$core.Deprecated('Use dumpWalletRequestDescriptor instead')
const DumpWalletRequest$json = {
  '1': 'DumpWalletRequest',
  '2': [
    {'1': 'filename', '3': 1, '4': 1, '5': 9, '10': 'filename'},
    {'1': 'wallet', '3': 2, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `DumpWalletRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dumpWalletRequestDescriptor =
    $convert.base64Decode('ChFEdW1wV2FsbGV0UmVxdWVzdBIaCghmaWxlbmFtZRgBIAEoCVIIZmlsZW5hbWUSFgoGd2FsbG'
        'V0GAIgASgJUgZ3YWxsZXQ=');

@$core.Deprecated('Use dumpWalletResponseDescriptor instead')
const DumpWalletResponse$json = {
  '1': 'DumpWalletResponse',
  '2': [
    {'1': 'filename', '3': 1, '4': 1, '5': 9, '10': 'filename'},
  ],
};

/// Descriptor for `DumpWalletResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dumpWalletResponseDescriptor =
    $convert.base64Decode('ChJEdW1wV2FsbGV0UmVzcG9uc2USGgoIZmlsZW5hbWUYASABKAlSCGZpbGVuYW1l');

@$core.Deprecated('Use importWalletRequestDescriptor instead')
const ImportWalletRequest$json = {
  '1': 'ImportWalletRequest',
  '2': [
    {'1': 'filename', '3': 1, '4': 1, '5': 9, '10': 'filename'},
    {'1': 'wallet', '3': 2, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `ImportWalletRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importWalletRequestDescriptor =
    $convert.base64Decode('ChNJbXBvcnRXYWxsZXRSZXF1ZXN0EhoKCGZpbGVuYW1lGAEgASgJUghmaWxlbmFtZRIWCgZ3YW'
        'xsZXQYAiABKAlSBndhbGxldA==');

@$core.Deprecated('Use importWalletResponseDescriptor instead')
const ImportWalletResponse$json = {
  '1': 'ImportWalletResponse',
};

/// Descriptor for `ImportWalletResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importWalletResponseDescriptor = $convert.base64Decode('ChRJbXBvcnRXYWxsZXRSZXNwb25zZQ==');

@$core.Deprecated('Use unloadWalletRequestDescriptor instead')
const UnloadWalletRequest$json = {
  '1': 'UnloadWalletRequest',
  '2': [
    {'1': 'wallet_name', '3': 1, '4': 1, '5': 9, '10': 'walletName'},
    {'1': 'wallet', '3': 2, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `UnloadWalletRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unloadWalletRequestDescriptor =
    $convert.base64Decode('ChNVbmxvYWRXYWxsZXRSZXF1ZXN0Eh8KC3dhbGxldF9uYW1lGAEgASgJUgp3YWxsZXROYW1lEh'
        'YKBndhbGxldBgCIAEoCVIGd2FsbGV0');

@$core.Deprecated('Use unloadWalletResponseDescriptor instead')
const UnloadWalletResponse$json = {
  '1': 'UnloadWalletResponse',
};

/// Descriptor for `UnloadWalletResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unloadWalletResponseDescriptor = $convert.base64Decode('ChRVbmxvYWRXYWxsZXRSZXNwb25zZQ==');

@$core.Deprecated('Use dumpPrivKeyRequestDescriptor instead')
const DumpPrivKeyRequest$json = {
  '1': 'DumpPrivKeyRequest',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'wallet', '3': 2, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `DumpPrivKeyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dumpPrivKeyRequestDescriptor =
    $convert.base64Decode('ChJEdW1wUHJpdktleVJlcXVlc3QSGAoHYWRkcmVzcxgBIAEoCVIHYWRkcmVzcxIWCgZ3YWxsZX'
        'QYAiABKAlSBndhbGxldA==');

@$core.Deprecated('Use dumpPrivKeyResponseDescriptor instead')
const DumpPrivKeyResponse$json = {
  '1': 'DumpPrivKeyResponse',
  '2': [
    {'1': 'private_key', '3': 1, '4': 1, '5': 9, '10': 'privateKey'},
  ],
};

/// Descriptor for `DumpPrivKeyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dumpPrivKeyResponseDescriptor =
    $convert.base64Decode('ChNEdW1wUHJpdktleVJlc3BvbnNlEh8KC3ByaXZhdGVfa2V5GAEgASgJUgpwcml2YXRlS2V5');

@$core.Deprecated('Use importPrivKeyRequestDescriptor instead')
const ImportPrivKeyRequest$json = {
  '1': 'ImportPrivKeyRequest',
  '2': [
    {'1': 'private_key', '3': 1, '4': 1, '5': 9, '10': 'privateKey'},
    {'1': 'label', '3': 2, '4': 1, '5': 9, '10': 'label'},
    {'1': 'rescan', '3': 3, '4': 1, '5': 8, '10': 'rescan'},
    {'1': 'wallet', '3': 4, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `ImportPrivKeyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importPrivKeyRequestDescriptor =
    $convert.base64Decode('ChRJbXBvcnRQcml2S2V5UmVxdWVzdBIfCgtwcml2YXRlX2tleRgBIAEoCVIKcHJpdmF0ZUtleR'
        'IUCgVsYWJlbBgCIAEoCVIFbGFiZWwSFgoGcmVzY2FuGAMgASgIUgZyZXNjYW4SFgoGd2FsbGV0'
        'GAQgASgJUgZ3YWxsZXQ=');

@$core.Deprecated('Use importPrivKeyResponseDescriptor instead')
const ImportPrivKeyResponse$json = {
  '1': 'ImportPrivKeyResponse',
};

/// Descriptor for `ImportPrivKeyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importPrivKeyResponseDescriptor = $convert.base64Decode('ChVJbXBvcnRQcml2S2V5UmVzcG9uc2U=');

@$core.Deprecated('Use importAddressRequestDescriptor instead')
const ImportAddressRequest$json = {
  '1': 'ImportAddressRequest',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'label', '3': 2, '4': 1, '5': 9, '10': 'label'},
    {'1': 'rescan', '3': 3, '4': 1, '5': 8, '10': 'rescan'},
    {'1': 'wallet', '3': 4, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `ImportAddressRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importAddressRequestDescriptor =
    $convert.base64Decode('ChRJbXBvcnRBZGRyZXNzUmVxdWVzdBIYCgdhZGRyZXNzGAEgASgJUgdhZGRyZXNzEhQKBWxhYm'
        'VsGAIgASgJUgVsYWJlbBIWCgZyZXNjYW4YAyABKAhSBnJlc2NhbhIWCgZ3YWxsZXQYBCABKAlS'
        'BndhbGxldA==');

@$core.Deprecated('Use importAddressResponseDescriptor instead')
const ImportAddressResponse$json = {
  '1': 'ImportAddressResponse',
};

/// Descriptor for `ImportAddressResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importAddressResponseDescriptor = $convert.base64Decode('ChVJbXBvcnRBZGRyZXNzUmVzcG9uc2U=');

@$core.Deprecated('Use importPubKeyRequestDescriptor instead')
const ImportPubKeyRequest$json = {
  '1': 'ImportPubKeyRequest',
  '2': [
    {'1': 'pubkey', '3': 1, '4': 1, '5': 9, '10': 'pubkey'},
    {'1': 'rescan', '3': 2, '4': 1, '5': 8, '10': 'rescan'},
    {'1': 'wallet', '3': 3, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `ImportPubKeyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importPubKeyRequestDescriptor =
    $convert.base64Decode('ChNJbXBvcnRQdWJLZXlSZXF1ZXN0EhYKBnB1YmtleRgBIAEoCVIGcHVia2V5EhYKBnJlc2Nhbh'
        'gCIAEoCFIGcmVzY2FuEhYKBndhbGxldBgDIAEoCVIGd2FsbGV0');

@$core.Deprecated('Use importPubKeyResponseDescriptor instead')
const ImportPubKeyResponse$json = {
  '1': 'ImportPubKeyResponse',
};

/// Descriptor for `ImportPubKeyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List importPubKeyResponseDescriptor = $convert.base64Decode('ChRJbXBvcnRQdWJLZXlSZXNwb25zZQ==');

@$core.Deprecated('Use keyPoolRefillRequestDescriptor instead')
const KeyPoolRefillRequest$json = {
  '1': 'KeyPoolRefillRequest',
  '2': [
    {'1': 'new_size', '3': 1, '4': 1, '5': 13, '10': 'newSize'},
    {'1': 'wallet', '3': 2, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `KeyPoolRefillRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List keyPoolRefillRequestDescriptor =
    $convert.base64Decode('ChRLZXlQb29sUmVmaWxsUmVxdWVzdBIZCghuZXdfc2l6ZRgBIAEoDVIHbmV3U2l6ZRIWCgZ3YW'
        'xsZXQYAiABKAlSBndhbGxldA==');

@$core.Deprecated('Use keyPoolRefillResponseDescriptor instead')
const KeyPoolRefillResponse$json = {
  '1': 'KeyPoolRefillResponse',
};

/// Descriptor for `KeyPoolRefillResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List keyPoolRefillResponseDescriptor = $convert.base64Decode('ChVLZXlQb29sUmVmaWxsUmVzcG9uc2U=');

@$core.Deprecated('Use getAccountRequestDescriptor instead')
const GetAccountRequest$json = {
  '1': 'GetAccountRequest',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'wallet', '3': 2, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `GetAccountRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAccountRequestDescriptor =
    $convert.base64Decode('ChFHZXRBY2NvdW50UmVxdWVzdBIYCgdhZGRyZXNzGAEgASgJUgdhZGRyZXNzEhYKBndhbGxldB'
        'gCIAEoCVIGd2FsbGV0');

@$core.Deprecated('Use getAccountResponseDescriptor instead')
const GetAccountResponse$json = {
  '1': 'GetAccountResponse',
  '2': [
    {'1': 'account', '3': 1, '4': 1, '5': 9, '10': 'account'},
  ],
};

/// Descriptor for `GetAccountResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAccountResponseDescriptor =
    $convert.base64Decode('ChJHZXRBY2NvdW50UmVzcG9uc2USGAoHYWNjb3VudBgBIAEoCVIHYWNjb3VudA==');

@$core.Deprecated('Use setAccountRequestDescriptor instead')
const SetAccountRequest$json = {
  '1': 'SetAccountRequest',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'account', '3': 2, '4': 1, '5': 9, '10': 'account'},
    {'1': 'wallet', '3': 3, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `SetAccountRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setAccountRequestDescriptor =
    $convert.base64Decode('ChFTZXRBY2NvdW50UmVxdWVzdBIYCgdhZGRyZXNzGAEgASgJUgdhZGRyZXNzEhgKB2FjY291bn'
        'QYAiABKAlSB2FjY291bnQSFgoGd2FsbGV0GAMgASgJUgZ3YWxsZXQ=');

@$core.Deprecated('Use setAccountResponseDescriptor instead')
const SetAccountResponse$json = {
  '1': 'SetAccountResponse',
};

/// Descriptor for `SetAccountResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setAccountResponseDescriptor = $convert.base64Decode('ChJTZXRBY2NvdW50UmVzcG9uc2U=');

@$core.Deprecated('Use getAddressesByAccountRequestDescriptor instead')
const GetAddressesByAccountRequest$json = {
  '1': 'GetAddressesByAccountRequest',
  '2': [
    {'1': 'account', '3': 1, '4': 1, '5': 9, '10': 'account'},
    {'1': 'wallet', '3': 2, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `GetAddressesByAccountRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAddressesByAccountRequestDescriptor =
    $convert.base64Decode('ChxHZXRBZGRyZXNzZXNCeUFjY291bnRSZXF1ZXN0EhgKB2FjY291bnQYASABKAlSB2FjY291bn'
        'QSFgoGd2FsbGV0GAIgASgJUgZ3YWxsZXQ=');

@$core.Deprecated('Use getAddressesByAccountResponseDescriptor instead')
const GetAddressesByAccountResponse$json = {
  '1': 'GetAddressesByAccountResponse',
  '2': [
    {'1': 'addresses', '3': 1, '4': 3, '5': 9, '10': 'addresses'},
  ],
};

/// Descriptor for `GetAddressesByAccountResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAddressesByAccountResponseDescriptor =
    $convert.base64Decode('Ch1HZXRBZGRyZXNzZXNCeUFjY291bnRSZXNwb25zZRIcCglhZGRyZXNzZXMYASADKAlSCWFkZH'
        'Jlc3Nlcw==');

@$core.Deprecated('Use listAccountsRequestDescriptor instead')
const ListAccountsRequest$json = {
  '1': 'ListAccountsRequest',
  '2': [
    {'1': 'min_conf', '3': 1, '4': 1, '5': 5, '10': 'minConf'},
    {'1': 'wallet', '3': 2, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `ListAccountsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listAccountsRequestDescriptor =
    $convert.base64Decode('ChNMaXN0QWNjb3VudHNSZXF1ZXN0EhkKCG1pbl9jb25mGAEgASgFUgdtaW5Db25mEhYKBndhbG'
        'xldBgCIAEoCVIGd2FsbGV0');

@$core.Deprecated('Use listAccountsResponseDescriptor instead')
const ListAccountsResponse$json = {
  '1': 'ListAccountsResponse',
  '2': [
    {
      '1': 'accounts',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.bitcoin.bitcoind.v1alpha.ListAccountsResponse.AccountsEntry',
      '10': 'accounts'
    },
  ],
  '3': [ListAccountsResponse_AccountsEntry$json],
};

@$core.Deprecated('Use listAccountsResponseDescriptor instead')
const ListAccountsResponse_AccountsEntry$json = {
  '1': 'AccountsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 1, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `ListAccountsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listAccountsResponseDescriptor =
    $convert.base64Decode('ChRMaXN0QWNjb3VudHNSZXNwb25zZRJYCghhY2NvdW50cxgBIAMoCzI8LmJpdGNvaW4uYml0Y2'
        '9pbmQudjFhbHBoYS5MaXN0QWNjb3VudHNSZXNwb25zZS5BY2NvdW50c0VudHJ5UghhY2NvdW50'
        'cxo7Cg1BY2NvdW50c0VudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgBUgV2YW'
        'x1ZToCOAE=');

@$core.Deprecated('Use addMultisigAddressRequestDescriptor instead')
const AddMultisigAddressRequest$json = {
  '1': 'AddMultisigAddressRequest',
  '2': [
    {'1': 'required_sigs', '3': 1, '4': 1, '5': 5, '10': 'requiredSigs'},
    {'1': 'keys', '3': 2, '4': 3, '5': 9, '10': 'keys'},
    {'1': 'label', '3': 3, '4': 1, '5': 9, '10': 'label'},
    {'1': 'wallet', '3': 4, '4': 1, '5': 9, '10': 'wallet'},
  ],
};

/// Descriptor for `AddMultisigAddressRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addMultisigAddressRequestDescriptor =
    $convert.base64Decode('ChlBZGRNdWx0aXNpZ0FkZHJlc3NSZXF1ZXN0EiMKDXJlcXVpcmVkX3NpZ3MYASABKAVSDHJlcX'
        'VpcmVkU2lncxISCgRrZXlzGAIgAygJUgRrZXlzEhQKBWxhYmVsGAMgASgJUgVsYWJlbBIWCgZ3'
        'YWxsZXQYBCABKAlSBndhbGxldA==');

@$core.Deprecated('Use addMultisigAddressResponseDescriptor instead')
const AddMultisigAddressResponse$json = {
  '1': 'AddMultisigAddressResponse',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
  ],
};

/// Descriptor for `AddMultisigAddressResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addMultisigAddressResponseDescriptor =
    $convert.base64Decode('ChpBZGRNdWx0aXNpZ0FkZHJlc3NSZXNwb25zZRIYCgdhZGRyZXNzGAEgASgJUgdhZGRyZXNz');

@$core.Deprecated('Use createMultisigRequestDescriptor instead')
const CreateMultisigRequest$json = {
  '1': 'CreateMultisigRequest',
  '2': [
    {'1': 'required_sigs', '3': 1, '4': 1, '5': 5, '10': 'requiredSigs'},
    {'1': 'keys', '3': 2, '4': 3, '5': 9, '10': 'keys'},
  ],
};

/// Descriptor for `CreateMultisigRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createMultisigRequestDescriptor =
    $convert.base64Decode('ChVDcmVhdGVNdWx0aXNpZ1JlcXVlc3QSIwoNcmVxdWlyZWRfc2lncxgBIAEoBVIMcmVxdWlyZW'
        'RTaWdzEhIKBGtleXMYAiADKAlSBGtleXM=');

@$core.Deprecated('Use createMultisigResponseDescriptor instead')
const CreateMultisigResponse$json = {
  '1': 'CreateMultisigResponse',
  '2': [
    {'1': 'address', '3': 1, '4': 1, '5': 9, '10': 'address'},
    {'1': 'redeem_script', '3': 2, '4': 1, '5': 9, '10': 'redeemScript'},
  ],
};

/// Descriptor for `CreateMultisigResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createMultisigResponseDescriptor =
    $convert.base64Decode('ChZDcmVhdGVNdWx0aXNpZ1Jlc3BvbnNlEhgKB2FkZHJlc3MYASABKAlSB2FkZHJlc3MSIwoNcm'
        'VkZWVtX3NjcmlwdBgCIAEoCVIMcmVkZWVtU2NyaXB0');

@$core.Deprecated('Use createRawTransactionRequestDescriptor instead')
const CreateRawTransactionRequest$json = {
  '1': 'CreateRawTransactionRequest',
  '2': [
    {
      '1': 'inputs',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.bitcoin.bitcoind.v1alpha.CreateRawTransactionRequest.Input',
      '10': 'inputs'
    },
    {
      '1': 'outputs',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.bitcoin.bitcoind.v1alpha.CreateRawTransactionRequest.OutputsEntry',
      '10': 'outputs'
    },
    {'1': 'locktime', '3': 3, '4': 1, '5': 13, '10': 'locktime'},
  ],
  '3': [CreateRawTransactionRequest_Input$json, CreateRawTransactionRequest_OutputsEntry$json],
};

@$core.Deprecated('Use createRawTransactionRequestDescriptor instead')
const CreateRawTransactionRequest_Input$json = {
  '1': 'Input',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'vout', '3': 2, '4': 1, '5': 13, '10': 'vout'},
    {'1': 'sequence', '3': 3, '4': 1, '5': 13, '10': 'sequence'},
  ],
};

@$core.Deprecated('Use createRawTransactionRequestDescriptor instead')
const CreateRawTransactionRequest_OutputsEntry$json = {
  '1': 'OutputsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 1, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `CreateRawTransactionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createRawTransactionRequestDescriptor =
    $convert.base64Decode('ChtDcmVhdGVSYXdUcmFuc2FjdGlvblJlcXVlc3QSUwoGaW5wdXRzGAEgAygLMjsuYml0Y29pbi'
        '5iaXRjb2luZC52MWFscGhhLkNyZWF0ZVJhd1RyYW5zYWN0aW9uUmVxdWVzdC5JbnB1dFIGaW5w'
        'dXRzElwKB291dHB1dHMYAiADKAsyQi5iaXRjb2luLmJpdGNvaW5kLnYxYWxwaGEuQ3JlYXRlUm'
        'F3VHJhbnNhY3Rpb25SZXF1ZXN0Lk91dHB1dHNFbnRyeVIHb3V0cHV0cxIaCghsb2NrdGltZRgD'
        'IAEoDVIIbG9ja3RpbWUaSwoFSW5wdXQSEgoEdHhpZBgBIAEoCVIEdHhpZBISCgR2b3V0GAIgAS'
        'gNUgR2b3V0EhoKCHNlcXVlbmNlGAMgASgNUghzZXF1ZW5jZRo6CgxPdXRwdXRzRW50cnkSEAoD'
        'a2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAFSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use createRawTransactionResponseDescriptor instead')
const CreateRawTransactionResponse$json = {
  '1': 'CreateRawTransactionResponse',
  '2': [
    {'1': 'tx', '3': 1, '4': 1, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.RawTransaction', '10': 'tx'},
  ],
};

/// Descriptor for `CreateRawTransactionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createRawTransactionResponseDescriptor =
    $convert.base64Decode('ChxDcmVhdGVSYXdUcmFuc2FjdGlvblJlc3BvbnNlEjgKAnR4GAEgASgLMiguYml0Y29pbi5iaX'
        'Rjb2luZC52MWFscGhhLlJhd1RyYW5zYWN0aW9uUgJ0eA==');

@$core.Deprecated('Use createPsbtRequestDescriptor instead')
const CreatePsbtRequest$json = {
  '1': 'CreatePsbtRequest',
  '2': [
    {'1': 'inputs', '3': 1, '4': 3, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.CreatePsbtRequest.Input', '10': 'inputs'},
    {
      '1': 'outputs',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.bitcoin.bitcoind.v1alpha.CreatePsbtRequest.OutputsEntry',
      '10': 'outputs'
    },
    {'1': 'locktime', '3': 3, '4': 1, '5': 13, '10': 'locktime'},
    {'1': 'replaceable', '3': 4, '4': 1, '5': 8, '10': 'replaceable'},
  ],
  '3': [CreatePsbtRequest_Input$json, CreatePsbtRequest_OutputsEntry$json],
};

@$core.Deprecated('Use createPsbtRequestDescriptor instead')
const CreatePsbtRequest_Input$json = {
  '1': 'Input',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'vout', '3': 2, '4': 1, '5': 13, '10': 'vout'},
    {'1': 'sequence', '3': 3, '4': 1, '5': 13, '10': 'sequence'},
  ],
};

@$core.Deprecated('Use createPsbtRequestDescriptor instead')
const CreatePsbtRequest_OutputsEntry$json = {
  '1': 'OutputsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 1, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `CreatePsbtRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createPsbtRequestDescriptor =
    $convert.base64Decode('ChFDcmVhdGVQc2J0UmVxdWVzdBJJCgZpbnB1dHMYASADKAsyMS5iaXRjb2luLmJpdGNvaW5kLn'
        'YxYWxwaGEuQ3JlYXRlUHNidFJlcXVlc3QuSW5wdXRSBmlucHV0cxJSCgdvdXRwdXRzGAIgAygL'
        'MjguYml0Y29pbi5iaXRjb2luZC52MWFscGhhLkNyZWF0ZVBzYnRSZXF1ZXN0Lk91dHB1dHNFbn'
        'RyeVIHb3V0cHV0cxIaCghsb2NrdGltZRgDIAEoDVIIbG9ja3RpbWUSIAoLcmVwbGFjZWFibGUY'
        'BCABKAhSC3JlcGxhY2VhYmxlGksKBUlucHV0EhIKBHR4aWQYASABKAlSBHR4aWQSEgoEdm91dB'
        'gCIAEoDVIEdm91dBIaCghzZXF1ZW5jZRgDIAEoDVIIc2VxdWVuY2UaOgoMT3V0cHV0c0VudHJ5'
        'EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgBUgV2YWx1ZToCOAE=');

@$core.Deprecated('Use createPsbtResponseDescriptor instead')
const CreatePsbtResponse$json = {
  '1': 'CreatePsbtResponse',
  '2': [
    {'1': 'psbt', '3': 1, '4': 1, '5': 9, '10': 'psbt'},
  ],
};

/// Descriptor for `CreatePsbtResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createPsbtResponseDescriptor =
    $convert.base64Decode('ChJDcmVhdGVQc2J0UmVzcG9uc2USEgoEcHNidBgBIAEoCVIEcHNidA==');

@$core.Deprecated('Use decodePsbtRequestDescriptor instead')
const DecodePsbtRequest$json = {
  '1': 'DecodePsbtRequest',
  '2': [
    {'1': 'psbt', '3': 1, '4': 1, '5': 9, '10': 'psbt'},
  ],
};

/// Descriptor for `DecodePsbtRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List decodePsbtRequestDescriptor =
    $convert.base64Decode('ChFEZWNvZGVQc2J0UmVxdWVzdBISCgRwc2J0GAEgASgJUgRwc2J0');

@$core.Deprecated('Use decodePsbtResponseDescriptor instead')
const DecodePsbtResponse$json = {
  '1': 'DecodePsbtResponse',
  '2': [
    {'1': 'tx', '3': 1, '4': 1, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.DecodeRawTransactionResponse', '10': 'tx'},
    {
      '1': 'unknown',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.bitcoin.bitcoind.v1alpha.DecodePsbtResponse.UnknownEntry',
      '10': 'unknown'
    },
    {'1': 'inputs', '3': 3, '4': 3, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.DecodePsbtResponse.Input', '10': 'inputs'},
    {
      '1': 'outputs',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.bitcoin.bitcoind.v1alpha.DecodePsbtResponse.Output',
      '10': 'outputs'
    },
    {'1': 'fee', '3': 5, '4': 1, '5': 1, '10': 'fee'},
  ],
  '3': [
    DecodePsbtResponse_WitnessUtxo$json,
    DecodePsbtResponse_RedeemScript$json,
    DecodePsbtResponse_Bip32Deriv$json,
    DecodePsbtResponse_Input$json,
    DecodePsbtResponse_Output$json,
    DecodePsbtResponse_UnknownEntry$json
  ],
};

@$core.Deprecated('Use decodePsbtResponseDescriptor instead')
const DecodePsbtResponse_WitnessUtxo$json = {
  '1': 'WitnessUtxo',
  '2': [
    {'1': 'amount', '3': 1, '4': 1, '5': 1, '10': 'amount'},
    {
      '1': 'script_pub_key',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.bitcoin.bitcoind.v1alpha.ScriptPubKey',
      '10': 'scriptPubKey'
    },
  ],
};

@$core.Deprecated('Use decodePsbtResponseDescriptor instead')
const DecodePsbtResponse_RedeemScript$json = {
  '1': 'RedeemScript',
  '2': [
    {'1': 'asm', '3': 1, '4': 1, '5': 9, '10': 'asm'},
    {'1': 'hex', '3': 2, '4': 1, '5': 9, '10': 'hex'},
    {'1': 'type', '3': 3, '4': 1, '5': 9, '10': 'type'},
  ],
};

@$core.Deprecated('Use decodePsbtResponseDescriptor instead')
const DecodePsbtResponse_Bip32Deriv$json = {
  '1': 'Bip32Deriv',
  '2': [
    {'1': 'pubkey', '3': 1, '4': 1, '5': 9, '10': 'pubkey'},
    {'1': 'master_fingerprint', '3': 2, '4': 1, '5': 9, '10': 'masterFingerprint'},
    {'1': 'path', '3': 3, '4': 1, '5': 9, '10': 'path'},
  ],
};

@$core.Deprecated('Use decodePsbtResponseDescriptor instead')
const DecodePsbtResponse_Input$json = {
  '1': 'Input',
  '2': [
    {
      '1': 'non_witness_utxo',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.bitcoin.bitcoind.v1alpha.DecodeRawTransactionResponse',
      '10': 'nonWitnessUtxo'
    },
    {
      '1': 'witness_utxo',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.bitcoin.bitcoind.v1alpha.DecodePsbtResponse.WitnessUtxo',
      '10': 'witnessUtxo'
    },
    {
      '1': 'partial_signatures',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.bitcoin.bitcoind.v1alpha.DecodePsbtResponse.Input.PartialSignaturesEntry',
      '10': 'partialSignatures'
    },
    {'1': 'sighash', '3': 4, '4': 1, '5': 9, '10': 'sighash'},
    {
      '1': 'redeem_script',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.bitcoin.bitcoind.v1alpha.DecodePsbtResponse.RedeemScript',
      '10': 'redeemScript'
    },
    {
      '1': 'witness_script',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.bitcoin.bitcoind.v1alpha.DecodePsbtResponse.RedeemScript',
      '10': 'witnessScript'
    },
    {
      '1': 'bip32_derivs',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.bitcoin.bitcoind.v1alpha.DecodePsbtResponse.Bip32Deriv',
      '10': 'bip32Derivs'
    },
    {
      '1': 'final_scriptsig',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.bitcoin.bitcoind.v1alpha.ScriptSig',
      '10': 'finalScriptsig'
    },
    {'1': 'final_scriptwitness', '3': 9, '4': 3, '5': 9, '10': 'finalScriptwitness'},
    {
      '1': 'unknown',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.bitcoin.bitcoind.v1alpha.DecodePsbtResponse.Input.UnknownEntry',
      '10': 'unknown'
    },
  ],
  '3': [DecodePsbtResponse_Input_PartialSignaturesEntry$json, DecodePsbtResponse_Input_UnknownEntry$json],
};

@$core.Deprecated('Use decodePsbtResponseDescriptor instead')
const DecodePsbtResponse_Input_PartialSignaturesEntry$json = {
  '1': 'PartialSignaturesEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use decodePsbtResponseDescriptor instead')
const DecodePsbtResponse_Input_UnknownEntry$json = {
  '1': 'UnknownEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use decodePsbtResponseDescriptor instead')
const DecodePsbtResponse_Output$json = {
  '1': 'Output',
  '2': [
    {
      '1': 'redeem_script',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.bitcoin.bitcoind.v1alpha.DecodePsbtResponse.RedeemScript',
      '10': 'redeemScript'
    },
    {
      '1': 'witness_script',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.bitcoin.bitcoind.v1alpha.DecodePsbtResponse.RedeemScript',
      '10': 'witnessScript'
    },
    {
      '1': 'bip32_derivs',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.bitcoin.bitcoind.v1alpha.DecodePsbtResponse.Bip32Deriv',
      '10': 'bip32Derivs'
    },
    {
      '1': 'unknown',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.bitcoin.bitcoind.v1alpha.DecodePsbtResponse.Output.UnknownEntry',
      '10': 'unknown'
    },
  ],
  '3': [DecodePsbtResponse_Output_UnknownEntry$json],
};

@$core.Deprecated('Use decodePsbtResponseDescriptor instead')
const DecodePsbtResponse_Output_UnknownEntry$json = {
  '1': 'UnknownEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use decodePsbtResponseDescriptor instead')
const DecodePsbtResponse_UnknownEntry$json = {
  '1': 'UnknownEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `DecodePsbtResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List decodePsbtResponseDescriptor =
    $convert.base64Decode('ChJEZWNvZGVQc2J0UmVzcG9uc2USRgoCdHgYASABKAsyNi5iaXRjb2luLmJpdGNvaW5kLnYxYW'
        'xwaGEuRGVjb2RlUmF3VHJhbnNhY3Rpb25SZXNwb25zZVICdHgSUwoHdW5rbm93bhgCIAMoCzI5'
        'LmJpdGNvaW4uYml0Y29pbmQudjFhbHBoYS5EZWNvZGVQc2J0UmVzcG9uc2UuVW5rbm93bkVudH'
        'J5Ugd1bmtub3duEkoKBmlucHV0cxgDIAMoCzIyLmJpdGNvaW4uYml0Y29pbmQudjFhbHBoYS5E'
        'ZWNvZGVQc2J0UmVzcG9uc2UuSW5wdXRSBmlucHV0cxJNCgdvdXRwdXRzGAQgAygLMjMuYml0Y2'
        '9pbi5iaXRjb2luZC52MWFscGhhLkRlY29kZVBzYnRSZXNwb25zZS5PdXRwdXRSB291dHB1dHMS'
        'EAoDZmVlGAUgASgBUgNmZWUacwoLV2l0bmVzc1V0eG8SFgoGYW1vdW50GAEgASgBUgZhbW91bn'
        'QSTAoOc2NyaXB0X3B1Yl9rZXkYAiABKAsyJi5iaXRjb2luLmJpdGNvaW5kLnYxYWxwaGEuU2Ny'
        'aXB0UHViS2V5UgxzY3JpcHRQdWJLZXkaRgoMUmVkZWVtU2NyaXB0EhAKA2FzbRgBIAEoCVIDYX'
        'NtEhAKA2hleBgCIAEoCVIDaGV4EhIKBHR5cGUYAyABKAlSBHR5cGUaZwoKQmlwMzJEZXJpdhIW'
        'CgZwdWJrZXkYASABKAlSBnB1YmtleRItChJtYXN0ZXJfZmluZ2VycHJpbnQYAiABKAlSEW1hc3'
        'RlckZpbmdlcnByaW50EhIKBHBhdGgYAyABKAlSBHBhdGga1AcKBUlucHV0EmAKEG5vbl93aXRu'
        'ZXNzX3V0eG8YASABKAsyNi5iaXRjb2luLmJpdGNvaW5kLnYxYWxwaGEuRGVjb2RlUmF3VHJhbn'
        'NhY3Rpb25SZXNwb25zZVIObm9uV2l0bmVzc1V0eG8SWwoMd2l0bmVzc191dHhvGAIgASgLMjgu'
        'Yml0Y29pbi5iaXRjb2luZC52MWFscGhhLkRlY29kZVBzYnRSZXNwb25zZS5XaXRuZXNzVXR4b1'
        'ILd2l0bmVzc1V0eG8SeAoScGFydGlhbF9zaWduYXR1cmVzGAMgAygLMkkuYml0Y29pbi5iaXRj'
        'b2luZC52MWFscGhhLkRlY29kZVBzYnRSZXNwb25zZS5JbnB1dC5QYXJ0aWFsU2lnbmF0dXJlc0'
        'VudHJ5UhFwYXJ0aWFsU2lnbmF0dXJlcxIYCgdzaWdoYXNoGAQgASgJUgdzaWdoYXNoEl4KDXJl'
        'ZGVlbV9zY3JpcHQYBSABKAsyOS5iaXRjb2luLmJpdGNvaW5kLnYxYWxwaGEuRGVjb2RlUHNidF'
        'Jlc3BvbnNlLlJlZGVlbVNjcmlwdFIMcmVkZWVtU2NyaXB0EmAKDndpdG5lc3Nfc2NyaXB0GAYg'
        'ASgLMjkuYml0Y29pbi5iaXRjb2luZC52MWFscGhhLkRlY29kZVBzYnRSZXNwb25zZS5SZWRlZW'
        '1TY3JpcHRSDXdpdG5lc3NTY3JpcHQSWgoMYmlwMzJfZGVyaXZzGAcgAygLMjcuYml0Y29pbi5i'
        'aXRjb2luZC52MWFscGhhLkRlY29kZVBzYnRSZXNwb25zZS5CaXAzMkRlcml2UgtiaXAzMkRlcm'
        'l2cxJMCg9maW5hbF9zY3JpcHRzaWcYCCABKAsyIy5iaXRjb2luLmJpdGNvaW5kLnYxYWxwaGEu'
        'U2NyaXB0U2lnUg5maW5hbFNjcmlwdHNpZxIvChNmaW5hbF9zY3JpcHR3aXRuZXNzGAkgAygJUh'
        'JmaW5hbFNjcmlwdHdpdG5lc3MSWQoHdW5rbm93bhgKIAMoCzI/LmJpdGNvaW4uYml0Y29pbmQu'
        'djFhbHBoYS5EZWNvZGVQc2J0UmVzcG9uc2UuSW5wdXQuVW5rbm93bkVudHJ5Ugd1bmtub3duGk'
        'QKFlBhcnRpYWxTaWduYXR1cmVzRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiAB'
        'KAlSBXZhbHVlOgI4ARo6CgxVbmtub3duRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdW'
        'UYAiABKAlSBXZhbHVlOgI4ARq+AwoGT3V0cHV0El4KDXJlZGVlbV9zY3JpcHQYASABKAsyOS5i'
        'aXRjb2luLmJpdGNvaW5kLnYxYWxwaGEuRGVjb2RlUHNidFJlc3BvbnNlLlJlZGVlbVNjcmlwdF'
        'IMcmVkZWVtU2NyaXB0EmAKDndpdG5lc3Nfc2NyaXB0GAIgASgLMjkuYml0Y29pbi5iaXRjb2lu'
        'ZC52MWFscGhhLkRlY29kZVBzYnRSZXNwb25zZS5SZWRlZW1TY3JpcHRSDXdpdG5lc3NTY3JpcH'
        'QSWgoMYmlwMzJfZGVyaXZzGAMgAygLMjcuYml0Y29pbi5iaXRjb2luZC52MWFscGhhLkRlY29k'
        'ZVBzYnRSZXNwb25zZS5CaXAzMkRlcml2UgtiaXAzMkRlcml2cxJaCgd1bmtub3duGAQgAygLMk'
        'AuYml0Y29pbi5iaXRjb2luZC52MWFscGhhLkRlY29kZVBzYnRSZXNwb25zZS5PdXRwdXQuVW5r'
        'bm93bkVudHJ5Ugd1bmtub3duGjoKDFVua25vd25FbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCg'
        'V2YWx1ZRgCIAEoCVIFdmFsdWU6AjgBGjoKDFVua25vd25FbnRyeRIQCgNrZXkYASABKAlSA2tl'
        'eRIUCgV2YWx1ZRgCIAEoCVIFdmFsdWU6AjgB');

@$core.Deprecated('Use analyzePsbtRequestDescriptor instead')
const AnalyzePsbtRequest$json = {
  '1': 'AnalyzePsbtRequest',
  '2': [
    {'1': 'psbt', '3': 1, '4': 1, '5': 9, '10': 'psbt'},
  ],
};

/// Descriptor for `AnalyzePsbtRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List analyzePsbtRequestDescriptor =
    $convert.base64Decode('ChJBbmFseXplUHNidFJlcXVlc3QSEgoEcHNidBgBIAEoCVIEcHNidA==');

@$core.Deprecated('Use analyzePsbtResponseDescriptor instead')
const AnalyzePsbtResponse$json = {
  '1': 'AnalyzePsbtResponse',
  '2': [
    {
      '1': 'inputs',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.bitcoin.bitcoind.v1alpha.AnalyzePsbtResponse.Input',
      '10': 'inputs'
    },
    {'1': 'estimated_vsize', '3': 2, '4': 1, '5': 1, '10': 'estimatedVsize'},
    {'1': 'estimated_feerate', '3': 3, '4': 1, '5': 1, '10': 'estimatedFeerate'},
    {'1': 'fee', '3': 4, '4': 1, '5': 1, '10': 'fee'},
    {'1': 'next', '3': 5, '4': 1, '5': 9, '10': 'next'},
    {'1': 'error', '3': 6, '4': 1, '5': 9, '10': 'error'},
  ],
  '3': [AnalyzePsbtResponse_Input$json],
};

@$core.Deprecated('Use analyzePsbtResponseDescriptor instead')
const AnalyzePsbtResponse_Input$json = {
  '1': 'Input',
  '2': [
    {'1': 'has_utxo', '3': 1, '4': 1, '5': 8, '10': 'hasUtxo'},
    {'1': 'is_final', '3': 2, '4': 1, '5': 8, '10': 'isFinal'},
    {
      '1': 'missing',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.bitcoin.bitcoind.v1alpha.AnalyzePsbtResponse.Input.Missing',
      '10': 'missing'
    },
    {'1': 'next', '3': 4, '4': 1, '5': 9, '10': 'next'},
  ],
  '3': [AnalyzePsbtResponse_Input_Missing$json],
};

@$core.Deprecated('Use analyzePsbtResponseDescriptor instead')
const AnalyzePsbtResponse_Input_Missing$json = {
  '1': 'Missing',
  '2': [
    {'1': 'pubkeys', '3': 1, '4': 3, '5': 9, '10': 'pubkeys'},
    {'1': 'signatures', '3': 2, '4': 3, '5': 9, '10': 'signatures'},
    {'1': 'redeem_script', '3': 3, '4': 1, '5': 9, '10': 'redeemScript'},
    {'1': 'witness_script', '3': 4, '4': 1, '5': 9, '10': 'witnessScript'},
  ],
};

/// Descriptor for `AnalyzePsbtResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List analyzePsbtResponseDescriptor =
    $convert.base64Decode('ChNBbmFseXplUHNidFJlc3BvbnNlEksKBmlucHV0cxgBIAMoCzIzLmJpdGNvaW4uYml0Y29pbm'
        'QudjFhbHBoYS5BbmFseXplUHNidFJlc3BvbnNlLklucHV0UgZpbnB1dHMSJwoPZXN0aW1hdGVk'
        'X3ZzaXplGAIgASgBUg5lc3RpbWF0ZWRWc2l6ZRIrChFlc3RpbWF0ZWRfZmVlcmF0ZRgDIAEoAV'
        'IQZXN0aW1hdGVkRmVlcmF0ZRIQCgNmZWUYBCABKAFSA2ZlZRISCgRuZXh0GAUgASgJUgRuZXh0'
        'EhQKBWVycm9yGAYgASgJUgVlcnJvchq6AgoFSW5wdXQSGQoIaGFzX3V0eG8YASABKAhSB2hhc1'
        'V0eG8SGQoIaXNfZmluYWwYAiABKAhSB2lzRmluYWwSVQoHbWlzc2luZxgDIAEoCzI7LmJpdGNv'
        'aW4uYml0Y29pbmQudjFhbHBoYS5BbmFseXplUHNidFJlc3BvbnNlLklucHV0Lk1pc3NpbmdSB2'
        '1pc3NpbmcSEgoEbmV4dBgEIAEoCVIEbmV4dBqPAQoHTWlzc2luZxIYCgdwdWJrZXlzGAEgAygJ'
        'UgdwdWJrZXlzEh4KCnNpZ25hdHVyZXMYAiADKAlSCnNpZ25hdHVyZXMSIwoNcmVkZWVtX3Njcm'
        'lwdBgDIAEoCVIMcmVkZWVtU2NyaXB0EiUKDndpdG5lc3Nfc2NyaXB0GAQgASgJUg13aXRuZXNz'
        'U2NyaXB0');

@$core.Deprecated('Use combinePsbtRequestDescriptor instead')
const CombinePsbtRequest$json = {
  '1': 'CombinePsbtRequest',
  '2': [
    {'1': 'psbts', '3': 1, '4': 3, '5': 9, '10': 'psbts'},
  ],
};

/// Descriptor for `CombinePsbtRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List combinePsbtRequestDescriptor =
    $convert.base64Decode('ChJDb21iaW5lUHNidFJlcXVlc3QSFAoFcHNidHMYASADKAlSBXBzYnRz');

@$core.Deprecated('Use combinePsbtResponseDescriptor instead')
const CombinePsbtResponse$json = {
  '1': 'CombinePsbtResponse',
  '2': [
    {'1': 'psbt', '3': 1, '4': 1, '5': 9, '10': 'psbt'},
  ],
};

/// Descriptor for `CombinePsbtResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List combinePsbtResponseDescriptor =
    $convert.base64Decode('ChNDb21iaW5lUHNidFJlc3BvbnNlEhIKBHBzYnQYASABKAlSBHBzYnQ=');

@$core.Deprecated('Use utxoUpdatePsbtRequestDescriptor instead')
const UtxoUpdatePsbtRequest$json = {
  '1': 'UtxoUpdatePsbtRequest',
  '2': [
    {'1': 'psbt', '3': 1, '4': 1, '5': 9, '10': 'psbt'},
    {'1': 'descriptors', '3': 2, '4': 3, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.Descriptor', '10': 'descriptors'},
  ],
};

/// Descriptor for `UtxoUpdatePsbtRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List utxoUpdatePsbtRequestDescriptor =
    $convert.base64Decode('ChVVdHhvVXBkYXRlUHNidFJlcXVlc3QSEgoEcHNidBgBIAEoCVIEcHNidBJGCgtkZXNjcmlwdG'
        '9ycxgCIAMoCzIkLmJpdGNvaW4uYml0Y29pbmQudjFhbHBoYS5EZXNjcmlwdG9yUgtkZXNjcmlw'
        'dG9ycw==');

@$core.Deprecated('Use utxoUpdatePsbtResponseDescriptor instead')
const UtxoUpdatePsbtResponse$json = {
  '1': 'UtxoUpdatePsbtResponse',
  '2': [
    {'1': 'psbt', '3': 1, '4': 1, '5': 9, '10': 'psbt'},
  ],
};

/// Descriptor for `UtxoUpdatePsbtResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List utxoUpdatePsbtResponseDescriptor =
    $convert.base64Decode('ChZVdHhvVXBkYXRlUHNidFJlc3BvbnNlEhIKBHBzYnQYASABKAlSBHBzYnQ=');

@$core.Deprecated('Use joinPsbtsRequestDescriptor instead')
const JoinPsbtsRequest$json = {
  '1': 'JoinPsbtsRequest',
  '2': [
    {'1': 'psbts', '3': 1, '4': 3, '5': 9, '10': 'psbts'},
  ],
};

/// Descriptor for `JoinPsbtsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinPsbtsRequestDescriptor =
    $convert.base64Decode('ChBKb2luUHNidHNSZXF1ZXN0EhQKBXBzYnRzGAEgAygJUgVwc2J0cw==');

@$core.Deprecated('Use joinPsbtsResponseDescriptor instead')
const JoinPsbtsResponse$json = {
  '1': 'JoinPsbtsResponse',
  '2': [
    {'1': 'psbt', '3': 1, '4': 1, '5': 9, '10': 'psbt'},
  ],
};

/// Descriptor for `JoinPsbtsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinPsbtsResponseDescriptor =
    $convert.base64Decode('ChFKb2luUHNidHNSZXNwb25zZRISCgRwc2J0GAEgASgJUgRwc2J0');

@$core.Deprecated('Use testMempoolAcceptRequestDescriptor instead')
const TestMempoolAcceptRequest$json = {
  '1': 'TestMempoolAcceptRequest',
  '2': [
    {'1': 'rawtxs', '3': 1, '4': 3, '5': 9, '10': 'rawtxs'},
    {'1': 'max_fee_rate', '3': 2, '4': 1, '5': 1, '10': 'maxFeeRate'},
  ],
};

/// Descriptor for `TestMempoolAcceptRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List testMempoolAcceptRequestDescriptor =
    $convert.base64Decode('ChhUZXN0TWVtcG9vbEFjY2VwdFJlcXVlc3QSFgoGcmF3dHhzGAEgAygJUgZyYXd0eHMSIAoMbW'
        'F4X2ZlZV9yYXRlGAIgASgBUgptYXhGZWVSYXRl');

@$core.Deprecated('Use testMempoolAcceptResponseDescriptor instead')
const TestMempoolAcceptResponse$json = {
  '1': 'TestMempoolAcceptResponse',
  '2': [
    {
      '1': 'results',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.bitcoin.bitcoind.v1alpha.TestMempoolAcceptResponse.Result',
      '10': 'results'
    },
  ],
  '3': [TestMempoolAcceptResponse_Result$json],
};

@$core.Deprecated('Use testMempoolAcceptResponseDescriptor instead')
const TestMempoolAcceptResponse_Result$json = {
  '1': 'Result',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'allowed', '3': 2, '4': 1, '5': 8, '10': 'allowed'},
    {'1': 'reject_reason', '3': 3, '4': 1, '5': 9, '10': 'rejectReason'},
    {'1': 'vsize', '3': 4, '4': 1, '5': 13, '10': 'vsize'},
    {'1': 'fees', '3': 5, '4': 1, '5': 1, '10': 'fees'},
  ],
};

/// Descriptor for `TestMempoolAcceptResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List testMempoolAcceptResponseDescriptor =
    $convert.base64Decode('ChlUZXN0TWVtcG9vbEFjY2VwdFJlc3BvbnNlElQKB3Jlc3VsdHMYASADKAsyOi5iaXRjb2luLm'
        'JpdGNvaW5kLnYxYWxwaGEuVGVzdE1lbXBvb2xBY2NlcHRSZXNwb25zZS5SZXN1bHRSB3Jlc3Vs'
        'dHMahQEKBlJlc3VsdBISCgR0eGlkGAEgASgJUgR0eGlkEhgKB2FsbG93ZWQYAiABKAhSB2FsbG'
        '93ZWQSIwoNcmVqZWN0X3JlYXNvbhgDIAEoCVIMcmVqZWN0UmVhc29uEhQKBXZzaXplGAQgASgN'
        'UgV2c2l6ZRISCgRmZWVzGAUgASgBUgRmZWVz');

@$core.Deprecated('Use descriptorRangeDescriptor instead')
const DescriptorRange$json = {
  '1': 'DescriptorRange',
  '2': [
    {'1': 'end', '3': 1, '4': 1, '5': 5, '9': 0, '10': 'end'},
    {'1': 'range', '3': 2, '4': 1, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.Range', '9': 0, '10': 'range'},
  ],
  '8': [
    {'1': 'range_type'},
  ],
};

/// Descriptor for `DescriptorRange`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List descriptorRangeDescriptor =
    $convert.base64Decode('Cg9EZXNjcmlwdG9yUmFuZ2USEgoDZW5kGAEgASgFSABSA2VuZBI3CgVyYW5nZRgCIAEoCzIfLm'
        'JpdGNvaW4uYml0Y29pbmQudjFhbHBoYS5SYW5nZUgAUgVyYW5nZUIMCgpyYW5nZV90eXBl');

@$core.Deprecated('Use rangeDescriptor instead')
const Range$json = {
  '1': 'Range',
  '2': [
    {'1': 'begin', '3': 1, '4': 1, '5': 5, '10': 'begin'},
    {'1': 'end', '3': 2, '4': 1, '5': 5, '10': 'end'},
  ],
};

/// Descriptor for `Range`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rangeDescriptor =
    $convert.base64Decode('CgVSYW5nZRIUCgViZWdpbhgBIAEoBVIFYmVnaW4SEAoDZW5kGAIgASgFUgNlbmQ=');

@$core.Deprecated('Use descriptorDescriptor instead')
const Descriptor$json = {
  '1': 'Descriptor',
  '2': [
    {'1': 'string_descriptor', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'stringDescriptor'},
    {
      '1': 'object_descriptor',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.bitcoin.bitcoind.v1alpha.DescriptorObject',
      '9': 0,
      '10': 'objectDescriptor'
    },
  ],
  '8': [
    {'1': 'descriptor'},
  ],
};

/// Descriptor for `Descriptor`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List descriptorDescriptor =
    $convert.base64Decode('CgpEZXNjcmlwdG9yEi0KEXN0cmluZ19kZXNjcmlwdG9yGAEgASgJSABSEHN0cmluZ0Rlc2NyaX'
        'B0b3ISWQoRb2JqZWN0X2Rlc2NyaXB0b3IYAiABKAsyKi5iaXRjb2luLmJpdGNvaW5kLnYxYWxw'
        'aGEuRGVzY3JpcHRvck9iamVjdEgAUhBvYmplY3REZXNjcmlwdG9yQgwKCmRlc2NyaXB0b3I=');

@$core.Deprecated('Use descriptorObjectDescriptor instead')
const DescriptorObject$json = {
  '1': 'DescriptorObject',
  '2': [
    {'1': 'desc', '3': 1, '4': 1, '5': 9, '10': 'desc'},
    {'1': 'range', '3': 2, '4': 1, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.DescriptorRange', '10': 'range'},
  ],
};

/// Descriptor for `DescriptorObject`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List descriptorObjectDescriptor =
    $convert.base64Decode('ChBEZXNjcmlwdG9yT2JqZWN0EhIKBGRlc2MYASABKAlSBGRlc2MSPwoFcmFuZ2UYAiABKAsyKS'
        '5iaXRjb2luLmJpdGNvaW5kLnYxYWxwaGEuRGVzY3JpcHRvclJhbmdlUgVyYW5nZQ==');

@$core.Deprecated('Use getZmqNotificationsResponseDescriptor instead')
const GetZmqNotificationsResponse$json = {
  '1': 'GetZmqNotificationsResponse',
  '2': [
    {
      '1': 'notifications',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.bitcoin.bitcoind.v1alpha.GetZmqNotificationsResponse.Notification',
      '10': 'notifications'
    },
  ],
  '3': [GetZmqNotificationsResponse_Notification$json],
};

@$core.Deprecated('Use getZmqNotificationsResponseDescriptor instead')
const GetZmqNotificationsResponse_Notification$json = {
  '1': 'Notification',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 9, '10': 'type'},
    {'1': 'address', '3': 2, '4': 1, '5': 9, '10': 'address'},
    {'1': 'high_water_mark', '3': 3, '4': 1, '5': 3, '10': 'highWaterMark'},
  ],
};

/// Descriptor for `GetZmqNotificationsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getZmqNotificationsResponseDescriptor =
    $convert.base64Decode('ChtHZXRabXFOb3RpZmljYXRpb25zUmVzcG9uc2USaAoNbm90aWZpY2F0aW9ucxgBIAMoCzJCLm'
        'JpdGNvaW4uYml0Y29pbmQudjFhbHBoYS5HZXRabXFOb3RpZmljYXRpb25zUmVzcG9uc2UuTm90'
        'aWZpY2F0aW9uUg1ub3RpZmljYXRpb25zGmQKDE5vdGlmaWNhdGlvbhISCgR0eXBlGAEgASgJUg'
        'R0eXBlEhgKB2FkZHJlc3MYAiABKAlSB2FkZHJlc3MSJgoPaGlnaF93YXRlcl9tYXJrGAMgASgD'
        'Ug1oaWdoV2F0ZXJNYXJr');

const $core.Map<$core.String, $core.dynamic> BitcoinServiceBase$json = {
  '1': 'BitcoinService',
  '2': [
    {
      '1': 'GetBlockchainInfo',
      '2': '.bitcoin.bitcoind.v1alpha.GetBlockchainInfoRequest',
      '3': '.bitcoin.bitcoind.v1alpha.GetBlockchainInfoResponse'
    },
    {
      '1': 'GetPeerInfo',
      '2': '.bitcoin.bitcoind.v1alpha.GetPeerInfoRequest',
      '3': '.bitcoin.bitcoind.v1alpha.GetPeerInfoResponse'
    },
    {
      '1': 'GetTransaction',
      '2': '.bitcoin.bitcoind.v1alpha.GetTransactionRequest',
      '3': '.bitcoin.bitcoind.v1alpha.GetTransactionResponse'
    },
    {
      '1': 'ListSinceBlock',
      '2': '.bitcoin.bitcoind.v1alpha.ListSinceBlockRequest',
      '3': '.bitcoin.bitcoind.v1alpha.ListSinceBlockResponse'
    },
    {
      '1': 'GetNewAddress',
      '2': '.bitcoin.bitcoind.v1alpha.GetNewAddressRequest',
      '3': '.bitcoin.bitcoind.v1alpha.GetNewAddressResponse'
    },
    {
      '1': 'GetWalletInfo',
      '2': '.bitcoin.bitcoind.v1alpha.GetWalletInfoRequest',
      '3': '.bitcoin.bitcoind.v1alpha.GetWalletInfoResponse'
    },
    {
      '1': 'GetBalances',
      '2': '.bitcoin.bitcoind.v1alpha.GetBalancesRequest',
      '3': '.bitcoin.bitcoind.v1alpha.GetBalancesResponse'
    },
    {'1': 'Send', '2': '.bitcoin.bitcoind.v1alpha.SendRequest', '3': '.bitcoin.bitcoind.v1alpha.SendResponse'},
    {
      '1': 'SendToAddress',
      '2': '.bitcoin.bitcoind.v1alpha.SendToAddressRequest',
      '3': '.bitcoin.bitcoind.v1alpha.SendToAddressResponse'
    },
    {'1': 'BumpFee', '2': '.bitcoin.bitcoind.v1alpha.BumpFeeRequest', '3': '.bitcoin.bitcoind.v1alpha.BumpFeeResponse'},
    {
      '1': 'EstimateSmartFee',
      '2': '.bitcoin.bitcoind.v1alpha.EstimateSmartFeeRequest',
      '3': '.bitcoin.bitcoind.v1alpha.EstimateSmartFeeResponse'
    },
    {
      '1': 'ImportDescriptors',
      '2': '.bitcoin.bitcoind.v1alpha.ImportDescriptorsRequest',
      '3': '.bitcoin.bitcoind.v1alpha.ImportDescriptorsResponse'
    },
    {'1': 'ListWallets', '2': '.google.protobuf.Empty', '3': '.bitcoin.bitcoind.v1alpha.ListWalletsResponse'},
    {
      '1': 'ListUnspent',
      '2': '.bitcoin.bitcoind.v1alpha.ListUnspentRequest',
      '3': '.bitcoin.bitcoind.v1alpha.ListUnspentResponse'
    },
    {
      '1': 'ListTransactions',
      '2': '.bitcoin.bitcoind.v1alpha.ListTransactionsRequest',
      '3': '.bitcoin.bitcoind.v1alpha.ListTransactionsResponse'
    },
    {
      '1': 'GetDescriptorInfo',
      '2': '.bitcoin.bitcoind.v1alpha.GetDescriptorInfoRequest',
      '3': '.bitcoin.bitcoind.v1alpha.GetDescriptorInfoResponse'
    },
    {
      '1': 'GetAddressInfo',
      '2': '.bitcoin.bitcoind.v1alpha.GetAddressInfoRequest',
      '3': '.bitcoin.bitcoind.v1alpha.GetAddressInfoResponse'
    },
    {
      '1': 'GetRawMempool',
      '2': '.bitcoin.bitcoind.v1alpha.GetRawMempoolRequest',
      '3': '.bitcoin.bitcoind.v1alpha.GetRawMempoolResponse'
    },
    {
      '1': 'GetRawTransaction',
      '2': '.bitcoin.bitcoind.v1alpha.GetRawTransactionRequest',
      '3': '.bitcoin.bitcoind.v1alpha.GetRawTransactionResponse'
    },
    {
      '1': 'DecodeRawTransaction',
      '2': '.bitcoin.bitcoind.v1alpha.DecodeRawTransactionRequest',
      '3': '.bitcoin.bitcoind.v1alpha.DecodeRawTransactionResponse'
    },
    {
      '1': 'CreateRawTransaction',
      '2': '.bitcoin.bitcoind.v1alpha.CreateRawTransactionRequest',
      '3': '.bitcoin.bitcoind.v1alpha.CreateRawTransactionResponse'
    },
    {
      '1': 'GetBlock',
      '2': '.bitcoin.bitcoind.v1alpha.GetBlockRequest',
      '3': '.bitcoin.bitcoind.v1alpha.GetBlockResponse'
    },
    {
      '1': 'GetBlockHash',
      '2': '.bitcoin.bitcoind.v1alpha.GetBlockHashRequest',
      '3': '.bitcoin.bitcoind.v1alpha.GetBlockHashResponse'
    },
    {
      '1': 'CreateWallet',
      '2': '.bitcoin.bitcoind.v1alpha.CreateWalletRequest',
      '3': '.bitcoin.bitcoind.v1alpha.CreateWalletResponse'
    },
    {
      '1': 'BackupWallet',
      '2': '.bitcoin.bitcoind.v1alpha.BackupWalletRequest',
      '3': '.bitcoin.bitcoind.v1alpha.BackupWalletResponse'
    },
    {
      '1': 'DumpWallet',
      '2': '.bitcoin.bitcoind.v1alpha.DumpWalletRequest',
      '3': '.bitcoin.bitcoind.v1alpha.DumpWalletResponse'
    },
    {
      '1': 'ImportWallet',
      '2': '.bitcoin.bitcoind.v1alpha.ImportWalletRequest',
      '3': '.bitcoin.bitcoind.v1alpha.ImportWalletResponse'
    },
    {
      '1': 'UnloadWallet',
      '2': '.bitcoin.bitcoind.v1alpha.UnloadWalletRequest',
      '3': '.bitcoin.bitcoind.v1alpha.UnloadWalletResponse'
    },
    {
      '1': 'DumpPrivKey',
      '2': '.bitcoin.bitcoind.v1alpha.DumpPrivKeyRequest',
      '3': '.bitcoin.bitcoind.v1alpha.DumpPrivKeyResponse'
    },
    {
      '1': 'ImportPrivKey',
      '2': '.bitcoin.bitcoind.v1alpha.ImportPrivKeyRequest',
      '3': '.bitcoin.bitcoind.v1alpha.ImportPrivKeyResponse'
    },
    {
      '1': 'ImportAddress',
      '2': '.bitcoin.bitcoind.v1alpha.ImportAddressRequest',
      '3': '.bitcoin.bitcoind.v1alpha.ImportAddressResponse'
    },
    {
      '1': 'ImportPubKey',
      '2': '.bitcoin.bitcoind.v1alpha.ImportPubKeyRequest',
      '3': '.bitcoin.bitcoind.v1alpha.ImportPubKeyResponse'
    },
    {
      '1': 'KeyPoolRefill',
      '2': '.bitcoin.bitcoind.v1alpha.KeyPoolRefillRequest',
      '3': '.bitcoin.bitcoind.v1alpha.KeyPoolRefillResponse'
    },
    {
      '1': 'GetAccount',
      '2': '.bitcoin.bitcoind.v1alpha.GetAccountRequest',
      '3': '.bitcoin.bitcoind.v1alpha.GetAccountResponse'
    },
    {
      '1': 'SetAccount',
      '2': '.bitcoin.bitcoind.v1alpha.SetAccountRequest',
      '3': '.bitcoin.bitcoind.v1alpha.SetAccountResponse'
    },
    {
      '1': 'GetAddressesByAccount',
      '2': '.bitcoin.bitcoind.v1alpha.GetAddressesByAccountRequest',
      '3': '.bitcoin.bitcoind.v1alpha.GetAddressesByAccountResponse'
    },
    {
      '1': 'ListAccounts',
      '2': '.bitcoin.bitcoind.v1alpha.ListAccountsRequest',
      '3': '.bitcoin.bitcoind.v1alpha.ListAccountsResponse'
    },
    {
      '1': 'AddMultisigAddress',
      '2': '.bitcoin.bitcoind.v1alpha.AddMultisigAddressRequest',
      '3': '.bitcoin.bitcoind.v1alpha.AddMultisigAddressResponse'
    },
    {
      '1': 'CreateMultisig',
      '2': '.bitcoin.bitcoind.v1alpha.CreateMultisigRequest',
      '3': '.bitcoin.bitcoind.v1alpha.CreateMultisigResponse'
    },
    {
      '1': 'CreatePsbt',
      '2': '.bitcoin.bitcoind.v1alpha.CreatePsbtRequest',
      '3': '.bitcoin.bitcoind.v1alpha.CreatePsbtResponse'
    },
    {
      '1': 'DecodePsbt',
      '2': '.bitcoin.bitcoind.v1alpha.DecodePsbtRequest',
      '3': '.bitcoin.bitcoind.v1alpha.DecodePsbtResponse'
    },
    {
      '1': 'AnalyzePsbt',
      '2': '.bitcoin.bitcoind.v1alpha.AnalyzePsbtRequest',
      '3': '.bitcoin.bitcoind.v1alpha.AnalyzePsbtResponse'
    },
    {
      '1': 'CombinePsbt',
      '2': '.bitcoin.bitcoind.v1alpha.CombinePsbtRequest',
      '3': '.bitcoin.bitcoind.v1alpha.CombinePsbtResponse'
    },
    {
      '1': 'UtxoUpdatePsbt',
      '2': '.bitcoin.bitcoind.v1alpha.UtxoUpdatePsbtRequest',
      '3': '.bitcoin.bitcoind.v1alpha.UtxoUpdatePsbtResponse'
    },
    {
      '1': 'JoinPsbts',
      '2': '.bitcoin.bitcoind.v1alpha.JoinPsbtsRequest',
      '3': '.bitcoin.bitcoind.v1alpha.JoinPsbtsResponse'
    },
    {
      '1': 'TestMempoolAccept',
      '2': '.bitcoin.bitcoind.v1alpha.TestMempoolAcceptRequest',
      '3': '.bitcoin.bitcoind.v1alpha.TestMempoolAcceptResponse'
    },
    {
      '1': 'GetZmqNotifications',
      '2': '.google.protobuf.Empty',
      '3': '.bitcoin.bitcoind.v1alpha.GetZmqNotificationsResponse'
    },
  ],
};

@$core.Deprecated('Use bitcoinServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> BitcoinServiceBase$messageJson = {
  '.bitcoin.bitcoind.v1alpha.GetBlockchainInfoRequest': GetBlockchainInfoRequest$json,
  '.bitcoin.bitcoind.v1alpha.GetBlockchainInfoResponse': GetBlockchainInfoResponse$json,
  '.bitcoin.bitcoind.v1alpha.GetPeerInfoRequest': GetPeerInfoRequest$json,
  '.bitcoin.bitcoind.v1alpha.GetPeerInfoResponse': GetPeerInfoResponse$json,
  '.bitcoin.bitcoind.v1alpha.Peer': Peer$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.google.protobuf.Duration': $1.Duration$json,
  '.bitcoin.bitcoind.v1alpha.Peer.BytesSentPerMsgEntry': Peer_BytesSentPerMsgEntry$json,
  '.bitcoin.bitcoind.v1alpha.Peer.BytesReceivedPerMsgEntry': Peer_BytesReceivedPerMsgEntry$json,
  '.bitcoin.bitcoind.v1alpha.GetTransactionRequest': GetTransactionRequest$json,
  '.bitcoin.bitcoind.v1alpha.GetTransactionResponse': GetTransactionResponse$json,
  '.bitcoin.bitcoind.v1alpha.GetTransactionResponse.Details': GetTransactionResponse_Details$json,
  '.bitcoin.bitcoind.v1alpha.ListSinceBlockRequest': ListSinceBlockRequest$json,
  '.bitcoin.bitcoind.v1alpha.ListSinceBlockResponse': ListSinceBlockResponse$json,
  '.bitcoin.bitcoind.v1alpha.GetNewAddressRequest': GetNewAddressRequest$json,
  '.bitcoin.bitcoind.v1alpha.GetNewAddressResponse': GetNewAddressResponse$json,
  '.bitcoin.bitcoind.v1alpha.GetWalletInfoRequest': GetWalletInfoRequest$json,
  '.bitcoin.bitcoind.v1alpha.GetWalletInfoResponse': GetWalletInfoResponse$json,
  '.bitcoin.bitcoind.v1alpha.WalletScan': WalletScan$json,
  '.bitcoin.bitcoind.v1alpha.GetBalancesRequest': GetBalancesRequest$json,
  '.bitcoin.bitcoind.v1alpha.GetBalancesResponse': GetBalancesResponse$json,
  '.bitcoin.bitcoind.v1alpha.GetBalancesResponse.Mine': GetBalancesResponse_Mine$json,
  '.bitcoin.bitcoind.v1alpha.GetBalancesResponse.Watchonly': GetBalancesResponse_Watchonly$json,
  '.bitcoin.bitcoind.v1alpha.SendRequest': SendRequest$json,
  '.bitcoin.bitcoind.v1alpha.SendRequest.DestinationsEntry': SendRequest_DestinationsEntry$json,
  '.google.protobuf.BoolValue': $2.BoolValue$json,
  '.bitcoin.bitcoind.v1alpha.SendResponse': SendResponse$json,
  '.bitcoin.bitcoind.v1alpha.RawTransaction': RawTransaction$json,
  '.bitcoin.bitcoind.v1alpha.SendToAddressRequest': SendToAddressRequest$json,
  '.bitcoin.bitcoind.v1alpha.SendToAddressResponse': SendToAddressResponse$json,
  '.bitcoin.bitcoind.v1alpha.BumpFeeRequest': BumpFeeRequest$json,
  '.bitcoin.bitcoind.v1alpha.BumpFeeResponse': BumpFeeResponse$json,
  '.bitcoin.bitcoind.v1alpha.EstimateSmartFeeRequest': EstimateSmartFeeRequest$json,
  '.bitcoin.bitcoind.v1alpha.EstimateSmartFeeResponse': EstimateSmartFeeResponse$json,
  '.bitcoin.bitcoind.v1alpha.ImportDescriptorsRequest': ImportDescriptorsRequest$json,
  '.bitcoin.bitcoind.v1alpha.ImportDescriptorsRequest.Request': ImportDescriptorsRequest_Request$json,
  '.bitcoin.bitcoind.v1alpha.ImportDescriptorsResponse': ImportDescriptorsResponse$json,
  '.bitcoin.bitcoind.v1alpha.ImportDescriptorsResponse.Response': ImportDescriptorsResponse_Response$json,
  '.bitcoin.bitcoind.v1alpha.ImportDescriptorsResponse.Error': ImportDescriptorsResponse_Error$json,
  '.google.protobuf.Empty': $3.Empty$json,
  '.bitcoin.bitcoind.v1alpha.ListWalletsResponse': ListWalletsResponse$json,
  '.bitcoin.bitcoind.v1alpha.ListUnspentRequest': ListUnspentRequest$json,
  '.bitcoin.bitcoind.v1alpha.ListUnspentResponse': ListUnspentResponse$json,
  '.bitcoin.bitcoind.v1alpha.UnspentOutput': UnspentOutput$json,
  '.bitcoin.bitcoind.v1alpha.ListTransactionsRequest': ListTransactionsRequest$json,
  '.bitcoin.bitcoind.v1alpha.ListTransactionsResponse': ListTransactionsResponse$json,
  '.bitcoin.bitcoind.v1alpha.GetDescriptorInfoRequest': GetDescriptorInfoRequest$json,
  '.bitcoin.bitcoind.v1alpha.GetDescriptorInfoResponse': GetDescriptorInfoResponse$json,
  '.bitcoin.bitcoind.v1alpha.GetAddressInfoRequest': GetAddressInfoRequest$json,
  '.bitcoin.bitcoind.v1alpha.GetAddressInfoResponse': GetAddressInfoResponse$json,
  '.bitcoin.bitcoind.v1alpha.GetRawMempoolRequest': GetRawMempoolRequest$json,
  '.bitcoin.bitcoind.v1alpha.GetRawMempoolResponse': GetRawMempoolResponse$json,
  '.bitcoin.bitcoind.v1alpha.GetRawMempoolResponse.TransactionsEntry': GetRawMempoolResponse_TransactionsEntry$json,
  '.bitcoin.bitcoind.v1alpha.MempoolEntry': MempoolEntry$json,
  '.bitcoin.bitcoind.v1alpha.MempoolEntry.Fees': MempoolEntry_Fees$json,
  '.bitcoin.bitcoind.v1alpha.GetRawTransactionRequest': GetRawTransactionRequest$json,
  '.bitcoin.bitcoind.v1alpha.GetRawTransactionResponse': GetRawTransactionResponse$json,
  '.bitcoin.bitcoind.v1alpha.Input': Input$json,
  '.bitcoin.bitcoind.v1alpha.ScriptSig': ScriptSig$json,
  '.bitcoin.bitcoind.v1alpha.Output': Output$json,
  '.bitcoin.bitcoind.v1alpha.ScriptPubKey': ScriptPubKey$json,
  '.bitcoin.bitcoind.v1alpha.DecodeRawTransactionRequest': DecodeRawTransactionRequest$json,
  '.bitcoin.bitcoind.v1alpha.DecodeRawTransactionResponse': DecodeRawTransactionResponse$json,
  '.bitcoin.bitcoind.v1alpha.CreateRawTransactionRequest': CreateRawTransactionRequest$json,
  '.bitcoin.bitcoind.v1alpha.CreateRawTransactionRequest.Input': CreateRawTransactionRequest_Input$json,
  '.bitcoin.bitcoind.v1alpha.CreateRawTransactionRequest.OutputsEntry': CreateRawTransactionRequest_OutputsEntry$json,
  '.bitcoin.bitcoind.v1alpha.CreateRawTransactionResponse': CreateRawTransactionResponse$json,
  '.bitcoin.bitcoind.v1alpha.GetBlockRequest': GetBlockRequest$json,
  '.bitcoin.bitcoind.v1alpha.GetBlockResponse': GetBlockResponse$json,
  '.bitcoin.bitcoind.v1alpha.GetBlockHashRequest': GetBlockHashRequest$json,
  '.bitcoin.bitcoind.v1alpha.GetBlockHashResponse': GetBlockHashResponse$json,
  '.bitcoin.bitcoind.v1alpha.CreateWalletRequest': CreateWalletRequest$json,
  '.bitcoin.bitcoind.v1alpha.CreateWalletResponse': CreateWalletResponse$json,
  '.bitcoin.bitcoind.v1alpha.BackupWalletRequest': BackupWalletRequest$json,
  '.bitcoin.bitcoind.v1alpha.BackupWalletResponse': BackupWalletResponse$json,
  '.bitcoin.bitcoind.v1alpha.DumpWalletRequest': DumpWalletRequest$json,
  '.bitcoin.bitcoind.v1alpha.DumpWalletResponse': DumpWalletResponse$json,
  '.bitcoin.bitcoind.v1alpha.ImportWalletRequest': ImportWalletRequest$json,
  '.bitcoin.bitcoind.v1alpha.ImportWalletResponse': ImportWalletResponse$json,
  '.bitcoin.bitcoind.v1alpha.UnloadWalletRequest': UnloadWalletRequest$json,
  '.bitcoin.bitcoind.v1alpha.UnloadWalletResponse': UnloadWalletResponse$json,
  '.bitcoin.bitcoind.v1alpha.DumpPrivKeyRequest': DumpPrivKeyRequest$json,
  '.bitcoin.bitcoind.v1alpha.DumpPrivKeyResponse': DumpPrivKeyResponse$json,
  '.bitcoin.bitcoind.v1alpha.ImportPrivKeyRequest': ImportPrivKeyRequest$json,
  '.bitcoin.bitcoind.v1alpha.ImportPrivKeyResponse': ImportPrivKeyResponse$json,
  '.bitcoin.bitcoind.v1alpha.ImportAddressRequest': ImportAddressRequest$json,
  '.bitcoin.bitcoind.v1alpha.ImportAddressResponse': ImportAddressResponse$json,
  '.bitcoin.bitcoind.v1alpha.ImportPubKeyRequest': ImportPubKeyRequest$json,
  '.bitcoin.bitcoind.v1alpha.ImportPubKeyResponse': ImportPubKeyResponse$json,
  '.bitcoin.bitcoind.v1alpha.KeyPoolRefillRequest': KeyPoolRefillRequest$json,
  '.bitcoin.bitcoind.v1alpha.KeyPoolRefillResponse': KeyPoolRefillResponse$json,
  '.bitcoin.bitcoind.v1alpha.GetAccountRequest': GetAccountRequest$json,
  '.bitcoin.bitcoind.v1alpha.GetAccountResponse': GetAccountResponse$json,
  '.bitcoin.bitcoind.v1alpha.SetAccountRequest': SetAccountRequest$json,
  '.bitcoin.bitcoind.v1alpha.SetAccountResponse': SetAccountResponse$json,
  '.bitcoin.bitcoind.v1alpha.GetAddressesByAccountRequest': GetAddressesByAccountRequest$json,
  '.bitcoin.bitcoind.v1alpha.GetAddressesByAccountResponse': GetAddressesByAccountResponse$json,
  '.bitcoin.bitcoind.v1alpha.ListAccountsRequest': ListAccountsRequest$json,
  '.bitcoin.bitcoind.v1alpha.ListAccountsResponse': ListAccountsResponse$json,
  '.bitcoin.bitcoind.v1alpha.ListAccountsResponse.AccountsEntry': ListAccountsResponse_AccountsEntry$json,
  '.bitcoin.bitcoind.v1alpha.AddMultisigAddressRequest': AddMultisigAddressRequest$json,
  '.bitcoin.bitcoind.v1alpha.AddMultisigAddressResponse': AddMultisigAddressResponse$json,
  '.bitcoin.bitcoind.v1alpha.CreateMultisigRequest': CreateMultisigRequest$json,
  '.bitcoin.bitcoind.v1alpha.CreateMultisigResponse': CreateMultisigResponse$json,
  '.bitcoin.bitcoind.v1alpha.CreatePsbtRequest': CreatePsbtRequest$json,
  '.bitcoin.bitcoind.v1alpha.CreatePsbtRequest.Input': CreatePsbtRequest_Input$json,
  '.bitcoin.bitcoind.v1alpha.CreatePsbtRequest.OutputsEntry': CreatePsbtRequest_OutputsEntry$json,
  '.bitcoin.bitcoind.v1alpha.CreatePsbtResponse': CreatePsbtResponse$json,
  '.bitcoin.bitcoind.v1alpha.DecodePsbtRequest': DecodePsbtRequest$json,
  '.bitcoin.bitcoind.v1alpha.DecodePsbtResponse': DecodePsbtResponse$json,
  '.bitcoin.bitcoind.v1alpha.DecodePsbtResponse.UnknownEntry': DecodePsbtResponse_UnknownEntry$json,
  '.bitcoin.bitcoind.v1alpha.DecodePsbtResponse.Input': DecodePsbtResponse_Input$json,
  '.bitcoin.bitcoind.v1alpha.DecodePsbtResponse.WitnessUtxo': DecodePsbtResponse_WitnessUtxo$json,
  '.bitcoin.bitcoind.v1alpha.DecodePsbtResponse.Input.PartialSignaturesEntry':
      DecodePsbtResponse_Input_PartialSignaturesEntry$json,
  '.bitcoin.bitcoind.v1alpha.DecodePsbtResponse.RedeemScript': DecodePsbtResponse_RedeemScript$json,
  '.bitcoin.bitcoind.v1alpha.DecodePsbtResponse.Bip32Deriv': DecodePsbtResponse_Bip32Deriv$json,
  '.bitcoin.bitcoind.v1alpha.DecodePsbtResponse.Input.UnknownEntry': DecodePsbtResponse_Input_UnknownEntry$json,
  '.bitcoin.bitcoind.v1alpha.DecodePsbtResponse.Output': DecodePsbtResponse_Output$json,
  '.bitcoin.bitcoind.v1alpha.DecodePsbtResponse.Output.UnknownEntry': DecodePsbtResponse_Output_UnknownEntry$json,
  '.bitcoin.bitcoind.v1alpha.AnalyzePsbtRequest': AnalyzePsbtRequest$json,
  '.bitcoin.bitcoind.v1alpha.AnalyzePsbtResponse': AnalyzePsbtResponse$json,
  '.bitcoin.bitcoind.v1alpha.AnalyzePsbtResponse.Input': AnalyzePsbtResponse_Input$json,
  '.bitcoin.bitcoind.v1alpha.AnalyzePsbtResponse.Input.Missing': AnalyzePsbtResponse_Input_Missing$json,
  '.bitcoin.bitcoind.v1alpha.CombinePsbtRequest': CombinePsbtRequest$json,
  '.bitcoin.bitcoind.v1alpha.CombinePsbtResponse': CombinePsbtResponse$json,
  '.bitcoin.bitcoind.v1alpha.UtxoUpdatePsbtRequest': UtxoUpdatePsbtRequest$json,
  '.bitcoin.bitcoind.v1alpha.Descriptor': Descriptor$json,
  '.bitcoin.bitcoind.v1alpha.DescriptorObject': DescriptorObject$json,
  '.bitcoin.bitcoind.v1alpha.DescriptorRange': DescriptorRange$json,
  '.bitcoin.bitcoind.v1alpha.Range': Range$json,
  '.bitcoin.bitcoind.v1alpha.UtxoUpdatePsbtResponse': UtxoUpdatePsbtResponse$json,
  '.bitcoin.bitcoind.v1alpha.JoinPsbtsRequest': JoinPsbtsRequest$json,
  '.bitcoin.bitcoind.v1alpha.JoinPsbtsResponse': JoinPsbtsResponse$json,
  '.bitcoin.bitcoind.v1alpha.TestMempoolAcceptRequest': TestMempoolAcceptRequest$json,
  '.bitcoin.bitcoind.v1alpha.TestMempoolAcceptResponse': TestMempoolAcceptResponse$json,
  '.bitcoin.bitcoind.v1alpha.TestMempoolAcceptResponse.Result': TestMempoolAcceptResponse_Result$json,
  '.bitcoin.bitcoind.v1alpha.GetZmqNotificationsResponse': GetZmqNotificationsResponse$json,
  '.bitcoin.bitcoind.v1alpha.GetZmqNotificationsResponse.Notification': GetZmqNotificationsResponse_Notification$json,
};

/// Descriptor for `BitcoinService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List bitcoinServiceDescriptor =
    $convert.base64Decode('Cg5CaXRjb2luU2VydmljZRJ8ChFHZXRCbG9ja2NoYWluSW5mbxIyLmJpdGNvaW4uYml0Y29pbm'
        'QudjFhbHBoYS5HZXRCbG9ja2NoYWluSW5mb1JlcXVlc3QaMy5iaXRjb2luLmJpdGNvaW5kLnYx'
        'YWxwaGEuR2V0QmxvY2tjaGFpbkluZm9SZXNwb25zZRJqCgtHZXRQZWVySW5mbxIsLmJpdGNvaW'
        '4uYml0Y29pbmQudjFhbHBoYS5HZXRQZWVySW5mb1JlcXVlc3QaLS5iaXRjb2luLmJpdGNvaW5k'
        'LnYxYWxwaGEuR2V0UGVlckluZm9SZXNwb25zZRJzCg5HZXRUcmFuc2FjdGlvbhIvLmJpdGNvaW'
        '4uYml0Y29pbmQudjFhbHBoYS5HZXRUcmFuc2FjdGlvblJlcXVlc3QaMC5iaXRjb2luLmJpdGNv'
        'aW5kLnYxYWxwaGEuR2V0VHJhbnNhY3Rpb25SZXNwb25zZRJzCg5MaXN0U2luY2VCbG9jaxIvLm'
        'JpdGNvaW4uYml0Y29pbmQudjFhbHBoYS5MaXN0U2luY2VCbG9ja1JlcXVlc3QaMC5iaXRjb2lu'
        'LmJpdGNvaW5kLnYxYWxwaGEuTGlzdFNpbmNlQmxvY2tSZXNwb25zZRJwCg1HZXROZXdBZGRyZX'
        'NzEi4uYml0Y29pbi5iaXRjb2luZC52MWFscGhhLkdldE5ld0FkZHJlc3NSZXF1ZXN0Gi8uYml0'
        'Y29pbi5iaXRjb2luZC52MWFscGhhLkdldE5ld0FkZHJlc3NSZXNwb25zZRJwCg1HZXRXYWxsZX'
        'RJbmZvEi4uYml0Y29pbi5iaXRjb2luZC52MWFscGhhLkdldFdhbGxldEluZm9SZXF1ZXN0Gi8u'
        'Yml0Y29pbi5iaXRjb2luZC52MWFscGhhLkdldFdhbGxldEluZm9SZXNwb25zZRJqCgtHZXRCYW'
        'xhbmNlcxIsLmJpdGNvaW4uYml0Y29pbmQudjFhbHBoYS5HZXRCYWxhbmNlc1JlcXVlc3QaLS5i'
        'aXRjb2luLmJpdGNvaW5kLnYxYWxwaGEuR2V0QmFsYW5jZXNSZXNwb25zZRJVCgRTZW5kEiUuYm'
        'l0Y29pbi5iaXRjb2luZC52MWFscGhhLlNlbmRSZXF1ZXN0GiYuYml0Y29pbi5iaXRjb2luZC52'
        'MWFscGhhLlNlbmRSZXNwb25zZRJwCg1TZW5kVG9BZGRyZXNzEi4uYml0Y29pbi5iaXRjb2luZC'
        '52MWFscGhhLlNlbmRUb0FkZHJlc3NSZXF1ZXN0Gi8uYml0Y29pbi5iaXRjb2luZC52MWFscGhh'
        'LlNlbmRUb0FkZHJlc3NSZXNwb25zZRJeCgdCdW1wRmVlEiguYml0Y29pbi5iaXRjb2luZC52MW'
        'FscGhhLkJ1bXBGZWVSZXF1ZXN0GikuYml0Y29pbi5iaXRjb2luZC52MWFscGhhLkJ1bXBGZWVS'
        'ZXNwb25zZRJ5ChBFc3RpbWF0ZVNtYXJ0RmVlEjEuYml0Y29pbi5iaXRjb2luZC52MWFscGhhLk'
        'VzdGltYXRlU21hcnRGZWVSZXF1ZXN0GjIuYml0Y29pbi5iaXRjb2luZC52MWFscGhhLkVzdGlt'
        'YXRlU21hcnRGZWVSZXNwb25zZRJ8ChFJbXBvcnREZXNjcmlwdG9ycxIyLmJpdGNvaW4uYml0Y2'
        '9pbmQudjFhbHBoYS5JbXBvcnREZXNjcmlwdG9yc1JlcXVlc3QaMy5iaXRjb2luLmJpdGNvaW5k'
        'LnYxYWxwaGEuSW1wb3J0RGVzY3JpcHRvcnNSZXNwb25zZRJUCgtMaXN0V2FsbGV0cxIWLmdvb2'
        'dsZS5wcm90b2J1Zi5FbXB0eRotLmJpdGNvaW4uYml0Y29pbmQudjFhbHBoYS5MaXN0V2FsbGV0'
        'c1Jlc3BvbnNlEmoKC0xpc3RVbnNwZW50EiwuYml0Y29pbi5iaXRjb2luZC52MWFscGhhLkxpc3'
        'RVbnNwZW50UmVxdWVzdBotLmJpdGNvaW4uYml0Y29pbmQudjFhbHBoYS5MaXN0VW5zcGVudFJl'
        'c3BvbnNlEnkKEExpc3RUcmFuc2FjdGlvbnMSMS5iaXRjb2luLmJpdGNvaW5kLnYxYWxwaGEuTG'
        'lzdFRyYW5zYWN0aW9uc1JlcXVlc3QaMi5iaXRjb2luLmJpdGNvaW5kLnYxYWxwaGEuTGlzdFRy'
        'YW5zYWN0aW9uc1Jlc3BvbnNlEnwKEUdldERlc2NyaXB0b3JJbmZvEjIuYml0Y29pbi5iaXRjb2'
        'luZC52MWFscGhhLkdldERlc2NyaXB0b3JJbmZvUmVxdWVzdBozLmJpdGNvaW4uYml0Y29pbmQu'
        'djFhbHBoYS5HZXREZXNjcmlwdG9ySW5mb1Jlc3BvbnNlEnMKDkdldEFkZHJlc3NJbmZvEi8uYm'
        'l0Y29pbi5iaXRjb2luZC52MWFscGhhLkdldEFkZHJlc3NJbmZvUmVxdWVzdBowLmJpdGNvaW4u'
        'Yml0Y29pbmQudjFhbHBoYS5HZXRBZGRyZXNzSW5mb1Jlc3BvbnNlEnAKDUdldFJhd01lbXBvb2'
        'wSLi5iaXRjb2luLmJpdGNvaW5kLnYxYWxwaGEuR2V0UmF3TWVtcG9vbFJlcXVlc3QaLy5iaXRj'
        'b2luLmJpdGNvaW5kLnYxYWxwaGEuR2V0UmF3TWVtcG9vbFJlc3BvbnNlEnwKEUdldFJhd1RyYW'
        '5zYWN0aW9uEjIuYml0Y29pbi5iaXRjb2luZC52MWFscGhhLkdldFJhd1RyYW5zYWN0aW9uUmVx'
        'dWVzdBozLmJpdGNvaW4uYml0Y29pbmQudjFhbHBoYS5HZXRSYXdUcmFuc2FjdGlvblJlc3Bvbn'
        'NlEoUBChREZWNvZGVSYXdUcmFuc2FjdGlvbhI1LmJpdGNvaW4uYml0Y29pbmQudjFhbHBoYS5E'
        'ZWNvZGVSYXdUcmFuc2FjdGlvblJlcXVlc3QaNi5iaXRjb2luLmJpdGNvaW5kLnYxYWxwaGEuRG'
        'Vjb2RlUmF3VHJhbnNhY3Rpb25SZXNwb25zZRKFAQoUQ3JlYXRlUmF3VHJhbnNhY3Rpb24SNS5i'
        'aXRjb2luLmJpdGNvaW5kLnYxYWxwaGEuQ3JlYXRlUmF3VHJhbnNhY3Rpb25SZXF1ZXN0GjYuYm'
        'l0Y29pbi5iaXRjb2luZC52MWFscGhhLkNyZWF0ZVJhd1RyYW5zYWN0aW9uUmVzcG9uc2USYQoI'
        'R2V0QmxvY2sSKS5iaXRjb2luLmJpdGNvaW5kLnYxYWxwaGEuR2V0QmxvY2tSZXF1ZXN0GiouYm'
        'l0Y29pbi5iaXRjb2luZC52MWFscGhhLkdldEJsb2NrUmVzcG9uc2USbQoMR2V0QmxvY2tIYXNo'
        'Ei0uYml0Y29pbi5iaXRjb2luZC52MWFscGhhLkdldEJsb2NrSGFzaFJlcXVlc3QaLi5iaXRjb2'
        'luLmJpdGNvaW5kLnYxYWxwaGEuR2V0QmxvY2tIYXNoUmVzcG9uc2USbQoMQ3JlYXRlV2FsbGV0'
        'Ei0uYml0Y29pbi5iaXRjb2luZC52MWFscGhhLkNyZWF0ZVdhbGxldFJlcXVlc3QaLi5iaXRjb2'
        'luLmJpdGNvaW5kLnYxYWxwaGEuQ3JlYXRlV2FsbGV0UmVzcG9uc2USbQoMQmFja3VwV2FsbGV0'
        'Ei0uYml0Y29pbi5iaXRjb2luZC52MWFscGhhLkJhY2t1cFdhbGxldFJlcXVlc3QaLi5iaXRjb2'
        'luLmJpdGNvaW5kLnYxYWxwaGEuQmFja3VwV2FsbGV0UmVzcG9uc2USZwoKRHVtcFdhbGxldBIr'
        'LmJpdGNvaW4uYml0Y29pbmQudjFhbHBoYS5EdW1wV2FsbGV0UmVxdWVzdBosLmJpdGNvaW4uYm'
        'l0Y29pbmQudjFhbHBoYS5EdW1wV2FsbGV0UmVzcG9uc2USbQoMSW1wb3J0V2FsbGV0Ei0uYml0'
        'Y29pbi5iaXRjb2luZC52MWFscGhhLkltcG9ydFdhbGxldFJlcXVlc3QaLi5iaXRjb2luLmJpdG'
        'NvaW5kLnYxYWxwaGEuSW1wb3J0V2FsbGV0UmVzcG9uc2USbQoMVW5sb2FkV2FsbGV0Ei0uYml0'
        'Y29pbi5iaXRjb2luZC52MWFscGhhLlVubG9hZFdhbGxldFJlcXVlc3QaLi5iaXRjb2luLmJpdG'
        'NvaW5kLnYxYWxwaGEuVW5sb2FkV2FsbGV0UmVzcG9uc2USagoLRHVtcFByaXZLZXkSLC5iaXRj'
        'b2luLmJpdGNvaW5kLnYxYWxwaGEuRHVtcFByaXZLZXlSZXF1ZXN0Gi0uYml0Y29pbi5iaXRjb2'
        'luZC52MWFscGhhLkR1bXBQcml2S2V5UmVzcG9uc2UScAoNSW1wb3J0UHJpdktleRIuLmJpdGNv'
        'aW4uYml0Y29pbmQudjFhbHBoYS5JbXBvcnRQcml2S2V5UmVxdWVzdBovLmJpdGNvaW4uYml0Y2'
        '9pbmQudjFhbHBoYS5JbXBvcnRQcml2S2V5UmVzcG9uc2UScAoNSW1wb3J0QWRkcmVzcxIuLmJp'
        'dGNvaW4uYml0Y29pbmQudjFhbHBoYS5JbXBvcnRBZGRyZXNzUmVxdWVzdBovLmJpdGNvaW4uYm'
        'l0Y29pbmQudjFhbHBoYS5JbXBvcnRBZGRyZXNzUmVzcG9uc2USbQoMSW1wb3J0UHViS2V5Ei0u'
        'Yml0Y29pbi5iaXRjb2luZC52MWFscGhhLkltcG9ydFB1YktleVJlcXVlc3QaLi5iaXRjb2luLm'
        'JpdGNvaW5kLnYxYWxwaGEuSW1wb3J0UHViS2V5UmVzcG9uc2UScAoNS2V5UG9vbFJlZmlsbBIu'
        'LmJpdGNvaW4uYml0Y29pbmQudjFhbHBoYS5LZXlQb29sUmVmaWxsUmVxdWVzdBovLmJpdGNvaW'
        '4uYml0Y29pbmQudjFhbHBoYS5LZXlQb29sUmVmaWxsUmVzcG9uc2USZwoKR2V0QWNjb3VudBIr'
        'LmJpdGNvaW4uYml0Y29pbmQudjFhbHBoYS5HZXRBY2NvdW50UmVxdWVzdBosLmJpdGNvaW4uYm'
        'l0Y29pbmQudjFhbHBoYS5HZXRBY2NvdW50UmVzcG9uc2USZwoKU2V0QWNjb3VudBIrLmJpdGNv'
        'aW4uYml0Y29pbmQudjFhbHBoYS5TZXRBY2NvdW50UmVxdWVzdBosLmJpdGNvaW4uYml0Y29pbm'
        'QudjFhbHBoYS5TZXRBY2NvdW50UmVzcG9uc2USiAEKFUdldEFkZHJlc3Nlc0J5QWNjb3VudBI2'
        'LmJpdGNvaW4uYml0Y29pbmQudjFhbHBoYS5HZXRBZGRyZXNzZXNCeUFjY291bnRSZXF1ZXN0Gj'
        'cuYml0Y29pbi5iaXRjb2luZC52MWFscGhhLkdldEFkZHJlc3Nlc0J5QWNjb3VudFJlc3BvbnNl'
        'Em0KDExpc3RBY2NvdW50cxItLmJpdGNvaW4uYml0Y29pbmQudjFhbHBoYS5MaXN0QWNjb3VudH'
        'NSZXF1ZXN0Gi4uYml0Y29pbi5iaXRjb2luZC52MWFscGhhLkxpc3RBY2NvdW50c1Jlc3BvbnNl'
        'En8KEkFkZE11bHRpc2lnQWRkcmVzcxIzLmJpdGNvaW4uYml0Y29pbmQudjFhbHBoYS5BZGRNdW'
        'x0aXNpZ0FkZHJlc3NSZXF1ZXN0GjQuYml0Y29pbi5iaXRjb2luZC52MWFscGhhLkFkZE11bHRp'
        'c2lnQWRkcmVzc1Jlc3BvbnNlEnMKDkNyZWF0ZU11bHRpc2lnEi8uYml0Y29pbi5iaXRjb2luZC'
        '52MWFscGhhLkNyZWF0ZU11bHRpc2lnUmVxdWVzdBowLmJpdGNvaW4uYml0Y29pbmQudjFhbHBo'
        'YS5DcmVhdGVNdWx0aXNpZ1Jlc3BvbnNlEmcKCkNyZWF0ZVBzYnQSKy5iaXRjb2luLmJpdGNvaW'
        '5kLnYxYWxwaGEuQ3JlYXRlUHNidFJlcXVlc3QaLC5iaXRjb2luLmJpdGNvaW5kLnYxYWxwaGEu'
        'Q3JlYXRlUHNidFJlc3BvbnNlEmcKCkRlY29kZVBzYnQSKy5iaXRjb2luLmJpdGNvaW5kLnYxYW'
        'xwaGEuRGVjb2RlUHNidFJlcXVlc3QaLC5iaXRjb2luLmJpdGNvaW5kLnYxYWxwaGEuRGVjb2Rl'
        'UHNidFJlc3BvbnNlEmoKC0FuYWx5emVQc2J0EiwuYml0Y29pbi5iaXRjb2luZC52MWFscGhhLk'
        'FuYWx5emVQc2J0UmVxdWVzdBotLmJpdGNvaW4uYml0Y29pbmQudjFhbHBoYS5BbmFseXplUHNi'
        'dFJlc3BvbnNlEmoKC0NvbWJpbmVQc2J0EiwuYml0Y29pbi5iaXRjb2luZC52MWFscGhhLkNvbW'
        'JpbmVQc2J0UmVxdWVzdBotLmJpdGNvaW4uYml0Y29pbmQudjFhbHBoYS5Db21iaW5lUHNidFJl'
        'c3BvbnNlEnMKDlV0eG9VcGRhdGVQc2J0Ei8uYml0Y29pbi5iaXRjb2luZC52MWFscGhhLlV0eG'
        '9VcGRhdGVQc2J0UmVxdWVzdBowLmJpdGNvaW4uYml0Y29pbmQudjFhbHBoYS5VdHhvVXBkYXRl'
        'UHNidFJlc3BvbnNlEmQKCUpvaW5Qc2J0cxIqLmJpdGNvaW4uYml0Y29pbmQudjFhbHBoYS5Kb2'
        'luUHNidHNSZXF1ZXN0GisuYml0Y29pbi5iaXRjb2luZC52MWFscGhhLkpvaW5Qc2J0c1Jlc3Bv'
        'bnNlEnwKEVRlc3RNZW1wb29sQWNjZXB0EjIuYml0Y29pbi5iaXRjb2luZC52MWFscGhhLlRlc3'
        'RNZW1wb29sQWNjZXB0UmVxdWVzdBozLmJpdGNvaW4uYml0Y29pbmQudjFhbHBoYS5UZXN0TWVt'
        'cG9vbEFjY2VwdFJlc3BvbnNlEmQKE0dldFptcU5vdGlmaWNhdGlvbnMSFi5nb29nbGUucHJvdG'
        '9idWYuRW1wdHkaNS5iaXRjb2luLmJpdGNvaW5kLnYxYWxwaGEuR2V0Wm1xTm90aWZpY2F0aW9u'
        'c1Jlc3BvbnNl');
