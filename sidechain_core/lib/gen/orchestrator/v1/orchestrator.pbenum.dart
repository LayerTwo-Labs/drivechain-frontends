// This is a generated file - do not edit.
//
// Generated from orchestrator/v1/orchestrator.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// SidechainType keeps the response strongly-typed so callers don't have to
/// match magic strings. UNSPECIFIED is reserved for forwards-compat — when
/// a frontend sees it, the binary is known to the orchestrator but doesn't
/// have a typed enum value yet.
class SidechainType extends $pb.ProtobufEnum {
  static const SidechainType SIDECHAIN_TYPE_UNSPECIFIED =
      SidechainType._(0, _omitEnumNames ? '' : 'SIDECHAIN_TYPE_UNSPECIFIED');
  static const SidechainType SIDECHAIN_TYPE_THUNDER =
      SidechainType._(1, _omitEnumNames ? '' : 'SIDECHAIN_TYPE_THUNDER');
  static const SidechainType SIDECHAIN_TYPE_ZSIDE = SidechainType._(2, _omitEnumNames ? '' : 'SIDECHAIN_TYPE_ZSIDE');
  static const SidechainType SIDECHAIN_TYPE_BITNAMES =
      SidechainType._(3, _omitEnumNames ? '' : 'SIDECHAIN_TYPE_BITNAMES');
  static const SidechainType SIDECHAIN_TYPE_BITASSETS =
      SidechainType._(4, _omitEnumNames ? '' : 'SIDECHAIN_TYPE_BITASSETS');
  static const SidechainType SIDECHAIN_TYPE_TRUTHCOIN =
      SidechainType._(5, _omitEnumNames ? '' : 'SIDECHAIN_TYPE_TRUTHCOIN');
  static const SidechainType SIDECHAIN_TYPE_PHOTON = SidechainType._(6, _omitEnumNames ? '' : 'SIDECHAIN_TYPE_PHOTON');
  static const SidechainType SIDECHAIN_TYPE_COINSHIFT =
      SidechainType._(7, _omitEnumNames ? '' : 'SIDECHAIN_TYPE_COINSHIFT');
  static const SidechainType SIDECHAIN_TYPE_FREEBANK =
      SidechainType._(8, _omitEnumNames ? '' : 'SIDECHAIN_TYPE_FREEBANK');

  static const $core.List<SidechainType> values = <SidechainType>[
    SIDECHAIN_TYPE_UNSPECIFIED,
    SIDECHAIN_TYPE_THUNDER,
    SIDECHAIN_TYPE_ZSIDE,
    SIDECHAIN_TYPE_BITNAMES,
    SIDECHAIN_TYPE_BITASSETS,
    SIDECHAIN_TYPE_TRUTHCOIN,
    SIDECHAIN_TYPE_PHOTON,
    SIDECHAIN_TYPE_COINSHIFT,
    SIDECHAIN_TYPE_FREEBANK,
  ];

  static final $core.List<SidechainType?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 8);
  static SidechainType? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SidechainType._(super.value, super.name);
}

/// BinaryType is the single typed identifier for any binary the system tracks.
/// Used wire-side by the orchestrator and consumed directly by the Flutter
/// frontends — there is no parallel Dart enum. UNSPECIFIED is reserved for
/// forwards-compat: when a frontend sees it, the binary is known to the
/// orchestrator but doesn't have a typed enum value yet.
class BinaryType extends $pb.ProtobufEnum {
  static const BinaryType BINARY_TYPE_UNSPECIFIED = BinaryType._(0, _omitEnumNames ? '' : 'BINARY_TYPE_UNSPECIFIED');
  static const BinaryType BINARY_TYPE_BITCOIND = BinaryType._(1, _omitEnumNames ? '' : 'BINARY_TYPE_BITCOIND');
  static const BinaryType BINARY_TYPE_ENFORCER = BinaryType._(2, _omitEnumNames ? '' : 'BINARY_TYPE_ENFORCER');
  static const BinaryType BINARY_TYPE_BITWINDOWD = BinaryType._(3, _omitEnumNames ? '' : 'BINARY_TYPE_BITWINDOWD');
  static const BinaryType BINARY_TYPE_THUNDER = BinaryType._(4, _omitEnumNames ? '' : 'BINARY_TYPE_THUNDER');
  static const BinaryType BINARY_TYPE_ZSIDE = BinaryType._(5, _omitEnumNames ? '' : 'BINARY_TYPE_ZSIDE');
  static const BinaryType BINARY_TYPE_BITNAMES = BinaryType._(6, _omitEnumNames ? '' : 'BINARY_TYPE_BITNAMES');
  static const BinaryType BINARY_TYPE_BITASSETS = BinaryType._(7, _omitEnumNames ? '' : 'BINARY_TYPE_BITASSETS');
  static const BinaryType BINARY_TYPE_TRUTHCOIN = BinaryType._(8, _omitEnumNames ? '' : 'BINARY_TYPE_TRUTHCOIN');
  static const BinaryType BINARY_TYPE_PHOTON = BinaryType._(9, _omitEnumNames ? '' : 'BINARY_TYPE_PHOTON');
  static const BinaryType BINARY_TYPE_COINSHIFT = BinaryType._(10, _omitEnumNames ? '' : 'BINARY_TYPE_COINSHIFT');
  static const BinaryType BINARY_TYPE_GRPCURL = BinaryType._(11, _omitEnumNames ? '' : 'BINARY_TYPE_GRPCURL');
  static const BinaryType BINARY_TYPE_DRIVECHAIND = BinaryType._(12, _omitEnumNames ? '' : 'BINARY_TYPE_DRIVECHAIND');
  static const BinaryType BINARY_TYPE_ZSIDED = BinaryType._(13, _omitEnumNames ? '' : 'BINARY_TYPE_ZSIDED');
  static const BinaryType BINARY_TYPE_BBC = BinaryType._(15, _omitEnumNames ? '' : 'BINARY_TYPE_BBC');
  static const BinaryType BINARY_TYPE_FREEBANK = BinaryType._(16, _omitEnumNames ? '' : 'BINARY_TYPE_FREEBANK');
  static const BinaryType BINARY_TYPE_SOLANA = BinaryType._(17, _omitEnumNames ? '' : 'BINARY_TYPE_SOLANA');

