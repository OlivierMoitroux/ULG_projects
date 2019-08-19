
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:gps_tracer/store/secured_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:gps_tracer/models/login.dart';
import 'package:gps_tracer/models/register_data.dart';
import 'dart:async';
import 'dart:convert';
import 'package:connectivity/connectivity.dart';



/* ======================================================================= *
 *                      Connectivity to internet state
 * ======================================================================= */
/// Return "cellular", "wifi" or "none"
Future<String> getInternetCoMean() async {
  ConnectivityResult mean = await (Connectivity().checkConnectivity());
  if (mean == ConnectivityResult.mobile) {
    return "cellular";
  } else if (mean == ConnectivityResult.wifi) {
    return "wifi";
  } else{
    return "none";
  }
}

Future<bool> isCo2Internet() async {
  ConnectivityResult mean = await Connectivity().checkConnectivity();
  return (mean==ConnectivityResult.wifi)||(mean==ConnectivityResult.mobile);
}

/* ======================================================================= *
 *                          NetworkUtilsSingleton
 * ======================================================================= */

/// A singleton to access the network utility of this app
class NetworkUtilsSingleton {
  // Change instantiation here the day you want to use another server (Firebase, ...)
  static final BaseNetworkUtils _singleton = new MyNetworkUtils();

  NetworkUtilsSingleton();

  static BaseNetworkUtils getInstance() {
    return _singleton;
  }
}

/// Wrapper of the http.Response used in the app code. <br>
/// ```success``` is true/false upon success or not
/// ```content``` is the reply content of the server.
/// In case of error, it contains the error message, possibly filter or processed to be more human readable.
class ServerReply {
  bool success;
  String content;
  ServerReply(this.success, this.content);

  bool isSuccess() => success;
}


/* ======================================================================= *
 *                         BaseNetworkUtils
 * ======================================================================= */

/// Abstract class to define the methods a given server api needs to respect to communicate with this app
abstract class BaseNetworkUtils {

  // default timeout in seconds
  static int TIME_OUT = 10;

  /// Return user status (e.g. is token still valid ?)
  bool isLoggedIn();

  /// Sends logs of the app to ```email``` and launch web mail client of user.
  bool sendLogs(String email);

  /// Log in on server<br>
  /// @return <success, content> where content is the error string if an error
  ///         occured or the token given back by server if any
  Future<ServerReply> logIn(String username, String pswd);

  /// Create a user on server
  /// @return <success, content> where content is the error string if an error
  ///         occured or the token given back by server if any
  Future<ServerReply> createUser(String username, String pswd, String pswdConf, String email, String homeAddress, String homeZip, String homeCountry, String workAddress, String workZip, String workCountry, String work);

  /// Logout from server
  /// @return <success, content> where content is the error string if an error
  ///         occured, otherwise empty.
  Future<ServerReply> logout();

  /// Request new token
  /// @return <success, content> where content is the error string if an error
  ///         occured, or the token given back by server
  Future<ServerReply> getToken();

  /// Getter for account information (work address, ...)
  /// @return <success, content> where content is the error string if an error
  ///         occured, or the account data structure of this app filled.
  Future<ServerReply> getAccountData();

  /// Post trajectories in memory to server
  Future<ServerReply> sendTrajectories(String poolTrajectories);

  /// Delete the habits stored in the server database for this user
  /// @return <success, content> where content is the error string if an error
  ///         occured
  Future<ServerReply> deleteRemoteData();

  /// Ask server to get the configuration file for background location initialisation
  /// @return <success, content> where content is the error string if an error
  ///         occured, or the configuration JSON for initialisation
  Future<ServerReply> getInitConfig();

  /// Delete the account and its associated data on the server
  /// @return <success, content> where content is the error string if an error
  ///         occured
  Future<ServerReply> deleteAccount();

  /// Download the user data from server (account infos + habits)
  /// @return <success, content> where content is the error string if an error
  ///         occured, a raw json otherwise
  Future<ServerReply> downloadUserData();

