import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  late Recipe recipe;
  List<Image> images = [];
  bool _showExtendedFabs = false;
  final _textController = TextEditingController();
  final client = Supabase.instance.client;
  Future<bool>? readImagesBool;

  _readImages() async {
    final user = client.auth.currentUser;
    List<Image> cache = [];

    if (recipe.images != null) {
      for (int i = 0; i < recipe.images!; i++) {
        final result = await client.storage
            .from('images/${user!.id}/${recipe.id}')
            .download('${recipe.name}$i.jpg');
        cache.add(Image.memory(result));
      }
      setState(() {
        images.addAll(cache);
      });
      return true;
    }
  }

  void _deleteRecipe(Recipe recipe) {
    final user = client.auth.currentUser;

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
                  const Text('Name des Rezepts eingeben, um es zu löschen'),
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
                  if (_textController.text == recipe.name) {
                    final List<String> files = List<String>.generate(recipe.images!,
                            (int index) => "${user!.id}/${recipe.id}/${recipe.name!}$index.jpg");
                    await client.storage.from('images').remove(
                        files
                    );
                    await client.from('recipes').delete().match({
                      'recipe': jsonEncode(recipe.toJson()),
                      'user_id': user!.id
                    });

                    Navigator.of(context).popUntil((route) => route.isFirst == true);
                    Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                            opaque: false,
                            pageBuilder: (BuildContext context, _, __) =>
                              const MaterialHomePage(pageIndex: 0, reload: false)
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
    final user = client.auth.currentUser;

    recipe.favourite = !recipe.favourite!;

    await client.from('recipes').update({
      'recipe': jsonEncode(recipe.toJson()),
      'user_id': user!.id
    }).eq(
      'recipe', jsonEncode(widget.recipe.toJson())
    );

    setState(() {
      this.recipe = recipe;
    });
  }

  bool _isRecipeFavourite(Recipe recipe) {
    return recipe.favourite!;
  }

  @override
  void initState() {
    recipe = widget.recipe;
    _readImages();
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: readImagesBool,
      builder: (context, snapshot) {
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
                                  enableInfiniteScroll: false,
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
                        heroTag: "btn2",
                        mini: true,
                        onPressed: () {
                          _deleteRecipe(recipe);
                        },
                        child: LineIcon.alternateTrash(),
                      ),
                    ),
                    FloatingActionButton(
                      heroTag: "btn3",
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
                        heroTag: "btn4",
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
                  heroTag: "btn1",
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
    );
  }
}