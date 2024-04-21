

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_io/io.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_downloader_web/image_downloader_web.dart';
import 'package:flutter_svg/svg.dart';
import 'package:universal_html/html.dart' as html;
import 'package:device_info/device_info.dart';



// used
// ShareButtonComponent(
// context: context,
// screenShotKey: screenShotKey,
// shareTextValue: shareTextValue),
// ),


class ShareButtonComponent extends StatefulWidget {
  final BuildContext context;
  final GlobalKey screenShotKey;
  final String shareTextValue;

  const ShareButtonComponent(
      {super.key,
      required this.context,
      required this.screenShotKey,
      required this.shareTextValue});

  @override
  State<ShareButtonComponent> createState() => _ShareButtonComponentState();
}

class _ShareButtonComponentState extends State<ShareButtonComponent> {
  // late LanguageStore? _languageStore = null;
  //
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   _languageStore = Provider.of<LanguageStore>(context);
  // }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {


    return PopupMenuButton(
      color: Colors.white,
      position: PopupMenuPosition.over,
      tooltip: "",
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      itemBuilder: (BuildContext context) =>
          [
        PopupMenuItem(
          value: 'txt',
          child: buildMenuItemText(
              AppLocalizations.of(context).translate("share_text")),
        ),
        PopupMenuItem(
          value: 'shareImage',
          child: buildMenuItemText(
              AppLocalizations.of(context).translate("share_image")),
        ),
        PopupMenuItem(
          value: 'saveImage',
          child: buildMenuItemText(
              AppLocalizations.of(context).translate("save_image")),
        ),
      ],
      onSelected: (value) async {
        switch (value) {
          case "shareImage":
            Uint8List? screenshot =
                await captureWidgetAsPng(widget.screenShotKey);

            if (screenshot != null) {
              if (Platform.isWindows) {
                _shareImageScreenShotWeb(screenshot);
              } else {
                _shareImageScreenShot(screenshot);
              }
            }
            break;
          case "saveImage":
            Uint8List? screenshot =
                await captureWidgetAsPng(widget.screenShotKey);
            if (screenshot != null) {
              if (kIsWeb) {
                _saveImageScreenShot(screenshot);
              } else if (Platform.isAndroid) {
                DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
                int androidApiVersion = androidInfo.version.sdkInt;

                if (androidApiVersion >= 33) {
                  PermissionStatus status = await Permission.photos.status;
                  _saveImageScreenShot(screenshot);

                  // if (status.isGranted) {
                  //   _saveImageScreenShot(screenshot);
                  // } else if (status.isPermanentlyDenied) {
                  //   await openAppSettings();
                  // } else {
                  //   await Permission.photos.request();
                  //   PermissionStatus status = await Permission.photos.status;
                  //   if (status.isGranted) {
                  //     _saveImageScreenShot(screenshot);
                  //   } else {
                  //     await openAppSettings();
                  //   }
                  // }
                } else {
                  var storageStatus = await Permission.storage.status;
                  if (storageStatus.isGranted) {
                    _saveImageScreenShot(screenshot);
                  } else if (storageStatus.isPermanentlyDenied) {
                    await openAppSettings();
                  } else {
                    await Permission.storage.request();
                    PermissionStatus status = await Permission.storage.status;
                    if (status.isGranted) {
                      _saveImageScreenShot(screenshot);
                    } else {
                      await openAppSettings();
                    }
                  }
                }
              } else {
                _saveImageScreenShot(screenshot);
              }
            }
            break;

          default:
            _shareText(
                widget.context,
                widget.shareTextValue
                    .toString()
                    .changeDigitByLanguage(_languageStore!),
                "pageName");
            break;
        }
        // Handle item selection here
      },
      child: Container(
        height:  40,
        decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(16.0)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
                  buildShareSvgPicture(context),
                  SizedBox(
                    width:  5,
                  ),
                  buildShareText(context)
                ],
        ),
      ),
      offset: const Offset(0, -160),
    );
  }

  Widget buildMenuItemText(String title) {
    return Text(
      title,
      style: CustomTextStyle.mnm_Custom_Font14m(
          context, AppColors.materialPrimaryColor(), null, TextDecoration.none),
    );
  }

  Widget buildShareText(BuildContext context) {
    return Text(
      AppLocalizations.of(context).translate("share"),
    );
  }

  Widget buildShareSvgPicture(BuildContext context) {
    return SvgPicture.asset(Assets.share,
        width: 16,
        height:16,
        color: Colors.black);
  }

  // this method will share captured screenShot
  void _shareImageScreenShot(Uint8List screenshot) async {
    final box = context.findRenderObject() as RenderBox?;

    DateTime now = DateTime.now();
    PersianDate persianDate = PersianDate();
    String title =
        "${persianDate.toJalali(now.year, now.month, now.day)}-${now.hour}:${now.minute}:${now.second}";

    // android IOS0
    await Share.shareXFiles(
      [
        XFile.fromData(
          screenshot,
          name: '$title.png',
          mimeType: 'image/png',
        ),
      ],
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  void _shareImageScreenShotWeb(Uint8List screenshot) async {
    var file = [
      html.File([screenshot], "imagename.jpg", {"type": "image/jpeg"})
    ];
    var data = {"title": "Baran", "text": "Baran", "files": file};
    shareScreenShotWeb(data);
  }

  void shareScreenShotWeb(Map<String, Object> data) async {
    try {
      await html.window.navigator.share(
          data); // IMPORTANT  navigator.share will only work on websites with https and not HTTP
    } catch (e) {
      print(e);
    }
  }

  //this method take a screenShot from specified boundary area
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
      return null;
    }
  }

  // this method will save captured screenShot in galley folder(while using mobile phone) or save if download folder(while using web)
  Future<void> _saveImageScreenShot(Uint8List screenshot) async {
    DateTime now = DateTime.now();
    PersianDate persianDate = PersianDate();
    // String title = "${persianDate.toJalali(now.year, now.month, now.day)}-${now.hour}:${now.minute}:${now.second}";

    String date = persianDate.toJalali(now.year, now.month, now.day);
    String title = date.replaceAll('/', '') +
        "_" +
        "${now.hour}${now.minute}${now.second}";

    if (kIsWeb) {
      loading("start");
      try {
        await WebImageDownloader.downloadImageFromUInt8List(
            uInt8List: screenshot, name: title);
      } catch (e) {
        e.toString();
      }

      loading("stop");
    } else {
      var resultMap = await ImageGallerySaver.saveImage(
        screenshot,
        name: title,
      );

      if (resultMap['isSuccess'] == true) {
        Flushbar(
          message: AppLocalizations.of(context)
              .translate('image_saved_successfully'),
          animationDuration: Duration(milliseconds: 600),
          duration: Duration(seconds: 2),
        )..show(context);
      }
    }
  }

  // this method will share the result text
  Future<void> _shareText(
      BuildContext context, String text, String pageName) async {
    final box = context.findRenderObject() as RenderBox?;
    await Share.share(
      text,
      subject: pageName,
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }
}