  /// Ask the server to get the latest update of user travel habits
  /// @return <success, content> where content is the error string if an error
  ///         occured, a json of list of habits model string (JSON) otherwise
  Future<ServerReply> getHabits();

  // TODO: add here methods to send specific things.
}

/* ======================================================================= *
 *                          MyNetworkUtils
 * ======================================================================= */

/// An implementation of the BaseNetworkUtils with the [keep calm and stay polite here] CentOs machine provided by the University.
class MyNetworkUtils implements BaseNetworkUtils{

  bool verbose = true;
  bool useHTTPS = true;
  String portNo;

  MyNetworkUtils(){
    BaseNetworkUtils.TIME_OUT = 10; // 5 seconds can be too few sometimes.
    portNo = (useHTTPS?"443":"80");
  }

  /*   ------------------------------------------------------------- *
   *                     Specific to this class
   *   ------------------------------------------------------------- */

  /// Generic method to postData
  /// Use current session stored on disk in header<br>
  ///
  ///   * @param ``jsonStrBody``,  body to send (json string),
  ///   * @param ``url`` url to send
  ///   * @param ``useSession`` Wether to send the current session in headers or not
  ///   * @return <status_code, body> where status_code is the one replied by server,
  ///         body its content
  Future<http.Response> _postData(String jsonStrBody, String url, bool useSession) async {
    http.Response response;

    String session = await SecuredStorageSingleton.getSession();

    if (useSession) {
      if (session == null) {
        print("[_postData] Error async: session not yet retrieve from memory !");
        return http.Response("User session does not exist", -1);
      }
      else {
        if (useHTTPS){
          response = await http.post(
              new Uri.https("spem3.montefiore.ulg.ac.be:" + portNo, url),
              headers: {
                "Content-Type": "application/json",
                "Authorization": session
              },
              body: jsonStrBody).timeout(
              new Duration(seconds: BaseNetworkUtils.TIME_OUT));
        }
        else{
          response = await http.post(
              new Uri.http("spem3.montefiore.ulg.ac.be:" + portNo, url),
              headers: {
                "Content-Type": "application/json",
                "Authorization": session
              },
              body: jsonStrBody).timeout(
              new Duration(seconds: BaseNetworkUtils.TIME_OUT));
        }
      }
    }
    else{
      if (useHTTPS){
        response = await http.post(
            new Uri.https("spem3.montefiore.ulg.ac.be:"+portNo, url),
            headers: {"Content-Type": "application/json"},
            body: jsonStrBody).timeout(new Duration(seconds: BaseNetworkUtils.TIME_OUT));
      }
      else{
        response = await http.post(
            new Uri.http("spem3.montefiore.ulg.ac.be:"+portNo, url),
            headers: {"Content-Type": "application/json"},
            body: jsonStrBody).timeout(new Duration(seconds: BaseNetworkUtils.TIME_OUT));
      }
    }
    if (verbose && response != null){
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
    }

    return response;
  }


  /// Generic method to getData
  /// Use current session stored on disk in header<br>
  ///
  ///   * @param ``jsonStrBody``,  body to send (json string),
  ///   * @param ``url`` url to send
  ///   * @return <status_code, body> where status_code is the one replied by server,
  ///         body its content
  ///   NB: not used due to server API
  Future<http.Response> _getData(String jsonStrBody, String url) async {
    http.Response response;

    String session = await SecuredStorageSingleton.getSession();


    if (session == null) {
      print("[_postData] Error async: session not yet retrieve from memory !");
      return http.Response("User session does not exist", -1);
    }

    if (useHTTPS){
      response = await http.get(
          new Uri.https("spem3.montefiore.ulg.ac.be:" + portNo, url),
          headers: {
            "Content-Type": "application/json",
            "Authorization": session
          }).timeout(
          new Duration(seconds: BaseNetworkUtils.TIME_OUT));
    }
    else {
      response = await http.get(
        new Uri.http("spem3.montefiore.ulg.ac.be:" + portNo, url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": session
        },
      ).timeout(new Duration(seconds: BaseNetworkUtils.TIME_OUT));
    }
    return response;
  }


