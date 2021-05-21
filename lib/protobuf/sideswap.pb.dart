///
//  Generated code. Do not modify.
//  source: sideswap.proto
//
// @dart = 2.3
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

class Empty extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'Empty', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'sideswap.proto'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  Empty._() : super();
  factory Empty() => create();
  factory Empty.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Empty.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Empty clone() => Empty()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Empty copyWith(void Function(Empty) updates) => super.copyWith((message) => updates(message as Empty)); // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Empty create() => Empty._();
  Empty createEmptyInstance() => create();
  static $pb.PbList<Empty> createRepeated() => $pb.PbList<Empty>();
  @$core.pragma('dart2js:noInline')
  static Empty getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Empty>(create);
  static Empty _defaultInstance;
}

class Address extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'Address', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'sideswap.proto'), createEmptyInstance: create)
    ..aQS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'addr')
  ;

  Address._() : super();
  factory Address() => create();
  factory Address.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Address.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Address clone() => Address()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Address copyWith(void Function(Address) updates) => super.copyWith((message) => updates(message as Address)); // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Address create() => Address._();
  Address createEmptyInstance() => create();
  static $pb.PbList<Address> createRepeated() => $pb.PbList<Address>();
  @$core.pragma('dart2js:noInline')
  static Address getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Address>(create);
  static Address _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get addr => $_getSZ(0);
  @$pb.TagNumber(1)
  set addr($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddr() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddr() => clearField(1);
}

