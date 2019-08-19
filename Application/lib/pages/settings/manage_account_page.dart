import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:gps_tracer/network/network_utils.dart';
import 'package:gps_tracer/utils/colors.dart';
import 'package:gps_tracer/store/file_manager.dart' as file_manager;
import 'package:gps_tracer/utils/alert_box.dart' as alert_box;
import 'dart:convert';

/// A DevButton is a setting button with a leading icon and a trailing cheveron
/// that redirects the user onto a new page via the function ```onTap```.


/// Simple button that perform a one shot action via the function [onTap]
class NormalButton extends StatelessWidget {
  final String _title;
  final GestureTapCallback _onTap;
  final Icon _icon;
  final String _subtitle;

  NormalButton(this._title, this._onTap, this._subtitle, this._icon);

  @override
  Widget build(BuildContext context) {
    return new Container(
        decoration: new BoxDecoration(color: Colors.white),
        child: new Column(
          children: <Widget>[
            new ListTile(
              leading: _icon, // Icon(Icons.info_outline)
              title: Text('$_title'),
              subtitle: _subtitle != null
                  ? new Text(_subtitle)
                  : null, // _parameterValue == 0 ? const Text("This is a subtitle") : null,
              onTap: _onTap,
            ),
            new Divider(
              height: 0.0,
            ),
          ],
        ));
  }
}

/// A page to manage account informations
class AccountManagementPage extends StatefulWidget {

  final VoidCallback onAccountDeletion;
  AccountManagementPage(this.onAccountDeletion);


  @override
  State createState() => new ManageAccountPageState();

}

class ManageAccountPageState extends State<AccountManagementPage> {
  static var values = {"Localization": true, "Mobile data": false};

  Future<bool> _cleanDataOnDevice() async {
    print("Deleting files");
    bool coordDestroyed; bool trajDestroyed; bool geofenceDestroyed;
    coordDestroyed = await file_manager.CoordinatesStorageSingleton.getInstance().clean();
    trajDestroyed = await file_manager.PoolTrajectoriesStorageSingleton.getInstance().clean();
    geofenceDestroyed = await file_manager.GeofenceStorageSingleton.getInstance().clean();
    return coordDestroyed && trajDestroyed && geofenceDestroyed;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            backgroundColor: covoitULiegeColor,
            title: new Center(
                child: new Text("Account management",
                    style: new TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)))),
        body:
        new ListView(
            padding: new EdgeInsets.symmetric(vertical: 5.0),
            children: <Widget>[
              new NormalButton(
                  "Consult remote data",
                      () {
                        NetworkUtilsSingleton.getInstance().downloadUserData().then((ServerReply reply){
                          if (reply.isSuccess()){
                            alert_box.showScrollableDialogBox(context, "Data stored on server", reply.content);
                          }
                          else{
                            print("[Download remote data] Failed: server replied:\n\n${reply.content}");
                            alert_box.showDialogBox(context, "Error downloading remote data", "Please try again or later. If problem persists, contact the administrator.");
                          }

                        });
                  },
                  null,
                  new Icon(Icons.cloud_download)
              ),
              new NormalButton(
                  "Delete local data",
                      () {
                    void _onAccept(){_cleanDataOnDevice();}
                    alert_box.ConfirmAlertBox(context, "Deleting files", "Are you sure ?", _onAccept);
                  },
                  null,
                  new Icon(Icons.delete)
              ),
              new NormalButton(
                  "Delete my account",
                      () {
                        void _onAccept() async {
                          ServerReply reply = await NetworkUtilsSingleton.getInstance().deleteAccount();
                          if (reply.isSuccess())
                            widget.onAccountDeletion();
                          else{
                            print("[Delete account] Failed: server replied:\n\n${reply.content}");
                            alert_box.showDialogBox(context, "Error deleting your account", "Please try again or later. If problem persists, contact the administrator.");
                          }

                        }
                        alert_box.ConfirmAlertBox(context, "Deleting account", "Are you sure ? You will loose all your data", _onAccept);
                        //alert_box.showDialogBox(context, "Oups ...", "This feature is not yet implemented");
                  },
                  null,
                  new Icon(Icons.delete)
              ),
              new NormalButton(
                  "Delete server data",
                      () {
                        void _onAccept() async {
                          ServerReply reply = await NetworkUtilsSingleton.getInstance().deleteRemoteData();
                          if (!reply.isSuccess()) {
                            print(
                                "[Delete remote habits] Failed: server replied:\n\n${reply
                                    .content}");
                            alert_box.showDialogBox(
                                context, "Error deleting account",
                                "Please try again or later. If problem persists, contact the administrator");
                          }
                        }
                        alert_box.ConfirmAlertBox(context, "Deleting files", "Are you sure ?", _onAccept);
                  },
                  null,
                  new Icon(Icons.delete)
              ),
            ]));
  }
}