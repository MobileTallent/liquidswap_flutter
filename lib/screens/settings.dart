import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sideswap/common/theme.dart';
import 'package:sideswap/models/wallet.dart';
import 'package:sideswap/common/widgets.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var wallet = context.watch<Wallet>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Spacer(),
        Text('Settings', style: TextStyle(fontSize: 24)),
        Spacer(),
        Divider(),
        FlatButton.icon(
          icon: Icon(
            Icons.circle,
            size: 35.0,
          ),
          label: Expanded(child: Text('View my recovery phase')),
          onPressed: () => wallet.settingsViewBackup(),
        ),
        Divider(),
        FlatButton.icon(
          onPressed: () {},
          icon: Icon(
            Icons.circle,
            size: 35.0,
          ),
          label: Expanded(child: Text('Security settings')),
        ),
        Divider(),
        FlatButton.icon(
          icon: Icon(
            Icons.circle,
            size: 35.0,
          ),
          label: Expanded(child: Text('About us')),
          onPressed: () => wallet.settingsViewAboutUs(),
        ),
        Divider(),
        Spacer(flex: 10),
        Divider(),
        FlatButton.icon(
          icon: Icon(
            Icons.circle,
            size: 35.0,
          ),
          label: Expanded(child: Text('Delete wallet')),
          onPressed: () => wallet.settingsDeletePrompt(),
        ),
        Divider(),
        Spacer(),
      ],
    );
  }
}

class SettingsViewBackup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var wallet = context.watch<Wallet>();
    var words = wallet.getMnemonicWords();
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
            Text('Your recovery 12 words', style: fontSmallTitle),
            SizedBox(height: 30),
            Table(
                children: List<TableRow>.generate(
                    4,
                    (rowIndex) => TableRow(
                            children: List<Widget>.generate(3, (colIndex) {
                          int index = rowIndex * 3 + colIndex;
                          return MnemonicWord.disabled(
                            index: index,
                            initialValue: words[index],
                          );
                        })))),
          ],
        ),
      ),
    );
  }
}

class SettingsAboutUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var wallet = context.watch<Wallet>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
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
            Text('About us', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}

class SettingsDeletePrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var wallet = context.watch<Wallet>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
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
            Spacer(),
            Text('Are you sure to delete wallet',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlineButton(
                  child: SizedBox(
                    width: 100,
                    height: 40,
                    child: Center(child: Text('No')),
                  ),
                  onPressed: () => wallet.goBack(),
                ),
                SizedBox(width: 10),
                OutlineButton(
                  child: SizedBox(
                    width: 100,
                    height: 40,
                    child: Center(child: Text('Yes')),
                  ),
                  onPressed: () => wallet.settingsDeletePromptConfirm(),
                ),
              ],
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
