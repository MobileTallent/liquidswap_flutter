import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:sideswap/common/helpers.dart';
import 'package:sideswap/common/theme.dart';
import 'package:sideswap/models/wallet.dart';

class AddressField extends StatefulWidget {
  final TextEditingController controller;
  final AddrType addrType;
  final bool enabled;

  AddressField({
    @required this.controller,
    @required this.addrType,
    this.enabled = true,
  }) : super(key: ValueKey(addrType));

  @override
  _AddressFieldState createState() => _AddressFieldState();
}

class _AddressFieldState extends State<AddressField> {
  String errorText = null;

  _AddressFieldState();

  void validate(Wallet wallet) {
    String newErrorText =
        wallet.commonAddrErrorStr(widget.controller.text, widget.addrType);
    if (newErrorText != errorText) {
      setState(() {
        errorText = newErrorText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var wallet = context.watch<Wallet>();
    return TextField(
      controller: widget.controller,
      onChanged: (addr) => setState(() {
        validate(wallet);
      }),
      decoration: InputDecoration(
        labelText: 'Address',
        border: OutlineInputBorder(),
        errorText: errorText,
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlineButton(
              onPressed: () async {
                await pasteFromClipboard(widget.controller);
                validate(wallet);
              },
              child: Text('Paste'),
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(
                        builder: (context) => AddressQrScanner(
                              resultCb: (value) {
                                widget.controller.text = value;
                                validate(wallet);
                              },
                            )));
              },
              icon: Icon(Icons.qr_code_outlined),
            ),
          ],
        ),
      ),
    );
  }
}

class AddressQrScanner extends StatefulWidget {
  final ValueChanged<String> resultCb;

  AddressQrScanner({this.resultCb});

  @override
  State<StatefulWidget> createState() =>
      _AddressQrScannerState(resultCb: resultCb);
}

class _AddressQrScannerState extends State<AddressQrScanner> {
  QRViewController qrController;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final ValueChanged<String> resultCb;

  _AddressQrScannerState({this.resultCb});
  bool done = false;

  void popup() {
    done = true;
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            QRView(
                key: qrKey,
                onQRViewCreated: _onQrViewCreated,
                overlay: QrScannerOverlayShape(
                  borderColor: Colors.white,
                  borderRadius: 10,
                  borderLength: 30,
                  borderWidth: 5,
                  cutOutSize: 250,
                )),
            Container(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => popup(),
                icon: Icon(Icons.close, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onQrViewCreated(QRViewController controller) {
    this.qrController = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!done) {
        done = true;
        resultCb(scanData);
        popup();
      }
    });
  }

  @override
  void dispose() {
    qrController.dispose();
    super.dispose();
  }
}

class AmountField extends StatefulWidget {
  final TextEditingController controller;
  final String asset;
  final bool enabled;

  AmountField({
    @required this.controller,
    @required this.asset,
    this.enabled = true,
  });

  @override
  _AmountFieldState createState() => _AmountFieldState();
}

class _AmountFieldState extends State<AmountField> {
  String errorText = null;

  void validate(Wallet wallet) {
    var balance = wallet.balances[widget.asset];
    String newSendAmountError = wallet.amountErrorStr(
      widget.controller.text,
      1,
      balance,
    );
    if (newSendAmountError != errorText) {
      setState(() {
        errorText = newSendAmountError;
      });
    }
  }

  void setMax(Wallet wallet) {
    int amount = wallet.balances[widget.asset];
    setMaxAmount(widget.controller, amount);
  }

  @override
  Widget build(BuildContext context) {
    var wallet = context.watch<Wallet>();
    return TextField(
      enabled: widget.enabled,
      controller: widget.controller,
      onChanged: (value) => validate(wallet),
      decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Amount',
          errorText: errorText,
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // OutlineButton.icon(
              //   icon: Icon(Icons.refresh),
              //   onPressed: () => {},
              //   label: Text('USD'),
              // ),
              OutlineButton(
                child: Text('MAX'),
                onPressed: () => setMax(wallet),
              ),
            ],
          )),
    );
  }
}

class MnemonicWord extends StatelessWidget {
  final int index;
  final ValueChanged<String> onChanged;
  final bool readOnly;
  final String initialValue;

  static MnemonicWord enabled({index, onChanged}) {
    return MnemonicWord(
      index: index,
      onChanged: onChanged,
      readOnly: false,
      initialValue: null,
    );
  }

  static MnemonicWord disabled({index, initialValue}) {
    return MnemonicWord(
      index: index,
      onChanged: null,
      readOnly: true,
      initialValue: initialValue,
    );
  }

  MnemonicWord(
      {this.index, this.onChanged, this.readOnly, this.initialValue}) {}

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
      child: Row(children: [
        SizedBox(
            width: 20,
            child: Align(
                child: Text('${index + 1}'), alignment: Alignment.center)),
        Expanded(
            child: TextFormField(
          initialValue: initialValue,
          readOnly: readOnly,
          decoration: InputDecoration(
              isDense: true,
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(5),
              )),
          onChanged: this.onChanged,
        ))
      ]),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  final String title;

  CustomAppBar({@required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Stack(
        children: [
          Container(color: colorPanels),
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => context.read<Wallet>().goBack(),
            ),
          ),
          Center(child: Text(title, style: fontSmallTitle)),
        ],
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({@required this.text, @required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 40,
      child: ElevatedButton(
        child: Text(text.toUpperCase()),
        onPressed: onPressed,
        //style: ElevatedButton.styleFrom(primary: Colors.),
      ),
    );
  }
}

class ShareTxidButtons extends StatelessWidget {
  final bool isLiquid;
  final String txid;

  const ShareTxidButtons({@required this.txid, @required this.isLiquid});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () => openTxidUrl(txid, isLiquid),
              child: Text('Link to external explorer'.toUpperCase()),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
          child: SizedBox(
            height: 50,
            child: CustomButton(
              onPressed: () => shareTxid(txid),
              text: 'Share'.toUpperCase(),
            ),
          ),
        ),
      ],
    );
  }
}

class ShareAddress extends StatelessWidget {
  const ShareAddress({
    @required this.addr,
  });

  final String addr;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        CustomButton(
          text: 'Copy',
          onPressed: () => copyToClipboard(context, addr),
        ),
        CustomButton(
          text: 'Share',
          onPressed: () => shareAddress(addr),
        ),
      ],
    );
  }
}

class CopyButton extends StatelessWidget {
  final String value;

  const CopyButton({@required this.value});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.copy,
        size: 32,
      ),
      onPressed: () => copyToClipboard(context, value),
    );
  }
}
