enum QuestionCategory {
  science('Science', 'Explore the mysteries of the natural world'),
  history('History', 'Journey through time and human achievements'),
  geography('Geography', 'Discover the world around us'),
  literature('Literature', 'Dive into the world of books and stories'),
  math('Mathematics', 'Challenge yourself with numbers and logic'),
  tech('Technology', 'Learn about innovations and digital world'),
  sports('Sports', 'Test your knowledge of games and athletics'),
  arts('Arts', 'Explore creativity and artistic expression');

  final String name;
  final String description;

  const QuestionCategory(this.name, this.description);

  static List<QuestionCategory> get categories => QuestionCategory.values;

  String get imageAsset => 'assets/images/categories/${name.toLowerCase()}.png';

  @override
  String toString() => name;
}
