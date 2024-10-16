import 'dart:convert';
import 'dart:developer';
import 'package:csv/csv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import '../helpers/my_dialogs.dart';
import '../helpers/pref.dart';
import '../models/ip_details.dart';
import '../models/vpn.dart';

class APIs {
  static Future<List<Vpn>> getVPNServers() async {
    final List<Vpn> vpnList = [];

    try {
      final res = await get(Uri.parse('https://speedsecurevpn.vercel.app/api/get-ovpn'));

      // Log response status and body for debugging
      log('Response Status: ${res.statusCode}');
      // log('Response Body: ${res.body}');

      // Check for successful response
      if (res.statusCode != 200) {
        throw Exception('Failed to load VPN servers. Status Code: ${res.statusCode}');
      }

      // Parse the CSV response directly
      String csvString = res.body.trim(); // Ensure there are no extra newlines or spaces
      List<List<dynamic>> list = const CsvToListConverter(eol: '\n').convert(csvString);

      // Assuming the first row is the header
      final header = list[0];

      for (int i = 1; i < list.length; ++i) {
        Map<String, dynamic> tempJson = {};

        // Create a JSON-like map from CSV
        for (int j = 0; j < header.length; ++j) {
          tempJson[header[j].toString()] = list[i][j];
        }

        // Add Vpn instance to the list
        vpnList.add(Vpn.fromJson(tempJson));
      }
    } catch (e) {
      MyDialogs.error(msg: e.toString());
      log('getVPNServers Error: $e');
    }

    // Shuffle the list if needed
    vpnList.shuffle();

    // Store the vpn list in preferences
    if (vpnList.isNotEmpty) Pref.vpnList = vpnList;

    return vpnList;
  }

  static Future<void> getIPDetails({required Rx<IPDetails> ipData}) async {
    try {
      final res = await get(Uri.parse('http://ip-api.com/json/'));

      // Log response for debugging
      log('getIPDetails Response Body: ${res.body}');

      final data = jsonDecode(res.body);
      ipData.value = IPDetails.fromJson(data);
    } catch (e) {
      MyDialogs.error(msg: e.toString());
      log('getIPDetails Error: $e');
    }
  }
}