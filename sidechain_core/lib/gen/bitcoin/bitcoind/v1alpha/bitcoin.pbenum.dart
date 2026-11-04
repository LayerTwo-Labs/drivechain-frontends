// This is a generated file - do not edit.
//
// Generated from bitcoin/bitcoind/v1alpha/bitcoin.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class Peer_Network extends $pb.ProtobufEnum {
  static const Peer_Network NETWORK_UNSPECIFIED = Peer_Network._(0, _omitEnumNames ? '' : 'NETWORK_UNSPECIFIED');
  static const Peer_Network NETWORK_IPV4 = Peer_Network._(1, _omitEnumNames ? '' : 'NETWORK_IPV4');
  static const Peer_Network NETWORK_IPV6 = Peer_Network._(2, _omitEnumNames ? '' : 'NETWORK_IPV6');
  static const Peer_Network NETWORK_ONION = Peer_Network._(3, _omitEnumNames ? '' : 'NETWORK_ONION');
  static const Peer_Network NETWORK_I2P = Peer_Network._(4, _omitEnumNames ? '' : 'NETWORK_I2P');
  static const Peer_Network NETWORK_CJDNS = Peer_Network._(5, _omitEnumNames ? '' : 'NETWORK_CJDNS');
  static const Peer_Network NETWORK_NOT_PUBLICLY_ROUTABLE =
      Peer_Network._(6, _omitEnumNames ? '' : 'NETWORK_NOT_PUBLICLY_ROUTABLE');

  static const $core.List<Peer_Network> values = <Peer_Network>[
    NETWORK_UNSPECIFIED,
    NETWORK_IPV4,
    NETWORK_IPV6,
    NETWORK_ONION,
    NETWORK_I2P,
    NETWORK_CJDNS,
    NETWORK_NOT_PUBLICLY_ROUTABLE,
  ];

  static final $core.List<Peer_Network?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 6);
  static Peer_Network? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Peer_Network._(super.value, super.name);
}

class Peer_ConnectionType extends $pb.ProtobufEnum {
  static const Peer_ConnectionType CONNECTION_TYPE_UNSPECIFIED =
      Peer_ConnectionType._(0, _omitEnumNames ? '' : 'CONNECTION_TYPE_UNSPECIFIED');
  static const Peer_ConnectionType CONNECTION_TYPE_OUTBOUND_FULL_RELAY =
      Peer_ConnectionType._(1, _omitEnumNames ? '' : 'CONNECTION_TYPE_OUTBOUND_FULL_RELAY');
  static const Peer_ConnectionType CONNECTION_TYPE_BLOCK_RELAY_ONLY =
      Peer_ConnectionType._(2, _omitEnumNames ? '' : 'CONNECTION_TYPE_BLOCK_RELAY_ONLY');
  static const Peer_ConnectionType CONNECTION_TYPE_INBOUND =
      Peer_ConnectionType._(3, _omitEnumNames ? '' : 'CONNECTION_TYPE_INBOUND');
  static const Peer_ConnectionType CONNECTION_TYPE_MANUAL =
      Peer_ConnectionType._(4, _omitEnumNames ? '' : 'CONNECTION_TYPE_MANUAL');
  static const Peer_ConnectionType CONNECTION_TYPE_ADDR_FETCH =
      Peer_ConnectionType._(5, _omitEnumNames ? '' : 'CONNECTION_TYPE_ADDR_FETCH');
  static const Peer_ConnectionType CONNECTION_TYPE_FEEDER =
      Peer_ConnectionType._(6, _omitEnumNames ? '' : 'CONNECTION_TYPE_FEEDER');

  static const $core.List<Peer_ConnectionType> values = <Peer_ConnectionType>[
    CONNECTION_TYPE_UNSPECIFIED,
    CONNECTION_TYPE_OUTBOUND_FULL_RELAY,
    CONNECTION_TYPE_BLOCK_RELAY_ONLY,
    CONNECTION_TYPE_INBOUND,
    CONNECTION_TYPE_MANUAL,
    CONNECTION_TYPE_ADDR_FETCH,
    CONNECTION_TYPE_FEEDER,
  ];

  static final $core.List<Peer_ConnectionType?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 6);
  static Peer_ConnectionType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Peer_ConnectionType._(super.value, super.name);
}