  static const $core.List<BinaryType> values = <BinaryType>[
    BINARY_TYPE_UNSPECIFIED,
    BINARY_TYPE_BITCOIND,
    BINARY_TYPE_ENFORCER,
    BINARY_TYPE_BITWINDOWD,
    BINARY_TYPE_THUNDER,
    BINARY_TYPE_ZSIDE,
    BINARY_TYPE_BITNAMES,
    BINARY_TYPE_BITASSETS,
    BINARY_TYPE_TRUTHCOIN,
    BINARY_TYPE_PHOTON,
    BINARY_TYPE_COINSHIFT,
    BINARY_TYPE_GRPCURL,
    BINARY_TYPE_DRIVECHAIND,
    BINARY_TYPE_ZSIDED,
    BINARY_TYPE_BBC,
    BINARY_TYPE_FREEBANK,
    BINARY_TYPE_SOLANA,
  ];

  static final $core.List<BinaryType?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 17);
  static BinaryType? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const BinaryType._(super.value, super.name);
}

class MainchainSyncPhase extends $pb.ProtobufEnum {
  /// The node reports no mainchain sync.
  static const MainchainSyncPhase MAINCHAIN_SYNC_PHASE_UNSPECIFIED =
      MainchainSyncPhase._(0, _omitEnumNames ? '' : 'MAINCHAIN_SYNC_PHASE_UNSPECIFIED');

  /// The node fetches the mainchain headers.
  static const MainchainSyncPhase MAINCHAIN_SYNC_PHASE_HEADERS =
      MainchainSyncPhase._(1, _omitEnumNames ? '' : 'MAINCHAIN_SYNC_PHASE_HEADERS');

  /// The node connects the mainchain state.
  static const MainchainSyncPhase MAINCHAIN_SYNC_PHASE_STATE =
      MainchainSyncPhase._(2, _omitEnumNames ? '' : 'MAINCHAIN_SYNC_PHASE_STATE');

  /// The node writes the fetched mainchain headers to disk.
  static const MainchainSyncPhase MAINCHAIN_SYNC_PHASE_WRITING =
      MainchainSyncPhase._(3, _omitEnumNames ? '' : 'MAINCHAIN_SYNC_PHASE_WRITING');

  /// The node reports a phase this build does not name.
  static const MainchainSyncPhase MAINCHAIN_SYNC_PHASE_OTHER =
      MainchainSyncPhase._(4, _omitEnumNames ? '' : 'MAINCHAIN_SYNC_PHASE_OTHER');

  static const $core.List<MainchainSyncPhase> values = <MainchainSyncPhase>[
    MAINCHAIN_SYNC_PHASE_UNSPECIFIED,
    MAINCHAIN_SYNC_PHASE_HEADERS,
    MAINCHAIN_SYNC_PHASE_STATE,
    MAINCHAIN_SYNC_PHASE_WRITING,
    MAINCHAIN_SYNC_PHASE_OTHER,
  ];

  static final $core.List<MainchainSyncPhase?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 4);
  static MainchainSyncPhase? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MainchainSyncPhase._(super.value, super.name);
}

