import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main_material.dart';
import 'classes/recipe_classes.dart';
import 'edit_recipe.dart';

class ViewRecipePage extends StatefulWidget {
  final Recipe recipe;
  const ViewRecipePage({required this.recipe, super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<ViewRecipePage> createState() => _ViewRecipePageState();
}

class _ViewRecipePageState extends State<ViewRecipePage> {
  Recipe recipe = Recipe();
  List<Image> images = [];
  bool _showExtendedFabs = false;
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  _readImages() {
    if (recipe.images != null) {
      for (int i = 0; i < recipe.images!.length; i++) {
        images.add(Image.memory(base64Decode(recipe.images![i])));
      }
    }
  }

  void _deleteRecipe(Recipe recipe) {
    setState(() {
      _showExtendedFabs = !_showExtendedFabs;
    });
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Rezept löschen'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  const Text('Name des Rezepts eingeben, um es löschen zu können'),
                  TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                        hintText: 'Name'
                    ),
                  )
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Löschen'),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  List<String>? recipes = prefs.getStringList('recipes');

                  if (_textController.text == recipe.name) {
                    int oldIndex = recipes!.indexOf(jsonEncode(recipe.toJson()));
                    if (oldIndex != -1) {
                      recipes.removeAt(oldIndex);
                    }
                    await prefs.setStringList('recipes', recipes);

                    Navigator.of(context).popUntil((route) => route.isFirst == true);
                    Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                            opaque: false,
                            pageBuilder: (BuildContext context, _, __) =>
                              const MaterialHomePage(pageIndex: 0)
                        ));
                  }
                },
              ),
              OutlinedButton(
                child: const Text('Zurück'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
    );
  }

  void _favorRecipe(Recipe recipe) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? recipes = prefs.getStringList('recipes');
    int index = recipes!.indexOf(jsonEncode(recipe.toJson()));

    if (index != -1) {
      recipe.favourite = !recipe.favourite!;
      recipes[index] = jsonEncode(recipe.toJson());

    }
    await prefs.setStringList('recipes', recipes);
    setState(() {
      this.recipe = recipe;
    });
    print("object");
  }

  bool _isRecipeFavourite(Recipe recipe) {
    return recipe.favourite!;
  }

  @override
  Widget build(BuildContext context) {
    recipe = widget.recipe;
    _readImages();
    return Scaffold(
        appBar: AppBar(
          /*actions: [
            TextButton(
              onPressed: () async {
                //if (await _saveRecipe()) Navigator.of(context).pop();
              },
              child: const Text('Speichern'),
            )
          ],*/
        ),
        body: Stack(
          children: [
            Container(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            child: Text(
                              recipe.name!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 30
                              ),
                            ),
                          ),
                          CarouselSlider(
                              items: images,
                              options: CarouselOptions(
                                aspectRatio: 16/9,
                                viewportFraction: 0.8,
                                initialPage: 0,
                                enableInfiniteScroll: true,
                                reverse: false,
                                autoPlay: false,
                                enlargeCenterPage: true,
                                enlargeFactor: 0.3,
                                scrollDirection: Axis.horizontal,
                              )
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            child: Text(
                              recipe.desc!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 18
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                            child: const Divider(),
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: const Text(
                              "Zutaten:",
                              style: TextStyle(
                                  fontSize: 24
                              ),
                            ),
                          ),
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: recipe.ingredients != null ? recipe.ingredients!.length : 0,
                            itemBuilder: (context, index) {
                              return Text(
                                "${recipe.ingredients![index].count} "
                                    "${recipe.ingredients![index].unit!} "
                                    "${recipe.ingredients![index].name}",
                                style: const TextStyle(
                                    fontSize: 18
                                ),
                              );
                            },
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                            child: const Divider(),
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: const Text(
                              "Schritte:",
                              style: TextStyle(
                                  fontSize: 24
                              ),
                            ),
                          ),
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: recipe.steps != null ? recipe.steps!.length : 0,
                            itemBuilder: (context, index) {
                              return Text(
                                "${index + 1}. ${recipe.steps![index].desc}",
                                style: const TextStyle(
                                    fontSize: 18
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                )
            ),
            Visibility(
              visible: _showExtendedFabs,
              child: GestureDetector(
                onTap: () => setState(() => _showExtendedFabs = !_showExtendedFabs),
                child: Container(
                  color: Colors.black.withOpacity(0.8),
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Visibility(
              visible: _showExtendedFabs,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: FloatingActionButton(
                      mini: true,
                      onPressed: () {
                        _deleteRecipe(recipe);
                      },
                      child: LineIcon.alternateTrash(),
                    ),
                  ),
                  FloatingActionButton(
                    mini: true,
                    onPressed: () {
                      _favorRecipe(recipe);
                    },
                    child: _isRecipeFavourite(recipe)
                        ? LineIcon.starAlt()
                        : LineIcon.star(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: FloatingActionButton(
                      onPressed: () {
                        Navigator.of(context).push(PageRouteBuilder(
                            opaque: false,
                            pageBuilder: (BuildContext context, _, __) =>
                                EditRecipePage(recipe: recipe)
                        ));
                      },
                      child: LineIcon.pen(),
                    ),
                  )
                ],
              ),
            ),
            Visibility(
              visible: !_showExtendedFabs,
              child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _showExtendedFabs = !_showExtendedFabs;
                  });
                },
                child: LineIcon.cog(),
              ),
            )
          ],
        )/*FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(PageRouteBuilder(
                opaque: false,
                pageBuilder: (BuildContext context, _, __) =>
                    EditRecipePage(recipe: recipe)
            ));
          },
          child: LineIcon.pen(),
        )*//*FloatingActionButton(
          onPressed: () => _favouriteRecipe(recipe),
          child: _isRecipeFavourite(recipe) ? LineIcon.starAlt() : LineIcon.star(),
        )*/,
    );
  }
}