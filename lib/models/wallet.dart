import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sideswap/common/encryption.dart';
import 'package:sideswap/common/helpers.dart';
import 'package:sideswap/protobuf/sideswap.pb.dart';
import 'package:sideswap/side_swap_client_ffi.dart';

enum Status {
  loading,
  reviewLicense,
  noWalet,
  backupNewPrompt,
  backupNewView,
  backupNewCheck,
  backupNewCheckFailed,
  importing,
  backup,

  registered,
  assetsSelect,
  assetDetails,
  txDetails,
  txEditMemo,

  assetReceive,
  assetSendEnter,
  assetSendCreateTx,
  assetSendConfirm,
  assetSendProcessing,
  assetSendSucceed,

  swapWaitServer,
  swapReview,
  swapSucceed,
  swapWaitPegTx,

  settingsBackup,
  settingsAboutUs,
  settingsDeletePrompt,
}

enum SwapType {
  atomic,
  pegIn,
  pegOut,
}

enum SwapWallet {
  local,
  extern,
}

enum AddrType {
  bitcoin,
  elements,
}

const mnemnicField = 'mnemonic';
const licenseAcceptedField = 'license_accepted';
const disabledAssetsField = 'disabled_assets';

class Lib {
  static var dynLib = (Platform.isIOS || Platform.isMacOS)
      ? ffi.DynamicLibrary.process()
      : ffi.DynamicLibrary.open("libsideswap_client.so");
  static var lib = NativeLibrary(Lib.dynLib);
}

typedef dartPostCObject = ffi.Pointer Function(
    ffi.Pointer<
        ffi.NativeFunction<
            ffi.Int8 Function(ffi.Int64, ffi.Pointer<ffi.Dart_CObject>)>>);

const int kBackupCheckLineCount = 4;
const int kBackupCheckWordCount = 3;

AddrType swapAddrType(SwapType swapType) {
  if (swapType == SwapType.pegOut) {
    return AddrType.bitcoin;
  }
  return AddrType.elements;
}

String addrTypeStr(AddrType addrType) {
  switch (addrType) {
    case AddrType.bitcoin:
      return 'Bitcoin';
    case AddrType.elements:
      return 'Liquid';
  }
  throw Exception('unexpected value');
}

String swapTypeStr(SwapType swapType) {
  switch (swapType) {
    case SwapType.atomic:
      return 'Swapped';
    case SwapType.pegIn:
      return 'Peg-In';
    case SwapType.pegOut:
      return 'Peg-Out';
  }
  throw Exception('unexpected value');
}

class Wallet extends ChangeNotifier {
  int _client = 0;

  Encryption encryption = Encryption();

  String _mnemonic = "";
  bool _licenseAccepted = false;
  var disabledAssetTickers = Set<String>();
  var enabledAssetTickers = List<String>();

  Status status = Status.loading;

  ServerStatus serverStatus = null;

  final swapAmountController = TextEditingController();
  final swapAddressRecvController = TextEditingController();
  String swapSendAsset = null;
  String swapRecvAsset = null;
  int swapSendAmount = null;
  int swapRecvAmount = null;
  int swapNetworkFee = null;
  int swapServerFee = null;
  int swapCreatedAt = null;
  int swapExpiresAt = null;
  String swapSucceedTxid = null;
  DateTime swapSucceedTimestamp = null;
  SwapWallet swapSendWallet = SwapWallet.local;
  SwapWallet swapRecvWallet = SwapWallet.local;
  String swapNetworkError = null;
  String swapRecvAddressExternal = null;
  String swapPegAddressServer = null;

  String selectedWalletAsset = null;
  String recvAddress = null;

  Map<int, List<String>> backupCheckAllWords;
  Map<int, int> backupCheckSelectedWords;

  int mainPage = 0;

  var assetTickers = List<String>();
  var assets = Map<String, Asset>();
  var assetImagesBig = Map<String, Image>();
  var assetImagesSmall = Map<String, Image>();

