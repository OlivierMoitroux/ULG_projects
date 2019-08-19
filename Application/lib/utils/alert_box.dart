import 'package:flutter/material.dart';
import 'package:gps_tracer/utils/colors.dart';

/// Launch a custom dialog box (alert box)
void showDialogBox(BuildContext context, String title, String content) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: title == null
            ? new Text("")
            : new Text(title),
        content: content == null
            ? new Text("Please try again")
            : new Text(content),
        actions: <Widget>[
          // buttons at the bottom of the dialog
          new FlatButton(
            child: new Text("Close",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: covoitULiegeColor)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

/// Launch a custom dialog box with content in a scroll view
void showScrollableDialogBox(BuildContext context, String title, String content) {
  showDialog(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: title == null ? new Text("") : new Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(content),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Close', style: TextStyle(
      fontWeight: FontWeight.bold, color: covoitULiegeColor)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

/// An alert box with call back to perform action only if accept is pressed.<br>
/// We use a stateful widget so that we can call void showDialog() while being
/// able to detect which button is pressed thanks to callbacks.
/// This way, we can provide a function (callback) that change bool in the caller
class ConfirmAlertBox extends StatefulWidget {

  VoidCallback onAccept;
  BuildContext parentContext;
  ConfirmAlertBox(BuildContext parentContext, String title, String content, VoidCallback onAccept){
    this.onAccept = onAccept;
    this.parentContext = parentContext;
    ConfirmAlertBoxState.showDialogBox(parentContext, title, content, onAccept);
  }

  @override
  ConfirmAlertBoxState createState() => ConfirmAlertBoxState();
}

class ConfirmAlertBoxState extends State<ConfirmAlertBox> {
  /// Static so that we don't care of the instance of ConfirmAlertBoxState
  static void showDialogBox(BuildContext context, String title, String content, VoidCallback onAccept) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: title == null
              ? new Text("")
              : new Text(title),
          content: content == null
              ? new Text("Are you sure ?")
              : new Text(content),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: covoitULiegeColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("Accept",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: covoitULiegeColor)),
              onPressed: () {
                onAccept();
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  // Required to override but we don't care
  @override
  Widget build(BuildContext context) {
    return Container(
    );
  }
}
