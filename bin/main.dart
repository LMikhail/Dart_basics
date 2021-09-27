import 'dart:math' as math;
import 'src/computational_methods.dart';
import 'src/delimiters_calculator.dart';
import 'src/linear_algebra.dart';
import 'src/points.dart';
import 'src/users.dart';

extension MyExt on num {
  /// Возвращает арифметический корень n-й степени из x
  /// вычисленный методом касательных Ньютона
  double radical(int n, {eps = 1e-11}) {
    assert(n>2, 'Показатель корня должен быть не менее двух.');
    assert(n.isOdd && this<0,
    'Корень с четным показателем степени невозможен от отрицательного числа.');
    // if (n<2 || n.isEven && this<0) throw ArgumentError();

    double pow(double x, int n) {
      if (n==0) return 1.0;
      return x*pow(x,n-1);
    }

    var x = abs();
    double _iter(double xk) => ((n-1)*xk + x/pow(xk, n-1))/n;

    var res = x/n, delta = 1.0;
    while (delta > eps) {
      res = _iter(res);
      delta = pow(res, n) - x;
    }
    return res * sign;
  }
}


void main() async {
  var dc = DelimitersCalculator();

  print('\nЗадача 1');
  print('-------------');
  var a=5*7, b=3*7, c=2*7;
  print('НОД($a,$b) = ${dc.getGCD(a,b)}');
  print('НОД([$a,$b,$c]) = ${dc.getGCD2([a,b,c])}');
  print('НОК($a,$b) = ${dc.getLCM(a,b)}');
  print('НОК([$a,$b,$c]) = ${dc.getLCM2([a,b,c])}');

  var num = 2*2*3*3*3*73*101;
  print('factors($num) = ${dc.factorize(num)}');

  print('\nЗадача 2');
  print('-------------');
  var numStr = '${(5<<3)+5}';
  var num2 = dc.radix10to2(numStr);
  print('radix10to2($numStr)=$num2');
  print('radix2to10($num2)=${dc.radix2to10(num2)}');

  print('\nЗадача 3');
  print('-------------');
  var str = '    12 asd  34 fg   ';
  print('"$str" => ${dc.getNumListFromStr(str)}');

  print('\nЗадача 4');
  print('-------------');
  print('${dc.getWordStatistics(await dc.getWordsList())}');

  print('\nЗадача 5');
  print('-------------');
  print(dc.parseDigitsWords(['zero', 'three', 'dot', 'one', 'four', 'one', 'five', 'nine', 'two', 'six',
    'five', 'three', 'five', 'eight', 'nine', 'seven', 'nine', 'three', 'two',
    'three', 'eight', 'four', 'six', 'two']));

  print('\nЗадача 6');
  print('-------------');
  var i = Point.abscissa(), j = Point.ordinate(), k = Point.applicate();
  var zero = Point.zero;
  var p1 = Point(1, 1, 1);
  print('p1.length = ${p1.length()}\nzero.distanceTo(p1) = ${zero.distanceTo(p1)}');
  print('-p1 = ${-p1}');
  print('i+j-p1 = ${i+j-p1}');
  print('i+j+p1 = ${i+j+p1}');
  print('i * j = ${i * j}');
  print('p1 & p1 = ${p1 & p1}');
  print('triangleArea(i,j,k) = ${Point.triangleArea(i,j,k)}');


  print('\nЗадача 7');
  print('-------------');
  var x = -10.0, n = 5;
  var res = MyExt(x).radical(n);
  print('Radical($x, $n)=$res');
  print('\tТочность = ${(math.pow(res, n)-x).abs()}');

  print('\nЗадача 8');
  print('-------------');
  var userManager = UserManager.users([
    AdminUser('Ivan', 'admin@mail.ru'),
    AdminUser('Petr', 'admin@yandex.ru'),
    User('Maks', 'max@gmail.com'),
    User('Sveta', 'sveta@list.ru'),
  ]);

  print('printing MailList ...');
  userManager.printMailList();

  print('\nЗадача 9');
  print('-------------');
  var cm = ComputationalMethods(eps: 1e-11);
  var f = (double x) => -1/x;
  var x0 = 1.5;
  // res = cm.derivative(f, x0, 1);
  // print('Проверка производных высших порядков');
  // print('derivative(f,x0,1) = $res');
  // print('\tТочность = ${(1/math.pow(x0,2)-res).abs()}');
  // res = cm.derivative(f, x0, 2);
  // print('derivative(f,x0,2) = $res');
  // print('\tТочность = ${(-2/math.pow(x0,3)-res).abs()}');
  // res = cm.derivative(f, x0, 3);
  // print('derivative(f,x0,3) = $res');
  // print('\tТочность = ${(6/math.pow(x0,4)-res).abs()}');
  // res = cm.derivative(f, x0, 4);
  // print('derivative(f,x0,4) = $res');
  // print('\tТочность = ${(-24/math.pow(x0,5)-res).abs()}');

  // print('\nПроверка биномиальных коэффициентов');
  // var n2=4;
  // for(var i=0; i<=n2; i++) print('C($n2,$i)=${cm.binomial(n2,i)}');

  // print('\nПроверка расчета кривизны');
  // res = cm.curvature(f, x0);
  // print('cm.curvature(f, x0) = $res');
  // print('\tТочность = ${((2/math.pow(x0,3)).abs()/math.pow(1+1/math.pow(x0,4), 3/2)-res).abs()}');

  var a1=1.0, b1=4.0, x1=a1;
  res = cm.riemannIntegral(f, a1, b1);

  print('\nИнтеграл Римана');
  print('riemannIntegral(f, $a1, $b1) = $res');
  print('\tТочность = ${(-math.log(b1/a1)-res).abs()}');

  print('\nЗадача 10');
  print('-------------');
  var eq = LinearEquationSolver([
    [2, 5, 4],
    [1, 3, 2],
    [2, 10, 9]
  ],
      [30, 150, 110]);
  print('eq\n$eq\n');
  print('eq.toTriangular()\n${eq.toTriangular()}\n');

  print('Метод Гаусса');
  print('eq.gaussMethod()\n${eq.gaussMethod()}\n');

  print('Метод Крамера');
  print('eq.kramerMethod()\n${eq.kramerMethod()}\n');

  print('Прямой метод, через вычисление обратной матрицы ');
  print('eq.directAlgMethod()\n${eq.directAlgMethod()}\n');
}