  var txs = List<Transaction>();
  var assetTxs = Map<String, List<Transaction>>();
  var balances = Map<String, int>();

  final sendAmountController = TextEditingController();
  final sendAddressController = TextEditingController();
  final sendMemoController = TextEditingController();
  String sendAddrParsed = null;
  int sendAmountParsed = 0;
  String sendResultError = null;
  String sendResultTxid = null;
  int sendNetworkFee = 0;

  // Toggle assets page
  var filteredToggleTickers = List<String>();

  Transaction txDetails = null;

  var txMemoUpdates = Map<String, String>();
  String currentTxMemoUpdate = null;

  void _sendMsg(To to) {
    if (kDebugMode) {
      print('send: $to');
    }
    if (_client == 0) {
      throw ErrorDescription("client is not initialzed");
    }
    var buf = to.writeToBuffer();
    final pointer = allocate<ffi.Uint8>(count: buf.length);
    for (int i = 0; i < buf.length; i++) {
      pointer[i] = buf[i];
    }
    Lib.lib.sideswap_send_request(_client, pointer.cast(), buf.length);
    free(pointer);
  }

  Wallet() {
    final storeDartPostCObject = Lib.dynLib
        .lookupFunction<dartPostCObject, dartPostCObject>(
            'store_dart_post_cobject');
    assert(storeDartPostCObject != null);
    storeDartPostCObject(ffi.NativeApi.postCObject);

    _client = Lib.lib.sideswap_client_create();

    _startClient();
  }

  _startClient() async {
    await _addBtcAsset();

    ReceivePort receivePort = ReceivePort();

    var workDir = await getApplicationSupportDirectory();
    var workPath = Utf8.toUtf8(workDir.absolute.path);
    Lib.lib.sideswap_client_start(
        _client, workPath.cast(), receivePort.sendPort.nativePort);

    receivePort.listen((msgPtr) {
      var ptr = Lib.lib.sideswap_msg_ptr(msgPtr);
      var len = Lib.lib.sideswap_msg_len(msgPtr);
      var msg = new From.fromBuffer(ptr.asTypedList(len));
      Lib.lib.sideswap_msg_free(msgPtr);
      _recvMsg(msg);
    });

    await _loadState();

    if (!_licenseAccepted) {
      status = Status.reviewLicense;
    } else if (validateMnemonic(_mnemonic)) {
      _login(_mnemonic);
      status = Status.registered;
    } else {
      status = Status.noWalet;
    }

    notifyListeners();
  }

