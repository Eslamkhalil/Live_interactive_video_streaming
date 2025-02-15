import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:live_chat_app/broad_cast.dart';


class AudiencePage extends StatefulWidget {
  final String channelName;
  final String appId;

  const AudiencePage(
      {super.key, required this.channelName, required this.appId});

  @override
  AudiencePageState createState() => AudiencePageState();
}

class AudiencePageState extends State<AudiencePage> {
  late final RtcEngine _agoraEngine;
  bool isJoined = false;
  int? _remoteUid; // UID of the remote broadcaster

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    _agoraEngine = createAgoraRtcEngine();
    await _agoraEngine.initialize(RtcEngineContext(appId: widget.appId));

    // Set the channel profile to live broadcasting
    await _agoraEngine
        .setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);

    // Set the client role to audience
    await _agoraEngine.setClientRole(role: ClientRoleType.clientRoleAudience);

    // Enable video
    await _agoraEngine.enableVideo();

    // Set up event handlers
    _agoraEngine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        setState(() {
          isJoined = true;
        });
      },
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        setState(() {
          _remoteUid = remoteUid;
        
        });
      },
      onUserOffline: (RtcConnection connection, int remoteUid,
          UserOfflineReasonType reason) {
        setState(() {
          _remoteUid = null;
        });
      },
    ));


    
  }

  @override
  void dispose() {
    _agoraEngine.leaveChannel();
    _agoraEngine.release();
    super.dispose();
  }

  Future<void> _joinChannel() async {
    await _agoraEngine.joinChannel(
      token: token, // Use a token if you have token authentication enabled
      channelId: widget.channelName,
      uid: 0, // Use 0 for automatic uid assignment
      options: const ChannelMediaOptions(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audience')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_remoteUid != null)
              SizedBox(
                height: 600,
                child: AgoraVideoView(
                  controller: VideoViewController.remote(
                    rtcEngine: _agoraEngine,
                    canvas: VideoCanvas(uid: _remoteUid),
                    connection: RtcConnection(channelId: widget.channelName,),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isJoined ? null : _joinChannel,
              child: const Text('Join Channel'),
            ),
          ],
        ),
      ),
    );
  }
}