class Peer_TransportProtocol extends $pb.ProtobufEnum {
  static const Peer_TransportProtocol TRANSPORT_PROTOCOL_UNSPECIFIED =
      Peer_TransportProtocol._(0, _omitEnumNames ? '' : 'TRANSPORT_PROTOCOL_UNSPECIFIED');
  static const Peer_TransportProtocol TRANSPORT_PROTOCOL_DETECTING =
      Peer_TransportProtocol._(1, _omitEnumNames ? '' : 'TRANSPORT_PROTOCOL_DETECTING');
  static const Peer_TransportProtocol TRANSPORT_PROTOCOL_V1 =
      Peer_TransportProtocol._(2, _omitEnumNames ? '' : 'TRANSPORT_PROTOCOL_V1');
  static const Peer_TransportProtocol TRANSPORT_PROTOCOL_V2 =
      Peer_TransportProtocol._(3, _omitEnumNames ? '' : 'TRANSPORT_PROTOCOL_V2');

  static const $core.List<Peer_TransportProtocol> values = <Peer_TransportProtocol>[
    TRANSPORT_PROTOCOL_UNSPECIFIED,
    TRANSPORT_PROTOCOL_DETECTING,
    TRANSPORT_PROTOCOL_V1,
    TRANSPORT_PROTOCOL_V2,
  ];

  static final $core.List<Peer_TransportProtocol?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 3);
  static Peer_TransportProtocol? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Peer_TransportProtocol._(super.value, super.name);
}

class GetTransactionResponse_Replaceable extends $pb.ProtobufEnum {
  static const GetTransactionResponse_Replaceable REPLACEABLE_UNSPECIFIED =
      GetTransactionResponse_Replaceable._(0, _omitEnumNames ? '' : 'REPLACEABLE_UNSPECIFIED');
  static const GetTransactionResponse_Replaceable REPLACEABLE_YES =
      GetTransactionResponse_Replaceable._(1, _omitEnumNames ? '' : 'REPLACEABLE_YES');
  static const GetTransactionResponse_Replaceable REPLACEABLE_NO =
      GetTransactionResponse_Replaceable._(2, _omitEnumNames ? '' : 'REPLACEABLE_NO');

  static const $core.List<GetTransactionResponse_Replaceable> values = <GetTransactionResponse_Replaceable>[
    REPLACEABLE_UNSPECIFIED,
    REPLACEABLE_YES,
    REPLACEABLE_NO,
  ];

  static final $core.List<GetTransactionResponse_Replaceable?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 2);
  static GetTransactionResponse_Replaceable? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const GetTransactionResponse_Replaceable._(super.value, super.name);
}

class GetTransactionResponse_Category extends $pb.ProtobufEnum {
  static const GetTransactionResponse_Category CATEGORY_UNSPECIFIED =
      GetTransactionResponse_Category._(0, _omitEnumNames ? '' : 'CATEGORY_UNSPECIFIED');
  static const GetTransactionResponse_Category CATEGORY_SEND =
      GetTransactionResponse_Category._(1, _omitEnumNames ? '' : 'CATEGORY_SEND');
  static const GetTransactionResponse_Category CATEGORY_RECEIVE =
      GetTransactionResponse_Category._(2, _omitEnumNames ? '' : 'CATEGORY_RECEIVE');
  static const GetTransactionResponse_Category CATEGORY_GENERATE =
      GetTransactionResponse_Category._(3, _omitEnumNames ? '' : 'CATEGORY_GENERATE');
  static const GetTransactionResponse_Category CATEGORY_IMMATURE =
      GetTransactionResponse_Category._(4, _omitEnumNames ? '' : 'CATEGORY_IMMATURE');
  static const GetTransactionResponse_Category CATEGORY_ORPHAN =
      GetTransactionResponse_Category._(5, _omitEnumNames ? '' : 'CATEGORY_ORPHAN');

  static const $core.List<GetTransactionResponse_Category> values = <GetTransactionResponse_Category>[
    CATEGORY_UNSPECIFIED,
    CATEGORY_SEND,
    CATEGORY_RECEIVE,
    CATEGORY_GENERATE,
    CATEGORY_IMMATURE,
    CATEGORY_ORPHAN,
  ];

  static final $core.List<GetTransactionResponse_Category?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 5);
  static GetTransactionResponse_Category? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const GetTransactionResponse_Category._(super.value, super.name);
}

class GetRawTransactionRequest_Verbosity extends $pb.ProtobufEnum {
  static const GetRawTransactionRequest_Verbosity VERBOSITY_UNSPECIFIED =
      GetRawTransactionRequest_Verbosity._(0, _omitEnumNames ? '' : 'VERBOSITY_UNSPECIFIED');

  /// Returns the raw TX data, completely unprocessed. Response only sets hex.
  static const GetRawTransactionRequest_Verbosity VERBOSITY_RAW_DATA =
      GetRawTransactionRequest_Verbosity._(1, _omitEnumNames ? '' : 'VERBOSITY_RAW_DATA');