  /*   ------------------------------------------------------------- *
   *                     Bug Reporting
   *   ------------------------------------------------------------- */

  /// Send the content of the collected logs to the provided email address
  bool sendLogs(String email) {
    bg.BackgroundGeolocation.emailLog(email).then((bool success) {
      if(verbose) print('[emailLog] success = $success');
      return success;
    }).catchError((error) {
      if(verbose) print('[emailLog] FAILURE: $error');
      return false;
    });
  }


  /*   ------------------------------------------------------------- *
   *               Get information from server
   *   ------------------------------------------------------------- */

  /// Get the information of the account of the user. <br>
  /// *Not implemented*
  Future<ServerReply> getAccountData() async{
    return ServerReply(false, "Feature not implemented");
  }

  /// Get a token from server<br>
  /// *Not implemented*
  Future<ServerReply> getToken() async {
    return ServerReply(false, "Feature not implemented"); // (on advice of client)
  }

  /// By default, we make one-shot connection, no session memory when
  /// the app is shutdown
  bool isLoggedIn(){
    return false;
  }


  Future<ServerReply> getInitConfig() async{
    try {
      http.Response reply = await _postData(json.encode("GetConfig"), "/GetConfig", true);
      if (verbose) {
        print("[getInitConfig] Response status: ${reply.statusCode}");
        print("[getInitConfig] Response body: ${reply.body}");
      }

      if (reply.statusCode == 200) {
        return ServerReply(true, reply.body);
      }
      if (reply.statusCode >= 500)
        return ServerReply(false, "Server is not available");

      return ServerReply(false, reply.body);
    }
    catch(e){
      print("[postData] trigger exception: $e");
      return ServerReply(false, "Server does not respond");
    }
  }

  Future<ServerReply> getHabits() async {
    try {
      http.Response reply = await _postData(json.encode("GetHabits"), "/GetHabits", true);
      if (verbose) {
        print("[getHabits] Response status: ${reply.statusCode}");
        print("[getHabits] Response body: ${reply.body}");
      }

      if (reply.statusCode == 200) {
        return ServerReply(true, reply.body);
      } else {
        return ServerReply(false, reply.body);
      }
    } catch (e) {
      print("[postData] trigger exception: $e");
      return ServerReply(false, "Server does not respond");
    }
  }


  /*   ------------------------------------------------------------- *
   *                      Authentification
   *   ------------------------------------------------------------- */

  /// Logout
  Future<ServerReply> logout() async {
    // Nothing to send to server, otherwise, goes here
    return ServerReply(true, "");
  }

  /// Login
  Future<ServerReply> logIn(String username, String pswd) async {
    LoginData loginData = LoginData.empty();
    loginData.username = username;
    loginData.password = pswd;

    //Conversion of data into json.
    String jsonStringLoginData = json.encode(loginData);
    print(jsonStringLoginData);

    try {
      http.Response reply = await _postData(jsonStringLoginData, "/Login", false);
      if (verbose){
        print("[logIn] Response status: ${reply.statusCode}");
        print("[logIn] Response body: ${reply.body}");
      }
      if (reply.statusCode == 200)
        return ServerReply(true, reply.body);

      if (reply.statusCode >= 500)
        return ServerReply(false, "Server is not available");

//      return ServerReply(false, "Wrong ID or password");
      return ServerReply(false, reply.body);

    } catch (e) {
      if(verbose) print(e);
      return ServerReply(false, "Server currently unavailable");
    }
  }

