import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../models/users.dart';

class UserProvider extends ChangeNotifier {
  static const String _boxName = 'users_box';
  Users? _user;

  Users? get user => _user;

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(1)) {
      // generated adapter must be registered in main before calling init
      // Hive.registerAdapter(UsersAdapter());
    }
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<Users>(_boxName);
    }
    final box = Hive.box<Users>(_boxName);
    if (box.isNotEmpty) {
      _user = box.getAt(0);
    }
    notifyListeners();
  }

  Future<void> saveUser(Users user) async {
    final box = Hive.box<Users>(_boxName);
    await box.clear();
    await box.add(user);
    _user = user;
    notifyListeners();
  }

  Future<void> clearUser() async {
    final box = Hive.box<Users>(_boxName);
    await box.clear();
    _user = null;
    notifyListeners();
  }
}
