import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:gps_tracer/utils/colors.dart";
import "package:gps_tracer/models/register_data.dart" as register_data;
import 'package:validators/validators.dart';
import 'package:gps_tracer/network/network_utils.dart';
import 'dart:convert';
import 'package:gps_tracer/network/privacy_policy.dart' as pp;
import 'package:gps_tracer/utils/alert_box.dart';
import 'package:crypto/crypto.dart';

/// An enumeration for the submit button animation
enum RegisterButtonState {
  standard, inProgress, valid, notValid
}

/// Hash the pwd to avoid data leakage
String generateMd5(String input) {
  return md5.convert(utf8.encode(input)).toString();
}

/// The register page accessible from the login page
class RegisterPage extends StatefulWidget {

  final String title="";

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  var passKey = GlobalKey<FormFieldState>();

  // By default, the submit button display "Submit"
  RegisterButtonState _registerButtonState = RegisterButtonState.standard;

  register_data.RegisterData _data = new register_data.RegisterData.empty();

  // Wether agreement on privacy policy or not
  bool _agreedToTOS = false;

  // Which profession
  List<String> _profs = <String>['','Student', 'Teacher', 'Administrative staff', 'Other'];
  String _prof = '';

  final int MIN_PASSWORD_LENGTH = 4;

  TextEditingController _usernameController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _passwordConfController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _homeAddressController = new TextEditingController();
  TextEditingController _homeZipController = new TextEditingController();
  TextEditingController _homeCountryController = new TextEditingController();
  TextEditingController _workAddressController = new TextEditingController();
  TextEditingController _workZipController = new TextEditingController();
  TextEditingController _workCountryController = new TextEditingController();


  ///-----------------------------------------------------------------
  ///                UTILITY FUNCTIONS
  ///-----------------------------------------------------------------

  void _displayPrivacyPolicy(BuildContext context){
    // Route to tmp privacy policy
    // Navigator.pushNamed(context, "/privacy_policy");
    pp.launchURLPrivPolicy(context);
  }

  void animateSubmitButton() {

    setState(() {
      _registerButtonState = RegisterButtonState.inProgress;

    });
  }

  void displayStateSubmitButton(bool success) {
    setState(() {
      _registerButtonState = success?RegisterButtonState.valid:RegisterButtonState.notValid;
    });
  }


