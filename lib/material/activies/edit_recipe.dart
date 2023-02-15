import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kochbuch/material/activies/view_recipe.dart';
import 'package:kochbuch/material/main_material.dart';
import 'package:line_icons/line_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

import 'classes/recipe_classes.dart';

class EditRecipePage extends StatefulWidget {
  final Recipe recipe;
  const EditRecipePage({required this.recipe, super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<EditRecipePage> createState() => _EditRecipePageState();
}

class _EditRecipePageState extends State<EditRecipePage> {
  Recipe? recipe;
  final List<Uint8List> images = [];
  final List<TextEditingController> _ingredientsCountControllers = [];
  final List<TextEditingController> _ingredientsNameControllers = [];
  final List<TextEditingController> _stepControllers = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _personsController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final _dropdownValues = ['Gramm', 'Stück', 'Esslöffel', 'Teelöffel'];
  final _selectedValues = [];

  bool _loadRecipe(Recipe recipe) {
    _nameController.text = recipe.name!;
    _personsController.text = recipe.persons!.toString();
    _descController.text = recipe.desc!;

    for (int i = 0; i < recipe.images!.length; i++) {
      images.add(base64Decode(recipe.images![i]));
    }
    for (int i = 0; i < recipe.ingredients!.length; i++) {
      _ingredientsCountControllers.add(TextEditingController(text: recipe.ingredients![i].count.toString()));
      _ingredientsNameControllers.add(TextEditingController(text: recipe.ingredients![i].name!));
      _selectedValues.add(recipe.ingredients![i].unit);
    }
    for (int i = 0; i < recipe.steps!.length; i++) {
      _stepControllers.add(TextEditingController(text: recipe.steps![i].desc!));
    }
    return true;
  }

  Future<bool> _saveRecipe() async {
    List<String> recipes = [];
    List<String>? oldRecipes = [];
    List<String> imageStrings = [];
    List<Ingredient> ingredients = [];
    List<RecipeStep> steps = [];
    final prefs = await SharedPreferences.getInstance();

    try {
      for (int i = 0; i < _ingredientsCountControllers.length; i++) {
        if (_ingredientsCountControllers[i].text.isNotEmpty) {
          ingredients.add(Ingredient(
              count: int.parse(_ingredientsCountControllers[i].text),
              unit: _selectedValues[i],
              name: _ingredientsNameControllers[i].text));
        }
      }
      for (int i = 0; i < _stepControllers.length; i++) {
        if (_stepControllers[i].text.isNotEmpty) {
          steps.add(RecipeStep(position: i, desc: _stepControllers[i].text));
        }
      }
      for (int i = 0; i < images.length; i++) {
        imageStrings.add(base64.encode(images[i]).toString());
      }
      recipe = Recipe(
          name: _nameController.text,
          images: imageStrings,
          favourite: false,
          persons: int.parse(_personsController.text),
          desc: _descController.text,
          ingredients: ingredients,
          steps: steps);

      oldRecipes = prefs.getStringList('recipes');
      if (oldRecipes != null) recipes.addAll(oldRecipes);
      int oldIndex = recipes.indexOf(jsonEncode(widget.recipe.toJson()));
      if (oldIndex != -1) {
        recipes[oldIndex] = jsonEncode(recipe!.toJson());
      }

      await prefs.setStringList('recipes', recipes);
    } on Exception {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    _loadRecipe(widget.recipe);
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Rezept bearbeiten'),
          actions: [
            TextButton(
              onPressed: () async {
                if (await _saveRecipe()) {
                  Navigator.of(context).popUntil((route) => route.isFirst == true);
                  Navigator.of(context).push(PageRouteBuilder(
                      opaque: false,
                      pageBuilder: (BuildContext context, _, __) =>
                          ViewRecipePage(recipe: recipe!)
                  ));
                }
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
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Name',
                                hintText: '',
                              ),
                            ),
                            TextFormField(
                              controller: _personsController,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Anzahl der Personen',
                                hintText: '',
                              ),
                            ),
                            TextFormField(
                              controller: _descController,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                labelText: 'Beschreibung',
                                hintText: '',
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                              child: const Divider(),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: const [
                                Text(
                                  "Bilder",
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                            ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: images.length,
                                shrinkWrap: true,
                                itemBuilder: ((context, index) {
                                  return Container(
                                    margin: const EdgeInsets.all(10),
                                    child: Image.memory(
                                       images[index],
                                      //height: 300,
                                    ),
                                  );
                                })
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                OutlinedButton(
                                  onPressed: () async {
                                    List<XFile?> imgs = await ImagePicker().pickMultiImage(requestFullMetadata: true);
                                    List<Uint8List> cache = [];

                                    for (int i = 0; i < imgs.length; i++) {
                                      if (imgs[i] != null) cache.add(await imgs[i]!.readAsBytes());
                                    }
                                    setState(() {
                                      if (imgs.isNotEmpty) images.addAll(cache);
                                    });
                                  },
                                  child: LineIcon.image(),
                                ),
                                const SizedBox(width: 5.0),
                                OutlinedButton(
                                    onPressed: () async {
                                      XFile? img = await ImagePicker().pickImage(source: ImageSource.camera, requestFullMetadata: true);
                                      final cache = await img?.readAsBytes();
                                      setState(() {
                                        if (cache != null) images.add(cache);
                                      });
                                    },
                                    child: LineIcon.camera()
                                )
                              ],
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                              child: const Divider(),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  "Zutaten",
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _ingredientsCountControllers.add(TextEditingController());
                                      _selectedValues.add('Gramm');
                                      _ingredientsNameControllers.add(TextEditingController());
                                    });
                                  },
                                  child: const Text('Neue Zutat'),
                                ),
                              ],
                            ),
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: _ingredientsCountControllers.length,
                              itemBuilder: (context, index) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: TextField(
                                        controller: _ingredientsCountControllers[index],
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.digitsOnly,
                                        ],
                                        decoration: const InputDecoration(
                                          labelText: 'Menge',
                                          hintText: '',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5.0),
                                    Expanded(
                                      flex: 2,
                                      child: DropdownButton(
                                        hint: const Text('Einheit'),
                                        value: _selectedValues[index],
                                        onChanged: (newValue) {
                                          setState(() {
                                            _selectedValues[index] = newValue!;
                                          });
                                        },
                                        items: _dropdownValues.map((item) => DropdownMenuItem(
                                          value: item,
                                          child: Text(item),
                                        )).toList(),
                                      ),
                                    ),
                                    const SizedBox(width: 5.0),
                                    Expanded(
                                      flex: 3,
                                      child: TextField(
                                        controller: _ingredientsNameControllers[index],
                                        decoration: const InputDecoration(
                                          labelText: 'Name',
                                          hintText: '',
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                              child: const Divider(),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  "Schritte",
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: () {
                                    print("Tapped");
                                    setState(() {
                                      _stepControllers.add(TextEditingController());
                                    });
                                  },
                                  child: const Text('Neuer Schritt'),
                                ),
                              ],
                            ),
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: _stepControllers.length,
                              itemBuilder: (context, index) {
                                return TextField(
                                  controller: _stepControllers[index],
                                  decoration: InputDecoration(
                                    labelText: 'Schritt ${index + 1}',
                                    hintText: '',
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )
        )
    );
  }
}