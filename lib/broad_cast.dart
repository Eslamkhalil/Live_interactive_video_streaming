import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_rtm/agora_rtm.dart';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

const appId =
    "50b4f9c09089446891d912d2b2ed672b"; // Replace with your Agora App ID
const token =
    "007eJxTYJi+U9H/0y6j9dxchkl7zrhI35v+JSg+aXPlTP0lR/Ul1z9VYDA1SDJJs0w2sDSwsDQxMbOwNEyxNDRKMUoySk0xMzdKEracm94QyMiwS7+GmZEBAkF8Zobc/HwGBgDvvx27"; // Replace with your Agora Token
const channelName = "moo";

class BroadcastPage extends StatefulWidget {
  // final String channelName;
  // final String appId;

  const BroadcastPage({
    super.key,
  });

  @override
  BroadcastPageState createState() => BroadcastPageState();
}

class BroadcastPageState extends State<BroadcastPage> {
  late final RtcEngine _agoraEngine;

  bool isBroadcasting = false;
  List<int> remoteUids = [];

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    await [Permission.camera, Permission.microphone].request();
    _agoraEngine = createAgoraRtcEngine();
    await _agoraEngine.initialize(const RtcEngineContext(appId: appId));

    await _agoraEngine
        .setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);

    await _agoraEngine.setClientRole(
        role: ClientRoleType.clientRoleBroadcaster);

    await _agoraEngine.enableVideo();

    _agoraEngine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        setState(() {
          isBroadcasting = true;
        });
      },
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        print("User joined: $remoteUid");
        setState(() {
          remoteUids.add(remoteUid);
        });
      },
      onUserOffline: (RtcConnection connection, int remoteUid,
          UserOfflineReasonType reason) {
        print("User offline: $remoteUid");
        setState(() {
          remoteUids.remove(remoteUid);
        });
      },
    ));
  }

  Future<void> _changeUserRole(int uid, ClientRoleType role) async {
    // يمكنك إرسال رسالة إلى المستخدم لتغيير دوره
    // أو استخدام RTM SDK للتحكم في الأدوار
    await _agoraEngine.setClientRole(role: role);
  }

  @override
  void dispose() {
    _agoraEngine.leaveChannel();
    _agoraEngine.release();
    super.dispose();
  }

  Future<void> _startBroadcast() async {
    await _agoraEngine.joinChannel(
      token: token, // Use a token if you have token authentication enabled
      channelId: channelName,
      uid: 0, // Use 0 for automatic uid assignment
      options: const ChannelMediaOptions(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Broadcast')),
      body: Center(
        child: Column(
          children: [
            if (isBroadcasting)
              SizedBox(
                height: 600,
                child: AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: _agoraEngine,
                    canvas: const VideoCanvas(
                        uid: 0, view: 2), // UID 0 for local video
                  ),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isBroadcasting ? null : _startBroadcast,
              child: const Text('Start Broadcast'),
            ),
          ],
        ),
      ),
    );
  }
}
