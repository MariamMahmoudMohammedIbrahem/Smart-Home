import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mega/db/functions.dart';
import 'package:mega/db/reset_password.dart';
import 'package:mega/db/sign_up.dart';
import 'package:mega/ui/rooms.dart';

import '../constants.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  late String email;
  late String password;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * .09),
        child: SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              height: height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lets Sign you in!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 50,
                        ),
                        softWrap: true,
                      ),
                      SizedBox(
                        width: width * .7,
                        child: Text(
                          'Welcome to GlowGrid!\nLog in to unlock a world of possibilities.',
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
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              style: const TextStyle(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email is required';
                                } else if (!isEmailValid(value)) {
                                  return 'Enter a valid email address';
                                } else if (notFound) {
                                  return 'An Problem Occured';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: Colors.brown.shade700,
                                ),
                                labelText: 'Email',
                                floatingLabelStyle:
                                    MaterialStateTextStyle.resolveWith(
                                        (Set<MaterialState> states) {
                                  final Color color =
                                      states.contains(MaterialState.error)
                                          ? Theme.of(context).colorScheme.error
                                          : Colors.brown.shade700;
                                  return TextStyle(
                                      color: color,
                                      letterSpacing: 1.3,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18);
                                }),
                                labelStyle: MaterialStateTextStyle.resolveWith(
                                    (Set<MaterialState> states) {
                                  final Color color =
                                      states.contains(MaterialState.error)
                                          ? Theme.of(context).colorScheme.error
                                          : Colors.brown.shade700;
                                  return TextStyle(
                                      color: color, letterSpacing: 1.3);
                                }),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      const BorderRadius.all(Radius.circular(20.0)),
                                  borderSide: BorderSide(
                                    width: 3,
                                    color: Colors.brown.shade800,
                                  ),
                                ),
                                border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                  borderSide: BorderSide(
                                    width: 1,
                                    color: Colors.brown,
                                  ),
                                ),
                              ),
                              onChanged: (value) async {
                                email = value;
                                final userSnapshot = await FirebaseFirestore
                                    .instance
                                    .collection('users')
                                    .where('user email', isEqualTo: email)
                                    .get();
                                if (userSnapshot.docs.isEmpty) {
                                  notFound = true;
                                } else {
                                  notFound = false;
                                }
                              },
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            TextFormField(
                              controller: passwordController,
                              keyboardType: TextInputType.visiblePassword,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              style: const TextStyle(),
                              validator: (value) {
                                return null;
                              },
                              obscureText: eye,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.password,
                                  color: Colors.brown.shade700,
                                ),
                                labelText: 'Password',
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      eye = !eye;
                                    });
                                  },
                                  icon: Icon(
                                    eye
                                        ? Icons.remove_red_eye_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                ),
                                floatingLabelStyle:
                                    MaterialStateTextStyle.resolveWith(
                                        (Set<MaterialState> states) {
                                  final Color color =
                                      states.contains(MaterialState.error)
                                          ? Theme.of(context).colorScheme.error
                                          : Colors.brown.shade700;
                                  return TextStyle(
                                      color: color,
                                      letterSpacing: 1.3,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18);
                                }),
                                labelStyle: MaterialStateTextStyle.resolveWith(
                                    (Set<MaterialState> states) {
                                  final Color color =
                                      states.contains(MaterialState.error)
                                          ? Theme.of(context).colorScheme.error
                                          : Colors.brown.shade700;
                                  return TextStyle(
                                      color: color, letterSpacing: 1.3);
                                }),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      const BorderRadius.all(Radius.circular(20.0)),
                                  borderSide: BorderSide(
                                    width: 3,
                                    color: Colors.brown.shade800,
                                  ),
                                ),
                                border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                  borderSide: BorderSide(
                                    width: 1,
                                    color: Colors.brown,
                                  ),
                                ),
                              ),
                              onChanged: (value) async {
                                setState(() {
                                  password = passwordController.text;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Switch(
                                value: rememberPassword,
                                onChanged: (value) {
                                  if(value){
                                    setState(() {
                                      rememberPassword = value;
                                    });
                                  }
                                },
                              ),
                              const Text(
                                'Remember me',
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> const PasswordReset(),),);
                            },
                            child: const Text('Forget Password?'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(
                        width: width * .7,
                        child: ElevatedButton(
                          onPressed: () {
                            loginUser(context, email, password);
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.grey,
                              height: 20,
                              thickness: 1,
                            ),
                          ),
                          Text('OR'),
                          Expanded(
                            child: Divider(
                              color: Colors.grey,
                              height: 20,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: width * .7,
                        child: ElevatedButton(
                          onPressed: () {
                            handleSignIn(context);
                            ///TODO:handle email verification
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> const Rooms(userName: '',),),);
                          },
                          child: const Text(
                            'Login With Google',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Don\'t Have an Account?',),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> const SignUp(),),);
                        },
                        child: const Text(
                          'Register Now!',
                        ),
                      ),
                    ],
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
