import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class MyVideoView extends StatelessWidget {
  MyVideoView(
    this._renderer, {
    Key key,
    this.objectFit = RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
    this.mirror = false,
    this.fullScreen = false,
    this.filterQuality = FilterQuality.low,
  })  : assert(objectFit != null),
        assert(mirror != null),
        assert(filterQuality != null),
        super(key: key);

  final RTCVideoRenderer _renderer;
  final RTCVideoViewObjectFit objectFit;
  final bool mirror;
  final FilterQuality filterQuality;
  final fullScreen;

  RTCVideoRendererNative get videoRenderer =>
      _renderer.delegate as RTCVideoRendererNative;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) =>
            _buildVideoView(constraints));
  }

  Widget _buildVideoView(BoxConstraints constraints) {
    return Center(
      child: Container(
        color: Color(0x88000000),
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: FittedBox(
          fit: objectFit == RTCVideoViewObjectFit.RTCVideoViewObjectFitContain
              ? BoxFit.contain
              : BoxFit.cover,
          child: Center(
            child: ValueListenableBuilder<RTCVideoValue>(
              valueListenable: videoRenderer,
              builder:
                  (BuildContext context, RTCVideoValue value, Widget child) {
                double width = constraints.maxHeight * value.aspectRatio;
                double height = constraints.maxHeight;

                print("valueRatio");
                print(value.aspectRatio);

                return SizedBox(
                  width: width,
                  height: height,
                  child: fullScreen
                      ? Transform.rotate(
                          angle: pi / 2,
                          child: Transform.scale(
                            scale: value.aspectRatio,
                            child: child,
                          ),
                        )
                      : child,
                );
              },
              child: videoRenderer.textureId != null &&
                      videoRenderer.srcObject != null
                  ? Texture(
                      textureId: videoRenderer.textureId,
                      filterQuality: filterQuality,
                    )
                  : Container(),
            ),
          ),
        ),
      ),
    );
  }
}
