class Recipe {
  String? name;
  String? id;
  int? persons;
  bool? favourite;
  String? desc;
  int? images;
  List<Ingredient>? ingredients;
  List<RecipeStep>? steps;

  Recipe(
      {this.name,
        this.id,
        this.persons,
        this.favourite,
        this.desc,
        this.images,
        this.ingredients,
        this.steps});

  Recipe.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
    persons = json['persons'];
    favourite = json['favourite'];
    desc = json['desc'];
    images = json['images'];
    if (json['ingredients'] != null) {
      ingredients = <Ingredient>[];
      json['ingredients'].forEach((v) {
        ingredients!.add(new Ingredient.fromJson(v));
      });
    }
    if (json['steps'] != null) {
      steps = <RecipeStep>[];
      json['steps'].forEach((v) {
        steps!.add(new RecipeStep.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['id'] = this.id;
    data['persons'] = this.persons;
    data['favourite'] = this.favourite;
    data['desc'] = this.desc;
    data['images'] = this.images;
    if (this.ingredients != null) {
      data['ingredients'] = this.ingredients!.map((v) => v.toJson()).toList();
    }
    if (this.steps != null) {
      data['steps'] = this.steps!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Ingredient {
  int? count;
  String? unit;
  String? name;

  Ingredient({this.count, this.unit, this.name});

  Ingredient.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    unit = json['unit'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    data['unit'] = this.unit;
    data['name'] = this.name;
    return data;
  }
}

class RecipeStep {
  int? position;
  String? desc;

  RecipeStep({this.position, this.desc});

  RecipeStep.fromJson(Map<String, dynamic> json) {
    position = json['position'];
    desc = json['desc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['position'] = this.position;
    data['desc'] = this.desc;
    return data;
  }
}