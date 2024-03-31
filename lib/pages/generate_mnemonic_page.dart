import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vi_wallet/providers/wallet_provider.dart';
import 'package:vi_wallet/pages/verify_mnemonic_page.dart';

class GenerateMnemonicPage extends StatefulWidget {
  const GenerateMnemonicPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _GenerateMnemonicPageState createState() => _GenerateMnemonicPageState();
}

class _GenerateMnemonicPageState extends State<GenerateMnemonicPage> {
  bool _isRevealed = false;

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    final mnemonic = walletProvider.generateMnemonic();
    final mnemonicWords = mnemonic.split(' ');

    void copyToClipboard() {
      Clipboard.setData(ClipboardData(text: mnemonic));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mnemonic Copied to Clipboard')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Wallet'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Write down your Secret Recovery Phrase',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Write down this 12-word Secret Recovery Phrase and save it in a place that you trust and only you can access.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 16.0),

            // Tips section starts here
            Container(
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.blue[50], // Soft blue background
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 2), // changes position of shadow
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Text(
                    'Tips:',
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  Text('• Save in a password manager'),
                  Text('• Store in a safe deposit box'),
                  Text('• Write down and store in multiple secret places'),
                ],
              ),
            ),
            const SizedBox(height: 16.0),

            // Ẩn và Hiện 1 password
            TextButton(
              onPressed: () {
                setState(() {
                  _isRevealed = !_isRevealed;
                });
              },
              child: Text(
                _isRevealed ? 'Hide seed phrase' : 'Reveal seed phrase',
                style: const TextStyle(decoration: TextDecoration.underline),
              ),
            ),
            const SizedBox(height: 16.0),

            // Display 12 mnemonic words in a grid
            Expanded(
              child: _isRevealed
                  ? GridView.builder(
                      padding:
                          const EdgeInsets.all(8.0), // Add padding if needed
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // Number of columns
                        mainAxisSpacing: 10, // Space between rows
                        crossAxisSpacing: 10, // Space between columns
                        childAspectRatio: 3 / 1, // Aspect ratio of each cell
                      ),
                      itemCount: mnemonicWords.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors
                                .white, // Add a background color if needed
                            border: Border.all(color: Colors.blueAccent),
                            borderRadius:
                                BorderRadius.circular(12.0), // Rounded corners
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: const Offset(0, 2), // Shadow position
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}. ${mnemonicWords[index]}',
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                          'Tap "Reveal seed phrase" to show the mnemonic words.'),
                    ),
            ),

            // Coppy 12 mã ký tự - chỉ hiển thị khi _isRevealed là true
            if (_isRevealed) ...[
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: copyToClipboard,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  textStyle: const TextStyle(fontSize: 18.0),
                  elevation: 2,
                ),
                child: const Text('Copy to Clipboard'),
              ),
            ],

            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () {
                // Placeholder for next button action
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        VerifyMnemonicPage(mnemonic: mnemonic),
                  ),
                );
              },
              child: const Text(
                'Next',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
