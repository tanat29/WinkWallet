import 'package:multipurpose/model/day.dart';
import 'package:multipurpose/model/expense.dart';
import 'package:multipurpose/model/month.dart';
import 'package:multipurpose/model/year.dart';
import 'package:flutter/cupertino.dart';
import 'package:multipurpose/api/firebase_api.dart';
import 'package:multipurpose/model/user.dart';

class ProviderApi extends ChangeNotifier {
  List<User> _user = [];
  List<Expense> _expense = [];
  List<Day> _day = [];
  List<Month> _month = [];
  List<Year> _year = [];

  //List<Todo> get todos => _todos.where((todo) => todo.isDone == false).toList();
  List<User> get users => _user.toList();
  List<Expense> get expenses => _expense.toList();
  List<Day> get days => _day.toList();
  List<Month> get months => _month.toList();
  List<Year> get years => _year.toList();

  // List<Todo> get todosCompleted =>
  //     _todos.where((todo) => todo.isDone == true).toList();

  void setUsers(List<User> users) =>
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _user = users;
        notifyListeners();
      });

  void setExpenses(List<Expense> expense) =>
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _expense = expense;
        notifyListeners();
      });

  void setDay(List<Day> day) =>
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _day = day;
        notifyListeners();
      });

  void setMonth(List<Month> month) =>
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _month = month;
        notifyListeners();
      });

  void setYear(List<Year> year) =>
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _year = year;
        notifyListeners();
      });

  void removeUser(User user) => FirebaseApi.deleteUser(user);

  void addUser(User user) => FirebaseApi.createUser(user);

  void updateUser(User user, String username, String password, String tel) {
    user.username = username;
    user.password = password;
    user.tel = tel;

    FirebaseApi.updateUser(user);
  }

  void removePhoto(String photo_before) async =>
      await FirebaseApi.removePhoto(photo_before);
}
