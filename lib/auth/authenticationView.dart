import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test2/BottomTab.dart';
import 'package:test2/color.dart';
import 'package:test2/profile/CreateProfile.dart';

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  _AuthCheckerState createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  static bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginState();
  }

  Future<void> _checkLoginState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    setState(() {
      _AuthCheckerState.isLoggedIn = isLoggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomTab();
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static void showLoginSuccessMessage(BuildContext context) {
    const snackBar = SnackBar(
      content: Text('Login Successful'),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isShowRegister = false;
  bool _isLoading = false;

  Future<void> signUpWithEmailPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        await userCredential.user!.updateDisplayName(_nameController.text.trim());
        print("Sign up successful: ${userCredential.user}");
        showLoginSuccessMessage(context);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isLoggedIn', true);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CreateProfile()),
        );
        setState(() {
          _isShowRegister = false;
        });
      } on FirebaseAuthException catch (e) {
        _showErrorDialog(e.message);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> signInWithEmailPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        print("Sign in successful: ${userCredential.user}");

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isLoggedIn', true);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomTab()),
        );
      } on FirebaseAuthException catch (e) {
        _showErrorDialog(e.message);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _AuthCheckerState.isLoggedIn = false;
    print("Sign out successful");
  }

  void _showErrorDialog(String? message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message ?? 'An unknown error occurred'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'stuGent',
          style: TextStyle(color: Colors.white, fontFamily: 'bold'),
        ),
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Welcome",
                        style: TextStyle(
                            fontFamily: 'bold', fontSize: 40, color: Colors.black),
                      ),
                      Text(
                        " student!",
                        style: TextStyle(
                            fontFamily: 'bold', fontSize: 40, color: Colors.green),
                      ),
                    ],
                  ),
                  if (_isShowRegister) SizedBox(height: 20),
                  Container(
                    width: 200,
                    height: 200,
                    child: Image(
                      image: AssetImage('assets/login.png'),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    _isShowRegister ? 'Sign Up' : 'Log In',
                    style: const TextStyle(fontSize: 40, fontFamily: 'bold'),
                  ),
                  const Text(
                    'Welcome to stuGent!',
                    style:
                        TextStyle(color: Colors.green, fontSize: 20, fontFamily: 'bold'),
                  ),
                  SizedBox(height: 20),
                  if (_isShowRegister)
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                  if (_isShowRegister) SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) { 
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.appBarColorDark,
                      ),
                      onPressed: () {
                        if (_isShowRegister) {
                          signUpWithEmailPassword();
                        } else {
                          signInWithEmailPassword();
                        }
                      },
                      child: _isLoading
                          ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : Text(
                              _isShowRegister ? 'Sign Up' : "Let's Start!",
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isShowRegister = !_isShowRegister;
                      });
                    },
                    child: Text(
                      _isShowRegister
                          ? 'Already have an account? Log in'
                          : 'New to here? Create an account!',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
