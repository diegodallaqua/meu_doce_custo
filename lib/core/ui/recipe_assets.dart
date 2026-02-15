class RecipeAssets {
  RecipeAssets._();

  static const String fallback = 'images/cards/others.jpg';

  static const Map<String, String> byCategoryId = {
    '3aHDpcu4FW': 'images/cards/cake.jpg',
    'bS5JKmWBQ0': 'images/cards/party_candy.jpg',
    'AlBX0mBk3G': 'images/cards/filling.jpg',
    'Buofy8lXNc': 'images/cards/homemade_cake.jpg',
    'beDkDqLiQW': 'images/cards/dessert.jpg',
    'EYdx2m5HaW': 'images/cards/titbit.jpg',
    'tia5wVdUHX': 'images/cards/easter_egg.jpg',
    'ELjXmc5UjU': 'images/cards/snack.jpg',
    'WKrOYJDHRC': 'images/cards/others.jpg',
  };

  static String fromCategoryId(String? categoryId) =>
      byCategoryId[categoryId] ?? fallback;
}