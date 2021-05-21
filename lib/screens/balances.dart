import 'package:delayed_display/delayed_display.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sideswap/common/helpers.dart';
import 'package:sideswap/common/theme.dart';
import 'package:sideswap/common/widgets.dart';
import 'package:sideswap/models/wallet.dart';
import 'package:sideswap/protobuf/sideswap.pb.dart';

enum TxType { received, sent, swap, unknown }

TxType txType(Transaction tx) {
  bool anyPositive = false;
  bool anyNegative = false;
  for (var balance in tx.balances) {
    if (balance.amount > 0) {
      anyPositive = true;
    }
    if (balance.amount < 0) {
      anyNegative = true;
    }
  }
  if (tx.balances.length == 2 && anyPositive && anyPositive) {
    return TxType.swap;
  }

  if (anyPositive && !anyNegative) {
    return TxType.received;
  }
  if (anyNegative && !anyPositive) {
    return TxType.sent;
  }

  return TxType.unknown;
}

IconData txIcon(TxType type) {
  switch (type) {
    case TxType.received:
      return Icons.arrow_circle_down;
    case TxType.sent:
      return Icons.arrow_circle_up;
    case TxType.swap:
      return Icons.swap_horiz;
    case TxType.unknown:
      return Icons.device_unknown;
  }
  throw Exception('unknown type');
}

String txTypeName(TxType type) {
  switch (type) {
    case TxType.received:
      return 'Received';
    case TxType.sent:
      return 'Sent';
    case TxType.swap:
      return 'Swap';
    case TxType.unknown:
      return 'Unknown';
  }
  throw Exception('unknown type');
}

int txAssetAmount(Transaction tx, Asset asset) {
  int sum = 0;
  for (var balance in tx.balances) {
    if (balance.ticker == asset.ticker) {
      sum += balance.amount.toInt();
    }
  }
  return sum;
}

