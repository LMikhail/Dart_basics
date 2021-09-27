
abstract class LinearAlgebra {
  late final Map<String, dynamic> _params;
  late final List<num> _val;

  // Как проимплементить конструктор, чтобы он вызывался через super(...)???
  // LinearAlgebra(this._params, this._val);
  LinearAlgebra();

  LinearAlgebra operator -();
  LinearAlgebra operator -(LinearAlgebra v);
  LinearAlgebra operator +(LinearAlgebra v);
  LinearAlgebra operator *(Object v); // Объектное (векторное, матричное, тензорное)
                                      // произведение (в т.ч умножение на скаляр)
  Object        operator &(LinearAlgebra v); // Скалярное произведение

  bool get isNotEmpty => _val.isNotEmpty;
  bool get isEmpty => _val.isEmpty;
  // int  get length => _val.length; //Возникла путаница с длиной вектора

  final Exception _algArgExcept =
    Exception('Тип элемента должен быть числовой либо линейно-алгебраический');
  final Exception _numArgsExcept =
    Exception('Типы элементов должны быть числовыми');
  final Exception _notImplemented = Exception('Not implemented!');
  Exception get algArgExcept => _algArgExcept;
  Exception get notImplemented => _notImplemented;
}


class Vector<T extends num> extends LinearAlgebra {
  final Type _genType = T; //Это костыль. Не знаю как добраться до дженерика,
                      // если он вложенный. Костыль тоже не совсем работает.
                      // Нельзя сделать так: var _T = v._genType;
                      //                     Vector<_T>(...) ???
  bool get isRow => _params['isRow'];
  int get dim => _params['dim'];
  @override
  bool get isNotEmpty => _val.isNotEmpty;
  @override
  bool get isEmpty => _val.isEmpty;

  Vector.zero(int dim, {bool isRow = true}) {
    assert(dim>0, 'Вектор не может быть пустым.');
    _params = {'dim': dim, 'isRow': isRow};
    _val = List.generate(dim, (idx) {
      if(T==int || T==double || T==num) { // T==dynamic ???
        return (T==int)?0:0.0; //T.minPositive-T.minPositive Как с помощью дженерика получить ноль нужного типа???
      };
      throw '$T -- не поддерживаемый тип для конструктора zero';
    }, growable: false);
    // super({'dim': dim, 'isRow': isRow}, _val); Как проимплементить конструктор super???
  }

  // Единичный базисный вектор
  Vector.base(int dim, int numDim, {bool isRow = true}) {
    assert(dim > 0 && numDim > 0 && numDim <= dim);
    var e = (T==double)?1.0:1;
    _params = {'dim': dim, 'isRow': isRow};
    _val = List.generate(dim, (idx) => (idx==numDim-1)?e:e*0, growable: false);
    // super({'dim': dim, 'isRow': isRow}, _val);
  }

  factory Vector.generate(int length, T Function(int idx) generator,
      {bool isRow = true}) {
    var val = <T>[];
    for (var i=0; i<length; i++) {
      val.add(generator(i));
    }
    return Vector(val, isRow: isRow);
  }

  Vector.copy(Vector v) {
    _params = {'dim': v.dim, 'isRow': v.isRow};
    _val = List.generate(dim, (idx) => v[idx+1] as T, growable: false);
  }

  Vector(List<T> val, {bool isRow = true}) {
    _val = val;
    _params = {'dim': val.length, 'isRow': isRow};
  }

  // Меняет элементы с индексами i и j местами
  Vector<T> swap(int i, int j) {
    var n = this[i] as T;
    this[i] = this[j] as T;
    this[j] = n;
    return this;
  }

  @override
  Vector  operator - () {
    return Vector.generate(dim, (idx) => -_val[idx], isRow: isRow);
  }

  @override
  Vector  operator - (LinearAlgebra v) {
    assert(v is Vector);
    v as Vector<T>;
    assert(dim == v.dim && isRow == v.isRow);
    return Vector.generate(dim, (idx) => _val[idx] - v._val[idx], isRow: isRow);
  }

  @override
  Vector  operator + (LinearAlgebra v) {
    assert(v is Vector);
    v as Vector<T>;
    assert(dim == v.dim && isRow == v.isRow);
    return Vector.generate(dim, (idx) => _val[idx] + v._val[idx], isRow: isRow);
  }

