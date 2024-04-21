import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dio/dio.dart';
import 'dart:ui' as ui;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_downloader_web/image_downloader_web.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey key = GlobalKey();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("share screen"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [


          Expanded(
            child: Center(
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
          ),
          ShareButton(onClick: (value) async {
            if (value == "txt") {
              //share text
              _onShareText(context, "gsjgdfjakshg");
            } else if (value == "imageAssets") {
              //share image from asset
              _onShareXFileFromAssets(context);
            } else if (value == "imageScreenShot") {
              Uint8List? screenshot = await captureWidgetAsPng(key);
              if (screenshot != null) {
                _onShareScreenShot(screenshot);
              }
            } else if (value == "saveUrl") {
              // save imageUrl to gallery
              _onSaveImageUrlToGalleryWeb();
            } else if (value == "savePng") {
              // save captured screenShot imagePng to gallery

              Uint8List? screenshot = await captureWidgetAsPng(key);
              if (screenshot != null) {
                _onSaveImageScreenShotToGalleryWeb(screenshot);
              }
            }
          })
        ],
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

  Future<void> _onShareText(BuildContext context, String text) async {
    final box = context.findRenderObject() as RenderBox?;
    await Share.share(
      text,
      subject: "bill",
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  void _onShareXFileFromAssets(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    final data = await rootBundle.load('assets/images/image1.jpg');
    final buffer = data.buffer;
    await Share.shareXFiles(
      [
        XFile.fromData(
          buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
          name: 'bill.png',
          mimeType: 'image/png',
        ),
      ],
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
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

  Future<void> _onSaveImageUrlToGalleryWeb() async {
    String imageUrl =
        "https://ss0.baidu.com/94o3dSag_xI4khGko9WTAnF6hhy/image/h%3D300/sign=a62e824376d98d1069d40a31113eb807/838ba61ea8d3fd1fc9c7b6853a4e251f94ca5f46.jpg";

    if (kIsWeb) {
      await WebImageDownloader.downloadImageFromWeb(imageUrl);
    } else {
      var response = await Dio()
          .get(imageUrl, options: Options(responseType: ResponseType.bytes));
      final result = await ImageGallerySaver.saveImage(
          Uint8List.fromList(response.data),
          quality: 60,
          name: "hello");
      var ss = result;
    }
  }

  Future<void> _onSaveImageScreenShotToGalleryWeb(Uint8List screenshot) async {
    if (kIsWeb) {
      await WebImageDownloader.downloadImageFromUInt8List(
          uInt8List: screenshot, name: "name");
    } else {
      await ImageGallerySaver.saveImage(screenshot, name: "1402/09/02");
    }
  }
}

class ShareButton extends StatefulWidget {
  final Function onClick;

  const ShareButton({super.key, required this.onClick});

  @override
  State<ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends State<ShareButton> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(

      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(25),
      ),
      color: Colors.white,
      tooltip: "",
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem(
          value: 'txt',
          child: Text('share text'),
        ),
        const PopupMenuItem(
          value: 'imageScreenShot',
          child: Text('Share image ScreenShot'),
        ),
        const PopupMenuItem(
          value: 'savePng',
          child: Text('Save image screenShot png'),
        ),
        const PopupMenuItem(
          value: 'imageAssets',
          child: Text('Share image Assets'),
        ),
        const PopupMenuItem(
          value: 'saveUrl',
          child: Text('Save image url'),
        ),
      ],
      onSelected: (value) async {
        widget.onClick(value);
        // Handle item selection here
        print('Selected: $value');
      },
      child: Container(
        width: 100,
        height: 50,
        color: Colors.green,
        child: const Center(
          child: Text("Share"),
        ),
      ),

      // offset: const Offset(0, -100),
    );
  }
}