  /// Returns information about the TX
  static const GetRawTransactionRequest_Verbosity VERBOSITY_TX_INFO =
      GetRawTransactionRequest_Verbosity._(2, _omitEnumNames ? '' : 'VERBOSITY_TX_INFO');

  /// Returns information about the TX, including fee and prevout information.
  static const GetRawTransactionRequest_Verbosity VERBOSITY_TX_PREVOUT_INFO =
      GetRawTransactionRequest_Verbosity._(3, _omitEnumNames ? '' : 'VERBOSITY_TX_PREVOUT_INFO');

  static const $core.List<GetRawTransactionRequest_Verbosity> values = <GetRawTransactionRequest_Verbosity>[
    VERBOSITY_UNSPECIFIED,
    VERBOSITY_RAW_DATA,
    VERBOSITY_TX_INFO,
    VERBOSITY_TX_PREVOUT_INFO,
  ];

  static final $core.List<GetRawTransactionRequest_Verbosity?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 3);
  static GetRawTransactionRequest_Verbosity? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const GetRawTransactionRequest_Verbosity._(super.value, super.name);
}

class EstimateSmartFeeRequest_EstimateMode extends $pb.ProtobufEnum {
  static const EstimateSmartFeeRequest_EstimateMode ESTIMATE_MODE_UNSPECIFIED =
      EstimateSmartFeeRequest_EstimateMode._(0, _omitEnumNames ? '' : 'ESTIMATE_MODE_UNSPECIFIED');
  static const EstimateSmartFeeRequest_EstimateMode ESTIMATE_MODE_ECONOMICAL =
      EstimateSmartFeeRequest_EstimateMode._(1, _omitEnumNames ? '' : 'ESTIMATE_MODE_ECONOMICAL');
  static const EstimateSmartFeeRequest_EstimateMode ESTIMATE_MODE_CONSERVATIVE =
      EstimateSmartFeeRequest_EstimateMode._(2, _omitEnumNames ? '' : 'ESTIMATE_MODE_CONSERVATIVE');

  static const $core.List<EstimateSmartFeeRequest_EstimateMode> values = <EstimateSmartFeeRequest_EstimateMode>[
    ESTIMATE_MODE_UNSPECIFIED,
    ESTIMATE_MODE_ECONOMICAL,
    ESTIMATE_MODE_CONSERVATIVE,
  ];

  static final $core.List<EstimateSmartFeeRequest_EstimateMode?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static EstimateSmartFeeRequest_EstimateMode? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const EstimateSmartFeeRequest_EstimateMode._(super.value, super.name);
}

class GetBlockRequest_Verbosity extends $pb.ProtobufEnum {
  static const GetBlockRequest_Verbosity VERBOSITY_UNSPECIFIED =
      GetBlockRequest_Verbosity._(0, _omitEnumNames ? '' : 'VERBOSITY_UNSPECIFIED');

  /// Returns the raw block data, completely unprocessed. Response only sets hex.
  static const GetBlockRequest_Verbosity VERBOSITY_RAW_DATA =
      GetBlockRequest_Verbosity._(1, _omitEnumNames ? '' : 'VERBOSITY_RAW_DATA');

  /// Returns information about the block
  static const GetBlockRequest_Verbosity VERBOSITY_BLOCK_INFO =
      GetBlockRequest_Verbosity._(2, _omitEnumNames ? '' : 'VERBOSITY_BLOCK_INFO');

  /// Returns information about the block and information
  /// about each transaction
  static const GetBlockRequest_Verbosity VERBOSITY_BLOCK_TX_INFO =
      GetBlockRequest_Verbosity._(3, _omitEnumNames ? '' : 'VERBOSITY_BLOCK_TX_INFO');

  /// Returns information about the block, information
  /// about each transaction and prevout information.
  static const GetBlockRequest_Verbosity VERBOSITY_BLOCK_TX_PREVOUT_INFO =
      GetBlockRequest_Verbosity._(4, _omitEnumNames ? '' : 'VERBOSITY_BLOCK_TX_PREVOUT_INFO');

  static const $core.List<GetBlockRequest_Verbosity> values = <GetBlockRequest_Verbosity>[
    VERBOSITY_UNSPECIFIED,
    VERBOSITY_RAW_DATA,
    VERBOSITY_BLOCK_INFO,
    VERBOSITY_BLOCK_TX_INFO,
    VERBOSITY_BLOCK_TX_PREVOUT_INFO,
  ];

  static final $core.List<GetBlockRequest_Verbosity?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 4);
  static GetBlockRequest_Verbosity? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const GetBlockRequest_Verbosity._(super.value, super.name);
}

const $core.bool _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
