import 'package:http/http.dart' as http;

Future<String> getBalances(String address, String chain) async {
  final url = Uri.parse(
      'https://192.168.102.65:3001/getTokens?userAddress=$address&chain=$chain');

  try {
    final response = await http.get(url);

    // In ra nội dung của phản hồi từ server
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to get balances: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to get balances: $e');
  }
}