  // Векторное произведение либо умножение вектора на скаляр
  @override
  Vector operator * (Object m) {
    assert(m is List<Vector> && m.length==dim-2 && m.length>1 && m[0].dim == dim
        || m is Vector && dim==m.dim && dim==3 || m is num);
    if(m is num) {
      // Умножение вектора на скаляр
      return Vector.generate(dim, (idx) => _val[idx]*m, isRow: isRow);
    } else {
      // Векторное произведение
      var vList = (m is Vector<T>)?<Vector<T>>[m]:(m as List<Vector<T>>);
      var m2 = Matrix.fromVectors([Vector<T>.zero(dim), this, ...vList]);
      var res = Vector.zero(dim), sgn = (dim.isEven)?1:-1;
      for(var j=1; j<=m2.colCount; j++) {
        var detMnr = m2.minor(1,j).det() as num;
        res[j] = detMnr*(sgn*=-1);
      }
      return res;
    }
  }

  // Скалярное произведение
  @override
  num operator & (LinearAlgebra v) {
    assert(v is Vector);
    v as Vector;
    assert(dim==v.dim && dim>0 && isRow && !v.isRow);

    var res = (v[1] is int && T==int)?0:0.0;
    for(var i=1; i<=dim; i++) {
      res += (this[i] as T) * (v[i] as num); // Как добраться до дженерика v???
    }
    return res;
  }

  // Доступ к i-му элементу вектора (индексы начинаются с 1)
  Object operator [](int i) {
    assert(i>0 && i<=dim);
    return _val[i-1];
  }

  // Изменение i-го элемента вектора (индексы начинаются с 1)
  void  operator []=(int i, T v) {
    assert(i>0 && i<=dim);
    _val[i-1] = v;
  }

  @override
  bool operator ==(Object v) {
    if (identical(this, v)) return true;
    if (v.runtimeType != runtimeType)  return false;
    var ok = v is Vector && dim==v.dim && isRow==v.isRow;
    if(ok) {
      for (var i = 0; i < dim; i++) {
        ok = ok && _val[i] == (v as Vector)._val[i];
        if (!ok) break;
      }
    }
    return ok;
  }

  // Транспонирует вектор (анг. transpose)
  Vector tr() {
    return Vector<T>(_val as List<T>, isRow: !isRow);
  }

  @override
  String toString() {
    var res = '';
    for(var i=0; i<dim; i++) {
      res = '$res${(res.isEmpty)?'':(isRow)?', ':'\n'}${_val[i]}';
    }
    return '$res';
  }
}


class Matrix<T extends num> /*extends LinearAlgebra*/{
  late final List<Vector<T>> _val;
  late final Map<String, dynamic> _params;

  int get rowCount => _params['rowCount'];
  int get colCount => _params['colCount'];
  bool get isNotEmpty => _val.isNotEmpty;
  bool get isEmpty => _val.isEmpty;

  Matrix.zero(int rowCount, int colCount) {
    assert(rowCount>0 && colCount>0);
    _params = {'colCount': colCount, 'rowCount': rowCount};
    _val = List.generate(rowCount, (idx) => Vector<T>.zero(colCount));
  }

  Matrix(List<List<T>> val) {
    assert(val.isNotEmpty && val[0].isNotEmpty);
    _params = {'rowCount': val.length, 'colCount': val[0].length};
    for(var i=1; i<val.length; i++) {
      assert(colCount == val[i].length);
    };
    _val = List.generate(val.length, (i) {
      return Vector<T>.generate(val[i].length, (j) => val[i][j]);
    });
  }

  // Меняет строки с индексами i и j местами
  Matrix swapRows(int i, int j) {
    var v = this[i] as Vector<T>;
    _val[i-1] = _val[j-1];
    this[j] = v;
    return this;
  }

  // Меняет строки с индексами i и j местами
  Matrix replaceCol(List<num> col, int j) {
    var m = Matrix.copy(this);
    for(var i=1; i<=rowCount; i++){
      m[i][j] = col[i-1];
    }
    return m;
  }


  Matrix.fromVectors(List<Vector<T>> val) {
    assert(val.isNotEmpty);
    _params = {'rowCount': val.length, 'colCount': val[0].dim};
    for(var i=0; i<val.length; i++) {
      assert(colCount == val[i].dim);
    };
    _val = List.generate(val.length, (i) => Vector.copy(val[i]));
  }

  Matrix.copy(Matrix m) {
    _params = {'rowCount': m.rowCount, 'colCount': m.colCount};
    _val = List.generate(m.colCount, (i) => Vector.copy(m[i+1]));
  }

