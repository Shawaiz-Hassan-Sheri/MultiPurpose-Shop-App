import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/http_exception.dart';
import '../models/enums/auth_mode.dart';
import '../providers/auth.dart';

class AuthScreen extends StatelessWidget {
  static const routeName = 'auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final authProvider = Provider.of<Auth>(context, listen: false);
    print('auth build');

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(
                          authProvider.currentAuthMode == AuthMode.Login
                              ? 215
                              : 50,
                          authProvider.currentAuthMode == AuthMode.Login
                              ? 117
                              : 188,
                          255,
                          1)
                      .withOpacity(0.75),
                  Color.fromRGBO(250, 188, 117, 1).withOpacity(0.99),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'MyShop',
                        style: TextStyle(
                          color:
                              Theme.of(context).accentTextTheme.headline6.color,
                          fontSize: 50,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  AuthCard({Key key}) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  //Auth _auth;
  AnimationController _controller;
  Animation<double> _opacityAnimation;
  Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    //_auth = Provider.of<Auth>(context, listen: false);
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(begin: Offset(0, -1.2), end: Offset(0, 0))
        .animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An error occured'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (Provider.of<Auth>(context, listen: false).currentAuthMode ==
          AuthMode.Login) {
        // Log user in
        await Provider.of<Auth>(context, listen: false).login(
          _authData['email'],
          _authData['password'],
        );
      } else {
        // Sign user up
        await Provider.of<Auth>(context, listen: false).signup(
          _authData['email'],
          _authData['password'],
        );
      }
    } on HttpException catch (error) {
      var errorMessage = 'Authentication failed';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not valid email address';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Password invalid';
      } else {
        errorMessage = 'Unkown error. Try again.';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage =
          'Could not authenticate you. Please try again later.';
      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final authProvider = Provider.of<Auth>(context);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
        height: authProvider.currentAuthMode == AuthMode.Signup ? 320 : 260,
        constraints: BoxConstraints(
          minHeight:
              authProvider.currentAuthMode == AuthMode.Signup ? 320 : 260,
        ),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    }
                  },
                  onSaved: (value) {
                    _authData['email'] = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }
                  },
                  onSaved: (value) {
                    _authData['password'] = value;
                  },
                ),
                AnimatedContainer(
                  constraints: BoxConstraints(
                      minHeight: authProvider.currentAuthMode == AuthMode.Signup
                          ? 60
                          : 0,
                      maxHeight: authProvider.currentAuthMode == AuthMode.Signup
                          ? 120
                          : 0),
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: TextFormField(
                        enabled:
                            authProvider.currentAuthMode == AuthMode.Signup,
                        decoration:
                            InputDecoration(labelText: 'Confirm Password'),
                        obscureText: true,
                        validator:
                            authProvider.currentAuthMode == AuthMode.Signup
                                ? (value) {
                                    if (value != _passwordController.text) {
                                      return 'Passwords do not match!';
                                    }
                                  }
                                : null,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  ElevatedButton(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                      child: Text(authProvider.currentAuthMode == AuthMode.Login
                          ? 'LOGIN'
                          : 'SIGN UP',

                      style: TextStyle(
                        color:Theme.of(context).primaryTextTheme.button.color,
                      ),
                      ),
                    ),
                    onPressed: _submit,

                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor,// background
                      onPrimary: Theme.of(context).primaryColor, // foreground
                    ),



                  ),
                  // ElevatedButton(
                  //   child: Text(authProvider.currentAuthMode == AuthMode.Login
                  //       ? 'LOGIN'
                  //       : 'SIGN UP'),
                  //   onPressed: _submit,
                  //   style: ButtonStyle(
                  //
                  //   ),
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(30),
                  //   ),
                  //   padding:
                  //       EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                  //   color: Theme.of(context).primaryColor,
                  //   textColor: Theme.of(context).primaryTextTheme.button.color,
                  // ),
                TextButton(
                  child: Padding(
                   padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                    child: Text(
                        '${authProvider.currentAuthMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                    ),
                  ),
                  onPressed: () {
                    authProvider.setAuthMode(
                        authProvider.currentAuthMode == AuthMode.Login
                            ? AuthMode.Signup
                            : AuthMode.Login);
                    if (authProvider.currentAuthMode == AuthMode.Login) {
                      _controller.reverse();
                    } else {
                      _controller.forward();
                    }
                  },


                ),
                // FlatButton(
                //   child: Text(
                //       '${authProvider.currentAuthMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                //   onPressed: () {
                //     authProvider.setAuthMode(
                //         authProvider.currentAuthMode == AuthMode.Login
                //             ? AuthMode.Signup
                //             : AuthMode.Login);
                //     if (authProvider.currentAuthMode == AuthMode.Login) {
                //       _controller.reverse();
                //     } else {
                //       _controller.forward();
                //     }
                //   },
                //   padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                //   materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                //   textColor: Theme.of(context).primaryColor,
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