  void _recvMsg(From from) {
    if (kDebugMode) {
      print('recv: $from');
    }
    // Process message here
    switch (from.whichMsg()) {
      case From_Msg.newTx:
        txs.addAll(from.newTx.txs);
        txs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        for (var tx in from.newTx.txs) {
          for (var balance in tx.balances) {
            if (assetTxs[balance.ticker] == null) {
              assetTxs[balance.ticker] = List();
            }
            assetTxs[balance.ticker].add(tx);
          }
        }
        for (var txs in assetTxs.values) {
          txs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        }

        notifyListeners();
        break;
      case From_Msg.newAsset:
        var assetIcon = base64Decode(from.newAsset.icon);
        _addAsset(from.newAsset, assetIcon);
        break;
      case From_Msg.balanceUpdate:
        balances[from.balanceUpdate.ticker] = from.balanceUpdate.amount.toInt();
        notifyListeners();
        break;

      case From_Msg.swapReview:
        status = Status.swapReview;
        swapSendAsset = from.swapReview.sendAsset;
        swapRecvAsset = from.swapReview.recvAsset;
        swapSendAmount = from.swapReview.sendAmount.toInt();
        swapRecvAmount = from.swapReview.recvAmount.toInt();
        swapCreatedAt = from.swapReview.createdAt.toInt();
        swapExpiresAt = from.swapReview.expiresAt.toInt();
        swapServerFee = from.swapReview.serverFee.toInt();
        swapNetworkFee = from.swapReview.networkFee.toInt();
        notifyListeners();
        break;

      case From_Msg.swapFailed:
        swapNetworkError = from.swapFailed;
        status = Status.registered;
        notifyListeners();
        break;

      case From_Msg.swapSucceed:
        status = Status.swapSucceed;
        swapSucceedTxid = from.swapSucceed.txid;
        swapSucceedTimestamp = DateTime.fromMillisecondsSinceEpoch(
            from.swapSucceed.createdAt.toInt());
        swapSendAmount = from.swapSucceed.sentAmount.toInt();
        // recv_amount could be 0 for external pegs that is too low
        swapRecvAmount = from.swapSucceed.recvAmount.toInt();
        swapRecvAddressExternal = from.swapSucceed.recvAddr;

        notifyListeners();
        break;

      case From_Msg.swapWaitTx:
        status = Status.swapWaitPegTx;
        swapPegAddressServer = from.swapWaitTx.pegAddr;
        swapRecvAddressExternal = from.swapWaitTx.recvAddr;
        notifyListeners();
        break;

      case From_Msg.recvAddress:
        recvAddress = from.recvAddress.addr;
        notifyListeners();
        break;

      case From_Msg.createTxResult:
        switch (from.createTxResult.whichResult()) {
          case From_CreateTxResult_Result.errorMsg:
            sendResultError = from.createTxResult.errorMsg;
            status = Status.assetSendEnter;
            break;
          case From_CreateTxResult_Result.networkFee:
            sendNetworkFee = from.createTxResult.networkFee.toInt();
            status = Status.assetSendConfirm;
            break;
          case From_CreateTxResult_Result.notSet:
            throw Exception("invalid send result message");
        }
        notifyListeners();
        break;

      case From_Msg.sendResult:
        status = Status.assetDetails;
        switch (from.sendResult.whichResult()) {
          case From_SendResult_Result.errorMsg:
            sendResultError = from.sendResult.errorMsg;
            break;
          case From_SendResult_Result.txid:
            status = Status.assetSendSucceed;
            sendResultTxid = from.sendResult.txid;
            break;
          case From_SendResult_Result.notSet:
            throw Exception("invalid send result message");
        }
        notifyListeners();
        break;

      case From_Msg.serverStatus:
        serverStatus = from.serverStatus;
        // TODO: Allow pegs only after that
        notifyListeners();
        break;

      case From_Msg.notSet:
        throw Exception("invalid empty message");
    }
  }

  void _addBtcAsset() async {
    Asset bitcoinAsset = Asset();
    bitcoinAsset.name = 'Bitcoin';
    bitcoinAsset.ticker = kBitcoinTicker;
    bitcoinAsset.precision = kDefaultPrecision;
    var icon = await rootBundle.load('images/icon_btc.png');
    _addAsset(bitcoinAsset, icon.buffer.asUint8List());
  }

  void _addAsset(Asset asset, Uint8List assetIcon) {
    if (assets[asset.ticker] == null) {
      assetTickers.add(asset.ticker);
      assets[asset.ticker] = asset;
      assetImagesBig[asset.ticker] = Image.memory(
        assetIcon,
        width: 75,
        height: 75,
        filterQuality: FilterQuality.high,
      );
      assetImagesSmall[asset.ticker] = Image.memory(
        assetIcon,
        width: 32,
        height: 32,
        filterQuality: FilterQuality.high,
      );
      updateEnabledAssetIds();
    }
    // Make sure we don't have null values
    if (balances[asset.ticker] == null) {
      balances[asset.ticker] = 0;
    }
    _checkSelectedAsset();
    notifyListeners();
  }

  int parseBitcoinAmount(String value) {
    if (value == null) return null;
    int amount =
        Lib.lib.sideswap_parse_bitcoin_amount(Utf8.toUtf8(value).cast());
    if (!Lib.lib.sideswap_parsed_amount_valid(amount)) {
      return null;
    }
    return amount;
  }

