import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vpn_basic_project/apis/apis.dart';
import 'package:vpn_basic_project/controllers/native_ad_controller.dart';
import 'package:vpn_basic_project/helpers/ad_helper.dart';
import 'package:vpn_basic_project/helpers/config.dart';
import 'package:vpn_basic_project/models/ip_details.dart';
import 'package:vpn_basic_project/widgets/center_text.dart';
import 'package:vpn_basic_project/widgets/detail_card.dart';
import 'package:vpn_basic_project/widgets/drawer.dart';

import '../controllers/home_controller.dart';
import '../main.dart';
import '../services/vpn_engine.dart';
import '../widgets/count_down_timer.dart';
import 'location_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final _controller = Get.put(HomeController());
  final _adController = NativeAdController();

  @override
  Widget build(BuildContext context) {
    _adController.ad = AdHelper.loadNativeAd(adController: _adController);
    final ipData = IPDetails.fromJson({}).obs;
    APIs.getIPDetails(ipData: ipData);
    mq = MediaQuery.sizeOf(context);

    ///Add listener to update vpn state
    VpnEngine.vpnStageSnapshot().listen((event) {
      _controller.vpnState.value = event;
    });

    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xff13152a),
        //app bar
        appBar: AppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
          centerTitle: true,
          backgroundColor: Color(0xff13162b),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                onPressed: () {
                  Get.to(() => LocationScreen());
                },
                icon: Icon(Icons.language, color: Colors.white, size: 28),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Config.hideAds
            ? null
            : _adController.ad != null && _adController.adLoaded.isTrue
                ? SafeArea(
                    child: SizedBox(
                        height: 85, child: AdWidget(ad: _adController.ad!)))
                : null,
        drawer: DrawerWidget(),
        //body
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: mq.height * 0.02),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: mq.height * 0.03,
                ),
                Text(
                  'Welcome',
                  style: TextStyle(
                      fontSize: mq.height * 0.035,
                      fontWeight: FontWeight.w900,
                      color: Color(0xff5a6a86)),
                ),
                SizedBox(
                  height: mq.height * 0.03,
                ),
                //vpn button
                Obx(() => _vpnButton()),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CenterText(
                        text: 'Connected',
                        value: Obx(() => CountDownTimer(
                            startTimer: _controller.vpnState.value ==
                                VpnEngine.vpnConnected)),
                      ),
                      CenterText(
                        text: 'Your IP',
                        value: Obx(() => Text(
                              ipData.value.query,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: mq.height * .025,
                                  color: Colors.white),
                            )),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: mq.height * 0.03,
                ),
                StreamBuilder(
                  stream: VpnEngine.vpnStatusSnapshot(),
                  builder: (context, snapshot) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DetailCard(
                        iconColor: (Colors.green),
                        cardName: 'Download',
                        icon: Icons.download_outlined,
                        cardData: snapshot.data?.byteIn ?? '0 kbps',
                      ),
                      SizedBox(
                        width: mq.width * 0.03,
                      ),
                      DetailCard(
                        iconColor: const Color.fromARGB(255, 151, 102, 160),
                        cardName: 'Upload',
                        icon: Icons.upload_outlined,
                        cardData: snapshot.data?.byteOut ?? '0 kbps',
                      ),
                    ],
                  ),
                ),
              ]),
        ),
      ),
    );
  }

  //vpn button
  Widget _vpnButton() => Column(
        children: [
          //button
          Semantics(
            button: true,
            child: InkWell(
              onTap: () {
                _controller.connectToVpn();
              },
              borderRadius: BorderRadius.circular(100),
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _controller.getButtonColor.withOpacity(.1)),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _controller.getButtonColor.withOpacity(.3)),
                  child: Container(
                    width: mq.height * .14,
                    height: mq.height * .14,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _controller.getButtonColor),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //icon
                        Icon(
                          Icons.rocket_launch_outlined,
                          size: 40,
                          color: Colors.white,
                        ),
                        SizedBox(height: 4),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          //connection status label
          Container(
            margin:
                EdgeInsets.only(top: mq.height * .015, bottom: mq.height * .02),
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            decoration: BoxDecoration(
                color: Color(0xff6a6b9d),
                borderRadius: BorderRadius.circular(15)),
            child: Text(
              _controller.vpnState.value == VpnEngine.vpnDisconnected
                  ? 'Not Connected'
                  : _controller.vpnState.replaceAll('_', ' ').toUpperCase(),
              style: TextStyle(fontSize: 12.5, color: Colors.white),
            ),
          ),
        ],
      );
}
