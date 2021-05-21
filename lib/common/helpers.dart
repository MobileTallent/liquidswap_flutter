import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

const int kCoin = 100000000;
const int kDefaultPrecision = 8;

const String kBitcoinTicker = 'BTC';
const String kLiquidBitcoinTicker = 'L-BTC';

String amountStr(int amount, {bool forceSign = false}) {
  if (amount == null) {
    return '-';
  }
  String sign = '';
  if (amount < 0) {
    sign = "-";
    amount = -amount;
  } else if (forceSign && amount > 0) {
    sign = "+";
  }
  int bitAmount = amount ~/ kCoin;
  int satAmount = amount % kCoin;
  String satAmountStr = satAmount.toString().padLeft(8, '0');
  return "${sign}${bitAmount}.${satAmountStr}";
}

var shortFormat = DateFormat("MMM d, yyyy");
var longFormat = DateFormat("MMM d, yyyy 'at' HH:MM");

// Returns timestamp in UTC
DateTime parseTimestamp(String timestamp) {
  return DateTime.parse(timestamp + "Z");
}

String txDateStrShort(DateTime timestamp) {
  return shortFormat.format(timestamp.toLocal());
}

String txDateStrLong(DateTime timestamp) {
  return longFormat.format(timestamp.toLocal());
}

showMessage(BuildContext context, String title, String message) {
  AlertDialog alert =
      AlertDialog(title: Text(title), content: Text(message), actions: <Widget>[
    TextButton(
      child: Text('OK'),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    ),
  ]);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

class CustomTitle extends StatelessWidget {
  final String data;

  const CustomTitle(String this.data);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Text(
          data,
          style: TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

final snackBar = SnackBar(content: Text('Copied'));

void copyToClipboard(BuildContext context, String addr) {
  Clipboard.setData(new ClipboardData(text: addr));
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void setValue(TextEditingController controller, String value) {
  controller.text = value;
  controller.selection =
      TextSelection.fromPosition(TextPosition(offset: value.length));
}

void setMaxAmount(TextEditingController controller, int amount) {
  setValue(controller, amountStr(amount ?? 0));
}

void pasteFromClipboard(TextEditingController controller) async {
  var value = await Clipboard.getData(Clipboard.kTextPlain);
  if (value.text != null) {
    setValue(controller, value.text.replaceAll("\n", ""));
  }
}

void openTxidUrl(String txid, bool isLiquid) async {
  var url = isLiquid
      ? 'https://blockstream.info/liquid/tx/$txid'
      : 'https://blockstream.info/tx/$txid';
  if (await canLaunch(url)) {
    await launch(url);
  }
}

void shareTxid(String txid) async {
  Share.share(txid);
}

void shareAddress(String address) async {
  Share.share(address);
}
