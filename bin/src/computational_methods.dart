import 'dart:math' as math;

typedef DoubleFunc = double Function(double);

class ComputationalMethods {
  double eps;
  ComputationalMethods({this.eps=1e-11});

  // Возвращает true, если функция f вычислилась в точке x без сбоев и
  // вернула конечный результат, иначе возвращает false
  bool _computable(DoubleFunc f, double x) {
    try {
      var res = f(x);
      if (res==double.infinity ||
          res==double.negativeInfinity ||
          res==double.nan) {
        return false;
      }
      return true;
    } catch(e) {
      return false;
    }
  }

  // Возвращает значение функции f, если она вычислилась в точке x без сбоев и
  // вернула конечный результат, иначе выбрасывает исключение
  double _tryCall(DoubleFunc f, double x) {
    try {
      var res = f(x);
      if (res==double.infinity ||
          res==double.negativeInfinity ||
          res==double.nan) {
        throw Exception('Функция не вычислима в точке x=$x');
      }
      return res;
    } catch(e) {
      throw Exception('Функция не вычислима в точке x=$x');
    }
  }

  // Возвращает биномиальный коэффициент
  int binomial(int n, int k) {
    if (n<0 || k<0 || n<k) return 0;
    if(k==0 || n==0) return 1;
    return binomial(n-1,k-1)+binomial(n-1,k);
  }

  // Вычисляет производную n-го порядка функции f в точке x
  // методом двусторонней разности
  double derivative(DoubleFunc f,  double x, int n) {
    assert(n>=0);
    if(n==0) return _tryCall(f, x);

    if (_computable(f,x)) {
      var dictEps = {1: 1e-5, 2: 1e-4, 3: 1e-3};
      var dx = dictEps[n]??1e-3, res = 0.0, sgn = -1.0;
      for (var k=0; k<=n; k++) {
        res += (sgn*=-1) * binomial(n,k) * _tryCall(f,x+(n-2*k)*dx);
      }
      return res/math.pow(2*dx, n);
    } else {
      throw Exception('Функция не вычислима в точке x=$x');
    }
  }

  // Вычисляет кривизну функции f в точке x
  double curvature(DoubleFunc f,  double x) {
    var d = math.pow(1 + math.pow(derivative(f, x, 1), 2), 3/2);
    if (d==0) {
      throw Exception('В точке $x бесконечная кривизна');
    };
    return derivative(f, x, 2).abs() / d;
  }

  // Возвращает правую точку интервала от точки перегиба x
  double _indentFromInflection (DoubleFunc f, double a, double b, double x) {
    var x2 = x;
    // Потихоньку "отползаем" от точки перегиба
    while(curvature(f, x2+=1e-5)<1e-8);
    return x2;
  }

  // Возвращает правую точку интервала от точки x с нулевой кривизной
  double _indentFromZeroCurvature (DoubleFunc f, double a, double b, double x) {
    var c2 = curvature(f, (x+b)/2);
    var cb = curvature(f, b);
    if (c2==0 && cb==0) {
      if(_getEps(f, x, (x+b)/2)+_getEps(f, (x+b)/2, b) < 1e-8) {
        // "Наивно" предположим, что функция линейна
        return b;
      } else {
        // Попалась точка перегиба
        return _indentFromInflection (f, a, b, x);
      }
    } else {
      // Попалась точка перегиба
      return _indentFromInflection (f, a, b, x);
    }
  }

  // Возвращает следующую после x точку разбиения интервала интегрирования
  double _nextSplitInterval(DoubleFunc f, double a, double b, double x) {
    var k, c;
    c = curvature(f, x); // Кривизна
    if (c==0) {
      // Разбираемся с нулевой кривизной
      return _indentFromZeroCurvature(f, a, b, x);
    }

    k = derivative(f, x, 1); // Коэффициент наклона касательной
    var kr = 1e+5; // Доля от радиуса кривизны. Повышение порядка добавляет два порядка точности.
    var deltaL = 1/c/kr, // Шаг по дуге функции
        deltaX = math.sqrt(deltaL*deltaL/(1+k*k)); // Шаг по оси x
    var x2 = x+deltaX; // Правая граница частичного сегмента разбиения
    if (x2>b) {
      return b;
    }
    return x2;
  }

  double _getEps(DoubleFunc f, double x1, double x2) => (x2-x1)*(f(x2)-f(x1)).abs()/2;
  double _trapeziumArea (DoubleFunc f, x1, x2) => (f(x1)+f(x2))*(x2-x1)/2;

  // Вычисляет интеграл Римана от функции f на отрезке [a,b]
  // методом трапеций. Разбиение интервала происходит с учетом
  // кривизны функции f в точках разбиения. Если при разбиении попадается точка
  // разрыва второго рода, то выбрасывается исключение.
  // Точки разрыва первого рода не обработал, не знаю надо ли это.
  double riemannIntegral(DoubleFunc f,  double a, double b){
    var x1=a, x2=a, res=0.0;
    while(x2<b) {
      // x2 += 1e-5;
      x2 = _nextSplitInterval(f, a, b, x1);
      res += _trapeziumArea(f, x1, x2);
      x1 = x2;
    }
    return res;
  }

}