  String getNewMnemonic() {
    var mnemonicPtr = Lib.lib.sideswap_generate_mnemonic12();
    var mnemonic = Utf8.fromUtf8(mnemonicPtr.cast());
    Lib.lib.sideswap_string_free(mnemonicPtr);
    return mnemonic;
  }

  bool validateMnemonic(String mnemonic) {
    return Lib.lib.sideswap_verify_mnemonic(Utf8.toUtf8(mnemonic).cast());
  }

  void _checkSelectedAsset() {
    if (assets.length < 2) {
      return;
    }
    if (swapSendAsset == null) {
      swapSendAsset = kBitcoinTicker;
      swapRecvAsset = kLiquidBitcoinTicker;
    }
    var recvAssetsAllowed = swapRecvAssets();
    if (!recvAssetsAllowed.contains(swapRecvAsset)) {
      swapRecvAsset = recvAssetsAllowed.first;
    }

    var allowedSendList = allowedSendWallets();
    if (!allowedSendList.contains(swapSendWallet)) {
      swapSendWallet = allowedSendList.first;
    }

    var allowedRecvList = allowedRecvWallets();
    if (!allowedRecvList.contains(swapRecvWallet)) {
      swapRecvWallet = allowedRecvList.first;
    }
  }

  _loadState() async {
    var prefs = await SharedPreferences.getInstance();
    _mnemonic = prefs.getString(mnemnicField) ?? "";
    _licenseAccepted = prefs.getBool(licenseAcceptedField) ?? false;
    disabledAssetTickers =
        (prefs.getStringList(disabledAssetsField) ?? List()).toSet();
    updateEnabledAssetIds();
  }

