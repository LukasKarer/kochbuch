import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kochbuch/material/activies/classes/recipe_classes.dart';
import 'package:kochbuch/material/activies/new_recipe.dart';
import 'package:kochbuch/material/activies/view_recipe.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:kochbuch/material/activies/home.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../img/img.dart';

class MaterialHomePage extends StatefulWidget {
  const MaterialHomePage({super.key, required this.pageIndex});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final int pageIndex;

  @override
  State<MaterialHomePage> createState() => _MaterialHomePageState();
}

class _MaterialHomePageState extends State<MaterialHomePage> {
  int currentPageIndex = 0;
  late Future<List<Recipe>> recipes;

  void _newRecipe() {
    Navigator.of(context).push(
        PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) => const NewRecipePage()
        )
    );
    build(context);
  }

  Future<List<Recipe>> getRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? strings = prefs.getStringList('recipes');
    List<Recipe> cache = [];

    if (strings != null) {
      int i = 0;
      while (i <strings.length) {
        cache.add(Recipe.fromJson(jsonDecode(strings[i])));
        i++;
      }
    }
    return cache;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //currentPageIndex = widget.pageIndex;
    return Scaffold(
      appBar: AppBar(
        title: currentPageIndex == 0
            ? const Text("Mein Kochbuch")
            : const Text("Meine Favouriten")
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
        FutureBuilder(
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
                    return Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: InkWell(
                          child: Column(
                            children: <Widget>[
                              AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Image.memory(
                                  snapshot.data?[index].images?.length != 0
                                      ? base64Decode(snapshot.data![index].images![0])
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
        ),
        FutureBuilder(
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
                                  snapshot.data?[index].images?.length != 0
                                      ? base64Decode(snapshot.data![index].images![0])
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
        ),
      ][currentPageIndex],
      floatingActionButton: currentPageIndex == 0 ? FloatingActionButton.extended(
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