  Matrix operator -() {
    return Matrix(List.generate(rowCount,
            (i) => List.generate(colCount, (j) => -(this[i+1][j+1] as num),
                growable: false),
        growable: false
    ));
  }

  // @override
  Matrix operator - (Matrix m) {
    assert(colCount==m.colCount && rowCount==m.rowCount);
    return Matrix(List.generate(rowCount,
          (i) => List.generate(colCount,
                (j) => (this[i+1][j+1] as num)-(m[i+1][j+1] as num),
              growable: false
          ),
        growable: false
    ));
  }

  // @override
  Matrix operator + (Matrix m) {
    assert(colCount==m.colCount && rowCount==m.rowCount);
    return Matrix(List.generate(rowCount,
            (i) => List.generate(colCount,
                (j) => (this[i+1][j+1] as num)+(m[i+1][j+1] as num),
            growable: false
        ),
        growable: false
    ));
  }

  // Умножение двух матриц, либо матрицы на вектор, либо матрицы на скаляр
  // @override
  Object operator * (Object m) {
    if(m is num) {
      return Matrix(List.generate(rowCount,
              (i) => List.generate(colCount, (j) => m*(this[i+1][j+1] as num),
              growable: false),
          growable: false
      ));
    } else if(m is Matrix) {
      assert(colCount == m.rowCount);
      return Matrix(List.generate(rowCount,
              (i) => List.generate(colCount, (j) {
                var res = 0.0;
                for (var k = 0; k < colCount; k++) {
                  res += (this[i+1][k+1] as num)*(m[k+1][j+1] as num);
                }
                return res;
                }, growable: false),
          growable: false));
    } else if(m is Vector) {
      assert(colCount == m.dim && !m.isRow);
      return Vector.generate(m.dim, (idx) => this[idx+1]&m, isRow: false);
    }
    throw Exception('Некорректный тип аргумента при умножении на матрицу');
  }

  // Доступ к i-му элементу вектора (индексы начинаются с 1)
  Vector operator [](int i) {
    assert(i>0 && i<=rowCount);
    return _val[i-1];
  }

  // Изменение i-го элемента вектора (индексы начинаются с 1)
  void  operator []=(int i, Vector<T> v) {
    assert(i>0 && i<=rowCount);
    _val[i-1] = v;
  }


  @override
  bool operator ==(Object m) {
    if (identical(this, m)) return true;
    if (m.runtimeType != runtimeType)  return false;
    m as Matrix;
    var ok = m is Matrix && colCount==m.colCount && rowCount==m.rowCount;
    if(ok) {
      for (var i = 1; i <= rowCount; i++) {
        for (var j = 1; j <= rowCount; j++) {
          ok = ok && this[i][j] == m[i][j];
          if (!ok) break;
        }
      }
    }
    return ok;
  }

  // (i,j)-й минор матрицы (индексация начинается с 1)
  Matrix minor(int i, int j) {
    assert(i<=rowCount && j<=colCount, 'subMatr: Должно быть i<=$rowCount && j<=$colCount');
    assert(rowCount>1 && colCount>1);
    return Matrix(List.generate(rowCount-1,
            (iIdx) => List.generate(colCount-1, (jIdx) {
              var i2 = iIdx+0+((iIdx+1<i)?0:1);
              var j2 = jIdx+1+((jIdx+1<j)?0:1);
              return _val[i2][j2] as T;
        }, growable: false),
        growable: false
    ));
  }

  // (i,j)-е алгебраическое дополнение матрицы (индексация начинается с 1)
  Object algComplement(int i, int j) {
    if((i+j).isEven) return minor(i,j);
    return -minor(i,j);
  }

  // Вычисляет определитель (детерминант) матрицы
  Object det() {
    assert(rowCount==colCount && colCount>0);
    if(colCount==1) return _val[0][1];

    var res = (this[1][1] is int)?0:0.0, sgn = -1;
    for(var j=1; j<=colCount; j++) {
      var detMnr = minor(1,j).det() as T;
      var a_1j = this[1][j] as T;
      res += a_1j*detMnr*(sgn*=-1);
    }
    return res;
  }

  //Возвращает матрицу, обратную к this
  Matrix inverse() {
    assert(colCount==rowCount, 'Матрица должна быть квадратной');
    var mDet = det() as T;
    assert(mDet!=0, 'Матрица должна быть не вырожденной.');
    var res = Matrix.zero(rowCount, colCount);
    var sgn = -1;
    for(var i=1; i<=rowCount; i++) {
      for(var j=1; j<=rowCount; j++) {
        res[j][i] = (sgn*=-1)*(minor(i, j).det() as T);
      }
    }
    return (res * (1/mDet)) as Matrix;
  }

