import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';

const appId = "50b4f9c09089446891d912d2b2ed672b";
const token = "007eJxTYDD9s3HP5cSsreu3/V91+80x3dwJzL/2tiUJ5iakCqVeWftYgcHUIMkkzTLZwNLAwtLExMzC0jDF0tAoxSjJKDXFzNwo6ejF/vSGQEYG3+5gZkYGCATxWRhKUotLGBgAOMMiGA==";
const channel = "test";



class MyApp2 extends StatefulWidget {
  const MyApp2({super.key});

  @override
  State<MyApp2> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp2> {
  late RtcEngine _engine;
  bool _isBroadcaster = false;
  bool _isMuted = false;
  bool _isCameraOff = false;
  int _likesCount = 0;
  List<String> _comments = [];
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();
    
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint('Joined channel successfully');
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("Remote user joined: $remoteUid");
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint("Remote user left: $remoteUid");
        },
      ),
    );

    await _engine.enableVideo();
    await _engine.startPreview();
  }

  Future<void> _toggleRole() async {
    setState(() {
      _isBroadcaster = !_isBroadcaster;
    });

    await _engine.setClientRole(
      role: _isBroadcaster 
          ? ClientRoleType.clientRoleBroadcaster 
          : ClientRoleType.clientRoleAudience,
    );

    if (_isBroadcaster) {
      await _engine.joinChannel(
        token: token,
        channelId: channel,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
        ),
        uid: 0,
      );
    } else {
      await _engine.leaveChannel();
    }
  }

  Widget _buildControlPanel() {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Like Button
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () => setState(() => _likesCount++),
                  ),
                  Text('$_likesCount', style: const TextStyle(color: Colors.white)),
                ],
              ),
              
              // Comment Input
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Add comment...',
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        if (_commentController.text.isNotEmpty) {
                          setState(() {
                            _comments.add(_commentController.text);
                            _commentController.clear();
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
              
              // Gift Button
              IconButton(
                icon: const Icon(Icons.card_giftcard, color: Colors.yellow),
                onPressed: () => _showGiftDialog(),
              ),
            ],
          ),
          
          // Comments Display
          SizedBox(
            height: 100,
            child: ListView.builder(
              itemCount: _comments.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(
                  _comments[index],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showGiftDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Gift'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildGiftItem('🎁', 'Basic Gift'),
            _buildGiftItem('💎', 'Diamond'),
            _buildGiftItem('🚀', 'Rocket'),
          ],
        ),
      ),
    );
  }

  Widget _buildGiftItem(String emoji, String name) {
    return ListTile(
      leading: Text(emoji, style: const TextStyle(fontSize: 24)),
      title: Text(name),
      onTap: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Live Stream'),
          actions: [
            IconButton(
              icon: Icon(_isBroadcaster ? Icons.stop : Icons.live_tv),
              onPressed: _toggleRole,
            ),
          ],
        ),
        body: Stack(
          children: [
            // Main Video View
            _isBroadcaster
                ? AgoraVideoView(
                    controller: VideoViewController(
                      rtcEngine: _engine,
                      canvas: const VideoCanvas(uid: 0),
                    ),
                  )
                : Center(
                    child: AgoraVideoView(
                      controller: VideoViewController.remote(
                        rtcEngine: _engine,
                        canvas: const VideoCanvas(uid: 1),
                        connection: const RtcConnection(channelId: channel),
                      ),
                    ),
                  ),

            // Broadcast Controls
            if (_isBroadcaster)
              Positioned(
                top: 40,
                right: 20,
                child: Column(
                  children: [
                    IconButton(
                      icon: Icon(_isCameraOff ? Icons.videocam_off : Icons.videocam),
                      color: Colors.white,
                      onPressed: () async {
                        await _engine.muteLocalVideoStream(!_isCameraOff);
                        setState(() => _isCameraOff = !_isCameraOff);
                      },
                    ),
                    IconButton(
                      icon: Icon(_isMuted ? Icons.mic_off : Icons.mic),
                      color: Colors.white,
                      onPressed: () async {
                        await _engine.muteLocalAudioStream(!_isMuted);
                        setState(() => _isMuted = !_isMuted);
                      },
                    ),
                  ],
                ),
              ),

            // Control Panel
            _buildControlPanel(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }
}