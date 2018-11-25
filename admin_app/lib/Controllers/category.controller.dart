import './../Models/category.model.dart';

class Controller {

  static Controller _instance;

  static Controller get instance {
    if (_instance == null) _instance = new Controller();
    return _instance;
  }

  Future<List<Category>> _categories;

  Future<List<Category>> get categories {
    if (_categories == null) _categories = Model.instance.getCategories();
    return _categories;
  }
}