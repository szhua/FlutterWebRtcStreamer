import 'package:flutter_webrtc_demo/src/call_sample/candis_entity.dart';

candisEntityFromJson(CandisEntity data, Map<String, dynamic> json) {
  if (json['candidate'] != null) {
    data.candidate = json['candidate'].toString();
  }
  if (json['sdpMLineIndex'] != null) {
    data.sdpMLineIndex = json['sdpMLineIndex'] is String
        ? int.tryParse(json['sdpMLineIndex'])
        : json['sdpMLineIndex'].toInt();
  }
  if (json['sdpMid'] != null) {
    data.sdpMid = json['sdpMid'].toString();
  }
  return data;
}

Map<String, dynamic> candisEntityToJson(CandisEntity entity) {
  final Map<String, dynamic> data = new Map<String, dynamic>();
  data['candidate'] = entity.candidate;
  data['sdpMLineIndex'] = entity.sdpMLineIndex;
  data['sdpMid'] = entity.sdpMid;
  return data;
}