  @override
  String toString() {
    // Вычисление ширины колонок матрицы
    var widthCols = <int>[];
    for(var j=1; j<=colCount; j++) {
      var w = 0;
      for(var i=1; i<=rowCount; i++) {
        var w2 = '${this[i][j]}'.length;
        if(w2>w) w=w2;
      }
      widthCols.add(w + (j==1?0:1));
    }
    // Формирование строки
    var res = '';
    for(var i=1; i<=rowCount; i++) {
      var rowStr = '';
      for(var j=1; j<=colCount; j++) {
        var itmStr = '${this[i][j]}';
        itmStr = itmStr.padLeft(widthCols[j-1], ' ');
        rowStr = '$rowStr$itmStr';
      }
      res = '$res|$rowStr|${(i==rowCount)?'':'\n'}';
    }
    return res;
  }
}

class LinearEquationSolver {
  late final Matrix A;
  late final Vector B;

  LinearEquationSolver(List<List<num>> A, List<num> B) {
    assert(A.length==B.length);
    this.A = Matrix(A);
    this.B = Vector<num>(B, isRow: false);
  }

  // Приводит расширенную матрицу системы лин. уравнений к треугольному виду
  List toTriangular() {
    var resA = Matrix.copy(A);
    var resB = Vector.copy(B);
    var coeff = 1.0;
    for(var j=1; j<=A.colCount; j++){
      for(var i=j+1; i<=A.rowCount; i++){
        if(resA[j][j]==0) {
          // Ищем первый не нулевой элемент ниже диагонали и меняем строки местами
          var swappedRows = false;
          for(var k=j+1; k<=A.rowCount; k++){
            if(A[k][j]!=0){
              resA.swapRows(j,k);
              resB.swap(j,k);
              swappedRows = true;
              break;
            }
          }
          if(!swappedRows) throw Exception('Система уравнений линейно зависима. Однозначного решения нет.');
        } else {
          coeff = (resA[i][j] as num) / (resA[j][j] as num);
          resA[i] -= resA[j] * coeff;
          resB[i] = (resB[i] as num) - (resB[j] as num) * coeff;
        }
      }
    }
    return [resA, resB];
  }

  //Решение системы лин. уравнений методом Гаусса
  Vector gaussMethod() {
    var tr = toTriangular();
    var trA = tr[0], trB = tr[1];
    var res = Vector.zero(B.dim);

    for(var i=B.dim; i>0; i--) {
      res[i]   = trB[i];
      for(var j=i+1; j<=B.dim; j++) {
        res[i] = (res[i] as num) - trA[i][j]*res[j];
      }
      res[i] = (res[i] as num) / trA[i][i];
    }
    return res;
  }

  //Решение системы лин. уравнений методом Крамера
  Vector kramerMethod() {
    var res = Vector.zero(B.dim);
    for(var j=1; j<=B.dim; j++) {
      var djDet = A.replaceCol(B._val, j).det();
      res[j] = (djDet as num) / (A.det() as num);
    }
    return res;
  }

  //Решение системы лин. уравнений методом обратной матрицы
  Vector directAlgMethod() => A.inverse() * B as Vector;

  @override
  String toString() {
    // Вычисление ширины колонок матрицы
    var widthCols = <int>[];
    for(var j=1; j<=A.colCount; j++) {
      var w = 0;
      for(var i=1; i<=A.rowCount; i++) {
        var w2 = '${A[i][j]}'.length;
        if(w2>w) w=w2;
      }
      widthCols.add(w + (j==1?0:1));
    }
    // Колонка свободных членов
    var w=0;
    for(var i=1; i<=B.dim; i++) {
      var w2 = '${B[i]}'.length;
      if(w2>w) w=w2;
    }
    widthCols.add(w+1);

    // Формирование строки
    var res = '';
    for(var i=1; i<=A.rowCount; i++) {
      var rowStr = '';
      for(var j=1; j<=A.colCount; j++) {
        var itmStr = '${A[i][j]}';
        itmStr = itmStr.padLeft(widthCols[j-1], ' ');
        rowStr = '$rowStr$itmStr';
      }
      var itmStrB = '${B[i]}';
      itmStrB = itmStrB.padLeft(widthCols[A.colCount], ' ');
      rowStr = '$rowStr|$itmStrB';

      res = '$res|$rowStr|${(i==A.rowCount)?'':'\n'}';
    }
    return res;
  }

}