import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icon.dart';

import 'classes/recipe_classes.dart';

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
  List<Image> images = [];

  _readImages() {
    if (widget.recipe.images != null) {
      for (int i = 0; i < widget.recipe.images!.length; i++) {
        images.add(Image.memory(base64Decode(widget.recipe.images![i])));
      }
    }
  }

  void _favouriteRecipe(Recipe recipe) {
    print("object");
  }

  bool _isRecipeFavourite(Recipe recipe) {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    _readImages();
    return Scaffold(
        appBar: AppBar(
          actions: [
            TextButton(
              onPressed: () async {
                //if (await _saveRecipe()) Navigator.of(context).pop();
              },
              child: const Text('Speichern'),
            )
          ],
        ),
        body: Container(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        child: Text(
                          widget.recipe.name!,
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
                        itemCount: widget.recipe.ingredients != null ? widget.recipe.ingredients!.length : 0,
                        itemBuilder: (context, index) {
                          return Text(
                            "${widget.recipe.ingredients![index].count} "
                                "${widget.recipe.ingredients![index].unit!} "
                                "${widget.recipe.ingredients![index].name}",
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
                        itemCount: widget.recipe.steps != null ? widget.recipe.steps!.length : 0,
                        itemBuilder: (context, index) {
                          return Text(
                            "${index + 1}. ${widget.recipe.steps![index].desc}",
                            style: const TextStyle(
                                fontSize: 18
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                )
              ]
            )
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _favouriteRecipe(widget.recipe),
          child: _isRecipeFavourite(widget.recipe) ? LineIcon.starAlt() : LineIcon.star(),
        ),
    );
  }
}