/// DeletionType selects which category of a binary's files to gather/delete.
class DeletionType extends $pb.ProtobufEnum {
  static const DeletionType DELETION_TYPE_UNSPECIFIED =
      DeletionType._(0, _omitEnumNames ? '' : 'DELETION_TYPE_UNSPECIFIED');
  static const DeletionType DELETION_TYPE_DATA = DeletionType._(1, _omitEnumNames ? '' : 'DELETION_TYPE_DATA');
  static const DeletionType DELETION_TYPE_WALLET = DeletionType._(2, _omitEnumNames ? '' : 'DELETION_TYPE_WALLET');
  static const DeletionType DELETION_TYPE_SETTINGS = DeletionType._(3, _omitEnumNames ? '' : 'DELETION_TYPE_SETTINGS');
  static const DeletionType DELETION_TYPE_LOGS = DeletionType._(4, _omitEnumNames ? '' : 'DELETION_TYPE_LOGS');
  static const DeletionType DELETION_TYPE_SOFTWARE = DeletionType._(5, _omitEnumNames ? '' : 'DELETION_TYPE_SOFTWARE');

  static const $core.List<DeletionType> values = <DeletionType>[
    DELETION_TYPE_UNSPECIFIED,
    DELETION_TYPE_DATA,
    DELETION_TYPE_WALLET,
    DELETION_TYPE_SETTINGS,
    DELETION_TYPE_LOGS,
    DELETION_TYPE_SOFTWARE,
  ];

  static final $core.List<DeletionType?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 5);
  static DeletionType? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const DeletionType._(super.value, super.name);
}

/// What the reject did to the chain Core follows.
class RejectOutcome extends $pb.ProtobufEnum {
  static const RejectOutcome REJECT_OUTCOME_UNSPECIFIED =
      RejectOutcome._(0, _omitEnumNames ? '' : 'REJECT_OUTCOME_UNSPECIFIED');

  /// Core dropped the block and followed another branch.
  static const RejectOutcome REJECT_OUTCOME_SWITCHED_BRANCH =
      RejectOutcome._(1, _omitEnumNames ? '' : 'REJECT_OUTCOME_SWITCHED_BRANCH');

  /// Core dropped the block and parked on its parent, with no branch to take.
  static const RejectOutcome REJECT_OUTCOME_PARKED_ON_PARENT =
      RejectOutcome._(2, _omitEnumNames ? '' : 'REJECT_OUTCOME_PARKED_ON_PARENT');

  /// The block already sat off the active chain, so the tip did not move.
  static const RejectOutcome REJECT_OUTCOME_ALREADY_INACTIVE =
      RejectOutcome._(3, _omitEnumNames ? '' : 'REJECT_OUTCOME_ALREADY_INACTIVE');

  static const $core.List<RejectOutcome> values = <RejectOutcome>[
    REJECT_OUTCOME_UNSPECIFIED,
    REJECT_OUTCOME_SWITCHED_BRANCH,
    REJECT_OUTCOME_PARKED_ON_PARENT,
    REJECT_OUTCOME_ALREADY_INACTIVE,
  ];

  static final $core.List<RejectOutcome?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 3);
  static RejectOutcome? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const RejectOutcome._(super.value, super.name);
}

/// Which step of a reset a progress message reports.
class ResetPhase extends $pb.ProtobufEnum {
  static const ResetPhase RESET_PHASE_UNSPECIFIED = ResetPhase._(0, _omitEnumNames ? '' : 'RESET_PHASE_UNSPECIFIED');

  /// The target reads as a height or a hash, and Core holds the block.
  static const ResetPhase RESET_PHASE_RESOLVE = ResetPhase._(1, _omitEnumNames ? '' : 'RESET_PHASE_RESOLVE');

  /// Core drops the target block and every block above it.
  static const ResetPhase RESET_PHASE_MOVE_BACK = ResetPhase._(2, _omitEnumNames ? '' : 'RESET_PHASE_MOVE_BACK');

  /// Core re-validates the dropped blocks from disk and climbs to the old tip.
  static const ResetPhase RESET_PHASE_SYNC_FORWARD = ResetPhase._(3, _omitEnumNames ? '' : 'RESET_PHASE_SYNC_FORWARD');

  /// The enforcer comes back onto the chain Core follows.
  static const ResetPhase RESET_PHASE_ENFORCER = ResetPhase._(4, _omitEnumNames ? '' : 'RESET_PHASE_ENFORCER');

  /// The reset is over.
  static const ResetPhase RESET_PHASE_DONE = ResetPhase._(5, _omitEnumNames ? '' : 'RESET_PHASE_DONE');

  static const $core.List<ResetPhase> values = <ResetPhase>[
    RESET_PHASE_UNSPECIFIED,
    RESET_PHASE_RESOLVE,
    RESET_PHASE_MOVE_BACK,
    RESET_PHASE_SYNC_FORWARD,
    RESET_PHASE_ENFORCER,
    RESET_PHASE_DONE,
  ];

  static final $core.List<ResetPhase?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 5);
  static ResetPhase? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ResetPhase._(super.value, super.name);
}

const $core.bool _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
