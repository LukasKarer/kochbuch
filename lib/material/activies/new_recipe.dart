import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kochbuch/material/main_material.dart';
import 'package:line_icons/line_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'classes/recipe_classes.dart';

class NewRecipePage extends StatefulWidget {
  const NewRecipePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<NewRecipePage> createState() => _NewRecipePageState();
}

class _NewRecipePageState extends State<NewRecipePage> {
  final List<XFile?> images = [];
  final List<TextEditingController> _ingredientsCountControllers = [TextEditingController()];
  final List<TextEditingController> _ingredientsNameControllers = [TextEditingController()];
  final List<TextEditingController> _stepControllers = [TextEditingController()];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _personsController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final _dropdownValues = ['Gramm', 'Stück', 'Esslöffel', 'Teelöffel', 'Milliliter'];
  final List<String?> _selectedValues = ['Gramm'];
  final client = Supabase.instance.client;

  Future<bool> _saveRecipe() async {
    Recipe recipe;
    List<String> recipes = [];
    List<String>? oldRecipes = [];
    List<Ingredient> ingredients = [];
    List<RecipeStep> steps = [];
    final prefs = await SharedPreferences.getInstance();
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

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
      recipe = Recipe(
          name: _nameController.text,
          id: const Uuid().v4(),
          images: images.length,
          favourite: false,
          persons: int.parse(_personsController.text),
          desc: _descController.text,
          ingredients: ingredients,
          steps: steps);

      for (int i = 0; i < images.length; i++) {
        final result = await client.storage
            .from('images/${user!.id}/${recipe.id}')
            .upload('${_nameController.text}$i.jpg', File(images[i]!.path));
        //final imageUrl = result.data!.url;
        print(result);
      }

      /*oldRecipes = prefs.getStringList('recipes');
      if (oldRecipes != null) recipes.addAll(oldRecipes);
      recipes.add(jsonEncode(recipe.toJson()));*/

      await client.from('recipes').insert({
        'recipe': jsonEncode(recipe.toJson()),
        'user_id': user!.id
      });
      //await prefs.setStringList('recipes', recipes);
    } on Exception catch (e) {
      //print(e);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Neues Rezept'),
          actions: [
            TextButton(
              onPressed: () async {
                if (await _saveRecipe()) {
                  print("object");
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(
                    PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (BuildContext context, _, __) =>
                        const MaterialHomePage(pageIndex: 0, reload: false)
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
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Name',
                                hintText: '',
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: TextFormField(
                              controller: _personsController,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Anzahl der Personen',
                                hintText: '',
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: TextFormField(
                              controller: _descController,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Beschreibung',
                                hintText: '',
                              ),
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
                                  child: Image.file(
                                    File(images[index]!.path),
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
                                  setState(() {
                                    if (imgs.isNotEmpty) images.addAll(imgs);
                                  });
                                },
                                child: LineIcon.image(),
                              ),
                              const SizedBox(width: 5.0),
                              OutlinedButton(
                                  onPressed: () async {
                                    XFile? img = await ImagePicker().pickImage(source: ImageSource.camera, requestFullMetadata: true);
                                    setState(() {
                                      if (img != null) images.add(img);
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
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Row(
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
                                      _selectedValues.add("Gramm");
                                      _ingredientsNameControllers.add(TextEditingController());
                                    });
                                  },
                                  child: const Text('Neue Zutat'),
                                ),
                              ],
                            ),
                          ),
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _ingredientsCountControllers.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: TextField(
                                        controller: _ingredientsCountControllers[index],
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.digitsOnly,
                                        ],
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Menge',
                                          hintText: '',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5.0),
                                    Expanded(
                                      flex: 3,
                                      child: DropdownButtonFormField(
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Einheit',
                                          hintText: '',
                                        ),
                                        hint: const Text('Einheit'),
                                        value: _selectedValues[index] ?? "",
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
                                          border: OutlineInputBorder(),
                                          labelText: 'Zutat',
                                          hintText: '',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                            child: const Divider(),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Row(
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
                                    setState(() {
                                      _stepControllers.add(TextEditingController());
                                    });
                                  },
                                  child: const Text('Neuer Schritt'),
                                ),
                              ],
                            ),
                          ),
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _stepControllers.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:  const EdgeInsets.only(top: 10),
                                child: TextField(
                                  controller: _stepControllers[index],
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    labelText: 'Schritt ${index + 1}',
                                    hintText: '',
                                  ),
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