import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main_material.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".


  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  bool login = true;
  late final AnimationController _animationController;
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        left: false,
        right: false,
        bottom: false,
        child: Container(
          margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
          child: ListView(
            shrinkWrap: true,
            children: [
              Column(
                children: [
                  Lottie.asset(
                    'lib/img/38435-register.json',
                    controller: _animationController,
                    animate: true,
                    onLoaded: (composition) {
                      // Configure the AnimationController with the duration of the
                      // Lottie file and start the animation.
                      _animationController
                        ..duration = composition.duration
                        ..forward();
                      _animationController.repeat();
                    },
                  ),
                  login
                    ? const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 30,
                      ),
                    )
                    : const Text(
                      "Register",
                      style: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: TextFormField(
                      controller: _mailController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'E-Mail',
                        hintText: '',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: TextFormField(
                      controller: _passController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Passwort',
                        hintText: '',
                      ),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: FilledButton(
                          onPressed: () async {
                            var mail = _mailController.text;
                            var pass = _passController.text;

                            try {
                              if (login) {
                                await Supabase.instance.client.auth.signInWithPassword(
                                    email: mail,
                                    password: pass
                                );
                              } else {
                                await Supabase.instance.client.auth.signUp(
                                    email: mail,
                                    password: pass
                                );
                              }
                              const storage = FlutterSecureStorage(aOptions: AndroidOptions(
                                encryptedSharedPreferences: true,
                              ));

                              await storage.write(key: "mail", value: mail);
                              await storage.write(key: "pass", value: pass);

                              Navigator.of(context).pushReplacement(
                                  PageRouteBuilder(
                                      opaque: false,
                                      pageBuilder: (BuildContext context, _, __) =>
                                      const MaterialHomePage(pageIndex: 0, reload: true)
                                  ));

                            } on Exception catch (e) {
                              const snackBar = SnackBar(
                                content: Text('Fehler! Versuch es erneut'),
                              );

                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: login
                              ? const Text(
                                "Login",
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              )
                              : const Text(
                                "Register",
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                          )
                      )
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            login = !login;
                            _animationController.reset();
                            _animationController.repeat();
                            _mailController.clear();
                            _passController.clear();
                          });
                        },
                        child: login
                            ? const Text("Du hast keinen Account? Hier registrieren")
                            : const Text("Du hast einen Account? Hier einloggen"),
                      )
                  ),
                ],
              )
            ],
          ),
        ),
      )
    );
  }

// This method is rerun every time setState is called, for instance as done
// by the _incrementCounter method above.
//
// The Flutter framework has been optimized to make rerunning build methods
// fast, so that you can just rebuild anything that needs updating rather
// than having to individually change instances of widgets.
/*return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }*/
}
