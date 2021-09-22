import 'src/delimiters_calculator.dart';

extension MyExt on num {
  /// Возвращает арифметический корень n-й степени из x
  /// вычисленный методом касательных Ньютона
  double radical(int n, {eps = 1e-11}) {
    assert(n<2, 'Показатель корня должен быть не менее двух.');
    assert(n.isEven && this<0,
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
  var a=5*7, b=3*7, c=2*7;
  print('НОД($a,$b) = ${dc.getGCD(a,b)}');
  print('НОД([$a,$b,$c]) = ${dc.getGCD2([a,b,c])}');
  print('НОК($a,$b) = ${dc.getLCM(a,b)}');
  print('НОК([$a,$b,$c]) = ${dc.getLCM2([a,b,c])}');

  var num = 2*2*3*3*3*73*101;
  print('factors($num) = ${dc.factorize(num)}');
  
  var numStr = '${(5<<3)+5}';
  var num2 = dc.radix10to2(numStr);
  print('radix10to2($numStr)=$num2');
  print('radix2to10($num2)=${dc.radix2to10(num2)}');
  
  var str = '    12 asd  34 fg   ';
  print('"$str" => ${dc.getNumListFromStr(str)}');

  print('${dc.getWordStatistics(await dc.getWordsList())}');

  print(dc.parseDigitsWords(['zero', 'three', 'dot', 'one', 'four', 'one', 'five', 'nine', 'two', 'six',
    'five', 'three', 'five', 'eight', 'nine', 'seven', 'nine', 'three', 'two',
    'three', 'eight', 'four', 'six', 'two']));

  var x = -10.0, n = 5;
  print('Radical($x, $n)=${MyExt(x).radical(n)}');
}

