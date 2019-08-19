import 'package:flutter/material.dart';
import 'package:gps_tracer/utils/colors.dart';
import 'package:gps_tracer/utils/alert_box.dart';
import 'package:gps_tracer/models/login.dart' as login_model;
import 'package:gps_tracer/network/network_utils.dart';
import 'package:gps_tracer/store/secured_storage.dart';
import 'dart:convert';
import 'dart:async';
import 'package:crypto/crypto.dart';

/* ======================================================================= *
 *                               Utils
 * ======================================================================= */
/// An enumeration for the submit button state (UI animation)
enum LoginButtonState {
  standard, inProgress, valid, notValid
}
/// Hash password to enhance security (limit data leakage)
String generateMd5(String input) {
  return md5.convert(utf8.encode(input)).toString();
}


/* ======================================================================= *
 *                          Login Page
 * ======================================================================= */
/// First screen seen by the user when opening the app. Login page.
class LoginPage extends StatefulWidget {

  LoginPage({this.onSignedIn});

  // A callback to return status to root_page
  final VoidCallback onSignedIn;

  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Create an empty LoginData model (will be filled in the form)
  login_model.LoginData _data = new login_model.LoginData.empty();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  LoginButtonState _loginButtonState;
  final int MIN_PASSWORD_LENGTH = 4;

  // Called before build
  @override
  void initState() {
    super.initState();
    // Login button state should be in standard mode by default ("log in")
    _loginButtonState = LoginButtonState.standard;
  }

  /*   ------------------------------------------------------------- *
   *                           Validators
   *   ------------------------------------------------------------- */
  String _validatePassword(String pswd) {
    if (pswd.length < MIN_PASSWORD_LENGTH) {
      return 'The Password must be at least 4 characters.';
    }
    return null;
  }

  String _validateUsername(String usr) {
    if (usr.length < 1) {
      return 'Please enter your username !';
    }
    return null;
  }

  /*   ------------------------------------------------------------- *
   *                         Submit button
   *   ------------------------------------------------------------- */
  /// Display a little spinner instead of the "log in" message to notify user that app is querying server
  void animateLogInButton() {

    setState(() {
      _loginButtonState = LoginButtonState.inProgress;

    });
  }

  /// Display in a visual manner the success of a server query
  void displayStateLogInButton(bool success) {
    setState(() {
      _loginButtonState = success?LoginButtonState.valid:LoginButtonState.notValid;
    });

  }

  /// Reset the login button to the message "log in"
  resetStateLogInButton(){
    setState(() {
      _loginButtonState = LoginButtonState.standard;
    });
  }

  /// Logic of a submit request for logging in
  void submit(context) async {
    // Check user inputs are valid and save the form
    if (this._formKey.currentState.validate()) {

      try {
        _formKey.currentState.save();

        // Display splash screen/spinner
        animateLogInButton();

        bool isConnected = await isCo2Internet();

        if (!isConnected) {
          showDialogBox(context, "No internet connection available.",
              "Please turn on wifi or cellular network in your settings.");
        }
        else {
          // Query server
          ServerReply reply = await NetworkUtilsSingleton.getInstance().logIn(
              _data.username, _data.password);

          if (reply.isSuccess()) {
            print("[Login] ${json.encode(_data)}");

            // Store login data (session) to secured storage, for later queries
            await SecuredStorageSingleton.getInstance().write(
                key: "session", value: json.encode(_data));

            displayStateLogInButton(reply.isSuccess());

            // Wait a little bit so that user has time to see the animation
            await new Future.delayed(new Duration(seconds: 1));

            resetStateLogInButton();

            // Root to home page
            widget.onSignedIn();
          } else {
            // Wrong id or password
            displayStateLogInButton(reply.isSuccess());
            showDialogBox(context, reply.content, "Please try again");

            // Wait a little bit so that user has time to see
            await new Future.delayed(new Duration(seconds: 1));
            resetStateLogInButton();

          }
        }
      }
      catch (e){
        resetStateLogInButton();
        showDialogBox(
            context, "Error logging in", "Please try again or later");
        print(e.toString());
      }
      resetStateLogInButton();
    }
  }

  /*   ------------------------------------------------------------- *
   *                                UI
   *   ------------------------------------------------------------- */
  Widget _buildBody() {
    final username = TextFormField(
      keyboardType: TextInputType.text,
      // .emailAddress
      autofocus: false,
      validator: this._validateUsername,
      onSaved: (String inputUsr) {
        this._data.username = inputUsr;
      },
      decoration: InputDecoration(
        hintText: 'Username',
        labelText: 'Username',
      ),
    );

    /// Form input for password
    final password = TextFormField(
      autofocus: false,
      obscureText: true,
      validator: this._validatePassword,
      onSaved: (String inputUsr) {
        this._data.password = generateMd5(inputUsr);
      },
      decoration: InputDecoration(
        hintText: 'Password',
        labelText: 'Password',
      ),
    );

    Widget _setUpLogInButtonChild() {
      if (_loginButtonState == LoginButtonState.standard) {
        return new Text(
          'Login',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
          ),
        );
      }
      else if (_loginButtonState == LoginButtonState.inProgress) {
        return CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        );
      } else if (_loginButtonState == LoginButtonState.valid) {
        return Icon(Icons.check, color: Colors.white);
      }
      else {
        return Icon(Icons.close, color: Colors.red);
      }
    }

    /// Log in button
    final logInButton = RaisedButton(
      color: covoitULiegeColor,
      padding: EdgeInsets.symmetric(vertical: 12.0),
      shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(30.0)),
      child: _setUpLogInButtonChild(),
      onPressed: () {
        this.submit(context);
      },
    );


    /// Clickable text
    final forgotPswd = new Row(
      // To make the text on the right
        textDirection: TextDirection.rtl, // or ltl
        children: <Widget>[
          new InkWell(
              child: new Text('Forgot your password ?',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black54)),
              onTap: () => showDialogBox(
                  context, "Oups ... ", "This feature is not yeat implemented")
          )
        ]);

    /// Clickable text
    final signUp = new Center(
        child: new InkWell(
            child: new Text('Don\'t have an account yet ? Sign Up !',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black54)),
            onTap: () {
              print("Sign up clicked");
              Navigator.pushNamed(context, '/register_page');
            }));

    return new Center(
      child: new Form(
        key: this._formKey,
        child: new ListView(
          padding: EdgeInsets.only(top: 60.0, left: 24.0, right: 24.0),
          children: <Widget>[
            // picture,
            new Icon(Icons.account_circle,
                size: 120.0, color: Colors.black54),
            SizedBox(height: 24.0),
            username,
            SizedBox(height: 16.0),
            password,
            SizedBox(height: 16.0),
            forgotPswd,
            SizedBox(height: 48.0),
            logInButton,
            SizedBox(height: 16.0),

            signUp,
            SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }

    @override
    Widget build(BuildContext context) {
      /// Form input for username

      return new Scaffold(
          appBar: new AppBar(
            backgroundColor: covoitULiegeColor,
            title: new Text('Login to Covoit ULiège Dev.'),
          ),
          body: _buildBody()
      );
    }
  }