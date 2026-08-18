#!/bin/bash
for v in 1.4.1 1.4.0 1.3.0 1.2.1 1.2.0 1.1.0 1.0.0; do
  echo "Checking $v"
  flutter pub add flutter_webrtc:$v >/dev/null 2>&1
  cat ~/.pub-cache/hosted/pub.dev/flutter_webrtc-*/ios/flutter_webrtc.podspec | grep WebRTC-SDK
done
