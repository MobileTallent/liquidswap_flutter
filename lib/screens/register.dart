import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sideswap/common/theme.dart';
import 'package:sideswap/models/wallet.dart';
import 'package:sideswap/common/helpers.dart';
import 'package:sideswap/common/widgets.dart';

class WalletImport extends StatelessWidget {
  final words = List.generate(12, (index) => "");

  String getMnemonic() {
    String result = words.fold(
        "", (previousValue, element) => previousValue + " " + element.trim());
    return result.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: mainDecoration,
      child: Column(
        children: [
          Spacer(),
          CustomTitle('Enter your 12 word recovery phrase'),
          Spacer(),
          Table(
              children: List<TableRow>.generate(
                  4,
                  (rowIndex) => TableRow(
                          children: List<Widget>.generate(3, (colIndex) {
                        int index = rowIndex * 3 + colIndex;
                        return MnemonicWord.enabled(
                            index: index,
                            onChanged: (String value) =>
                                {words[index] = value});
                      })))),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomButton(
                text: 'Back',
                onPressed: () => {context.read<Wallet>().goBack()},
              ),
              CustomButton(
                text: 'Import',
                onPressed: () {
                  var mnemonic = getMnemonic();
                  var wallet = context.read<Wallet>();
                  if (!wallet.validateMnemonic(mnemonic)) {
                    showMessage(
                        context, "Import failed", "Mnemonic is not valid");
                    return;
                  }
                  wallet.importMnemonic(mnemonic);
                },
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class WalletBackupNewPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: mainDecoration,
      child: Column(
        children: [
          Spacer(),
          CustomTitle('Do you wish to backup your wallet?'),
          Spacer(flex: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomButton(
                text: 'No',
                onPressed: () => {context.read<Wallet>().backupNewWalletNo()},
              ),
              CustomButton(
                text: 'Yes',
                onPressed: () => {context.read<Wallet>().backupNewWalletYes()},
              ),
            ],
          ),
          SizedBox(height: 20)
        ],
      ),
    );
  }
}

class WalletBackup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var wallet = context.watch<Wallet>();
    var words = wallet.getMnemonicWords();
    return Container(
      decoration: mainDecoration,
      child: Column(
        children: [
          Spacer(flex: 2),
          CustomTitle('Save your 12 word recovery phrase'),
          Spacer(flex: 1),
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
          Spacer(flex: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomButton(
                text: 'Back',
                onPressed: () => wallet.goBack(),
              ),
              CustomButton(
                text: 'Confirm',
                onPressed: () => wallet.backupNewWalletCheck(),
              ),
            ],
          ),
          SizedBox(height: 20)
        ],
      ),
    );
  }
}

class WalletBackupCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var wallet = context.watch<Wallet>();
    var wordIndices = wallet.backupCheckAllWords.keys.toList();
    return Container(
      decoration: mainDecoration,
      child: Column(
        children: [
          Spacer(),
          CustomTitle('Select the correct word'),
          Spacer(),
          Column(
            children: List<Widget>.generate(wordIndices.length, (int index) {
              int wordIndex = wordIndices[index];
              var words = wallet.backupCheckAllWords[wordIndex];
              return _MnemonicCheckRow(wordIndex: wordIndex, words: words);
            }),
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomButton(
                text: 'Back',
                onPressed: () => wallet.goBack(),
              ),
              CustomButton(
                text: 'Confirm',
                onPressed: () => wallet.backupNewWalletVerify(),
              ),
            ],
          ),
          SizedBox(height: 20)
        ],
      ),
    );
  }
}

class _MnemonicCheckRow extends StatelessWidget {
  final int wordIndex;
  final List<String> words;
  _MnemonicCheckRow({this.wordIndex, this.words});
  @override
  Widget build(BuildContext context) {
    var wallet = context.watch<Wallet>();
    return Column(children: [
      Text('Word #${wordIndex + 1}'),
      SizedBox(
        height: 50,
        child: Row(
          children: List<Widget>.generate(words.length, (int index) {
            int selectionIndex =
                wallet.backupCheckSelectedWords[wordIndex] ?? -1;
            bool isSelected = selectionIndex == index;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: OutlinedButton(
                    style: ButtonStyle(
                      backgroundColor: isSelected
                          ? MaterialStateProperty.all<Color>(Colors.white)
                          : null,
                    ),
                    onPressed: () {
                      wallet.backupNewWalletSelect(wordIndex, index);
                    },
                    child: Container(
                        child: Text(
                      words[index],
                    ))),
              ),
            );
          }),
        ),
      ),
    ]);
  }
}

class WalletBackupView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WalletBackup();
  }
}

class WalletBackupCheckFailed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: mainDecoration,
      child: Column(
        children: [
          Spacer(),
          CustomTitle('Please check selected words'),
          Spacer(),
          CustomButton(
            text: 'Back',
            onPressed: () => context.read<Wallet>().goBack(),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class WalletEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: mainDecoration,
      child: Center(
        child: Column(
          children: [
            Spacer(),
            CustomTitle("First launch"),
            Spacer(),
            CustomButton(
                text: "Create new wallet",
                onPressed: () => context.read<Wallet>().createNewWallet()),
            SizedBox(height: 20),
            CustomButton(
                text: "Import wallet",
                onPressed: () => context.read<Wallet>().startMnemonicImport()),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
