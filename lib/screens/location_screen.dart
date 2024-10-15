import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../controllers/location_controller.dart';
import '../controllers/native_ad_controller.dart';
import '../helpers/ad_helper.dart';
import '../widgets/vpn_card.dart';

class LocationScreen extends StatelessWidget {
  LocationScreen({super.key});

  final _controller = LocationController();
  final _adController = NativeAdController();

  @override
  Widget build(BuildContext context) {
    // Initialize the Ad only once
    if (_adController.ad == null) {
      _adController.ad = AdHelper.loadNativeAd(adController: _adController);
    }

    // Load VPN data if it's empty and not already loading
    if (_controller.vpnList.isEmpty && !_controller.isLoading.value) {
      _controller.getVpnData();
    }

    return Obx(
      () => Scaffold(
        backgroundColor: Color(0xff13152a),
        appBar: AppBar(
          automaticallyImplyLeading: true,
          foregroundColor: Colors.white,
          backgroundColor: Color(0xff13152a),
          title: Text(
            'VPN Locations (${_controller.vpnList.length})',
            style: TextStyle(color: Colors.white),
          ),
        ),
        bottomNavigationBar:
            _adController.ad != null && _adController.adLoaded.isTrue
                ? SafeArea(
                    child: SizedBox(
                        height: 85, child: AdWidget(ad: _adController.ad!)),
                  )
                : null,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10, right: 10),
          child: FloatingActionButton(
            backgroundColor: Color(0xff6a6b9d),
            onPressed: () => _controller.getVpnData(),
            child: Icon(Icons.refresh),
          ),
        ),
        body: _controller.isLoading.value
            ? Center(child: CircularProgressIndicator())
            : _controller.vpnList.isEmpty
                ? _noVPNFound()
                : _vpnData(),  
      ),
    );
  }

  _vpnData() {
    // Create a sorted copy of the VPN list
    List vpnList = List.from(_controller.vpnList);
    vpnList.sort((a, b) =>
        b.speed.compareTo(a.speed)); // Assuming speed is a numerical property

    return ListView.builder(
      itemCount: vpnList.length,
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        top: 15, // Adjust these values as needed
        bottom: 100,
        left: 16,
        right: 16,
      ),
      itemBuilder: (ctx, i) => VpnCard(vpn: vpnList[i]),
    );
  }

  _noVPNFound() => Center(
        child: Text(
          'VPNs Not Found! 😔',
          style: TextStyle(
              fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );
}
