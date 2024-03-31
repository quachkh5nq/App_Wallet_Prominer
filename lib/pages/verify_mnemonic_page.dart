import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vi_wallet/providers/wallet_provider.dart';
import 'package:vi_wallet/pages/wallet.dart';
import 'dart:math';

class VerifyMnemonicPage extends StatefulWidget {
  final String mnemonic;

  const VerifyMnemonicPage({Key? key, required this.mnemonic})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _VerifyMnemonicPageState createState() => _VerifyMnemonicPageState();
}

class _VerifyMnemonicPageState extends State<VerifyMnemonicPage> {
  bool isVerified = false;
  List<TextEditingController> mnemonicControllers =
      List.generate(12, (index) => TextEditingController());
  List<String> enteredKeys = List.filled(12, '');
  List<int> missingKeyIndices = [];

  @override
  void initState() {
    super.initState();
    generateRandomMissingKeys();
  }

  void generateRandomMissingKeys() {
    final random = Random();
    final allIndices = List.generate(12, (index) => index);
    allIndices.shuffle(random);
    missingKeyIndices = allIndices.sublist(0, 3);
  }

  void pasteMnemonic(String enteredMnemonic) {
    final List<String> keys = enteredMnemonic.trim().split(' ');

    if (keys.length == 12) {
      for (int i = 0; i < 12; i++) {
        if (missingKeyIndices.contains(i)) {
          mnemonicControllers[i].text = '';
        } else {
          mnemonicControllers[i].text = keys[i];
          enteredKeys[i] = keys[i];
        }
      }
    }
  }

  void verifyMnemonic() {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);

    final enteredMnemonic = enteredKeys.join(' ');

    if (enteredMnemonic.trim() == widget.mnemonic.trim()) {
      walletProvider.getPrivateKey(widget.mnemonic).then((privateKey) {
        setState(() {
          isVerified = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    void navigateToWalletPage() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WalletPage()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Secret Recovery Phrase'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Please verify your mnemonic phrase:',
                style: TextStyle(fontSize: 18.0),
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () async {
                  final clipboardData =
                      await Clipboard.getData(Clipboard.kTextPlain);
                  if (clipboardData != null) {
                    pasteMnemonic(clipboardData.text ?? '');
                  }
                },
                child: const Text('Paste'),
              ),
              const SizedBox(height: 16.0),
              Column(
                children: List.generate(4, (rowIndex) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(3, (columnIndex) {
                      final index = rowIndex * 3 + columnIndex;
                      return Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.all(10.0), // Khoảng cách 10px
                          child: TextField(
                            controller: mnemonicControllers[index],
                            onChanged: (value) {
                              enteredKeys[index] = value.trim();
                            },
                            decoration: InputDecoration(
                              labelText: '${index + 1}',
                              contentPadding: const EdgeInsets.all(
                                  12.0), // Khoảng cách trong khung
                              border: OutlineInputBorder(
                                // Khung viền
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: const BorderSide(
                                  color: Colors.blueAccent,
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
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  verifyMnemonic();
                },
                // ignore: sort_child_properties_last
                child: const Text('Verify'),
                style: ElevatedButton.styleFrom(
                  // ignore: deprecated_member_use
                  primary: Colors.blue,
                ),
              ),
              const SizedBox(height: 8.0),
              if (!isVerified)
                const Text(
                  'Verification failed. Please check your mnemonic.',
                  style: TextStyle(color: Colors.red),
                ),
              ElevatedButton(
                onPressed: isVerified
                    ? () {
                        navigateToWalletPage();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
