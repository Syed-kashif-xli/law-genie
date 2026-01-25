import 'dart:convert';
import 'dart:math';
import 'package:encrypt/encrypt.dart' as encrypt;

class EcourtEncryptionService {
  static const List<String> _globalIvs = [
    "556A586E32723575",
    "34743777217A2543",
    "413F4428472B4B62",
    "48404D635166546A",
    "614E645267556B58",
    "655368566D597133"
  ];

  static const String _hexChars = '0123456789abcdef';

  static String encryptRequest(dynamic data) {
    try {
      final dataString = json.encode(data);
      final random = Random();

      // Official logic: var randomiv = genRanHex(16);
      final randomiv =
          List.generate(16, (index) => _hexChars[random.nextInt(16)]).join();

      // Official logic: pick a random index from the IV array
      final ivIndex = random.nextInt(_globalIvs.length);
      final globaliv = _globalIvs[ivIndex];

      // Official logic: key = CryptoJS.enc.Hex.parse('4D6251655468576D5A7134743677397A');
      final key = encrypt.Key.fromBase16('4D6251655468576D5A7134743677397A');

      // Official logic: iv = CryptoJS.enc.Hex.parse(globaliv + randomiv);
      final iv = encrypt.IV.fromBase16(globaliv + randomiv);

      final encrypter =
          encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      final encrypted = encrypter.encrypt(dataString, iv: iv);

      // Official logic: encrypted_data = randomiv + globalIndex + encrypted_data (Base64)
      return '$randomiv$ivIndex${encrypted.base64}';
    } catch (e) {
      return '';
    }
  }

  static String decryptResponse(String encryptedText) {
    try {
      encryptedText = encryptedText.trim();
      if (encryptedText.length < 32) return '';

      // Official key for response decryption: 3273357638782F413F4428472B4B6250
      final key = encrypt.Key.fromBase16('3273357638782F413F4428472B4B6250');

      // First 32 chars are the random IV (hex)
      final ivHex = encryptedText.substring(0, 32);
      final iv = encrypt.IV.fromBase16(ivHex);

      final cipherText = encryptedText.substring(32);

      final encrypter =
          encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      final decrypted = encrypter.decrypt64(cipherText.trim(), iv: iv);

      // Clean up common escape issues as seen in main.js s.replace(...)
      return decrypted.trim();
    } catch (e) {
      return '';
    }
  }
}
