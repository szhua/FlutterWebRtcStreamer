import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc_demo/generated/json/base/json_convert_content.dart';
import 'package:flutter_webrtc_demo/src/call_sample/candis_entity.dart';
import 'package:get/get.dart';
import 'signaling.dart';

class NewController extends GetxController {
  RTCVideoRenderer videoRenderer = RTCVideoRenderer();

  ///是否是全屏；
  var fullScreen = false.obs;

  ///动态更新 RenderView进行 video的显示 ； ps：设置 render.src 并不会出发其进行直接播放的动作；
  var change = false.obs;

  final String serverUrl;
  final String videoUrl;

  NewController(this.serverUrl, this.videoUrl);

  final peerId = Random().nextDouble();

  var _iceServers;
  final net = new Dio();
  RTCPeerConnection pc;

  ///创建PeerConnetction的配置
  final Map<String, dynamic> _config = {
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': true},
    ]
  };

  ///创建offer 的 限制参数；
  final Map<String, dynamic> _dcConstraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': [],
  };

  @override
  void onInit() {
    super.onInit();
    net.interceptors.add(LogInterceptor(responseBody: true)); //开启请求日志
    videoRenderer.initialize();
    connect();
  }

  @override
  void onClose() {
    disConnect();
    super.onClose();
  }

  @override
  void dispose() {
    disConnect();
    super.dispose();
  }

  /// 链接的时候直接链接iceServers ；
  void connect() {
    net.get("$serverUrl/api/getIceServers").then((value) {
      _iceServers = json.decode(value.toString());
      onReceiveGetIceServers();
    });
  }

  void disConnect() {
    if (pc != null) {
      pc.close().then((value) {
        print('"pcClosed"');
      });
    }
    videoRenderer.srcObject = null;
    videoRenderer.dispose();

    ///挂断链接
    net.get("$serverUrl/api/hangup?peerid=$peerId}").then((value) {
      print('OfflineOK');
    });
  }

  void onReceiveGetIceServers() async {
    Session session = await _createSession();

    ///拨打链接
    var callurl = '$serverUrl/api/call?peerid=$peerId&&url=$videoUrl';
    try {
      RTCSessionDescription s = await session.pc.createOffer(_dcConstraints);
      await session.pc.setLocalDescription(s);
      net
          .post(
        callurl,
        data: s.toMap(),
        options: Options(contentType: Headers.jsonContentType),
      )
          .then((value) {
        print(jsonDecode(value.toString()));
        var result = jsonDecode(value.toString());
        var descr = new RTCSessionDescription(result['sdp'], result['type']);
        handleCallUrlResult(descr);
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void handleCallUrlResult(RTCSessionDescription desc) async {
    await pc.setRemoteDescription(desc);

    /// 拨通以后获得iceCandidate ；
    getIceCandidate();
  }

  String get sdpSemantics =>
      WebRTC.platformIsWindows ? 'plan-b' : 'unified-plan';

  Future<Session> _createSession() async {
    var newSession = Session(sid: "My$peerId", pid: peerId.toString());
    pc = await createPeerConnection({
      ..._iceServers,
      ...{'sdpSemantics': sdpSemantics}
    }, _config);
    switch (sdpSemantics) {
      case 'plan-b':

        ///接受stream，显示视频
        pc.onAddStream = (MediaStream stream) {
          print("onAddStream-------------plan-b---------------");
          videoRenderer.srcObject = stream;
          change.value = !change.value;
        };
        break;
      case 'unified-plan':

        /// 接收stream 显示视频；
        pc.onTrack = (event) {
          print("onAddStream--------------unified-plan--------------");
          if (event.track.kind == 'video') {
            videoRenderer.srcObject = event.streams[0];
            change.value = !change.value;
          }
        };
        break;
    }

    /// 监听候选链接成功 ==》 向接口添加
    pc.onIceCandidate = (candidate) async {
      if (candidate == null) {
        var desc = await pc.getLocalDescription();
        if (desc != null) {
          _addIceCandidate(candidate);
        }
        return;
      }
    };
    pc.onIceConnectionState = (state) {
      print("onIceConnectionState$state");
    };

    pc.onRemoveStream = (stream) {
      print("onRemoveStream");
    };

    pc.onDataChannel = (channel) {
      print("onDateChannel");
    };
    newSession.pc = pc;
    return newSession;
  }

  getIceCandidate() {
    net.get("$serverUrl/api/getIceCandidate?peerid=$peerId").then((value) {
      print(jsonDecode(value.toString()));
      var result = JsonConvert.fromJsonAsT<List<CandisEntity>>(
          jsonDecode(value.toString()));

      result.forEach((element) {
        RTCIceCandidate candidate = new RTCIceCandidate(
            element.candidate, element.sdpMid, element.sdpMLineIndex);

        ///添加candidate ；
        pc.addCandidate(candidate).then((value) {
          print('oK addCandidate');
        });
      });
    });
  }

  onReceiveCandidate() {}

  //only fetch Add
  _addIceCandidate(RTCIceCandidate candidate) {
    net
        .post(
          "$serverUrl/api/addIceCandidate?peerid=$peerId",
          data: candidate.toMap(),
          options: Options(contentType: Headers.jsonContentType),
        )
        .then((value) {});
  }
}
