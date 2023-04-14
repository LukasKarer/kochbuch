import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icon.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main_material.dart';
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
  final _dropdownValues = ['Gramm', 'Stück', 'Esslöffel', 'Teelöffel', 'Milliliter'];
  final _selectedValues = [];
  final client = Supabase.instance.client;
  bool saveButtonDisabled = true;

  _loadRecipe(Recipe recipe) async {
    _nameController.text = recipe.name!;
    _personsController.text = recipe.persons!.toString();
    _descController.text = recipe.desc!;
    final user = client.auth.currentUser;

    for (int i = 0; i < recipe.images!; i++) {
      final result = await client.storage
          .from('images/${user!.id}/${recipe.id}')
          .download('${recipe.name}$i.jpg');
      setState(() {
        images.add(result);
      });
    }
    for (int i = 0; i < recipe.ingredients!.length; i++) {
      _ingredientsCountControllers.add(TextEditingController(text: recipe.ingredients![i].count.toString()));
      _ingredientsNameControllers.add(TextEditingController(text: recipe.ingredients![i].name!));
      _selectedValues.add(recipe.ingredients![i].unit);
    }
    for (int i = 0; i < recipe.steps!.length; i++) {
      _stepControllers.add(TextEditingController(text: recipe.steps![i].desc!));
    }
    saveButtonDisabled = false;
    return true;
  }

  Future<bool> _saveRecipe() async {
    List<Ingredient> ingredients = [];
    List<RecipeStep> steps = [];
    final user = client.auth.currentUser;

    try {
      for (int i = 0; i < _ingredientsCountControllers.length; i++) {
        if (_ingredientsCountControllers[i].text.isNotEmpty
            && _selectedValues[i] != ''
            && _ingredientsNameControllers[i].text.isNotEmpty) {
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
          id: widget.recipe.id,
          images: images.length,
          favourite: false,
          persons: int.parse(_personsController.text),
          desc: _descController.text,
          ingredients: ingredients,
          steps: steps);

      final List<String> files = List<String>.generate(widget.recipe.images!,
              (int index) => "${user!.id}/${recipe!.id}/${recipe!.name!}$index.jpg");
      await client.storage.from('images').remove(
          files
      );

      final tempDir = await getTemporaryDirectory();
      for (int i = 0; i < images.length; i++) {
        final result = await client.storage
            .from('images')
            .upload('${user!.id}/${recipe!.id}/${_nameController.text}$i.jpg',
            await File('${tempDir.path}/${_nameController.text}$i.jpg').writeAsBytes(images[i]),
            fileOptions: const FileOptions(upsert: true)
        );
        //final imageUrl = result.data!.url;
        print(result);
      }
      /*await client.from('recipes').delete().match({
        'recipe': jsonEncode(widget.recipe.toJson()),
        'user_id': user!.id
      });*/

      final updateResult = await client.from('recipes').update({
        'recipe': jsonEncode(recipe!.toJson()),
        'user_id': user!.id
      }).eq("recipe", jsonEncode(widget.recipe.toJson())).select();
    } on Exception catch (e) {
      print(e);
      return false;
    }
    return true;
  }

  @override
  void initState() {
    _loadRecipe(widget.recipe);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Rezept bearbeiten'),
          actions: [
            TextButton(
              onPressed: () async {
                if (!saveButtonDisabled) {
                  if (await _saveRecipe()) {
                    Navigator.of(context).popUntil((route) => route.isFirst == true);
                    Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                            opaque: false,
                            pageBuilder: (BuildContext context, _, __) =>
                            const MaterialHomePage(pageIndex: 0, reload: false)
                        ));
                    /*Navigator.of(context).push(PageRouteBuilder(
                        opaque: false,
                        pageBuilder: (BuildContext context, _, __) =>
                            ViewRecipePage(recipe: recipe!)
                    ));*/
                  }
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