class Balance extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'Balance', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'sideswap.proto'), createEmptyInstance: create)
    ..aQS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'ticker')
    ..a<$fixnum.Int64>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'amount', $pb.PbFieldType.Q6, defaultOrMaker: $fixnum.Int64.ZERO)
  ;

  Balance._() : super();
  factory Balance() => create();
  factory Balance.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Balance.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Balance clone() => Balance()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Balance copyWith(void Function(Balance) updates) => super.copyWith((message) => updates(message as Balance)); // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Balance create() => Balance._();
  Balance createEmptyInstance() => create();
  static $pb.PbList<Balance> createRepeated() => $pb.PbList<Balance>();
  @$core.pragma('dart2js:noInline')
  static Balance getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Balance>(create);
  static Balance _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get ticker => $_getSZ(0);
  @$pb.TagNumber(1)
  set ticker($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTicker() => $_has(0);
  @$pb.TagNumber(1)
  void clearTicker() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get amount => $_getI64(1);
  @$pb.TagNumber(2)
  set amount($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmount() => clearField(2);
}

class Asset extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'Asset', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'sideswap.proto'), createEmptyInstance: create)
    ..aQS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'assetId')
    ..aQS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'name')
    ..aQS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'ticker')
    ..aQS(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'icon')
    ..a<$core.int>(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'precision', $pb.PbFieldType.QU3)
  ;

  Asset._() : super();
  factory Asset() => create();
  factory Asset.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Asset.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Asset clone() => Asset()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Asset copyWith(void Function(Asset) updates) => super.copyWith((message) => updates(message as Asset)); // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Asset create() => Asset._();
  Asset createEmptyInstance() => create();
  static $pb.PbList<Asset> createRepeated() => $pb.PbList<Asset>();
  @$core.pragma('dart2js:noInline')
  static Asset getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Asset>(create);
  static Asset _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get assetId => $_getSZ(0);
  @$pb.TagNumber(1)
  set assetId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAssetId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAssetId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get ticker => $_getSZ(2);
  @$pb.TagNumber(3)
  set ticker($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTicker() => $_has(2);
  @$pb.TagNumber(3)
  void clearTicker() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get icon => $_getSZ(3);
  @$pb.TagNumber(4)
  set icon($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasIcon() => $_has(3);
  @$pb.TagNumber(4)
  void clearIcon() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get precision => $_getIZ(4);
  @$pb.TagNumber(5)
  set precision($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasPrecision() => $_has(4);
  @$pb.TagNumber(5)
  void clearPrecision() => clearField(5);
}

class Transaction extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'Transaction', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'sideswap.proto'), createEmptyInstance: create)
    ..aQS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'txid')
    ..pc<Balance>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'balances', $pb.PbFieldType.PM, subBuilder: Balance.create)
    ..aQS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'createdAt')
    ..a<$core.int>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'blockHeight', $pb.PbFieldType.QU3)
    ..aQS(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'memo')
  ;

  Transaction._() : super();
  factory Transaction() => create();
  factory Transaction.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Transaction.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Transaction clone() => Transaction()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Transaction copyWith(void Function(Transaction) updates) => super.copyWith((message) => updates(message as Transaction)); // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Transaction create() => Transaction._();
  Transaction createEmptyInstance() => create();
  static $pb.PbList<Transaction> createRepeated() => $pb.PbList<Transaction>();
  @$core.pragma('dart2js:noInline')
  static Transaction getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Transaction>(create);
  static Transaction _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<Balance> get balances => $_getList(1);

  @$pb.TagNumber(3)
  $core.String get createdAt => $_getSZ(2);
  @$pb.TagNumber(3)
  set createdAt($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasCreatedAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearCreatedAt() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get blockHeight => $_getIZ(3);
  @$pb.TagNumber(4)
  set blockHeight($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasBlockHeight() => $_has(3);
  @$pb.TagNumber(4)
  void clearBlockHeight() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get memo => $_getSZ(4);
  @$pb.TagNumber(5)
  set memo($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasMemo() => $_has(4);
  @$pb.TagNumber(5)
  void clearMemo() => clearField(5);
}

class ServerStatus extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ServerStatus', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'sideswap.proto'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'minPegInAmount', $pb.PbFieldType.Q6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'minPegOutAmount', $pb.PbFieldType.Q6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.double>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'serverFeePercentPegIn', $pb.PbFieldType.QD)
    ..a<$core.double>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'serverFeePercentPegOut', $pb.PbFieldType.QD)
  ;

  ServerStatus._() : super();
  factory ServerStatus() => create();
  factory ServerStatus.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ServerStatus.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ServerStatus clone() => ServerStatus()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ServerStatus copyWith(void Function(ServerStatus) updates) => super.copyWith((message) => updates(message as ServerStatus)); // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ServerStatus create() => ServerStatus._();
  ServerStatus createEmptyInstance() => create();
  static $pb.PbList<ServerStatus> createRepeated() => $pb.PbList<ServerStatus>();
  @$core.pragma('dart2js:noInline')
  static ServerStatus getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ServerStatus>(create);
  static ServerStatus _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get minPegInAmount => $_getI64(0);
  @$pb.TagNumber(1)
  set minPegInAmount($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMinPegInAmount() => $_has(0);
  @$pb.TagNumber(1)
  void clearMinPegInAmount() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get minPegOutAmount => $_getI64(1);
  @$pb.TagNumber(2)
  set minPegOutAmount($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMinPegOutAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearMinPegOutAmount() => clearField(2);

  @$pb.TagNumber(3)
  $core.double get serverFeePercentPegIn => $_getN(2);
  @$pb.TagNumber(3)
  set serverFeePercentPegIn($core.double v) { $_setDouble(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasServerFeePercentPegIn() => $_has(2);
  @$pb.TagNumber(3)
  void clearServerFeePercentPegIn() => clearField(3);

  @$pb.TagNumber(4)
  $core.double get serverFeePercentPegOut => $_getN(3);
  @$pb.TagNumber(4)
  set serverFeePercentPegOut($core.double v) { $_setDouble(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasServerFeePercentPegOut() => $_has(3);
  @$pb.TagNumber(4)
  void clearServerFeePercentPegOut() => clearField(4);
}

class To_Login extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'To.Login', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'sideswap.proto'), createEmptyInstance: create)
    ..aQS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'mnemonic')
  ;

  To_Login._() : super();
  factory To_Login() => create();
  factory To_Login.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory To_Login.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  To_Login clone() => To_Login()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  To_Login copyWith(void Function(To_Login) updates) => super.copyWith((message) => updates(message as To_Login)); // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static To_Login create() => To_Login._();
  To_Login createEmptyInstance() => create();
  static $pb.PbList<To_Login> createRepeated() => $pb.PbList<To_Login>();
  @$core.pragma('dart2js:noInline')
  static To_Login getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<To_Login>(create);
  static To_Login _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get mnemonic => $_getSZ(0);
  @$pb.TagNumber(1)
  set mnemonic($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMnemonic() => $_has(0);
  @$pb.TagNumber(1)
  void clearMnemonic() => clearField(1);
}

class To_SwapRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'To.SwapRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'sideswap.proto'), createEmptyInstance: create)
    ..aQS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'sendTicker')
    ..aQS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'recvTicker')
    ..aInt64(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'sendAmount')
    ..aOS(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'recvAddr')
  ;

  To_SwapRequest._() : super();
  factory To_SwapRequest() => create();
  factory To_SwapRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory To_SwapRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  To_SwapRequest clone() => To_SwapRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  To_SwapRequest copyWith(void Function(To_SwapRequest) updates) => super.copyWith((message) => updates(message as To_SwapRequest)); // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static To_SwapRequest create() => To_SwapRequest._();
  To_SwapRequest createEmptyInstance() => create();
  static $pb.PbList<To_SwapRequest> createRepeated() => $pb.PbList<To_SwapRequest>();
  @$core.pragma('dart2js:noInline')
  static To_SwapRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<To_SwapRequest>(create);
  static To_SwapRequest _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sendTicker => $_getSZ(0);
  @$pb.TagNumber(1)
  set sendTicker($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSendTicker() => $_has(0);
  @$pb.TagNumber(1)
  void clearSendTicker() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get recvTicker => $_getSZ(1);
  @$pb.TagNumber(2)
  set recvTicker($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRecvTicker() => $_has(1);
  @$pb.TagNumber(2)
  void clearRecvTicker() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get sendAmount => $_getI64(2);
  @$pb.TagNumber(3)
  set sendAmount($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSendAmount() => $_has(2);
  @$pb.TagNumber(3)
  void clearSendAmount() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get recvAddr => $_getSZ(3);
  @$pb.TagNumber(4)
  set recvAddr($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasRecvAddr() => $_has(3);
  @$pb.TagNumber(4)
  void clearRecvAddr() => clearField(4);
}

class To_CreateTx extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'To.CreateTx', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'sideswap.proto'), createEmptyInstance: create)
    ..aQS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'addr')
    ..aQM<Balance>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'balance', subBuilder: Balance.create)
  ;

  To_CreateTx._() : super();
  factory To_CreateTx() => create();
  factory To_CreateTx.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory To_CreateTx.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  To_CreateTx clone() => To_CreateTx()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  To_CreateTx copyWith(void Function(To_CreateTx) updates) => super.copyWith((message) => updates(message as To_CreateTx)); // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static To_CreateTx create() => To_CreateTx._();
  To_CreateTx createEmptyInstance() => create();
  static $pb.PbList<To_CreateTx> createRepeated() => $pb.PbList<To_CreateTx>();
  @$core.pragma('dart2js:noInline')
  static To_CreateTx getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<To_CreateTx>(create);
  static To_CreateTx _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get addr => $_getSZ(0);
  @$pb.TagNumber(1)
  set addr($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddr() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddr() => clearField(1);

  @$pb.TagNumber(2)
  Balance get balance => $_getN(1);
  @$pb.TagNumber(2)
  set balance(Balance v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasBalance() => $_has(1);
  @$pb.TagNumber(2)
  void clearBalance() => clearField(2);
  @$pb.TagNumber(2)
  Balance ensureBalance() => $_ensure(1);
}

class To_SendTx extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'To.SendTx', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'sideswap.proto'), createEmptyInstance: create)
    ..aQS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'memo')
  ;

  To_SendTx._() : super();
  factory To_SendTx() => create();
  factory To_SendTx.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory To_SendTx.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  To_SendTx clone() => To_SendTx()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  To_SendTx copyWith(void Function(To_SendTx) updates) => super.copyWith((message) => updates(message as To_SendTx)); // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static To_SendTx create() => To_SendTx._();
  To_SendTx createEmptyInstance() => create();
  static $pb.PbList<To_SendTx> createRepeated() => $pb.PbList<To_SendTx>();
  @$core.pragma('dart2js:noInline')
  static To_SendTx getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<To_SendTx>(create);
  static To_SendTx _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get memo => $_getSZ(0);
  @$pb.TagNumber(1)
  set memo($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMemo() => $_has(0);
  @$pb.TagNumber(1)
  void clearMemo() => clearField(1);
}

