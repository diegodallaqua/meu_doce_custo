import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class RecipeCategory {
  RecipeCategory({
    this.id,
    this.name,
  });

  String? id;
  String? name;

  @override
  String toString() {
    return 'Categoria{id: $id, name: $name}';
  }

  ParseObject toParseObject() {
    final parseObject = ParseObject('RecipeCategory')
      ..objectId = id
      ..set('name', name!);
    return parseObject;
  }



  factory RecipeCategory.fromParse(ParseObject parseObject) {
    return RecipeCategory(
      id: parseObject.objectId,
      name: parseObject.get<String>('name'),
    );
  }
}