  /// Create a new user on server
  Future<ServerReply> createUser(String username, String pswd,
      String pswdConf, String email, String homeAddress, String homeZip,
      String homeCountry, String workAddress, String workZip,
      String workCountry, String work) async {

    RegisterData regData = RegisterData.empty();
    regData.username = username;
    regData.password = pswd;
    regData.passwordConf = pswdConf;
    regData.email = email;
    regData.homeAddress = homeAddress;
    regData.homeZip = homeZip;
    regData.homeCountry = homeCountry;
    regData.workAddress = workAddress;
    regData.workZip = workZip;
    regData.workCountry = workCountry;
    regData.work = work;

    //Conversion of data into json.
    String jsonString = json.encode(regData);
    try {
      http.Response reply = await _postData(jsonString, "/Register", false);
      if (verbose){
        print("[createUser] Response status: ${reply.statusCode}");
        print("[createUser] Response body: ${reply.body}");
      }
      if (reply.statusCode == 200) {
        return ServerReply(true, reply.body);
      }
      if (reply.statusCode >= 500)
        return ServerReply(false, "Server is not available");

      return ServerReply(false, reply.body);
    } catch (e) {
      if(verbose) print(e);
      return ServerReply(false, "Server does not respond");
    }
  }

  /*   ------------------------------------------------------------- *
   *                   Sending data collected
   *   ------------------------------------------------------------- */

  /// Flush the trajectories to server
  Future<ServerReply> sendTrajectories(String poolTrajectories) async {
    try {
      http.Response reply = await _postData(
              poolTrajectories, "/PostTrajectories", true);
      if (verbose) {
            print("[sendTrajectories] Response status: ${reply.statusCode}");
            print("[sendTrajectories] Response body: ${reply.body}");
          }

      if (reply.statusCode == 200) {
        return ServerReply(true, reply.body);
      }
      if (reply.statusCode >= 500)
        return ServerReply(false, "Server is not available");

      return ServerReply(false, reply.body);
    } catch (e) {
      print("[postData] trigger exception: $e");
      return ServerReply(false, "Server does not respond");
    }
  }

/*   ------------------------------------------------------------- *
   *                 Account management and GDPR stuffs
   *   ------------------------------------------------------------- */

  /// Delete from server the habits inferred from the user collected data
  Future<ServerReply> deleteRemoteData() async {
    try {
      http.Response reply = await _postData(json.encode("DeleteData"), "/DeleteData", true);
      if (verbose) {
            print("[deleteRemoteHabits] Response status: ${reply.statusCode}");
            print("[deleteRemoteHabits] Response body: ${reply.body}");
          }

      if (reply.statusCode == 200) {
        return ServerReply(true, reply.body);
      }
      if (reply.statusCode >= 500)
        return ServerReply(false, "Server is not available");

      return ServerReply(false, reply.body);

    } catch (e) {
      print("[postData] trigger exception: $e");
      return ServerReply(false, "Server does not respond");
    }
  }

  /// Delete the account of a user and the associated data
  Future<ServerReply> deleteAccount() async {
    try {
      http.Response reply = await _postData(json.encode("DeleteAccount"), "/DeleteAccount", true);
      if (verbose) {
            print("[deleteAccount] Response status: ${reply.statusCode}");
            print("[deleteAccount] Response body: ${reply.body}");
          }

      if (reply.statusCode == 200) {
        return ServerReply(true, reply.body);
      }
      if (reply.statusCode >= 500)
        return ServerReply(false, "Server is not available");

      return ServerReply(false, reply.body);
    } catch (e) {
      print("[postData] trigger exception: $e");
      return ServerReply(false, "Server does not respond");
    }
  }

  /// Fetch all the user data stored on the server
  Future<ServerReply> downloadUserData() async {
    try {
      http.Response reply = await _postData(json.encode("DownloadUserData"), "/DownloadUserData", true);
      if (verbose) {
            print("[deleteAccount] Response status: ${reply.statusCode}");
            print("[deleteAccount] Response body: ${reply.body}");
          }

      if (reply.statusCode == 200) {
        return ServerReply(true, reply.body);
      }
      if (reply.statusCode >= 500)
        return ServerReply(false, "Server is not available");

      return ServerReply(false, reply.body);
    } catch (e) {
      print("[postData] trigger exception: $e");
      return ServerReply(false, "Server does not respond");
    }
  }
}

/// Not used anymore:
// import 'package:tuple/tuple.dart';
// Tuple2<bool, String> ret = Tuple2(true, json.encode(RegisterData.empty()));