class To_SetMemo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'To.SetMemo', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'sideswap.proto'), createEmptyInstance: create)
    ..aQS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'txid')
    ..aQS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'memo')
  ;

  To_SetMemo._() : super();
  factory To_SetMemo() => create();
  factory To_SetMemo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory To_SetMemo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  To_SetMemo clone() => To_SetMemo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  To_SetMemo copyWith(void Function(To_SetMemo) updates) => super.copyWith((message) => updates(message as To_SetMemo)); // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static To_SetMemo create() => To_SetMemo._();
  To_SetMemo createEmptyInstance() => create();
  static $pb.PbList<To_SetMemo> createRepeated() => $pb.PbList<To_SetMemo>();
  @$core.pragma('dart2js:noInline')
  static To_SetMemo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<To_SetMemo>(create);
  static To_SetMemo _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get memo => $_getSZ(1);
  @$pb.TagNumber(2)
  set memo($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMemo() => $_has(1);
  @$pb.TagNumber(2)
  void clearMemo() => clearField(2);
}

enum To_Msg {
  login, 
  logout, 
  setMemo, 
  getRecvAddress, 
  createTx, 
  sendTx, 
  swapRequest, 
  swapCancel, 
  swapAccept, 
  notSet
}

class To extends $pb.GeneratedMessage {
  static const $core.Map<$core.int, To_Msg> _To_MsgByTag = {
    1 : To_Msg.login,
    2 : To_Msg.logout,
    10 : To_Msg.setMemo,
    11 : To_Msg.getRecvAddress,
    12 : To_Msg.createTx,
    13 : To_Msg.sendTx,
    20 : To_Msg.swapRequest,
    21 : To_Msg.swapCancel,
    22 : To_Msg.swapAccept,
    0 : To_Msg.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'To', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'sideswap.proto'), createEmptyInstance: create)
    ..oo(0, [1, 2, 10, 11, 12, 13, 20, 21, 22])
    ..aOM<To_Login>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'login', subBuilder: To_Login.create)
    ..aOM<Empty>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'logout', subBuilder: Empty.create)
    ..aOM<To_SetMemo>(10, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'setMemo', subBuilder: To_SetMemo.create)
    ..aOM<Empty>(11, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'getRecvAddress', subBuilder: Empty.create)
    ..aOM<To_CreateTx>(12, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'createTx', subBuilder: To_CreateTx.create)
    ..aOM<To_SendTx>(13, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'sendTx', subBuilder: To_SendTx.create)
    ..aOM<To_SwapRequest>(20, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'swapRequest', subBuilder: To_SwapRequest.create)
    ..aOM<Empty>(21, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'swapCancel', subBuilder: Empty.create)
    ..aOM<Empty>(22, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'swapAccept', subBuilder: Empty.create)
  ;

  To._() : super();
  factory To() => create();
  factory To.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory To.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  To clone() => To()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  To copyWith(void Function(To) updates) => super.copyWith((message) => updates(message as To)); // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static To create() => To._();
  To createEmptyInstance() => create();
  static $pb.PbList<To> createRepeated() => $pb.PbList<To>();
  @$core.pragma('dart2js:noInline')
  static To getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<To>(create);
  static To _defaultInstance;

  To_Msg whichMsg() => _To_MsgByTag[$_whichOneof(0)];
  void clearMsg() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  To_Login get login => $_getN(0);
  @$pb.TagNumber(1)
  set login(To_Login v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasLogin() => $_has(0);
  @$pb.TagNumber(1)
  void clearLogin() => clearField(1);
  @$pb.TagNumber(1)
  To_Login ensureLogin() => $_ensure(0);

  @$pb.TagNumber(2)
  Empty get logout => $_getN(1);
  @$pb.TagNumber(2)
  set logout(Empty v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasLogout() => $_has(1);
  @$pb.TagNumber(2)
  void clearLogout() => clearField(2);
  @$pb.TagNumber(2)
  Empty ensureLogout() => $_ensure(1);

  @$pb.TagNumber(10)
  To_SetMemo get setMemo => $_getN(2);
  @$pb.TagNumber(10)
  set setMemo(To_SetMemo v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasSetMemo() => $_has(2);
  @$pb.TagNumber(10)
  void clearSetMemo() => clearField(10);
  @$pb.TagNumber(10)
  To_SetMemo ensureSetMemo() => $_ensure(2);

  @$pb.TagNumber(11)
  Empty get getRecvAddress => $_getN(3);
  @$pb.TagNumber(11)
  set getRecvAddress(Empty v) { setField(11, v); }
  @$pb.TagNumber(11)
  $core.bool hasGetRecvAddress() => $_has(3);
  @$pb.TagNumber(11)
  void clearGetRecvAddress() => clearField(11);
  @$pb.TagNumber(11)
  Empty ensureGetRecvAddress() => $_ensure(3);

  @$pb.TagNumber(12)
  To_CreateTx get createTx => $_getN(4);
  @$pb.TagNumber(12)
  set createTx(To_CreateTx v) { setField(12, v); }
  @$pb.TagNumber(12)
  $core.bool hasCreateTx() => $_has(4);
  @$pb.TagNumber(12)
  void clearCreateTx() => clearField(12);
  @$pb.TagNumber(12)
  To_CreateTx ensureCreateTx() => $_ensure(4);

  @$pb.TagNumber(13)
  To_SendTx get sendTx => $_getN(5);
  @$pb.TagNumber(13)
  set sendTx(To_SendTx v) { setField(13, v); }
  @$pb.TagNumber(13)
  $core.bool hasSendTx() => $_has(5);
  @$pb.TagNumber(13)
  void clearSendTx() => clearField(13);
  @$pb.TagNumber(13)
  To_SendTx ensureSendTx() => $_ensure(5);

  @$pb.TagNumber(20)
  To_SwapRequest get swapRequest => $_getN(6);
  @$pb.TagNumber(20)
  set swapRequest(To_SwapRequest v) { setField(20, v); }
  @$pb.TagNumber(20)
  $core.bool hasSwapRequest() => $_has(6);
  @$pb.TagNumber(20)
  void clearSwapRequest() => clearField(20);
  @$pb.TagNumber(20)
  To_SwapRequest ensureSwapRequest() => $_ensure(6);

  @$pb.TagNumber(21)
  Empty get swapCancel => $_getN(7);
  @$pb.TagNumber(21)
  set swapCancel(Empty v) { setField(21, v); }
  @$pb.TagNumber(21)
  $core.bool hasSwapCancel() => $_has(7);
  @$pb.TagNumber(21)
  void clearSwapCancel() => clearField(21);
  @$pb.TagNumber(21)
  Empty ensureSwapCancel() => $_ensure(7);

  @$pb.TagNumber(22)
  Empty get swapAccept => $_getN(8);
  @$pb.TagNumber(22)
  set swapAccept(Empty v) { setField(22, v); }
  @$pb.TagNumber(22)
  $core.bool hasSwapAccept() => $_has(8);
  @$pb.TagNumber(22)
  void clearSwapAccept() => clearField(22);
  @$pb.TagNumber(22)
  Empty ensureSwapAccept() => $_ensure(8);
}

class From_NewTx extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'From.NewTx', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'sideswap.proto'), createEmptyInstance: create)
    ..pc<Transaction>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'txs', $pb.PbFieldType.PM, subBuilder: Transaction.create)
  ;

  From_NewTx._() : super();
  factory From_NewTx() => create();
  factory From_NewTx.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory From_NewTx.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  From_NewTx clone() => From_NewTx()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  From_NewTx copyWith(void Function(From_NewTx) updates) => super.copyWith((message) => updates(message as From_NewTx)); // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static From_NewTx create() => From_NewTx._();
  From_NewTx createEmptyInstance() => create();
  static $pb.PbList<From_NewTx> createRepeated() => $pb.PbList<From_NewTx>();
  @$core.pragma('dart2js:noInline')
  static From_NewTx getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<From_NewTx>(create);
  static From_NewTx _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Transaction> get txs => $_getList(0);
}

