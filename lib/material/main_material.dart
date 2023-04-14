import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:Kochbuch/material/activies/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_android/path_provider_android.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../img/img.dart';
import 'activies/classes/recipe_classes.dart';
import 'activies/new_recipe.dart';
import 'activies/view_recipe.dart';

class MaterialHomePage extends StatefulWidget {
  const MaterialHomePage({super.key, required this.pageIndex, required this.reload});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final int pageIndex;
  final bool reload;

  @override
  State<MaterialHomePage> createState() => _MaterialHomePageState();
}

class _MaterialHomePageState extends State<MaterialHomePage> {
  int currentPageIndex = 0;
  List<Recipe> recipes = [];
  List<Uint8List?> images = [];
  final client = Supabase.instance.client;

  void _newRecipe() {
    Navigator.of(context).push(
        PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) => const NewRecipePage()
        )
    );
    //build(context);
  }

  Future<bool> _hasCreds() async  {
    var storage = const FlutterSecureStorage(aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ));
    String? mail = await storage.read(key: "mail");
    String? pass = await storage.read(key: "pass");

    try {
      if (mail == null || pass == null) {
        return false;
      }
      await Supabase.instance.client.auth.signInWithPassword(
          email: mail,
          password: pass
      );
      return true;
    } on Exception catch (e) {
      return false;
    }
  }

  _getRecipes() async {
    if (widget.reload) {
      if (!await _hasCreds()) {
        Navigator.of(context).pushReplacement(
            PageRouteBuilder(
                opaque: false,
                pageBuilder: (BuildContext context, _, __) => const LoginScreen()
            ));
      } else {
        Navigator.of(context).pushReplacement(
            PageRouteBuilder(
                opaque: false,
                pageBuilder: (BuildContext context, _, __) => const MaterialHomePage(pageIndex: 0, reload: false)
            ));
      }
      return;
    }

    final user = client.auth.currentUser;
    final strings = await client.from('recipes').select('recipe');

    if (strings != null) {
      for (int i = 0; i < strings.length; i++) {
        Recipe recipe = Recipe.fromJson(
            jsonDecode(strings[i]['recipe'])
        );
        try {
          Uint8List image = await client.storage
              .from('images/${user!.id}/${recipe.id}')
              .download('${recipe.name}0.jpg');
          setState(() {
            recipes.add(recipe);
            images.add(image);
          });
        } on Exception catch (e) {
          setState(() {
            recipes.add(recipe);
            images.add(null);
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    currentPageIndex = widget.pageIndex;
    _getRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: currentPageIndex == 0
            ? const Text("Mein Kochbuch")
            : const Text("Meine Favouriten")
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              child: Text("Mein Kochbuch"),
              /*decoration: BoxDecoration(
                color: Colors.blue,
              ),*/
            ),
            ListTile(
              leading: LineIcon.fileImport(),
              title: const Text('Importieren'),
              onTap: () {
                // navigate to home screen
              },
            ),
            ListTile(
              leading: LineIcon.fileExport(),
              title: const Text('Exportieren'),
              onTap: () async {
                /*List<Recipe> recipes = await getRecipes();
                final dic = await getExternalStorageDirectory();
                File file = File('${dic!.path}/recipes.json');
                file.writeAsString(jsonEncode(recipes));
                print(jsonEncode(recipes));*/
              },
            ),
            ListTile(
              leading: LineIcon.fileExport(),
              title: const Text('Logout'),
              onTap: () async {
                var storage = const FlutterSecureStorage(aOptions: AndroidOptions(
                  encryptedSharedPreferences: true,
                ));

                await Supabase.instance.client.auth.signOut();
                await storage.delete(key: "mail");
                await storage.delete(key: "pass");

                Navigator.of(context).pushReplacement(
                    PageRouteBuilder(
                        opaque: false,
                        pageBuilder: (BuildContext context, _, __) => const LoginScreen()
                    ));
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(LineIcons.utensils),
            label: 'Rezepte',
          ),
          NavigationDestination(
            icon: Icon(LineIcons.bookmark),
            label: 'Favoriten',
          ),
        ],
      ),
      body: <Widget>[
        Container(
            alignment: Alignment.center,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                return Card(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: InkWell(
                      child: Column(
                        children: <Widget>[
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.memory(
                              images[index] != null ?
                                images[index]! : base64Decode(MyImage.image),
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(5),
                            child: Center(
                              child: Text(recipes[index].name!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                              ),
                            ),
                          )
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).push(PageRouteBuilder(
                            opaque: false,
                            pageBuilder: (BuildContext context, _, __) =>
                                ViewRecipePage(recipe: recipes[index])
                        ));
                      },
                    )
                );
              },
            )
        ),
        Container(
            alignment: Alignment.center,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                if (recipes[index].favourite == false) return const SizedBox();

                return Card(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: InkWell(
                      child: Column(
                        children: <Widget>[
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.memory(
                              images[index] != null ?
                              images[index]! : base64Decode(MyImage.image),
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(5),
                            child: Center(
                              child: Text(recipes[index].name!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                              ),
                            ),
                          )
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).push(PageRouteBuilder(
                            opaque: false,
                            pageBuilder: (BuildContext context, _, __) =>
                                ViewRecipePage(recipe: recipes[index])
                        ));
                      },
                    )
                );
              },
            )
        ),
        /*FutureBuilder(
          future: getRecipes(),
          builder: (context, snapshot) {
            return Container(
                alignment: Alignment.center,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemCount: snapshot.data != null ? snapshot.data?.length  : 0,
                  itemBuilder: (context, index) {
                    if (snapshot.data![index].favourite == false) return const SizedBox();

                    return Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: InkWell(
                          child: Column(
                            children: <Widget>[
                              AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Image.memory(
                                  snapshot.data?[index].images! != 0
                                      ? images[index]
                                  //base64Decode(snapshot.data![index].images![0])
                                      : base64Decode(MyImage.image),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.all(5),
                                child: Center(
                                  child: Text(snapshot.data![index].name!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                  ),
                                ),
                              )
                            ],
                          ),
                          onTap: () {
                            Navigator.of(context).push(PageRouteBuilder(
                                opaque: false,
                                pageBuilder: (BuildContext context, _, __) =>
                                    ViewRecipePage(recipe: snapshot.data![index])
                            ));
                          },
                        )
                    );
                  },
                )
            );
          }
        ),*/
      ][currentPageIndex],
      floatingActionButton: currentPageIndex == 0 ? FloatingActionButton.extended(
        heroTag: "btn1",
        onPressed: _newRecipe,
        icon: const Icon(Icons.add),
        label: const Text("Neues Rezept"),
      ) : null,
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
