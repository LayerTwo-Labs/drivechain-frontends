//
//  Generated code. Do not modify.
//  source: bitcoin/bitcoind/v1alpha/bitcoin.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

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

  static final $core.Map<$core.int, Peer_Network> _byValue = $pb.ProtobufEnum.initByValue(values);
  static Peer_Network? valueOf($core.int value) => _byValue[value];

  const Peer_Network._($core.int v, $core.String n) : super(v, n);
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

  static final $core.Map<$core.int, Peer_ConnectionType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static Peer_ConnectionType? valueOf($core.int value) => _byValue[value];

  const Peer_ConnectionType._($core.int v, $core.String n) : super(v, n);
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

  static final $core.Map<$core.int, Peer_TransportProtocol> _byValue = $pb.ProtobufEnum.initByValue(values);
  static Peer_TransportProtocol? valueOf($core.int value) => _byValue[value];

  const Peer_TransportProtocol._($core.int v, $core.String n) : super(v, n);
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

  static final $core.Map<$core.int, GetTransactionResponse_Replaceable> _byValue = $pb.ProtobufEnum.initByValue(values);
  static GetTransactionResponse_Replaceable? valueOf($core.int value) => _byValue[value];

  const GetTransactionResponse_Replaceable._($core.int v, $core.String n) : super(v, n);
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

  static final $core.Map<$core.int, GetTransactionResponse_Category> _byValue = $pb.ProtobufEnum.initByValue(values);
  static GetTransactionResponse_Category? valueOf($core.int value) => _byValue[value];

  const GetTransactionResponse_Category._($core.int v, $core.String n) : super(v, n);
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

  static final $core.Map<$core.int, EstimateSmartFeeRequest_EstimateMode> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static EstimateSmartFeeRequest_EstimateMode? valueOf($core.int value) => _byValue[value];

  const EstimateSmartFeeRequest_EstimateMode._($core.int v, $core.String n) : super(v, n);
}

class GetBlockRequest_Verbosity extends $pb.ProtobufEnum {
  static const GetBlockRequest_Verbosity VERBOSITY_UNSPECIFIED =
      GetBlockRequest_Verbosity._(0, _omitEnumNames ? '' : 'VERBOSITY_UNSPECIFIED');
  static const GetBlockRequest_Verbosity VERBOSITY_RAW_DATA =
      GetBlockRequest_Verbosity._(1, _omitEnumNames ? '' : 'VERBOSITY_RAW_DATA');
  static const GetBlockRequest_Verbosity VERBOSITY_BLOCK_INFO =
      GetBlockRequest_Verbosity._(2, _omitEnumNames ? '' : 'VERBOSITY_BLOCK_INFO');
  static const GetBlockRequest_Verbosity VERBOSITY_BLOCK_TX_INFO =
      GetBlockRequest_Verbosity._(3, _omitEnumNames ? '' : 'VERBOSITY_BLOCK_TX_INFO');
  static const GetBlockRequest_Verbosity VERBOSITY_BLOCK_TX_PREVOUT_INFO =
      GetBlockRequest_Verbosity._(4, _omitEnumNames ? '' : 'VERBOSITY_BLOCK_TX_PREVOUT_INFO');

  static const $core.List<GetBlockRequest_Verbosity> values = <GetBlockRequest_Verbosity>[
    VERBOSITY_UNSPECIFIED,
    VERBOSITY_RAW_DATA,
    VERBOSITY_BLOCK_INFO,
    VERBOSITY_BLOCK_TX_INFO,
    VERBOSITY_BLOCK_TX_PREVOUT_INFO,
  ];

  static final $core.Map<$core.int, GetBlockRequest_Verbosity> _byValue = $pb.ProtobufEnum.initByValue(values);
  static GetBlockRequest_Verbosity? valueOf($core.int value) => _byValue[value];

  const GetBlockRequest_Verbosity._($core.int v, $core.String n) : super(v, n);
}

const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