class WalletAssetOverview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var wallet = context.watch<Wallet>();
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        children: [
          Spacer(),
          Visibility(
            visible: false,
            child: Container(
              alignment: Alignment.centerRight,
              child: RawMaterialButton(
                onPressed: () {},
                elevation: 3.0,
                fillColor: Colors.black,
                child: Icon(
                  Icons.qr_code_scanner,
                  size: 35.0,
                  color: Colors.white,
                ),
                padding: EdgeInsets.all(12.0),
                shape: CircleBorder(),
              ),
            ),
          ),
          Spacer(),
          Row(children: [
            Text('Assets', style: fontSmallTitle),
            Spacer(),
            SizedBox(
              width: 60,
              height: 60,
              child: IconButton(
                icon: Icon(
                  Icons.list,
                  size: 48,
                ),
                onPressed: () => wallet.selectAvailableAssets(),
              ),
            )
          ]),
          Expanded(
            flex: 10,
            child: ListView(
              children: List<Widget>.generate(wallet.enabledAssetTickers.length,
                  (index) {
                var ticker = wallet.enabledAssetTickers[index];
                var asset = wallet.assets[ticker];
                var balance = wallet.balances[ticker];
                return _WalletBalanceItem(
                  asset: asset,
                  balance: balance,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletBalanceItem extends StatelessWidget {
  final Asset asset;
  final int balance;
  _WalletBalanceItem({this.asset, this.balance});

  @override
  Widget build(BuildContext context) {
    var wallet = context.watch<Wallet>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
            color: Color(0xFF1F3B69),
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            wallet.selectAssetDetails(asset.ticker);
          },
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              children: [
                wallet.assetImagesBig[asset.ticker],
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(asset.name, style: fontNormal),
                    SizedBox(height: 8),
                    Text(asset.ticker, style: fontNormalGray),
                  ],
                ),
                Spacer(),
                Text(amountStr(balance ?? 0), style: fontNormal),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WalletAssetDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var wallet = context.watch<Wallet>();
    var asset = wallet.assets[wallet.selectedWalletAsset];
    var balance = wallet.balances[wallet.selectedWalletAsset];
    var balanceStr = '${amountStr(balance ?? 0)} ${asset.ticker}';
    var assetTxs = wallet.assetTxs[asset.ticker] ?? List();
    return Container(
      decoration: mainDecoration,
      child: Column(
        children: [
          CustomAppBar(title: 'Asset details'),
          wallet.assetImagesBig[asset.ticker],
          SizedBox(height: 8),
          Text(asset.name, style: TextStyle(fontSize: 18)),
          SizedBox(height: 8),
          Text(balanceStr, style: TextStyle(fontSize: 24)),
          SizedBox(height: 8),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(12.0),
              child: Column(children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Transactions', style: fontSmallTitle),
                ),
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      return SizedBox(
                        child: _TxListItem(
                          asset: asset,
                          tx: assetTxs[index],
                        ),
                      );
                    },
                    itemCount: assetTxs.length,
                  ),
                ),
              ]),
            ),
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CustomButton(
                    onPressed: () => wallet.selectAssetSend(),
                    text: 'Send',
                  ),
                  CustomButton(
                    onPressed: () => wallet.selectAssetReceive(),
                    text: 'Receive',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TxListItem extends StatelessWidget {
  final Asset asset;
  final Transaction tx;
  const _TxListItem({this.asset, this.tx});

  @override
  Widget build(BuildContext context) {
    var timestamp = parseTimestamp(tx.createdAt);
    var timestampStr = txDateStrShort(timestamp);
    var type = txType(tx);
    var amount = txAssetAmount(tx, asset);
    var balanceStr = '${amountStr(amount, forceSign: true)} ${asset.ticker}';
    return SizedBox(
      height: 80,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            var wallet = context.read<Wallet>();
            wallet.showTxDetails(tx);
          },
          child: Container(
            decoration: BoxDecoration(
                color: Color(0xFF1F3B69),
                borderRadius: BorderRadius.all(Radius.circular(5))),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Row(
                children: [
                  Icon(txIcon(type), size: 50),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(timestampStr, style: fontNormal),
                      Text(txTypeName(type), style: fontNormalGray),
                    ],
                  ),
                  Spacer(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(balanceStr, style: fontNormal),
                      Text(''),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WalletAssetReceive extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var wallet = context.watch<Wallet>();
    var addr = wallet.recvAddress ?? "";
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
      child: Container(
        color: Colors.black,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => wallet.goBack(),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            Text("Receive", style: fontSmallTitle),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(addr),
            ),
            Spacer(),
            Container(
              color: Colors.white,
              child: QrImage(
                data: addr,
                version: QrVersions.auto,
                size: 300.0,
              ),
            ),
            Spacer(),
            ShareAddress(addr: addr),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class WalletAssetSendEnter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var wallet = context.watch<Wallet>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
      child: Container(
        color: Colors.black,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => wallet.goBack(),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AddressField(
                controller: wallet.sendAddressController,
                addrType: AddrType.elements,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AmountField(
                controller: wallet.sendAmountController,
                asset: wallet.selectedWalletAsset,
              ),
            ),
            Visibility(
              visible: wallet.sendResultError != null,
              child: Text(wallet.sendResultError ?? ""),
            ),
            Spacer(),
            CustomButton(
              text: 'Continue',
              onPressed: () => wallet.assetSendEnterContinue(context),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class WalletSendConfirm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var wallet = context.watch<Wallet>();
    var sendAmountStr = amountStr(wallet.sendAmountParsed);
    var asset = wallet.assets[wallet.selectedWalletAsset];
    var sendStr = '$sendAmountStr ${asset.ticker}';
    var networkFee =
        '${amountStr(wallet.sendNetworkFee)} $kLiquidBitcoinTicker';
    return Container(
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => wallet.goBack(),
                icon: Icon(Icons.close),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Send', style: fontSmallTitle),
                  Text(sendStr, style: fontSmallTitle),
                  SizedBox(height: 20),
                  Text('To'),
                  Text(wallet.sendAddrParsed),
                  SizedBox(height: 20),
                  Text('Network Fee'),
                  Text(networkFee),
                  SizedBox(height: 20),
                  Text('My notes'),
                  SizedBox(height: 10),
                  TextField(
                    maxLines: 3,
                    onChanged: (value) => {},
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Only visible to you'),
                    controller: wallet.sendMemoController,
                  ),
                  Spacer(),
                  Visibility(
                    visible: wallet.status == Status.assetSendProcessing,
                    child: DelayedDisplay(
                      delay: Duration(seconds: 1),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  Center(
                    child: CustomButton(
                      text: 'Confirm',
                      onPressed: () => wallet.assetSendConfirm(),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WalletSendSucceed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var wallet = context.watch<Wallet>();
    var sendAmountStr = amountStr(wallet.sendAmountParsed);
    var asset = wallet.assets[wallet.selectedWalletAsset];
    var sendStr = '$sendAmountStr ${asset.ticker}';
    var networkFee =
        '${amountStr(wallet.sendNetworkFee)} $kLiquidBitcoinTicker';
    const offset = 100.0;
    const iconSize = 100.0;
    var txid = wallet.sendResultTxid;
    return Stack(
      children: [
        Container(
          decoration: mainDecoration,
          child: Column(
            children: [
              SizedBox(
                height: offset,
                child: Container(color: Colors.white),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => wallet.goBack(),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: 60),
              Text('Sent', style: fontSmallTitle),
              SizedBox(height: 20),
              Text(sendStr, style: fontSmallTitle),
              SizedBox(height: 40),
              Text('Network Fee'),
              SizedBox(height: 10),
              Text(networkFee),
              SizedBox(height: 40),
              Text('Receiver'),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(child: Text(wallet.sendAddrParsed)),
                    CopyButton(value: wallet.sendAddrParsed),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Text('Transaction ID'),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(child: Text(txid)),
                    CopyButton(value: txid),
                  ],
                ),
              ),
              Spacer(),
              ShareTxidButtons(txid: wallet.sendResultTxid, isLiquid: true),
              SizedBox(height: 10),
            ],
          ),
        ),
        Column(
          children: [
            SizedBox(height: offset - iconSize / 2),
            Center(
                child:
                    SvgPicture.asset('images/check_mark.svg', width: iconSize)),
          ],
        ),
      ],
    );
  }
}

class WalletSelectAssets extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var wallet = context.watch<Wallet>();
    return Container(
        decoration: mainDecoration,
        child: Column(
          children: [
            CustomAppBar(title: 'Asset list'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    TextField(
                      onChanged: (value) => wallet.setToggleAssetFilter(value),
                      decoration: InputDecoration(
                          isDense: true,
                          icon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                          hintText: 'Search'),
                    ),
                    SizedBox(height: 40),
                    Expanded(
                      child: ListView(
                        children: List<Widget>.generate(
                            wallet.filteredToggleTickers.length, (index) {
                          String ticker = wallet.filteredToggleTickers[index];
                          var asset = wallet.assets[ticker];
                          return _AssetSelectItem(asset: asset);
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}

class _AssetSelectItem extends StatelessWidget {
  final Asset asset;
  _AssetSelectItem({this.asset});

  @override
  Widget build(BuildContext context) {
    var wallet = context.watch<Wallet>();
    var selected = !wallet.disabledAssetTickers.contains(asset.ticker);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
            color: Color(0xFF1F3B69),
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: Row(
          children: [
            wallet.assetImagesBig[asset.ticker],
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(asset.name, style: fontNormal),
                SizedBox(height: 8),
                Text(asset.ticker, style: fontNormalGray),
              ],
            ),
            Spacer(),
            Switch(
              key: Key(asset.ticker),
              value: selected,
              onChanged: (bool value) =>
                  wallet.toggleAssetVisibility(asset.ticker),
            )
          ],
        ),
      ),
    );
  }
}

class WalletTxDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var wallet = context.watch<Wallet>();
    var tx = wallet.txDetails;
    var type = txType(tx);
    var timestamp = parseTimestamp(tx.createdAt);
    var timestampStr = txDateStrLong(timestamp);
    return Container(
        decoration: mainDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomAppBar(title: 'Transaction details'),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Text(txTypeName(type), style: TextStyle(fontSize: 24)),
                  Text(timestampStr),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Amount'),
                      Table(
                        columnWidths: {
                          0: IntrinsicColumnWidth(),
                          1: IntrinsicColumnWidth(),
                        },
                        children: List<TableRow>.generate(tx.balances.length,
                            (index) {
                          var balance = tx.balances[index];
                          var asset = wallet.assets[balance.ticker];
                          var ticker = asset != null ? asset.ticker : '???';
                          var balanceStr = amountStr(balance.amount.toInt(),
                              forceSign: true);
                          return TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(balanceStr,
                                    textAlign: TextAlign.right),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(ticker),
                              ),
                            ],
                          );
                        }),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Text('My notes'),
                      Spacer(),
                      Text(wallet.txMemo(tx)),
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          size: 32,
                        ),
                        onPressed: () => wallet.editTxMemo(),
                      ),
                    ],
                  ),
                  Divider(),
                  Text('Transaction ID', textAlign: TextAlign.left),
                  Row(
                    children: [
                      Expanded(child: Text(tx.txid)),
                      IconButton(
                        icon: Icon(
                          Icons.copy,
                          size: 32,
                        ),
                        onPressed: () => copyToClipboard(context, tx.txid),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Spacer(),
            ShareTxidButtons(txid: tx.txid, isLiquid: true),
            SizedBox(height: 20),
          ],
        ));
  }
}

class WalletTxMemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var wallet = context.watch<Wallet>();
    return Container(
      decoration: mainDecoration,
      child: Column(children: [
        CustomAppBar(title: 'Add a note'),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextFormField(
                initialValue: wallet.txMemo(wallet.txDetails),
                keyboardType: TextInputType.multiline,
                maxLines: 10,
                onChanged: (value) => wallet.onTxMemoChanged(value),
                decoration: InputDecoration(
                    isDense: true,
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(5),
                    )),
              ),
            )
          ],
        ),
      ]),
    );
  }
}