class From_SwapReview extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'From.SwapReview', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'sideswap.proto'), createEmptyInstance: create)
    ..aQS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'sendAsset')
    ..aQS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'recvAsset')
    ..a<$fixnum.Int64>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'createdAt', $pb.PbFieldType.Q6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'expiresAt', $pb.PbFieldType.Q6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'sendAmount', $pb.PbFieldType.Q6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'recvAmount', $pb.PbFieldType.Q6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'networkFee', $pb.PbFieldType.Q6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(8, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'serverFee', $pb.PbFieldType.Q6, defaultOrMaker: $fixnum.Int64.ZERO)
  ;

  From_SwapReview._() : super();
  factory From_SwapReview() => create();
  factory From_SwapReview.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory From_SwapReview.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  From_SwapReview clone() => From_SwapReview()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  From_SwapReview copyWith(void Function(From_SwapReview) updates) => super.copyWith((message) => updates(message as From_SwapReview)); // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static From_SwapReview create() => From_SwapReview._();
  From_SwapReview createEmptyInstance() => create();
  static $pb.PbList<From_SwapReview> createRepeated() => $pb.PbList<From_SwapReview>();
  @$core.pragma('dart2js:noInline')
  static From_SwapReview getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<From_SwapReview>(create);
  static From_SwapReview _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sendAsset => $_getSZ(0);
  @$pb.TagNumber(1)
  set sendAsset($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSendAsset() => $_has(0);
  @$pb.TagNumber(1)
  void clearSendAsset() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get recvAsset => $_getSZ(1);
  @$pb.TagNumber(2)
  set recvAsset($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRecvAsset() => $_has(1);
  @$pb.TagNumber(2)
  void clearRecvAsset() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get createdAt => $_getI64(2);
  @$pb.TagNumber(3)
  set createdAt($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasCreatedAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearCreatedAt() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get expiresAt => $_getI64(3);
  @$pb.TagNumber(4)
  set expiresAt($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasExpiresAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearExpiresAt() => clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get sendAmount => $_getI64(4);
  @$pb.TagNumber(5)
  set sendAmount($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasSendAmount() => $_has(4);
  @$pb.TagNumber(5)
  void clearSendAmount() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get recvAmount => $_getI64(5);
  @$pb.TagNumber(6)
  set recvAmount($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasRecvAmount() => $_has(5);
  @$pb.TagNumber(6)
  void clearRecvAmount() => clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get networkFee => $_getI64(6);
  @$pb.TagNumber(7)
  set networkFee($fixnum.Int64 v) { $_setInt64(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasNetworkFee() => $_has(6);
  @$pb.TagNumber(7)
  void clearNetworkFee() => clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get serverFee => $_getI64(7);
  @$pb.TagNumber(8)
  set serverFee($fixnum.Int64 v) { $_setInt64(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasServerFee() => $_has(7);
  @$pb.TagNumber(8)
  void clearServerFee() => clearField(8);
}

class From_SwapWaitTx extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'From.SwapWaitTx', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'sideswap.proto'), createEmptyInstance: create)
    ..aQS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'pegAddr')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'recvAddr')
  ;

  From_SwapWaitTx._() : super();
  factory From_SwapWaitTx() => create();
  factory From_SwapWaitTx.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory From_SwapWaitTx.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  From_SwapWaitTx clone() => From_SwapWaitTx()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  From_SwapWaitTx copyWith(void Function(From_SwapWaitTx) updates) => super.copyWith((message) => updates(message as From_SwapWaitTx)); // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static From_SwapWaitTx create() => From_SwapWaitTx._();
  From_SwapWaitTx createEmptyInstance() => create();
  static $pb.PbList<From_SwapWaitTx> createRepeated() => $pb.PbList<From_SwapWaitTx>();
  @$core.pragma('dart2js:noInline')
  static From_SwapWaitTx getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<From_SwapWaitTx>(create);
  static From_SwapWaitTx _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get pegAddr => $_getSZ(0);
  @$pb.TagNumber(1)
  set pegAddr($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPegAddr() => $_has(0);
  @$pb.TagNumber(1)
  void clearPegAddr() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get recvAddr => $_getSZ(1);
  @$pb.TagNumber(2)
  set recvAddr($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRecvAddr() => $_has(1);
  @$pb.TagNumber(2)
  void clearRecvAddr() => clearField(2);
}

class From_SwapSucceed extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'From.SwapSucceed', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'sideswap.proto'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'createdAt', $pb.PbFieldType.Q6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'sentAmount', $pb.PbFieldType.Q6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'recvAmount', $pb.PbFieldType.Q6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aQS(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'txid')
    ..aOS(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'recvAddr')
  ;

  From_SwapSucceed._() : super();
  factory From_SwapSucceed() => create();
  factory From_SwapSucceed.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory From_SwapSucceed.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  From_SwapSucceed clone() => From_SwapSucceed()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  From_SwapSucceed copyWith(void Function(From_SwapSucceed) updates) => super.copyWith((message) => updates(message as From_SwapSucceed)); // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static From_SwapSucceed create() => From_SwapSucceed._();
  From_SwapSucceed createEmptyInstance() => create();
  static $pb.PbList<From_SwapSucceed> createRepeated() => $pb.PbList<From_SwapSucceed>();
  @$core.pragma('dart2js:noInline')
  static From_SwapSucceed getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<From_SwapSucceed>(create);
  static From_SwapSucceed _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get createdAt => $_getI64(0);
  @$pb.TagNumber(1)
  set createdAt($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCreatedAt() => $_has(0);
  @$pb.TagNumber(1)
  void clearCreatedAt() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get sentAmount => $_getI64(1);
  @$pb.TagNumber(2)
  set sentAmount($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSentAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearSentAmount() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get recvAmount => $_getI64(2);
  @$pb.TagNumber(3)
  set recvAmount($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRecvAmount() => $_has(2);
  @$pb.TagNumber(3)
  void clearRecvAmount() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get txid => $_getSZ(3);
  @$pb.TagNumber(4)
  set txid($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasTxid() => $_has(3);
  @$pb.TagNumber(4)
  void clearTxid() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get recvAddr => $_getSZ(4);
  @$pb.TagNumber(5)
  set recvAddr($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasRecvAddr() => $_has(4);
  @$pb.TagNumber(5)
  void clearRecvAddr() => clearField(5);
}

enum From_CreateTxResult_Result {
  errorMsg, 
  networkFee, 
  notSet
}

class From_CreateTxResult extends $pb.GeneratedMessage {
  static const $core.Map<$core.int, From_CreateTxResult_Result> _From_CreateTxResult_ResultByTag = {
    1 : From_CreateTxResult_Result.errorMsg,
    2 : From_CreateTxResult_Result.networkFee,
    0 : From_CreateTxResult_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'From.CreateTxResult', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'sideswap.proto'), createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'errorMsg')
    ..aInt64(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'networkFee')
    ..hasRequiredFields = false
  ;

  From_CreateTxResult._() : super();
  factory From_CreateTxResult() => create();
  factory From_CreateTxResult.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory From_CreateTxResult.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  From_CreateTxResult clone() => From_CreateTxResult()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  From_CreateTxResult copyWith(void Function(From_CreateTxResult) updates) => super.copyWith((message) => updates(message as From_CreateTxResult)); // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static From_CreateTxResult create() => From_CreateTxResult._();
  From_CreateTxResult createEmptyInstance() => create();
  static $pb.PbList<From_CreateTxResult> createRepeated() => $pb.PbList<From_CreateTxResult>();
  @$core.pragma('dart2js:noInline')
  static From_CreateTxResult getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<From_CreateTxResult>(create);
  static From_CreateTxResult _defaultInstance;

  From_CreateTxResult_Result whichResult() => _From_CreateTxResult_ResultByTag[$_whichOneof(0)];
  void clearResult() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get errorMsg => $_getSZ(0);
  @$pb.TagNumber(1)
  set errorMsg($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasErrorMsg() => $_has(0);
  @$pb.TagNumber(1)
  void clearErrorMsg() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get networkFee => $_getI64(1);
  @$pb.TagNumber(2)
  set networkFee($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasNetworkFee() => $_has(1);
  @$pb.TagNumber(2)
  void clearNetworkFee() => clearField(2);
}

enum From_SendResult_Result {
  errorMsg, 
  txid, 
  notSet
}

class From_SendResult extends $pb.GeneratedMessage {
  static const $core.Map<$core.int, From_SendResult_Result> _From_SendResult_ResultByTag = {
    1 : From_SendResult_Result.errorMsg,
    2 : From_SendResult_Result.txid,
    0 : From_SendResult_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'From.SendResult', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'sideswap.proto'), createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'errorMsg')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  From_SendResult._() : super();
  factory From_SendResult() => create();
  factory From_SendResult.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory From_SendResult.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  From_SendResult clone() => From_SendResult()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  From_SendResult copyWith(void Function(From_SendResult) updates) => super.copyWith((message) => updates(message as From_SendResult)); // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static From_SendResult create() => From_SendResult._();
  From_SendResult createEmptyInstance() => create();
  static $pb.PbList<From_SendResult> createRepeated() => $pb.PbList<From_SendResult>();
  @$core.pragma('dart2js:noInline')
  static From_SendResult getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<From_SendResult>(create);
  static From_SendResult _defaultInstance;

  From_SendResult_Result whichResult() => _From_SendResult_ResultByTag[$_whichOneof(0)];
  void clearResult() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get errorMsg => $_getSZ(0);
  @$pb.TagNumber(1)
  set errorMsg($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasErrorMsg() => $_has(0);
  @$pb.TagNumber(1)
  void clearErrorMsg() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get txid => $_getSZ(1);
  @$pb.TagNumber(2)
  set txid($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTxid() => $_has(1);
  @$pb.TagNumber(2)
  void clearTxid() => clearField(2);
}

enum From_Msg {
  newTx, 
  newAsset, 
  balanceUpdate, 
  serverStatus, 
  swapReview, 
  swapWaitTx, 
  swapSucceed, 
  swapFailed, 
  recvAddress, 
  createTxResult, 
  sendResult, 
  notSet
}

class From extends $pb.GeneratedMessage {
  static const $core.Map<$core.int, From_Msg> _From_MsgByTag = {
    1 : From_Msg.newTx,
    2 : From_Msg.newAsset,
    3 : From_Msg.balanceUpdate,
    4 : From_Msg.serverStatus,
    20 : From_Msg.swapReview,
    21 : From_Msg.swapWaitTx,
    22 : From_Msg.swapSucceed,
    23 : From_Msg.swapFailed,
    30 : From_Msg.recvAddress,
    31 : From_Msg.createTxResult,
    32 : From_Msg.sendResult,
    0 : From_Msg.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'From', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'sideswap.proto'), createEmptyInstance: create)
    ..oo(0, [1, 2, 3, 4, 20, 21, 22, 23, 30, 31, 32])
    ..aOM<From_NewTx>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'newTx', subBuilder: From_NewTx.create)
    ..aOM<Asset>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'newAsset', subBuilder: Asset.create)
    ..aOM<Balance>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'balanceUpdate', subBuilder: Balance.create)
    ..aOM<ServerStatus>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'serverStatus', subBuilder: ServerStatus.create)
    ..aOM<From_SwapReview>(20, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'swapReview', subBuilder: From_SwapReview.create)
    ..aOM<From_SwapWaitTx>(21, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'swapWaitTx', subBuilder: From_SwapWaitTx.create)
    ..aOM<From_SwapSucceed>(22, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'swapSucceed', subBuilder: From_SwapSucceed.create)
    ..aOS(23, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'swapFailed')
    ..aOM<Address>(30, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'recvAddress', subBuilder: Address.create)
    ..aOM<From_CreateTxResult>(31, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'createTxResult', subBuilder: From_CreateTxResult.create)
    ..aOM<From_SendResult>(32, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'sendResult', subBuilder: From_SendResult.create)
  ;

  From._() : super();
  factory From() => create();
  factory From.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory From.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  From clone() => From()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  From copyWith(void Function(From) updates) => super.copyWith((message) => updates(message as From)); // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static From create() => From._();
  From createEmptyInstance() => create();
  static $pb.PbList<From> createRepeated() => $pb.PbList<From>();
  @$core.pragma('dart2js:noInline')
  static From getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<From>(create);
  static From _defaultInstance;

  From_Msg whichMsg() => _From_MsgByTag[$_whichOneof(0)];
  void clearMsg() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  From_NewTx get newTx => $_getN(0);
  @$pb.TagNumber(1)
  set newTx(From_NewTx v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasNewTx() => $_has(0);
  @$pb.TagNumber(1)
  void clearNewTx() => clearField(1);
  @$pb.TagNumber(1)
  From_NewTx ensureNewTx() => $_ensure(0);

  @$pb.TagNumber(2)
  Asset get newAsset => $_getN(1);
  @$pb.TagNumber(2)
  set newAsset(Asset v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasNewAsset() => $_has(1);
  @$pb.TagNumber(2)
  void clearNewAsset() => clearField(2);
  @$pb.TagNumber(2)
  Asset ensureNewAsset() => $_ensure(1);

  @$pb.TagNumber(3)
  Balance get balanceUpdate => $_getN(2);
  @$pb.TagNumber(3)
  set balanceUpdate(Balance v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasBalanceUpdate() => $_has(2);
  @$pb.TagNumber(3)
  void clearBalanceUpdate() => clearField(3);
  @$pb.TagNumber(3)
  Balance ensureBalanceUpdate() => $_ensure(2);

  @$pb.TagNumber(4)
  ServerStatus get serverStatus => $_getN(3);
  @$pb.TagNumber(4)
  set serverStatus(ServerStatus v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasServerStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearServerStatus() => clearField(4);
  @$pb.TagNumber(4)
  ServerStatus ensureServerStatus() => $_ensure(3);

  @$pb.TagNumber(20)
  From_SwapReview get swapReview => $_getN(4);
  @$pb.TagNumber(20)
  set swapReview(From_SwapReview v) { setField(20, v); }
  @$pb.TagNumber(20)
  $core.bool hasSwapReview() => $_has(4);
  @$pb.TagNumber(20)
  void clearSwapReview() => clearField(20);
  @$pb.TagNumber(20)
  From_SwapReview ensureSwapReview() => $_ensure(4);

  @$pb.TagNumber(21)
  From_SwapWaitTx get swapWaitTx => $_getN(5);
  @$pb.TagNumber(21)
  set swapWaitTx(From_SwapWaitTx v) { setField(21, v); }
  @$pb.TagNumber(21)
  $core.bool hasSwapWaitTx() => $_has(5);
  @$pb.TagNumber(21)
  void clearSwapWaitTx() => clearField(21);
  @$pb.TagNumber(21)
  From_SwapWaitTx ensureSwapWaitTx() => $_ensure(5);

  @$pb.TagNumber(22)
  From_SwapSucceed get swapSucceed => $_getN(6);
  @$pb.TagNumber(22)
  set swapSucceed(From_SwapSucceed v) { setField(22, v); }
  @$pb.TagNumber(22)
  $core.bool hasSwapSucceed() => $_has(6);
  @$pb.TagNumber(22)
  void clearSwapSucceed() => clearField(22);
  @$pb.TagNumber(22)
  From_SwapSucceed ensureSwapSucceed() => $_ensure(6);

  @$pb.TagNumber(23)
  $core.String get swapFailed => $_getSZ(7);
  @$pb.TagNumber(23)
  set swapFailed($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(23)
  $core.bool hasSwapFailed() => $_has(7);
  @$pb.TagNumber(23)
  void clearSwapFailed() => clearField(23);

  @$pb.TagNumber(30)
  Address get recvAddress => $_getN(8);
  @$pb.TagNumber(30)
  set recvAddress(Address v) { setField(30, v); }
  @$pb.TagNumber(30)
  $core.bool hasRecvAddress() => $_has(8);
  @$pb.TagNumber(30)
  void clearRecvAddress() => clearField(30);
  @$pb.TagNumber(30)
  Address ensureRecvAddress() => $_ensure(8);

  @$pb.TagNumber(31)
  From_CreateTxResult get createTxResult => $_getN(9);
  @$pb.TagNumber(31)
  set createTxResult(From_CreateTxResult v) { setField(31, v); }
  @$pb.TagNumber(31)
  $core.bool hasCreateTxResult() => $_has(9);
  @$pb.TagNumber(31)
  void clearCreateTxResult() => clearField(31);
  @$pb.TagNumber(31)
  From_CreateTxResult ensureCreateTxResult() => $_ensure(9);

  @$pb.TagNumber(32)
  From_SendResult get sendResult => $_getN(10);
  @$pb.TagNumber(32)
  set sendResult(From_SendResult v) { setField(32, v); }
  @$pb.TagNumber(32)
  $core.bool hasSendResult() => $_has(10);
  @$pb.TagNumber(32)
  void clearSendResult() => clearField(32);
  @$pb.TagNumber(32)
  From_SendResult ensureSendResult() => $_ensure(10);
}

