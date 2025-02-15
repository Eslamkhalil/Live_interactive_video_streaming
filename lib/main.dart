import 'package:flutter/material.dart';
import 'package:live_chat_app/broad_cast.dart';
import 'package:live_chat_app/dio_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DioHelper.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    // return const MaterialApp(
    //   home: BiometricAuth(),
    // );
    return const MaterialApp(
      home: BroadcastPage(),
      // home: Scaffold(
      //   appBar: AppBar(
      //     title: const Text('Agora Video Call'),
      //   ),
      //   body: Stack(
      //     children: [
      //       Center(
      //         child: _remoteVideo(),
      //       ),
      //       Align(
      //         alignment: Alignment.topLeft,
      //         child: SizedBox(
      //           width: 100,
      //           height: 150,
      //           child: Center(
      //             child: _localUserJoined
      //                 ? AgoraVideoView(
      //                     controller: VideoViewController(
      //                       rtcEngine: _engine,
      //                       canvas: const VideoCanvas(uid: 0),
      //                     ),
      //                   )
      //                 : const CircularProgressIndicator(),
      //           ),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}
