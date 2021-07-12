import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc_demo/src/call_sample/new_controller.dart';
import 'package:flutter_webrtc_demo/src/utils/my_video_view.dart';
import 'package:get/get.dart';

class FullScreenPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    NewController controller = Get.find();
    SystemChrome.setEnabledSystemUIOverlays([]);
    return WillPopScope(
      onWillPop: () async {
        await SystemChrome.setEnabledSystemUIOverlays(
            [SystemUiOverlay.top, SystemUiOverlay.bottom]);
        return true;
      },
      child: Scaffold(
        body: Container(
            child: Stack(
          children: [
            Obx(() => Column(
                  children: [
                    if (controller.change.value) Container(),
                    Expanded(
                        child: MyVideoView(
                      controller.videoRenderer,
                      fullScreen: true,
                    ))
                  ],
                )),
            Positioned(
                top: 0,
                right: 0,
                child: Container(
                  alignment: Alignment.topCenter,
                  height: Get.height,
                  width: 40,
                  color: Color(0x55000000),
                  child: InkWell(
                    onTap: () async {
                      // 隐藏底部按钮栏
                      await SystemChrome.setEnabledSystemUIOverlays(
                          [SystemUiOverlay.top, SystemUiOverlay.bottom]);
                      Get.back();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: Icon(
                        Icons.arrow_upward,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ))
          ],
        )),
      ),
    );
  }
}

class NewSample extends StatelessWidget {
  // var serverUrl = 'http://192.168.30.93:8000';
  // var videoUrl = 'rtsp://admin:hy123456@192.168.30.245';

  final String serverUrl;
  final String videoUrl;

  NewSample(this.serverUrl, this.videoUrl);

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(NewController(serverUrl, videoUrl));
    return Scaffold(
      appBar: AppBar(
        title: Text("FlutterWebRtc-Streamer"),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.fullscreen),
        mini: true,
        onPressed: () {
          Get.to(FullScreenPage());
        },
      ),
      body: Container(
        child: Obx(() => Column(
              children: [
                if (controller.change.value) Container(),
                Expanded(
                    child: MyVideoView(
                  controller.videoRenderer,
                  fullScreen: false,
                ))
              ],
            )),
      ),
    );
  }
}
