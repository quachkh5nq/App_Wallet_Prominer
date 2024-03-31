import 'package:web3dart/web3dart.dart';
import 'package:flutter/foundation.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:ed25519_hd_key/ed25519_hd_key.dart';
import 'package:hex/hex.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Enum để định nghĩa các mạng lưới
enum BlockchainNetwork { ethereum, polygon, bnb, avax }

abstract class WalletAddressService {
  String generateMnemonic({BlockchainNetwork network});
  Future<String> getPrivateKey(String mnemonic);
  Future<EthereumAddress> getPublicKey(String privateKey);
}

class WalletProvider extends ChangeNotifier implements WalletAddressService {
  // Variable to store the private key
  String? privateKey;

  // Variable to store the mnemonic
  String? mnemonic;

  // Load the private key and mnemonic from the shared preferences
  Future<void> loadPrivateKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    privateKey = prefs.getString('privateKey');
    mnemonic = prefs.getString('mnemonic');
    // print('Loaded privateKey: $privateKey');
    // print('Loaded mnemonic: $mnemonic');
  }

  // // set the private key and mnemonic in the shared preferences
  Future<void> setPrivateKeyAndMnemonic(
      String privateKey, String mnemonic) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('privateKey', privateKey);
    await prefs.setString('mnemonic', mnemonic);

    this.privateKey = privateKey;
    this.mnemonic = mnemonic;
    notifyListeners();
  }

  // Get the saved mnemonic
  String getSavedMnemonic() {
    return mnemonic ?? '';
  }

  @override
  String generateMnemonic(
      {BlockchainNetwork network = BlockchainNetwork.polygon}) {
    // Sinh mnemonic theo yêu cầu của mạng lưới
    String generatedMnemonic = bip39.generateMnemonic();

    // Nếu mạng không phải là Ethereum, thì mặc định là Polygon
    if (network != BlockchainNetwork.ethereum) {
      // Bạn có thể thêm logic khác ở đây nếu cần
    }

    return generatedMnemonic;
  }

  @override
  // Future<String> getPrivateKey(String mnemonic) async {
  //   final seed = bip39.mnemonicToSeed(mnemonic);
  //   final master = await ED25519_HD_KEY.getMasterKeyFromSeed(seed);
  //   final privateKey = HEX.encode(master.key);

  //   // Set the private key and mnemonic in the shared preferences
  //   await setPrivateKeyAndMnemonic(privateKey, mnemonic);
  //   return privateKey;
  // }

  Future<String> getPrivateKey(String mnemonic) async {
    final seed = bip39.mnemonicToSeed(mnemonic);
    final root = bip32.BIP32.fromSeed(seed);

    // Chọn đường dẫn tùy chọn (ví dụ: m/44'/60'/0'/0/0)
    const path = "m/44'/60'/0'/0/0";
    final wallet = root.derivePath(path);

    // Kiểm tra xem privateKey có tồn tại không
    if (wallet.privateKey == null) {
      // Xử lý trường hợp khi privateKey là null
      throw Exception("Private key is null");
    }

    // Lấy private key
    final privateKey = HEX.encode(wallet.privateKey!);

    // Đảm bảo bạn đã cài đặt package SharedPreferences và import nó
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('privateKey', privateKey);

    return privateKey;
  }

  // @overridedish voyage trumpet belt merry fame bundle sick damage solid raven bounce
  // Future<EthereumAddress> getPublicKey(String privateKey) async {
  //   final private = EthPrivateKey.fromHex(privateKey);
  //   final address = await private.address;
  //   return address;
  // }

  // @override
  // Future<EthereumAddress> getPublicKey(String privateKey) async {
  //   final private = EthPrivateKey.fromHex(privateKey);
  //   // ignore: deprecated_member_use
  //   final address = await private.extractAddress();

  //   // Chuyển địa chỉ về dạng chuỗi với cả chữ thường và in hoa
  //   String formattedAddress = EthereumAddress.fromHex(address.hex).toString();

  //   // In ra địa chỉ để kiểm tra
  //   print('Address Hex: ${formattedAddress}');

  //   // Trả về địa chỉ EthereumAddress
  //   return EthereumAddress.fromHex(formattedAddress);
  // }

  // @override
  // Future<EthereumAddress> getPublicKey(String privateKey) async {
  //   final private = EthPrivateKey.fromHex(privateKey);
  //   // ignore: deprecated_member_use
  //   final address = await private.extractAddress();

  //   // Chuyển địa chỉ về dạng chuỗi
  //   String formattedAddress = address.hex;

  //   // Tạo một danh sách ký tự từ địa chỉ
  //   List<String> addressCharacters = formattedAddress.split('');

  //   // Lẫn lộn giữa chữ thường và chữ in hoa cho từng ký tự trong địa chỉ
  //   for (int i = 0; i < addressCharacters.length; i++) {
  //     if (i.isEven) {
  //       addressCharacters[i] = addressCharacters[i].toLowerCase();
  //     } else {
  //       addressCharacters[i] = addressCharacters[i].toUpperCase();
  //     }
  //   }

  //   // Kết hợp danh sách ký tự thành địa chỉ mới
  //   String mixedCaseAddress = addressCharacters.join();

  //   // In ra địa chỉ để kiểm tra
  //   print('Mixed Case Address: $mixedCaseAddress');

  //   // Trả về địa chỉ EthereumAddress
  //   return EthereumAddress.fromHex(mixedCaseAddress);
  // }

  @override
  Future<EthereumAddress> getPublicKey(String privateKey) async {
    final private = EthPrivateKey.fromHex(privateKey);
    // ignore: deprecated_member_use
    final address = await private.extractAddress();

    // Sử dụng hàm formatAddress để lẫn lộn chữ thường và chữ hoa trong địa chỉ
    String formattedAddress = formatAddress(address.hex);

    // In ra để kiểm tra
    print('Formatted Address: $formattedAddress');

    // Trả về địa chỉ EthereumAddress
    return EthereumAddress.fromHex(formattedAddress);
  }

  String formatAddress(String address) {
    // Chuyển địa chỉ thành chuỗi chữ thường
    String lowerCaseAddress =
        EthereumAddress.fromHex(address).toString().toLowerCase();

    // Lẫn lộn giữa chữ thường và chữ in hoa (ngoại trừ ký tự đầu)
    List<String> addressCharacters = lowerCaseAddress.split('');

    for (int i = 1; i < addressCharacters.length; i++) {
      if (i.isEven) {
        addressCharacters[i] = addressCharacters[i].toUpperCase();
      }
    }

    // Kết hợp danh sách ký tự thành địa chỉ mới
    String mixedCaseAddress = addressCharacters.join();

    return mixedCaseAddress;
  }

  /////
  bool _isWalletCreated = false;

  bool get isWalletCreated => _isWalletCreated;

// Trong phương thức setWalletStatus của WalletProvider
  void setWalletStatus(bool status) {
    _isWalletCreated = status;
    notifyListeners(); // Thông báo cho các người nghe về sự thay đổi trong trạng thái ví
  }
}
