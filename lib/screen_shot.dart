
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

import 'package:share_plus/share_plus.dart';

import 'package:flutter/services.dart';
class ScreenShot extends StatefulWidget {
  const ScreenShot({super.key});

  @override
  State<ScreenShot> createState() => _ScreenShotState();
}

class _ScreenShotState extends State<ScreenShot> {
  GlobalKey key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Capture Screenshot')),
      body: Center(
        child: RepaintBoundary(
          key: key,
          child: Container(
            width: 200,
            height: 200,
            color: Colors.green,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Capture this!',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),

                  Text(
                    'Second Text!',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Uint8List? screenshot = await captureWidgetAsPng(key);
          // Use the captured screenshot (Uint8List) here as needed
          // For instance, save it to a file or send it over a network
          // or display it in an Image widget.
          if (screenshot != null) {
            // Example: Displaying the captured image in an Image widget
            // showDialog(
            //   context: context,
            //   builder: (BuildContext context) {
            //     return Dialog(
            //       child: Image.memory(screenshot),
            //     );
            //   },
            // );

            _onShareScreenShot(context ,screenshot );
          }
        },
        child: Icon(Icons.camera),
      ),
    );
  }



  Future<Uint8List?> captureWidgetAsPng(GlobalKey key) async {
    try {
      RenderRepaintBoundary boundary =
      key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List? pngBytes = byteData?.buffer.asUint8List();
      return pngBytes;
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }


  void _onShareScreenShot(BuildContext context, Uint8List screenshot) async {
    final box = context.findRenderObject() as RenderBox?;
    await Share.shareXFiles(
      [
        XFile.fromData(
          screenshot,
          name: 'bill.png',
          mimeType: 'image/png',
        ),
      ],
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }


}





