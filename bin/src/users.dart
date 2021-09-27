class User {
  final String name;
  final String email;

  User(this.name, this.email);
}


mixin UserMailSystem on User {
  String getMailSystem() {
    var _email = email.split(RegExp(r"@"));
    assert(_email.length==2);
    return _email[1];
  }
}


class AdminUser extends User with UserMailSystem {
  AdminUser(name, email):super(name, email);
}


class GeneralUser extends User {
  GeneralUser(name, email):super(name, email);
}


class UserManager<T extends User> {
  final Map<String, T> _users = {};
  T? operator [](String userName) => _users[userName];
  void operator []=(String userName, T user) => _users[userName]=user;

  UserManager();
  UserManager.users(List<T> listUsers) {
    listUsers.forEach((user) => add(user));
  }

  void add(T user) {
    if(!_users.containsKey(user.name)) {
      _users[user.name] = user;
    }
  }
  void replace(T user) => _users[user.name] = user;
  void remove(String userName) => _users.remove(userName);

  void printMailList() {
    getMailList().forEach((itm) {
      var user = itm['user'];
      var emailLabel = (itm['admin'])?'Mail domen':'Email';
      var email = itm['email'];
      print('User: $user\t$emailLabel: $email');
    });
  }


  List<Map<String, dynamic>> getMailList() {
    var res = <Map<String, dynamic>>[];
    _users.forEach((key, value) {
      res.add(<String, dynamic>{
        'user': key,
        'email': (value is AdminUser)?value.getMailSystem():value.email,
        'admin': value is AdminUser});
    });
    return res;
  }

}