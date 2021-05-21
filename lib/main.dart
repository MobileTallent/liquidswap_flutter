import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sideswap/common/theme.dart';
import 'package:sideswap/models/wallet.dart';
import 'package:sideswap/screens/balances.dart';
import 'package:sideswap/screens/home.dart';
import 'package:sideswap/screens/license.dart';
import 'package:sideswap/screens/register.dart';
import 'package:sideswap/screens/settings.dart';
import 'package:sideswap/screens/swap.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Wallet()),
      ],
      child: _RootWidget(),
    );
  }
}

class MyPopupPage<T> extends Page<T> {
  const MyPopupPage({this.child});
  final Widget child;
  @override
  Route<T> createRoute(BuildContext context) {
    return _MyPopupPageRoute<T>(page: this);
  }
}

class _MyPopupPageRoute<T> extends PageRoute<T>
    with MaterialRouteTransitionMixin<T> {
  _MyPopupPageRoute({
    MyPopupPage<T> page,
  })  : assert(page != null),
        super(settings: page) {}

  MyPopupPage<T> get _page => settings as MyPopupPage<T>;

  @override
  Widget buildContent(BuildContext context) {
    return _page.child;
  }

  @override
  bool get opaque => false;

  @override
  bool get maintainState => true;

  @override
  bool get fullscreenDialog => false;
}

class _RootWidget extends StatelessWidget {
  List<Page<dynamic>> pages(Wallet wallet) {
    if (kDebugMode) {
      print('status: ${wallet.status}');
    }

    switch (wallet.status) {
      case Status.loading:
        return [
          MaterialPage(child: Container()),
        ];
      case Status.reviewLicense:
        return [
          MaterialPage(child: LicenseTerms()),
        ];
      case Status.noWalet:
        return [
          MaterialPage(child: WalletEmpty()),
        ];
      case Status.importing:
        return [
          MaterialPage(child: WalletEmpty()),
          MaterialPage(child: WalletImport()),
        ];
      case Status.backupNewPrompt:
        return [
          MaterialPage(child: WalletEmpty()),
          MaterialPage(child: WalletBackupNewPrompt()),
        ];
      case Status.backup:
        return [
          MaterialPage(child: WalletEmpty()),
          MaterialPage(child: WalletBackupNewPrompt()),
          MaterialPage(child: WalletBackup()),
        ];
      case Status.backupNewView:
        return [
          MaterialPage(child: WalletEmpty()),
          MaterialPage(child: WalletBackupNewPrompt()),
          MaterialPage(child: WalletBackupView()),
        ];
      case Status.backupNewCheck:
        return [
          MaterialPage(child: WalletEmpty()),
          MaterialPage(child: WalletBackupNewPrompt()),
          MaterialPage(child: WalletBackupView()),
          MaterialPage(child: WalletBackupCheck()),
        ];
      case Status.backupNewCheckFailed:
        return [
          MaterialPage(child: WalletEmpty()),
          MaterialPage(child: WalletBackupNewPrompt()),
          MaterialPage(child: WalletBackupView()),
          MaterialPage(child: WalletBackupCheck()),
          MaterialPage(child: WalletBackupCheckFailed()),
        ];

      case Status.registered:
      case Status.swapWaitServer:
        return [
          MaterialPage(child: WalletMain()),
        ];
      case Status.assetsSelect:
        return [
          MaterialPage(child: WalletMain()),
          MaterialPage(child: WalletSelectAssets()),
        ];
      case Status.assetDetails:
        return [
          MaterialPage(child: WalletMain()),
          MaterialPage(child: WalletAssetDetails()),
        ];
      case Status.txDetails:
        return [
          MaterialPage(child: WalletMain()),
          MaterialPage(child: WalletAssetDetails()),
          MaterialPage(child: WalletTxDetails()),
        ];
      case Status.txEditMemo:
        return [
          MaterialPage(child: WalletMain()),
          MaterialPage(child: WalletAssetDetails()),
          MaterialPage(child: WalletTxDetails()),
          MaterialPage(child: WalletTxMemo()),
        ];
      case Status.assetReceive:
        return [
          MaterialPage(child: WalletMain()),
          MaterialPage(child: WalletAssetDetails()),
          MyPopupPage(child: WalletAssetReceive()),
        ];
      case Status.assetSendEnter:
        return [
          MaterialPage(child: WalletMain()),
          MaterialPage(child: WalletAssetDetails()),
          MyPopupPage(child: WalletAssetSendEnter()),
        ];
      case Status.assetSendEnter:
        return [
          MaterialPage(child: WalletMain()),
          MaterialPage(child: WalletAssetDetails()),
          MyPopupPage(child: WalletAssetSendEnter()),
        ];
      case Status.assetSendConfirm:
        return [
          MaterialPage(child: WalletMain()),
          MaterialPage(child: WalletAssetDetails()),
          MyPopupPage(child: WalletAssetSendEnter()),
          MyPopupPage(child: WalletSendConfirm()),
        ];
      case Status.assetSendCreateTx:
        return [
          MaterialPage(child: WalletMain()),
          MaterialPage(child: WalletAssetDetails()),
          MyPopupPage(child: WalletAssetSendEnter()),
          MyPopupPage(child: WalletSendConfirm()),
        ];
      case Status.assetSendProcessing:
        return [
          MaterialPage(child: WalletMain()),
          MaterialPage(child: WalletAssetDetails()),
          MyPopupPage(child: WalletAssetSendEnter()),
          MyPopupPage(child: WalletSendConfirm()),
        ];
      case Status.assetSendSucceed:
        return [
          MaterialPage(child: WalletMain()),
          MaterialPage(child: WalletAssetDetails()),
          MyPopupPage(child: WalletSendSucceed()),
        ];
      case Status.swapReview:
        return [
          MaterialPage(child: WalletMain()),
          MaterialPage(child: SwapReview()),
        ];
      case Status.swapSucceed:
        return [
          MaterialPage(child: WalletMain()),
          MaterialPage(child: SwapReview()),
          MaterialPage(child: SwapSucceed()),
        ];
        break;
      case Status.swapWaitPegTx:
        return [
          MaterialPage(child: WalletMain()),
          MyPopupPage(child: SwapWaitPegTx()),
        ];
      case Status.settingsBackup:
        return [
          MaterialPage(child: WalletMain()),
          MyPopupPage(child: SettingsViewBackup()),
        ];
      case Status.settingsAboutUs:
        return [
          MaterialPage(child: WalletMain()),
          MyPopupPage(child: SettingsAboutUs()),
        ];
      case Status.settingsDeletePrompt:
        return [
          MaterialPage(child: WalletMain()),
          MyPopupPage(child: SettingsDeletePrompt()),
        ];
    }
    throw Exception("unexpecteded state");
  }

  @override
  Widget build(BuildContext context) {
    var wallet = context.watch<Wallet>();
    return MaterialApp(
      title: 'SideSwap',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: WillPopScope(
            onWillPop: () async {
              return wallet.goBack();
            },
            child: Navigator(
              pages: pages(wallet),
              onPopPage: (route, result) {
                print("on pop page");
                if (!route.didPop(result)) return false;
                return true;
              },
            ),
          ),
        ),
      ),
    );
  }
}
