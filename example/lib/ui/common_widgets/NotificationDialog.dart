import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_linux_plugin_example/ui/common_widgets/Buttons.dart';
import 'package:new_linux_plugin_example/utils/ColorConstant.dart';

showLoading(BuildContext context){
  return showDialog(
    // The user CANNOT close this dialog  by pressing outsite it
      barrierDismissible: false,
      context: context,
      builder: (_) {
        return Dialog(
          // The background color
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                // The loading indicator
                CircularProgressIndicator(
                  color: AppColors.red,
                ),
                SizedBox(
                  height: 15,
                ),
                // Some text
                Text('Loading...')
              ],
            ),
          ),
        );
      });
}

showWarningDialog(String message, BuildContext context,
    [Function? onConfirm, String textConfirm = "OK"]) {
    return showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      content: Text(message, style: TextStyle(fontSize: 14)),
      actions: [
        CupertinoDialogAction(
            child: Text(textConfirm),
            onPressed: () {
              Navigator.pop(context);
              if (onConfirm != null) {
                onConfirm();
              }
            }),
      ],
    ),
  );
}

showConfirmDialog(
    String title, String content, Function? onConfirm, Function? onCancel, BuildContext context, String confirm, String cancel) {
  return showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
              child: Text(confirm),
              onPressed: () {
                Navigator.pop(context);
                if (onConfirm != null) {
                  onConfirm();
                }
              }),
          CupertinoDialogAction(
              child: Text(cancel),
              onPressed: () async {
                Navigator.pop(context);
                if (onCancel != null) {
                  onCancel();
                }
              })
        ],
      ));
}

showResultDialog(String title, String result, bool isValid, BuildContext context, Function? func) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: false,
          title: Text(title, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.black,fontWeight: FontWeight.bold,)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // <-- Radius
          ),
          content: Container(
            height: 160,
            width: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  isValid ? Icon(Icons.check_circle_rounded, color: AppColors.green, size: 50):
                            Icon(Icons.error_outline_rounded, color: AppColors.main_red, size: 50),
                  Text(result,
                    style: TextStyle(
                      color: isValid ? AppColors.green : AppColors.main_red,
                      fontSize: 20,
                    )),
                  Padding(padding: EdgeInsets.only(top: 20),
                    child: confirmButton("OK", (){
                      Navigator.pop(context);
                      if (func != null) {
                        func();
                      }
                    })
                  )
                ],
              )),
          ),
        );
      });
}