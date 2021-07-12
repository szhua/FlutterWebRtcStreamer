import 'package:flutter_webrtc_demo/generated/json/base/json_convert_content.dart';

class CandisEntity with JsonConvert<CandisEntity> {
  String candidate;
  int sdpMLineIndex;
  String sdpMid;
}
