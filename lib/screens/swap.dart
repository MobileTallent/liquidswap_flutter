import 'package:delayed_display/delayed_display.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sideswap/common/helpers.dart';
import 'package:sideswap/common/theme.dart';
import 'package:sideswap/common/widgets.dart';
import 'package:sideswap/models/wallet.dart';
import 'package:sideswap/protobuf/sideswap.pb.dart';

class SwapIdle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var wallet = context.watch<Wallet>();
    int balance = wallet.balances[wallet.swapSendAsset] ?? 0;
    var balanceStr = amountStr(balance);
    var swapType = wallet.swapType();
    bool enabled = wallet.status != Status.swapWaitServer;
    // TODO: Do not allow change asset while waiting for RFQ, this will break things
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(15.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      child: Text('Deliver', style: fontSmallTitle),
                      alignment: Alignment.centerLeft,
                    ),
                    SizedBox(height: 10),
                    _AssetDropdown(
                      onAssetChanged: (String value) =>
                          {wallet.setSelectedLeftAsset(value)},
                      availableAssets: wallet.swapSendAssets(),
                      selectedAsset: wallet.swapSendAsset,
                    ),
                    Visibility(
                      visible: swapType != SwapType.atomic,
                      child: Row(
                        children: [
                          Expanded(
                            child: RadioListTile<SwapWallet>(
                              title: const Text('Local wallet'),
                              value: SwapWallet.local,
                              groupValue: wallet.swapSendWallet,
                              onChanged:
                                  wallet.setSendRadioCb(SwapWallet.local),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<SwapWallet>(
                              title: const Text('External wallet'),
                              value: SwapWallet.extern,
                              groupValue: wallet.swapSendWallet,
                              onChanged:
                                  wallet.setSendRadioCb(SwapWallet.extern),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: swapType == SwapType.atomic ||
                          swapType == SwapType.pegOut &&
                              wallet.swapSendWallet == SwapWallet.local,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: AmountField(
                          enabled: enabled,
                          asset: wallet.swapSendAsset,
                          controller: wallet.swapAmountController,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: wallet.swapSendWallet == SwapWallet.local,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text("Available amount: $balanceStr"),
                        alignment: Alignment.centerRight,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      child: Text('Receive', style: fontSmallTitle),
                      alignment: Alignment.centerLeft,
                    ),
                    SizedBox(height: 10),
                    _AssetDropdown(
                      onAssetChanged: (String value) =>
                          {wallet.setSelectedRightAsset(value)},
                      availableAssets: wallet.swapRecvAssets(),
                      selectedAsset: wallet.swapRecvAsset,
                    ),
                    Visibility(
                      visible: swapType != SwapType.atomic,
                      child: Row(
                        children: [
                          Expanded(
                            child: RadioListTile<SwapWallet>(
                              title: const Text('Local wallet'),
                              value: SwapWallet.local,
                              groupValue: wallet.swapRecvWallet,
                              onChanged:
                                  wallet.setRecvRadioCb(SwapWallet.local),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<SwapWallet>(
                              title: const Text('External wallet'),
                              value: SwapWallet.extern,
                              groupValue: wallet.swapRecvWallet,
                              onChanged:
                                  wallet.setRecvRadioCb(SwapWallet.extern),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: wallet.swapRecvWallet == SwapWallet.extern,
                      child: AddressField(
                        controller: wallet.swapAddressRecvController,
                        addrType: swapAddrType(swapType),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(wallet.swapNetworkError ?? ""),
                  SizedBox(height: 10),
                  CustomButton(
                    text: 'Swap request',
                    onPressed:
                        enabled ? () => wallet.requestSwap(context) : null,
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment(0.0, 0.6),
          child: Visibility(
            visible: wallet.status == Status.swapWaitServer,
            child: DelayedDisplay(
              delay: Duration(seconds: 0),
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ],
    );
  }
}

class _AssetDropdown extends StatelessWidget {
  final String selectedAsset;
  final List<String> availableAssets;
  final ValueChanged<String> onAssetChanged;

  _AssetDropdown(
      {this.selectedAsset, this.availableAssets, this.onAssetChanged});

  @override
  Widget build(BuildContext context) {
    var wallet = context.watch<Wallet>();
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1F3B69),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        value: selectedAsset,
        icon: Icon(Icons.arrow_drop_down_sharp),
        iconSize: 24,
        itemHeight: 60,
        underline: Container(),
        onChanged: onAssetChanged,
        items: availableAssets.map<DropdownMenuItem<String>>((String ticker) {
          var asset = wallet.assets[ticker];
          var assetImage = wallet.assetImagesSmall[ticker];
          return DropdownMenuItem<String>(
            value: ticker,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: assetImage,
                ),
                Text(asset.ticker),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class SwapReview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var wallet = context.watch<Wallet>();
    String sendAmount = amountStr(wallet.swapSendAmount);
    String recvAmount = amountStr(wallet.swapRecvAmount);
    String serverFee = amountStr(wallet.swapServerFee);
    String networkFee = amountStr(wallet.swapNetworkFee);
    Asset sendAsset = wallet.assets[wallet.swapSendAsset];
    Asset recvAsset = wallet.assets[wallet.swapRecvAsset];
    String swapPriceStr = wallet.swapPriceStr();

    return Container(
      decoration: mainDecoration,
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () => wallet.goBack(),
              icon: Icon(Icons.close),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Deliver', style: fontSmallTitle),
                  Text("$sendAmount ${sendAsset.ticker}", style: fontBigTitle),
                  Spacer(flex: 1),
                  Row(
                    children: [
                      SvgPicture.asset('images/swap.svg', width: 50),
                      SizedBox(width: 10),
                      Text(swapPriceStr, style: fontNormalGray),
                    ],
                  ),
                  Spacer(flex: 1),
                  Text('Receive', style: fontSmallTitle),
                  Text("$recvAmount ${recvAsset.ticker}", style: fontBigTitle),
                  Spacer(flex: 2),
                  Spacer(flex: 5),
                  Text('Commission:'),
                  SizedBox(height: 10),
                  _FeeBlock(
                    name: 'Swap Fee',
                    value: '$serverFee $kLiquidBitcoinTicker',
                  ),
                  _FeeBlock(
                    name: 'Transacton Fee',
                    value: '$networkFee $kLiquidBitcoinTicker',
                  ),
                  Spacer(),
                  Center(
                    child: CustomButton(
                        text: 'Swap', onPressed: () => wallet.acceptSwap()),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeeBlock extends StatelessWidget {
  final String name;
  final String value;

  const _FeeBlock({@required this.name, @required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Color(0xFF1F3B69),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: fontNormalGray),
            Text(value, style: fontNormal),
          ],
        ),
      ),
    );
  }
}

class SwapSucceed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var wallet = context.watch<Wallet>();
    String sendAmount = amountStr(wallet.swapSendAmount);
    String recvAmount = amountStr(wallet.swapRecvAmount);
    Asset sendAsset = wallet.assets[wallet.swapSendAsset];
    Asset recvAsset = wallet.assets[wallet.swapRecvAsset];
    String swapPriceStr = wallet.swapPriceStr();
    String convRateStr = wallet.swapConversionRateStr();
    var swapType = wallet.swapType();

    return Container(
      decoration: mainDecoration,
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12),
                  Text(swapTypeStr(swapType), style: TextStyle(fontSize: 24)),
                  SizedBox(height: 16),
                  Text(txDateStrLong(wallet.swapSucceedTimestamp)),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Delivered'),
                      Spacer(),
                      Text("$sendAmount ${sendAsset.ticker}",
                          style: TextStyle(fontSize: 20)),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Received'),
                      Spacer(),
                      Text("$recvAmount ${recvAsset.ticker}",
                          style: TextStyle(fontSize: 20)),
                    ],
                  ),
                  SizedBox(height: 16),
                  Visibility(
                    visible: swapType == SwapType.atomic,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text('Price'),
                          Spacer(),
                          Text(swapPriceStr, style: TextStyle(fontSize: 20)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Visibility(
                    visible: swapType != SwapType.atomic,
                    child: Row(
                      children: [
                        Text('Conversion rate'),
                        Spacer(),
                        Text(convRateStr, style: TextStyle(fontSize: 20)),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Visibility(
                    visible: wallet.swapRecvAddressExternal != null &&
                        wallet.swapRecvAddressExternal != "",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Receiving address'),
                        Row(
                          children: [
                            Expanded(
                                child:
                                    Text(wallet.swapRecvAddressExternal ?? "")),
                            IconButton(
                              icon: Icon(
                                Icons.copy,
                                size: 32,
                              ),
                              onPressed: () => copyToClipboard(
                                  context, wallet.swapSucceedTxid),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text('Transaction ID'),
                  Row(
                    children: [
                      Expanded(child: Text(wallet.swapSucceedTxid)),
                      IconButton(
                        icon: Icon(
                          Icons.copy,
                          size: 32,
                        ),
                        onPressed: () =>
                            copyToClipboard(context, wallet.swapSucceedTxid),
                      ),
                    ],
                  ),
                  Spacer(),
                  ShareTxidButtons(
                    txid: wallet.swapSucceedTxid,
                    isLiquid: swapType != SwapType.pegIn,
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

class SwapWaitPegTx extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var wallet = context.watch<Wallet>();
    var addr = wallet.swapPegAddressServer ?? "";
    var swapType = wallet.swapType();
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
            Text(swapTypeStr(swapType), style: fontSmallTitle),
            SizedBox(height: 30),
            Container(
              color: Colors.white,
              child: QrImage(
                data: addr,
                version: QrVersions.auto,
                size: 300.0,
              ),
            ),
            Spacer(),
            Text("${wallet.swapSendAsset}: Receiving address",
                style: TextStyle(fontSize: 24)),
            Text(addr),
            Visibility(
              visible: wallet.swapRecvWallet == SwapWallet.extern,
              child: Column(
                children: [
                  Text("Your ${wallet.swapRecvAsset} address",
                      style: TextStyle(fontSize: 24)),
                  Text(wallet.swapRecvAddressExternal ?? "<EMPTY>"),
                ],
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
