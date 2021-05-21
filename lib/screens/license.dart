import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:sideswap/common/theme.dart';
import 'package:sideswap/common/widgets.dart';
import 'package:sideswap/models/wallet.dart';

class LicenseTerms extends StatelessWidget {
  Future<String> loadLicense() async {
    return await rootBundle.loadString('LICENSE');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: mainDecoration,
      child: Center(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  Center(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Text(
                      "Terms and conditions",
                      style: TextStyle(fontSize: 24),
                    ),
                  )),
                  FutureBuilder<String>(
                    future: loadLicense(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          snapshot.data,
                          style: TextStyle(fontSize: 18),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            CustomButton(
                text: "Accept",
                onPressed: () => context.read<Wallet>().acceptLicense()),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
