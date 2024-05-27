/*

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'functions.dart';

class PasswordReset extends StatefulWidget {
  const PasswordReset({super.key});

  @override
  State<PasswordReset> createState() => _PasswordResetState();
}

class _PasswordResetState extends State<PasswordReset> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  late String _email;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width*.07),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reset Password',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 50,
                    ),
                    softWrap: true,
                  ),
                  SizedBox(
                    width: width * .7,
                    child: Text(
                      'Please Enter your email address to request a password reset',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                        fontSize: 28,
                      ),
                      softWrap: true,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: .03 * width),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email',style:TextStyle(color: Colors.pink.shade700,fontWeight: FontWeight.bold, fontSize: 24,),),
                          Container(
                            padding: const EdgeInsets.only(left: 15.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: TextFormField(
                              controller: emailController,
                              cursorColor: Colors.pink,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email is required';
                                } else if (!isEmailValid(value)) {
                                  return 'Enter a valid email address';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                hintText: 'Please Enter Your Email',
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(20.0),),
                                  borderSide:
                                  BorderSide(color: Colors.pink, width: 1.0),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                                  borderSide:
                                  BorderSide(width: 1, color: Colors.pink),
                                ),
                              ),
                              style: const TextStyle(
                                  color: Colors.pink,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                              onChanged: (value) {
                                _email = value;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width*.8,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.pink,
                          backgroundColor: Colors.pink.shade600,
                          disabledForegroundColor: Colors.pink.shade600,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),),
                        onPressed: (){
                          if(_formKey.currentState!.validate()){
                            passwordReset();
                          }
                          else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please fill input')),
                            );
                          }
                        },
                        child: const Text(
                          'Continue',
                          style: TextStyle(color: Colors.white, fontSize: 24,),
                        )
                    ),
                  ),
                ],
              ),
              Flexible(child: Image.asset('images/4707071.jpg',)),
            ],
          ),
        ),
      ),
    );
  }
  void passwordReset() {
    try{
      FirebaseAuth.instance.sendPasswordResetEmail(email: _email).then((value) {
        showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                content: Text('Reset Password'),
              );
            }
        );
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              content: Text('problem Occurred'),
            );
          }
      );
    }
  }
}
*/