  _saveState() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString(mnemnicField, _mnemonic);
    prefs.setBool(licenseAcceptedField, _licenseAccepted);
    prefs.setStringList(disabledAssetsField, disabledAssetTickers.toList());
  }

  void updateEnabledAssetIds() {
    enabledAssetTickers.clear();
    for (var ticker in assetTickers) {
      if (!disabledAssetTickers.contains(ticker) && ticker != kBitcoinTicker) {
        enabledAssetTickers.add(ticker);
      }
    }
  }

  String getMnemonic() {
    return _mnemonic;
  }

  List<String> getMnemonicWords() {
    return getMnemonic().split(" ");
  }

  void createNewWallet() {
    String mnemonic = getNewMnemonic();
    importMnemonic(mnemonic);
    status = Status.backupNewPrompt;
    notifyListeners();
  }

  void importMnemonic(String mnemonic) {
    assert(validateMnemonic(mnemonic));
    _logout();
    _login(mnemonic);
    _mnemonic = mnemonic;
    status = Status.registered;
    _saveState();
    _checkSelectedAsset();
    notifyListeners();
  }

  void acceptLicense() {
    _licenseAccepted = true;
    status = Status.noWalet;
    notifyListeners();
  }

  void startMnemonicImport() {
    assert(status == Status.noWalet);
    status = Status.importing;
    notifyListeners();
  }

  void startMnemonicBackup() {
    assert(status == Status.registered);
    status = Status.backup;
    notifyListeners();
  }

  void cancelMnemonicBackup() {
    assert(status == Status.backup);
    status = Status.registered;
    notifyListeners();
  }

  void backupNewWallet() {
    status = Status.backupNewView;
    notifyListeners();
  }

  void backupNewWalletYes() {
    status = Status.backupNewView;
    notifyListeners();
  }

  void backupNewWalletNo() {
    status = Status.registered;
    notifyListeners();
  }

  void backupNewWalletCheck() {
    backupCheckAllWords = Map();
    backupCheckSelectedWords = Map();
    var r = Random();
    var allWords = getMnemonic().split(" ").toList();
    assert(allWords.length == 12);
    var allIndices = List<int>.generate(12, (index) => index);
    allIndices.shuffle(r);
    var selectedIndices = allIndices.take(kBackupCheckLineCount).toList();
    selectedIndices.sort();
    for (int selectedIndex in selectedIndices) {
      String selectedWord = allWords[selectedIndex];
      var uniqueWords = allWords.toSet();
      uniqueWords.remove(selectedWord);
      var remainingWords = uniqueWords.toList();
      remainingWords.shuffle(r);
      var otherWords = remainingWords.take(kBackupCheckWordCount - 1).toList();
      otherWords.add(selectedWord);
      otherWords.shuffle(r);
      backupCheckAllWords[selectedIndex] = otherWords;
    }
    status = Status.backupNewCheck;
    notifyListeners();
  }

  void backupNewWalletSelect(int wordIndex, int selectedIndex) {
    backupCheckSelectedWords[wordIndex] = selectedIndex;
    notifyListeners();
  }

  bool _validSelectedWords() {
    if (kDebugMode) {
      if (listEquals(backupCheckSelectedWords.values.toSet().toList(), [1])) {
        return true;
      }
    }

    var allWords = _mnemonic.split(" ");
    for (int wordIndex in backupCheckAllWords.keys) {
      String correctWord = allWords[wordIndex];
      assert(correctWord != null);
      int selectedWordIndex = backupCheckSelectedWords[wordIndex];
      if (selectedWordIndex == null) {
        return false;
      }
      var wordList = backupCheckAllWords[wordIndex];
      String selectedWord = wordList[selectedWordIndex];
      if (selectedWord != correctWord) {
        return false;
      }
    }
    return true;
  }

  void backupNewWalletVerify() {
    if (_validSelectedWords()) {
      status = Status.registered;
    } else {
      status = Status.backupNewCheckFailed;
    }
    notifyListeners();
  }

  bool goBack() {
    switch (status) {
      case Status.backupNewCheck:
        status = Status.backupNewView;
        break;
      case Status.backupNewCheckFailed:
        status = Status.backupNewCheck;
        break;
      case Status.importing:
        status = Status.noWalet;
        break;
      case Status.assetsSelect:
        status = Status.registered;
        break;
      case Status.assetDetails:
        status = Status.registered;
        break;
      case Status.txDetails:
        status = Status.assetDetails;
        break;
      case Status.txEditMemo:
        _applyTxMemoChange();
        status = Status.txDetails;
        break;
      case Status.assetReceive:
        status = Status.assetDetails;
        break;
      case Status.assetSendEnter:
        status = Status.assetDetails;
        break;
      case Status.assetSendConfirm:
        status = Status.assetSendEnter;
        break;
      case Status.assetSendSucceed:
        status = Status.assetDetails;
        break;
      case Status.swapReview:
        _cancelSwap();
        status = Status.registered;
        break;
      case Status.swapSucceed:
        status = Status.registered;
        break;
      case Status.swapWaitPegTx:
        _pegStop();
        break;
      case Status.settingsBackup:
      case Status.settingsAboutUs:
      case Status.settingsDeletePrompt:
        status = Status.registered;
        break;
      case Status.backupNewView:
        status = Status.backupNewPrompt;
        break;

      case Status.loading:
      case Status.reviewLicense:
      case Status.noWalet:
      case Status.backupNewPrompt:
      case Status.backup:
      case Status.registered:
      case Status.assetSendCreateTx:
      case Status.assetSendProcessing:
      case Status.swapWaitServer:
        return true;
    }

    notifyListeners();
    return false;
  }

  void _login(String mnemonic) {
    var msg = To();
    msg.login = To_Login();
    msg.login.mnemonic = mnemonic;
    _sendMsg(msg);
  }

  void _logout() {
    txs = List();
    balances = Map();
    swapSendAsset = null;
    swapRecvAsset = null;

    var msg = To();
    msg.logout = Empty();
    _sendMsg(msg);
  }

  List<String> swapSendAssets() {
    return assets.keys.toList();
  }

  List<String> swapRecvAssets() {
    if (swapSendAsset == kBitcoinTicker) {
      return [kLiquidBitcoinTicker];
    }
    return assets.keys
        .where((element) =>
            element != swapSendAsset &&
            (swapSendAsset == kLiquidBitcoinTicker ||
                element != kBitcoinTicker))
        .toList();
  }

  void setSelectedLeftAsset(String ticker) {
    _resetState();
    swapSendAsset = ticker;
    _checkSelectedAsset();
    notifyListeners();
  }

  void setSelectedRightAsset(String ticker) {
    _resetState();
    swapRecvAsset = ticker;
    _checkSelectedAsset();
    notifyListeners();
  }

  void _resetState() {
    swapAmountController.text = "";
    swapAddressRecvController.text = "";
    swapRecvAmount = null;
    swapNetworkFee = null;
    swapServerFee = null;
    swapCreatedAt = null;
    swapExpiresAt = null;
    swapNetworkError = null;
  }

  void requestSwap(BuildContext context) {
    swapSendAmount = null;
    if (swapSendWallet == SwapWallet.local) {
      swapSendAmount = parseBitcoinAmount(swapAmountController.text);
      var balance = balances[swapSendAsset];
      if (swapSendAmount == null ||
          swapSendAmount <= 0 ||
          swapSendAmount > balance) {
        showMessage(context, "Error", "Please enter correct amount");
        return;
      }
    }

    swapRecvAddressExternal = null;
    if (swapRecvWallet != SwapWallet.local) {
      swapRecvAddressExternal = swapAddressRecvController.text;
      var addrType = swapAddrType(swapType());
      if (!isAddrValid(swapRecvAddressExternal, addrType)) {
        showMessage(context, 'Error',
            'Please enter correct ${addrTypeStr(addrType)} address');
        return;
      }
    }

    var msg = To();
    msg.swapRequest = To_SwapRequest();
    msg.swapRequest.sendTicker = swapSendAsset;
    msg.swapRequest.recvTicker = swapRecvAsset;

    if (swapSendAmount != null) {
      msg.swapRequest.sendAmount = Int64(swapSendAmount);
    }
    if (swapRecvAddressExternal != null) {
      msg.swapRequest.recvAddr = swapRecvAddressExternal;
    }

    _sendMsg(msg);
    status = Status.swapWaitServer;
    _resetState();
    notifyListeners();
  }

  void _cancelSwap() {
    var msg = To();
    msg.swapCancel = Empty();
    _sendMsg(msg);

    status = Status.registered;
    notifyListeners();
  }

  void acceptSwap() {
    var msg = To();
    msg.swapAccept = Empty();
    _sendMsg(msg);

    status = Status.registered;
    notifyListeners();
  }

  void selectAssetDetails(String value) {
    status = Status.assetDetails;
    selectedWalletAsset = value;
    notifyListeners();
  }

  void selectAssetReceive() {
    recvAddress = null;

    var msg = To();
    msg.getRecvAddress = Empty();
    _sendMsg(msg);

    status = Status.assetReceive;
    notifyListeners();
  }

  void selectAssetSend() {
    sendAmountController.text = "";
    sendAddressController.text = "";
    sendResultError = null;
    status = Status.assetSendEnter;
    notifyListeners();
  }

  void showTxDetails(Transaction tx) {
    status = Status.txDetails;
    txDetails = tx;
    notifyListeners();
  }

  static int convertAddrType(AddrType type) {
    switch (type) {
      case AddrType.bitcoin:
        return SIDESWAP_BITCOIN;
      case AddrType.elements:
        return SIDESWAP_ELEMENTS;
    }
    throw Exception('unexpected value');
  }

  bool isAddrValid(String addr, AddrType addrType) {
    if (addr.isEmpty || _client == 0) return false;
    var addrPtr = Utf8.toUtf8(addr);
    return Lib.lib.sideswap_check_addr(
        _client, addrPtr.cast(), convertAddrType(addrType));
  }

  String commonAddrErrorStr(String addr, AddrType addrType) {
    if (addr == null || addr == "") return null;
    return isAddrValid(addr, addrType) ? null : "Invalid address";
  }

  String elementsAddrErrorStr(String addr) {
    return commonAddrErrorStr(addr, AddrType.elements);
  }

  String bitcoinAddrErrorStr(String addr) {
    return commonAddrErrorStr(addr, AddrType.bitcoin);
  }

  String amountErrorStr(String value, int min, int max) {
    if (value == null || value == "") return null;
    var amount = parseBitcoinAmount(value);
    if (amount == null) return "Invalid amount";
    if (amount < min) return "Amount is too low";
    if (amount > max) return "Amount is too big";
    return null;
  }

  void assetSendEnterContinue(BuildContext context) {
    sendMemoController.text = '';
    var addr = sendAddressController.text;
    if (!isAddrValid(addr, AddrType.elements)) {
      showMessage(context, "Error", "Please enter correct Liquid address");
      return;
    }
    int amount = parseBitcoinAmount(sendAmountController.text);
    var balance = balances[selectedWalletAsset];
    if (amount == null || amount <= 0 || amount > balance) {
      showMessage(context, "Error", "Please enter correct amount");
      return;
    }

    sendResultError = null;
    sendAddrParsed = addr;
    sendAmountParsed = amount;
    status = Status.assetSendCreateTx;
    notifyListeners();

    var msg = To();
    msg.createTx = To_CreateTx();
    msg.createTx.addr = sendAddrParsed;
    msg.createTx.balance = Balance();
    msg.createTx.balance.amount = Int64(sendAmountParsed);
    msg.createTx.balance.ticker = selectedWalletAsset;
    _sendMsg(msg);
  }

  void assetSendConfirm() {
    var msg = To();
    msg.sendTx = To_SendTx();
    msg.sendTx.memo = sendMemoController.text;
    _sendMsg(msg);

    sendResultError = null;

    status = Status.assetSendProcessing;
    notifyListeners();
  }

  void _pegStop() {
    _resetState();
    status = Status.registered;
    notifyListeners();
  }

  void changeMainPage(int page) {
    mainPage = page;
    notifyListeners();
  }

  void selectAvailableAssets() {
    setToggleAssetFilter("");
    status = Status.assetsSelect;
    notifyListeners();
  }

  bool _showAsset(Asset asset, String filterLowerCase) {
    if (asset.ticker == kBitcoinTicker) {
      return false;
    }
    if (filterLowerCase.isEmpty) {
      return true;
    }
    String assetText =
        "${asset.ticker}\n${asset.name}\n${asset.assetId}".toLowerCase();
    return assetText.contains(filterLowerCase);
  }

  void setToggleAssetFilter(String filter) {
    var filterLowerCase = filter.toLowerCase();
    var filteredToggleTickersNew = List<String>();
    for (String ticker in assetTickers) {
      if (_showAsset(assets[ticker], filterLowerCase)) {
        filteredToggleTickersNew.add(ticker);
      }
    }
    if (!listEquals(filteredToggleTickersNew, filteredToggleTickers)) {
      filteredToggleTickers = filteredToggleTickersNew;
      notifyListeners();
    }
  }

  void toggleAssetVisibility(String ticker) {
    if (disabledAssetTickers.contains(ticker)) {
      disabledAssetTickers.remove(ticker);
    } else {
      disabledAssetTickers.add(ticker);
    }
    updateEnabledAssetIds();
    notifyListeners();
    _saveState();
  }

  void editTxMemo() {
    status = Status.txEditMemo;
    currentTxMemoUpdate = null;
    notifyListeners();
  }

  String txMemo(Transaction tx) {
    String updatedMemo = txMemoUpdates[tx.txid];
    if (updatedMemo != null) {
      return updatedMemo;
    }
    return tx.memo;
  }

  void onTxMemoChanged(String value) {
    currentTxMemoUpdate = value;
  }

  void _applyTxMemoChange() {
    if (currentTxMemoUpdate != null) {
      txMemoUpdates[txDetails.txid] = currentTxMemoUpdate;

      var msg = To();
      msg.setMemo = To_SetMemo();
      msg.setMemo.txid = txDetails.txid;
      msg.setMemo.memo = currentTxMemoUpdate;
      _sendMsg(msg);

      currentTxMemoUpdate = null;
    }
  }

  String swapPriceStr() {
    Asset sendAsset = assets[swapSendAsset];
    Asset recvAsset = assets[swapRecvAsset];

    Asset nonBtcAsset;
    int btcAmount = null;
    int nonBtcAmount = null;
    if (sendAsset.ticker == kLiquidBitcoinTicker) {
      nonBtcAsset = recvAsset;
      nonBtcAmount = swapRecvAmount;
      btcAmount = swapSendAmount;
    } else {
      nonBtcAsset = sendAsset;
      nonBtcAmount = swapSendAmount;
      btcAmount = swapRecvAmount;
    }
    String priceStr = '-';
    if (btcAmount != null && nonBtcAmount != null && btcAmount != 0) {
      double price = nonBtcAmount.toDouble() / btcAmount.toDouble();
      priceStr = price.toStringAsFixed(nonBtcAsset.precision.toInt());
    }
    return "1 ${kLiquidBitcoinTicker} = $priceStr ${nonBtcAsset.ticker}";
  }

  String swapConversionRateStr() {
    double rate = 100 * swapRecvAmount / swapSendAmount;
    var rateStr = rate.toStringAsFixed(1);
    return "${rateStr}%";
  }

  SwapType swapType() {
    if (swapSendAsset == kBitcoinTicker &&
        swapRecvAsset == kLiquidBitcoinTicker) {
      return SwapType.pegIn;
    }
    if (swapSendAsset == kLiquidBitcoinTicker &&
        swapRecvAsset == kBitcoinTicker) {
      return SwapType.pegOut;
    }
    return SwapType.atomic;
  }

  List<SwapWallet> allowedSendWallets() {
    switch (swapType()) {
      case SwapType.atomic:
        return [SwapWallet.local];
      case SwapType.pegIn:
        return [SwapWallet.extern];
      case SwapType.pegOut:
        return [SwapWallet.local, SwapWallet.extern];
    }
    throw Exception("unexpected state");
  }

  List<SwapWallet> allowedRecvWallets() {
    switch (swapType()) {
      case SwapType.atomic:
        return [SwapWallet.local];
      case SwapType.pegIn:
        return [SwapWallet.local, SwapWallet.extern];
      case SwapType.pegOut:
        return [SwapWallet.extern];
    }
    throw Exception("unexpected state");
  }

  ValueChanged<SwapWallet> setSendRadioCb(SwapWallet v) {
    var list = allowedSendWallets();
    if (!list.contains(v)) {
      return null;
    }
    return (SwapWallet v) {
      swapSendWallet = v;
      _checkSelectedAsset();
      notifyListeners();
    };
  }

  ValueChanged<SwapWallet> setRecvRadioCb(SwapWallet v) {
    var list = allowedRecvWallets();
    if (!list.contains(v)) {
      return null;
    }
    return (SwapWallet v) {
      swapRecvWallet = v;
      _checkSelectedAsset();
      notifyListeners();
    };
  }

  void settingsViewBackup() {
    status = Status.settingsBackup;
    notifyListeners();
  }

  void settingsViewAboutUs() {
    status = Status.settingsAboutUs;
    notifyListeners();
  }

  void settingsDeletePrompt() {
    status = Status.settingsDeletePrompt;
    notifyListeners();
  }

  void settingsDeletePromptConfirm() {
    _logout();
    _mnemonic = null;
    status = Status.noWalet;
    _saveState();
    notifyListeners();
  }
}
