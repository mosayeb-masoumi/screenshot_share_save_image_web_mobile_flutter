import 'package:flutter/material.dart';

import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

class Example2Screen extends StatefulWidget {
  const Example2Screen({super.key});

  @override
  State<Example2Screen> createState() => _Example2ScreenState();
}

class _Example2ScreenState extends State<Example2Screen> {

  final GlobalKey key = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Screenshot Demo'),
        ),
        body: Center(
          child: Container(
            width: 400,
            height: 400,
            color: Colors.amberAccent.shade100,
            child: Center(
              child: Stack(
                children: [
                  RepaintBoundary(
                    key: key,
                    child: Container(
                      width: 200,
                      height: 200,
                      color: Colors.red,
                      child: Center(child: Text("this is screen shot"),),
                    ),
                  ),

                  Container(
                    width: 200,
                    height: 200,
                    color: Colors.green,
                    child: Center(child: Text("hello"),),
                  ),
                ],
              ),
            ),
          )
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Uint8List? screenshot = await captureWidgetAsPng(key);
            if (screenshot != null) {
              _onShareScreenShot(screenshot);
            }
          },
          child: const Icon(Icons.camera),
        ),
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

  void _onShareScreenShot(Uint8List screenshot) async {
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

