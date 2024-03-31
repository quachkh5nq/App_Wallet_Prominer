import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vi_wallet/pages/generate_mnemonic_page.dart';
// import 'package:vi_wallet/pages/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Create Password Form',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const CreatePasswordPage(),
    );
  }
}

class CreatePasswordPage extends StatefulWidget {
  const CreatePasswordPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CreatePasswordPageState createState() => _CreatePasswordPageState();
}

class _CreatePasswordPageState extends State<CreatePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _storage = const FlutterSecureStorage();
  bool _agreedToTerms = false;
  bool _passwordVisible = false;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleAgreedToTerms(bool? newValue) {
    setState(() {
      _agreedToTerms = newValue ?? false;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  String? _validatePassword(String? value) => value != null && value.length >= 8
      ? null
      : 'Password must be at least 8 characters long.';

  String? _validateConfirmPassword(String? value) =>
      _passwordController.text == value ? null : 'Passwords do not match.';

  // Future<bool> _trySubmitForm() async {
  //   final currentState = _formKey.currentState;
  //   if (currentState != null && currentState.validate()) {
  //     if (_formKey.currentState?.validate() ?? false) {
  //       if (_agreedToTerms) {
  //         if (_passwordController.text == _confirmPasswordController.text) {
  //           await _storage.write(
  //               key: 'password', value: _passwordController.text);
  //           // ignore: use_build_context_synchronously
  //           if (mounted) {
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute(
  //                   builder: (context) => const GenerateMnemonicPage()),
  //             );
  //           }
  //         } else {
  //           _showSnackBar('The passwords do not match. Please try again.');
  //         }
  //       } else {
  //         _showSnackBar('You must agree to the terms to create a new wallet.');
  //       }
  //     } else {
  //       _showSnackBar('Please fill out the form correctly.');
  //     }

  //     return true; // Trả về true nếu tất cả điều kiện được thỏa mãn
  //   }
  //   return false; // Trả về false nếu không hợp lệ
  // }
  Future<bool> _trySubmitForm() async {
    final currentState = _formKey.currentState;
    if (currentState != null && currentState.validate()) {
      if (_formKey.currentState?.validate() ?? false) {
        if (_agreedToTerms) {
          if (_passwordController.text == _confirmPasswordController.text) {
            await _storage.write(
                key: 'password', value: _passwordController.text);

            // Thay thế trang hiện tại bằng trang mới (GenerateMnemonicPage)
            // ignore: use_build_context_synchronously
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const GenerateMnemonicPage(),
              ),
            );
          } else {
            _showSnackBar('The passwords do not match. Please try again.');
          }
        } else {
          _showSnackBar('You must agree to the terms to create a new wallet.');
        }
      } else {
        _showSnackBar('Please fill out the form correctly.');
      }

      return true; // Trả về true nếu tất cả điều kiện được thỏa mãn
    }
    return false; // Trả về false nếu không hợp lệ
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Password')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            // Căn giữa toàn bộ nội dung
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment
                    .center, // Căn giữa các thành phần theo chiều dọc
                crossAxisAlignment: CrossAxisAlignment
                    .stretch, // Kéo dài các thành phần theo chiều ngang
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'This password will unlock your Prominer wallet only on this device. Prominer cannot recover this password.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildPasswordInputField(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildConfirmPasswordInputField(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildAgreeTermsCheckbox(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildCreateWalletButton(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Các phương thức _buildPasswordInputField, _buildConfirmPasswordInputField, _buildAgreeTermsCheckbox, _buildCreateWalletButton vẫn giữ nguyên như ban đầu.

  Column _buildPasswordInputField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'New password (8 characters min)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blue, // Màu viền khung
                  width: 1.0, // Độ dày viền khung
                ),
                borderRadius:
                    BorderRadius.circular(8.0), // Độ cong của góc khung
              ),
              child: TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  border: InputBorder
                      .none, // Loại bỏ viền mặc định của TextFormField
                ),
                obscureText: !_passwordVisible,
                validator: _validatePassword,
              ),
            ),
            IconButton(
              icon: Icon(
                _passwordVisible ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: _togglePasswordVisibility,
            ),
          ],
        ),
      ],
    );
  }

  Column _buildConfirmPasswordInputField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Confirm password',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blue, // Màu viền khung
                  width: 1.0, // Độ dày viền khung
                ),
                borderRadius:
                    BorderRadius.circular(8.0), // Độ cong của góc khung
              ),
              child: TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  border: InputBorder
                      .none, // Loại bỏ viền mặc định của TextFormField
                ),
                obscureText: !_passwordVisible,
                validator: _validateConfirmPassword,
              ),
            ),
            IconButton(
              icon: Icon(
                _passwordVisible ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: _togglePasswordVisibility,
            ),
          ],
        ),
      ],
    );
  }

  CheckboxListTile _buildAgreeTermsCheckbox() {
    return CheckboxListTile(
      title: const Text(
          'I understand that Prominer cannot recover this password for me.'),
      value: _agreedToTerms,
      onChanged: _toggleAgreedToTerms,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  ElevatedButton _buildCreateWalletButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_agreedToTerms) {
          // Kiểm tra xem người dùng đã đồng ý điều khoản chưa
          if (await _trySubmitForm()) {
            // Đảm bảo rằng widgetknow voice setup arctic order total joke physical flash ugly raccoon lyrics vẫn còn tồn tại trước khi thực hiện điều hướng
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GenerateMnemonicPage(),
                ),
              );
            }
          }
        } else {
          _showSnackBar('You must agree to the terms to create a new wallet.');
        }
      },
      child: const Text('Create a new wallet'),
    );
  }
}
