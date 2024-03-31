import 'package:flutter/material.dart';
import 'package:vi_wallet/pages/create_password.dart';
import 'package:vi_wallet/pages/import_wallet.dart';

class CreateOrImportPage extends StatelessWidget {
  const CreateOrImportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                alignment: Alignment.center,
                child: const Text(
                  'LET`S GET STARTED',
                  style: TextStyle(
                    fontSize: 29.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 29.0),

              // Hello app
              Container(
                alignment: Alignment.center,
                child: const Text(
                  'Trusted by millions, Prominer is a secure wallet making the world of web3 accessible to all.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(height: 24.0),

              // Logo
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: SizedBox(
                  width: 150,
                  height: 200,
                  child: Image.asset(
                    'assets/images/logo.jpg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 50.0),

              // Login button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreatePasswordPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16.0),
                ),
                child: const Text(
                  'Create a new Wallet',
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ),

              const SizedBox(height: 16.0),

              // Register button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ImportWallet(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.all(16.0),
                ),
                child: const Text(
                  'Import an existing wallet',
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ),

              const SizedBox(height: 24.0),

              // Footer
              Container(
                alignment: Alignment.center,
                child: const Text(
                  '© 2024 Moralis. All rights reserved.',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
