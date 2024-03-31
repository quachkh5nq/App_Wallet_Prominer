import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vi_wallet/providers/wallet_provider.dart';
import 'package:vi_wallet/pages/wallet.dart';
import 'package:http/http.dart' as http;

class ImportWallet extends StatefulWidget {
  const ImportWallet({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ImportWalletState createState() => _ImportWalletState();
}

class _ImportWalletState extends State<ImportWallet> {
  List<TextEditingController> mnemonicControllers = List.generate(
    12,
    (index) => TextEditingController(),
  );

  List<String> enteredKeys = List.filled(12, '');

  void navigateToWalletPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WalletPage()),
    );
  }

  Future<void> pasteMnemonicFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null) {
      pasteMnemonic(clipboardData.text ?? '');
    }
  }

  void pasteMnemonic(String text) {
    final List<String> keys = text.trim().split(' ');
    for (var i = 0; i < enteredKeys.length && i < keys.length; i++) {
      mnemonicControllers[i].text = keys[i];
      enteredKeys[i] = keys[i];
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String secretKey = '';
    void verifyMnemonic() async {
      for (var i = 0; i < enteredKeys.length; i++) {
        secretKey += '${enteredKeys[i]} ';
      }

      // ignore: avoid_print
      print(secretKey);
      final response = await http.post(
        Uri.parse('http://192.168.102.65:3001/import-wallet'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'secretKey': secretKey.trim()}),
      );

      // ignore: avoid_print
      print(response.statusCode);
      // ignore: avoid_print
      print(response.body);

      final walletProvider =
          // ignore: use_build_context_synchronously
          Provider.of<WalletProvider>(context, listen: false);

      if (response.statusCode == 200) {
        walletProvider.setWalletStatus(true);
        walletProvider.setPrivateKeyAndMnemonic("Test", secretKey.toString());
        navigateToWalletPage();
      } else {
        // Nếu không thành công, có thể hiển thị thông báo hoặc xử lý khác
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text(
                'Invalid mnemonic phrase. Please make sure you have entered the correct phrase and all keys are valid.',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import from Seed'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: List.generate(4, (rowIndex) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(3, (columnIndex) {
                    final index = rowIndex * 3 + columnIndex;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextField(
                          controller: mnemonicControllers[index],
                          onChanged: (value) {
                            setState(() {
                              enteredKeys[index] = value.trim();
                            });
                          },
                          decoration: InputDecoration(
                            labelText: '${index + 1}',
                            contentPadding: const EdgeInsets.all(12.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                color: enteredKeys[index] == ''
                                    ? Colors.blueAccent
                                    : isValidKey(index)
                                        ? Colors.blueAccent
                                        : Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              }),
            ),
            ElevatedButton(
              onPressed: verifyMnemonic,
              child: const Text('Import'),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () async {
                await pasteMnemonicFromClipboard();
              },
              child: const Text('Paste'),
            ),
            const SizedBox(height: 24.0),
            const Text(
              'Note: Ensure you have the correct mnemonic phrase before importing.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14.0,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  bool isValidKeys() {
    return enteredKeys.every((key) => key.isNotEmpty);
  }

  bool isValidKey(int index) {
    // ignore: prefer_is_empty
    return enteredKeys[index].length > 0;
  }
}