  resetStateSubmitButton(){
    setState(() {
      _registerButtonState = RegisterButtonState.standard;
    });

  }
  /// UI for submit button
  Widget _setUpSubmitButtonChild() {
    if (_registerButtonState == RegisterButtonState.standard) {
      return const Text('Submit', style: TextStyle( color: Colors.white,fontSize: 24.0,));
    }
    else if (_registerButtonState == RegisterButtonState.inProgress) {
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      );
    } else if (_registerButtonState == RegisterButtonState.valid) {
      return Icon(Icons.check, color: Colors.white);
    }
    else {
      return Icon(Icons.close, color: Colors.red);
    }
  }

  ///----------------------------------------------------
  ///                    Validators
  ///----------------------------------------------------

  String _validateUsername(String usr){
    if(isNull(usr)){
      return "You didn't enter an username.";
    }
    return null;
  }

  String _validatePassword(String pswd){
    if(pswd.length < MIN_PASSWORD_LENGTH){
      return "Please enter a password of minimum 8 characters.";
    }
    return null;
  }

  String _validateConfirmPassword(String conf_pswd){
    var pswd = passKey.currentState.value;

    if(!equals(pswd, conf_pswd)){
      return "Password is not matching.";
    }
    return null;
  }

  String _validateMail(String mail){
    if(isNull(mail)){
      return "You didn't enter an email.";
    }

    if(!isEmail(mail)){
      return "You didn't enter a valid mail address.";
    }
    return null;
  }

  String _validateAddress(String address){
    if(isNull(address)){
      return "You didn't enter an address.";
    }
    return null;
  }

  String _validateZip(String zip){
    if(isNull(zip)){
      return "You didn't enter a zip code.";
    }

    if(!isNumeric(zip) || zip.length > 4){
      return "You didn't enter a valid zip code";
    }
    return null;
  }

  String _validateCountry(String country){
    if(isNull(country)){
      return "You didn't enter a country.";
    }
    return null;
  }

  ///----------------------------------------------------
  ///                    Functions
  ///----------------------------------------------------

  void _setAgreedToTOS(bool newValue) {
    setState(() {
      _agreedToTOS = newValue;
    });
  }

  void submit(context) async {
    // async when things with server will be implemented
    print("clicked submit");
    // this._formKey.currentState.validate()
    if (this._formKey.currentState.validate()) {
      print("form validated");
      bool isConnected = await isCo2Internet();

      if (!isConnected) {
        showDialogBox(context, "No internet connection available.",
            "Please turn on wifi or cellular network in your settings.");
      }

      else if (!_agreedToTOS) {
        print("did not agreed to TOS");
        showDialogBox(context, "Terms and services.",
            "You need to agree to the terms and services to create an account");
        return;
      }

      else {
        print("Ready to send to server");
        animateSubmitButton();

        _formKey.currentState.save();
        print(json.encode(_data.toJson()));

        try {
          ServerReply reply = await NetworkUtilsSingleton.getInstance()
              .createUser(
              _data.username,
              _data.password,
              _data.passwordConf,
              _data.email,
              _data.homeAddress,
              _data.homeZip,
              _data.homeCountry,
              _data.workAddress,
              _data.workZip,
              _data.workCountry,
              _data.work
          );
          print("end of query to server for create user");

          displayStateSubmitButton(reply.isSuccess());

          // Wait a little bit so that user has time to see, then reset
          await new Future.delayed(new Duration(seconds: 1));

          resetStateSubmitButton();

          if (reply.isSuccess()) {
            print("Creation success");
            Navigator.pop(context);
          }
          else {
            print("Reply is not success");
            showDialogBox(
                context, reply.content, "Please try again");
          }
        }
        catch (e) {
          resetStateSubmitButton();
          print("Falled in catch");
          showDialogBox(
              context, "Oups ... something didn't work",
              "Please try again or later and check your internet connection.");
          print(e.toString());
        }
      }
    }
    else{
      print("Could not validate form");
    }
  }

  ///----------------------------------------------------
  ///                   UI
  ///----------------------------------------------------

  @override
  Widget build(BuildContext context) {


    ///---------------------------
    ///   All the different fields
    ///---------------------------

    final username = new TextFormField(
      keyboardType: TextInputType.text,
      validator: this._validateUsername,
      controller: _usernameController,
      onSaved: (String inputUsr){
        this._data.username = inputUsr;
      },
      decoration: const InputDecoration(
        icon: const Icon(Icons.person),
        //hintText: 'Enter your Username',
        labelText: 'Username',
      ),
    );


    final password = new TextFormField(
      key: passKey,
      validator: this._validatePassword,
      controller: _passwordController,
      onSaved: (String inputUsr){
        // generateMd5(inputUsr)
        this._data.password = generateMd5(inputUsr);
      },
      obscureText: true,
      decoration: const InputDecoration(
        icon: const Icon(Icons.lock),
        //hintText: 'Enter your Password',
        labelText: 'Password',
      ),
    );

    final passwordConfirm = new TextFormField(
      validator: this._validateConfirmPassword,
      controller: _passwordConfController,
      onSaved: (String inputUsr){
        // generateMd5(inputUsr)
        this._data.passwordConf = inputUsr;
      },
      obscureText: true,
      decoration: const InputDecoration(
        icon: const Icon(null),
        //hintText: 'Enter your Password',
        labelText: 'Confirm your Password',
      ),
    );

    final mail = new TextFormField(
      keyboardType: TextInputType.emailAddress,
      validator: this._validateMail,
      controller: _emailController,
      onSaved: (String inputUsr){
        this._data.email = inputUsr;
      },
      decoration: const InputDecoration(
        icon: const Icon(Icons.email),
        //hintText: 'Enter your Email address',
        labelText: 'Email',
      )
    );

    final homeAddress_part1 = new TextFormField(
      validator: this._validateAddress,
      controller: _homeAddressController,
      onSaved: (String inputUsr){
        this._data.homeAddress = inputUsr;
      },
      decoration: const InputDecoration(
        icon: const Icon(Icons.home),
        labelText: 'Address',
      ),
    );


    final homeAddress_part2 = new Row(
      children: <Widget>[
        new Expanded(child: new TextFormField(
          keyboardType: TextInputType.number,
          validator: this._validateZip,
          controller: _homeZipController,
          onSaved: (String inputUsr){
            this._data.homeZip = inputUsr;
          },
          decoration: const InputDecoration(
            icon: const Icon(null),
            labelText: 'Zip code',
          )
        )),
        new Expanded(child: new TextFormField(
          keyboardType: TextInputType.text,
          validator: this._validateCountry,
          controller: _homeCountryController,
          onSaved: (String inputUsr){
            this._data.homeCountry = inputUsr;
          },
          decoration: const InputDecoration(
            icon: const Icon(null),
            labelText: 'Country',
          )
        )),
      ]
    );

    final workAddress_part1 = new TextFormField(
      validator: this._validateAddress,
      controller: _workAddressController,
      onSaved: (String inputUsr){
        this._data.workAddress = inputUsr;
      },
      decoration: const InputDecoration(
        icon: const Icon(Icons.place),
        labelText: 'Work address',
      ),
    );

    final workAddress_part2 = new Row(
      children: <Widget>[
        new Expanded(child: new TextFormField(
          keyboardType: TextInputType.number,
          validator: this._validateZip,
          controller: _workZipController,
          onSaved: (String inputUsr){
            this._data.workZip = inputUsr;
          },
          decoration: const InputDecoration(
            icon: const Icon(null),
            labelText: 'Zip code',
          )
        )),
        new Expanded(child: new TextFormField(
          keyboardType: TextInputType.text,
          validator: this._validateCountry,
          controller: _workCountryController,
          onSaved: (String inputUsr){
            this._data.workCountry = inputUsr;
          },
          decoration: const InputDecoration(
            icon: const Icon(null),
            labelText: 'Country',
          )
        )),
      ]
    );

    final work = new FormField(
      builder: (FormFieldState state) {
        return InputDecorator(
          decoration: InputDecoration(
            icon: const Icon(Icons.work),
            labelText: 'Profession',
          ),
          isEmpty: _prof == '',
          child: new DropdownButtonHideUnderline(
            child: new DropdownButton(
              value: _prof,
              isDense: true,
              onChanged: (String newValue) {
                setState(() {
                  //newContact.favoriteColor = newValue;
                  _prof = newValue;
                  this._data.work = newValue;
                  state.didChange(newValue);
                });
              },
              items: _profs.map((String value) {
                return new DropdownMenuItem(
                  value: value,
                  child: new Text(value),
                );
              }).toList(),
            ),
          ),
        );
      },
    );


    /// The line to agree to the terms and services (privacy policy)
    final privacyPolicy = new Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: <Widget>[
          Checkbox(
            value: _agreedToTOS,
            onChanged: _setAgreedToTOS,
            activeColor: covoitULiegeColor,
          ),
          Expanded(child:
            GestureDetector(
              onTap: ()=> _displayPrivacyPolicy(context),
              child: const Text(
                'I agree to the Terms of Services and Privacy Policy',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            )
          ),
        ],
      ),
    );

    /// submit button
    final submit = new Container(
      padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 40.0),
      child: new RaisedButton(
        color: covoitULiegeColor,
        padding: EdgeInsets.symmetric(vertical: 12.0),
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0)),
        child: _setUpSubmitButtonChild(),
        onPressed: (){
          this.submit(context);
        }
      ),
    );


///----------------------------------------------------
///            ORGANIZATION OF THE FIELDS
///----------------------------------------------------
    
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: covoitULiegeColor,
        title: new Text(
          'Registration Page'
        ),
      ),

      body: SafeArea(
        child: new Form(
          key: _formKey,
          child: new ListView(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            children: <Widget>[

              username,
              SizedBox(height: 18.0),
              password,
              passwordConfirm,
              SizedBox(height: 18.0),
              mail,
              SizedBox(height: 18.0),
              homeAddress_part1,
              homeAddress_part2,
              SizedBox(height: 18.0),
              workAddress_part1,
              workAddress_part2,
              SizedBox(height: 18.0),
              work,
              privacyPolicy,
              submit,
              SizedBox(height: 30.0),
              
            ]
          )
        ),
      ),
    );

  }
  
}