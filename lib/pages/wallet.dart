import 'package:ethers/signers/wallet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vi_wallet/pages/create_or_import.dart';
import 'package:vi_wallet/utils/get_balances.dart';
import 'package:vi_wallet/components/nft_balances.dart';
import 'package:vi_wallet/components/send_tokens.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

import '../providers/wallet_provider.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  String walletAddress = '';
  String balance = '';
  String pvKey = '';

  @override
  void initState() {
    super.initState();
    loadWalletData();
  }

  Future<void> loadWalletData() async {
    print('Calling loadWalletData');

    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? secretKey = prefs.getString("mnemonic");

    if (secretKey != null && secretKey.isNotEmpty) {
      final response = await http.post(
        Uri.parse('http://192.168.102.65:3001/import-wallet'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
          <String, String>{'secretKey': secretKey.toString().trim()},
        ),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        walletAddress = jsonResponse['walletAddress'];
        print('Wallet Address: $walletAddress');

        // Lấy privateKey từ WalletProvider
        String privateKey = await walletProvider.getPrivateKey(secretKey);
        print('PrivateKey: $privateKey');

        setState(() {
          this.walletAddress = walletAddress;
        });
      } else {
        print(
            'Failed to load wallet data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } else {
      print('Mnemonic is null or empty');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: MediaQuery.of(context).size.height *
                0.3, // Giảm chiều cao để tránh tràn
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Wallet Address',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8.0), // Giảm khoảng cách để tránh tràn
                Text(
                  walletAddress,
                  style: const TextStyle(
                    fontSize: 20.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Balance',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8.0),
                Text(
                  balance,
                  style: const TextStyle(
                    fontSize: 20.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  FloatingActionButton(
                    heroTag: 'sendButton',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SendTokensPage(privateKey: pvKey),
                        ),
                      );
                    },
                    child: const Icon(Icons.send),
                  ),
                  const SizedBox(height: 8.0),
                  const Text('Send'),
                ],
              ),
              Column(
                children: [
                  FloatingActionButton(
                    heroTag: 'refreshButton',
                    onPressed: () {
                      loadWalletData();
                    },
                    child: const Icon(Icons.replay_outlined),
                  ),
                  const SizedBox(height: 8.0),
                  const Text('Refresh'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16.0), // Giảm khoảng cách để tránh tràn
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: Colors.blue,
                    tabs: [
                      Tab(text: 'Tokens'),
                      Tab(text: 'NFTs'),
                      Tab(text: 'Options'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        Column(
                          children: [
                            Card(
                              margin: const EdgeInsets.all(16.0),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Sepolia ETH',
                                      style: TextStyle(
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      balance,
                                      style: const TextStyle(
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        SingleChildScrollView(
                            child: NFTListPage(
                                address: walletAddress, chain: 'sepolia')),
                        Center(
                          child: ListTile(
                            leading: const Icon(Icons.logout),
                            title: const Text('Logout'),
                            onTap: () async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.remove('privateKey');
                              // ignore: use_build_context_synchronously
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CreateOrImportPage(),
                                ),
                                (route) => false,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
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
