import 'package:contact_tracing/screens/home/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

TextEditingController nameController = TextEditingController();

class PhoneLogin extends StatefulWidget {
  @override
  _PhoneLoginState createState() => _PhoneLoginState();
}

class _PhoneLoginState extends State<PhoneLogin> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Contact Tracing")),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Form(
                key: _formKey,
                child: SingleChildScrollView(
                    child: Column(children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(20.0),
                        child: TextFormField(
                          controller: phoneController,
                          decoration: InputDecoration(
                            labelText: "Format: +92 312 5555555",
                          ),
                          // The validator receives the text that the user has entered.
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Enter phone number';
                            } else if (!value.contains('+')) {
                              return 'Enter valid phone number';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(20.0),
                        child: isLoading
                            ? CircularProgressIndicator()
                            : Container(
                          width: MediaQuery.of(context).size.width,
                          height: 60.0,
                          child: FlatButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(48.0),
                                side: BorderSide(color: Colors.transparent)),
                            color: Colors.green[400],
                            child: Text(
                              'Continue',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                setState(() {
                                  isLoading = true;
                                });
                                registerToFb(nameController.text.trim(),
                                    phoneController.text.trim());
                              }
                            },
                          ),
                        ),
                      )
                    ]))),
          ],
        ));
  }

  void registerToFb(String name, String phoneNo) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    await auth.verifyPhoneNumber(
      phoneNumber: phoneNo,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential);
        User user = auth.currentUser;

        setState(() {
          isLoading = false;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      },
      verificationFailed: (FirebaseAuthException e) {
        var msg;
        if (e.code == 'invalid-phone-number') {
          msg = 'Invalid number. Enter again.';
        } else {
          msg = e.message;
        }

        setState(() {
          isLoading = false;
        });

        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Error"),
                content: Text(msg.toString()),
                actions: [
                  FlatButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
      },
      codeSent: (String verificationId, int resendToken) {
        setState(() {
          isLoading = false;
        });

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  EnterSMS(verificationId, resendToken, phoneNo)),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          isLoading = false;
        });
        /*showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Error"),
                content: Text('Timeout. Try again later.'),
                actions: [
                  FlatButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });*/
      },
    );
  }
} //phone login

class EnterSMS extends StatefulWidget {
  EnterSMS(this.vId, this.tkn, this.phoneN);

  final String vId;
  final int tkn;
  final String phoneN;

  @override
  _EnterSMSState createState() => _EnterSMSState();
}

class _EnterSMSState extends State<EnterSMS> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController smsController = TextEditingController();
  var isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Phone Number Login")),
        body: Form(
            key: _formKey,
            child: SingleChildScrollView(
                child: Column(children: <Widget>[
                  Padding(
                      padding: EdgeInsets.all(10.0),
                      child: ListTile(
                        title: Text("SMS sent. Enter the verification code:",
                            style: TextStyle(color: Colors.black)),
                      )),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: TextFormField(
                      controller: smsController,
                      decoration: InputDecoration(
                        labelText: "Code",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter code';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.blue[700])),
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          setState(() {
                            isLoading = true;
                          });
                          verifySMS(widget.vId, smsController.text.trim());
                        }
                      },
                      child: Text('Submit'),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.all(10.0),
                      child: ListTile(
                        title: Text("Code not received? Send again.",
                            style: TextStyle(color: Colors.blue)),
                        onTap: () async {
                          await FirebaseAuth.instance.verifyPhoneNumber(
                            phoneNumber: widget.phoneN,
                            forceResendingToken: widget.tkn,
                            //verificationCompleted: (PhoneAuthCredential credential) {},
                            //verificationFailed: (FirebaseAuthException e) {},
                            codeSent: (String verificationId, int resendToken) {
                              setState(() {});
                            },
                            //codeAutoRetrievalTimeout: (String verificationId) {},
                          );
                        },
                      )),
                ]))));
  }

  void verifySMS(String vID, String msg) async {
    // Create a PhoneAuthCredential with the code
    PhoneAuthCredential phoneAuthCredential =
    PhoneAuthProvider.credential(verificationId: vID, smsCode: msg);
    // Sign the user in (or link) with the credential
    try {
      await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
      setState(() {
        isLoading = false;
      });
      User user = FirebaseAuth.instance.currentUser;

      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text(err.message),
              actions: [
                FlatButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
  } // verify sms

}
