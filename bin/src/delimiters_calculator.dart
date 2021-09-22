import 'dart:io';
import 'dart:math' as math;


class DelimitersCalculator {

  /// Регулярное выражение -- разделитель между словами
  final _delimiter = RegExp(r"( |\n|\t)");

  /// Функция-обертка для суперпозиции двуместной функции f
  /// Например для args = [a1,a2,a3, ...]
  /// результат будет равен f(f(f(f(a1, a2), a3), a4), ...)
  int _superposition(int Function(int,int) f, List<int> args) {
    assert(args.length>1);
    args.forEach((n) {assert(n>0, 'All arguments must be natural numbers!');});
    return args.reduce((int res, int num) => f(res, num));
  }

  /// Возвращает наибольший общий делитель (англ. greatest common divisor)
  /// натуральных чисел num1 и num2
  int getGCD(int num1, int num2) {
    assert(num1>0 && num2>0, 'All arguments must be natural numbers!');

    int _getGCD(int n1, int n2) {
      return (n2==0)?n1:_getGCD(n2, n1 % n2);
    };

    // Выбор входа в рекурсию
    if (num1>num2) {
      return _getGCD(num1, num2);
    } else {
      return _getGCD(num2, num1);
    }
  }

  /// Многоаргументный вариант
  int getGCD2(List<int> args) {
    return _superposition(getGCD, args);
  }

  /// Возвращает наименьшее общее кратное (англ. least common multiple)
  /// натуральных чисел num1 и num2
  int getLCM(int num1, int num2) {
    assert(num1>0 && num2>0);
    return (num1*num2) ~/ getGCD(num1,num2);
  }

  /// Многоаргументный вариант
  int getLCM2(List<int> args) {
    return _superposition(getLCM, args);
  }

  /// Разложение числа num на простые множители (факторизация),
  /// прямой перебор чисел на отрезке 2 <= r <= sqrt(num)), причем каждый
  /// найденный делитель сужает правую границу.
  /// Функция возвращает мапу где ключ -- простое число, значение -- его степень.
  Map<int, int> factorize(int num) {
    Map<int, int> factors;
    var n = num;

    factors = {};
    for (var i = 2; i <= math.sqrt(n); i++) {
      while (n % i == 0) {
        factors[i] = (factors[i]??0) + 1;
        n ~/= i;
      }
    }

    if (n != 1) {
      factors[n] = (factors[n]??0) + 1;
    }

    return factors;
  }

  /// Переводит строку с десятичням числом в строку с двоичным числом
  String radix10to2(String numStr) {
    var n = int.tryParse(numStr,radix: 10);
    assert(n!=null);

    var s = '';
    while (n!>0) {
      s = '${(n&1==0)?0:1}$s';
      n>>=1;
    }

    return s;
  }

  /// Переводит строку с двоичным числом в строку с десятичням числом
  String radix2to10(String numStr) {
    // return '${int.parse(numStr,radix: 2)}';
    var result=0;
    var d=1;
    for(var i=numStr.length-1; i>=0; i--) {
      assert(numStr[i]=='0' || numStr[i]=='1');
      result += (numStr[i]=='1')?d:0;
      d <<= 1;
    }
    return '$result';
  }

  /// возвращает список целых чисел, извлеченных из текста
  List<int> getNumListFromStr(String str) {
    var res = <int>[];
    str.trim().split(_delimiter).forEach((itm) {
      var n = int.tryParse(itm);
      if (n != null){
        res.add(n);
      }
    });
    return res;
  }

  /// Вспомогательная функция для получения списка слов из файла с текстом
  Future<List<String>> getWordsList() async {
    try {
      var txt = await File('assets/words.txt').readAsString();
      return txt.split(_delimiter);
    } catch (e) {
      print('Except: $e');
      return [];
    };
  }

  /// Возвращает мапу со статистикой присутствия слов в списке
  Map<String, int> getWordStatistics(List<String> listWords) {
    var stat = <String, int>{};
    listWords.forEach((word) {
      if (word.isNotEmpty) {
        stat[word] = (stat[word]??0) + 1;
      }
    });
    return stat;
  }

  /// Возвращает список не повторяющихся цифр, встречающихся в строке
  /// в виде английских слов
  List<int> parseDigitsWords(List<String> listWords) {
    var dict = {
      'zero':  [0,0],
      'one':   [1,0],
      'two':   [2,0],
      'three': [3,0],
      'four':  [4,0],
      'five':  [5,0],
      'six':   [6,0],
      'seven': [7,0],
      'eight': [8,0],
      'nine':  [9,0],
    };
    var complete = 0;

    var res = <int>[];
    for (var i=0; i<listWords.length; i++) {
      var _word = listWords[i].toLowerCase();
      var d = dict[_word];
      if (d != null && d[1]++ == 0) {
        res.add(d[0]);
        if (++complete == 10) break;
      }
    }

    return res;
  }

}