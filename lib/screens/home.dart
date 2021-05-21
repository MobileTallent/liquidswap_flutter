import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sideswap/models/wallet.dart';
import 'package:sideswap/screens/balances.dart';
import 'package:sideswap/screens/settings.dart';
import 'package:sideswap/screens/swap.dart';

class WalletMain extends StatelessWidget {
  Widget getChild(Wallet wallet) {
    switch (wallet.mainPage) {
      case 0:
        return WalletAssetOverview();
      case 1:
        return SwapIdle();
      case 2:
        return SettingsPage();
    }
    throw Exception('unexpected mainPage');
  }

  @override
  Widget build(BuildContext context) {
    var wallet = context.watch<Wallet>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        child: getChild(wallet),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF003E78), Color(0xFF000E3F)])),
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: wallet.mainPage,
          fixedColor: Colors.white,
          backgroundColor: Color(0xFF031231),
          items: [
            BottomNavigationBarItem(
              label: "Home",
              icon: Icon(Icons.home),
            ),
            BottomNavigationBarItem(
              label: "Swap",
              icon: Icon(Icons.swap_vert),
            ),
            BottomNavigationBarItem(
              label: "Settings",
              icon: Icon(Icons.settings),
            ),
          ],
          onTap: (int index) {
            wallet.changeMainPage(index);
          }),
    );
  }
}
