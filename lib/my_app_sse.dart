import 'package:flutter/material.dart';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:live_chat_app/app_text_button.dart';
import 'package:live_chat_app/dio_helper.dart';

class MyAppSse extends StatefulWidget {
  const MyAppSse({super.key});

  @override
  State<MyAppSse> createState() => _MyAppSseState();
}

class _MyAppSseState extends State<MyAppSse> {
  String data = '0';
  @override
  void initState() {
    super.initState();
    // getData();
  }

  // void getData() async {
  //   await DioHelper.getData(
  //       url: 'https://backend.odjust.com/api/online',
  //       headers: {
  //         'content-type': 'text/event-stream',
  //       }).then((value) {
  //     setState(() {
  //       data = value.data.toString();
  //     });
  //   });
  // }

  void getData() {
    SSEClient.subscribeToSSE(
      method: SSERequestType.GET,
      url: 'https://backend.odjust.com/api/online',
      header: {
        'Accept': 'text/event-stream',
      },
    ).listen((event) {
      setState(() {
        data = event.data ?? 'No data';
      });
    }, onError: (error) {
      // Handle errors
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(data, style: const TextStyle(fontSize: 30)),
          ),
          AppTextButton(
            buttonText: 'Submit',
            buttonType: ButtonType.text,
            onPressed: () {},
          ),
          const SizedBox(height: 10),
          AppTextButton(
            buttonType: ButtonType.elevated,
            buttonText: 'Download',
            icon: const Icon(Icons.download),
            iconSpacing: 12,
            onPressed: () {},
            isLoading: false,
          ),
          const SizedBox(height: 10),
          AppTextButton(
            buttonType: ButtonType.outlined,
            height: 50,
            gradient: const LinearGradient(colors: [Colors.blue, Colors.green]),
            borderColor: Colors.transparent,
            buttonText: 'Gradient Button',
            onPressed: () {},
          ),
          const SizedBox(height: 10),
          AppTextButton(
            backgroundColor: Colors.amber,
            disabledBackgroundColor: Colors.white,
            enableBorder: true,
            hoverColor: Colors.red,
            buttonText: 'Hover Button',
            elevation: 10,
            enableFeedback: true,
            highlightElevation: 40,
            height: 50,
            splashFactory: InkRipple.splashFactory,
            buttonType: ButtonType.outlined,
            // child: const Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Icon(
            //       Icons.payment,
            //       color: Colors.white,
            //     ),
            //     SizedBox(width: 8),
            //     Text(
            //       'Custom Payment Button',
            //       style: TextStyle(color: Colors.white),
            //     ),
            //   ],
            // ),
            onPressed: () {},
          )
        ],
      ),
    );
  }
}
