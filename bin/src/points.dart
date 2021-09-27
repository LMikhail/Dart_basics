import 'dart:math' as math;

class Point {
  double x, y, z;
  Point(this.x, this.y, this.z);
  static Point zero = Point(0.0, 0.0, 0.0);
  factory Point.abscissa()  => Point(1.0, 0.0, 0.0);
  factory Point.ordinate()  => Point(0.0, 1.0, 0.0);
  factory Point.applicate() => Point(0.0, 0.0, 1.0);

  Point  operator -() => Point(-x,-y,-z);
  Point  operator -(Point p) => Point(x-p.x,y-p.y,z-p.z);
  Point  operator +(Point p) => Point(x+p.x,y+p.y,z+p.z);
  Point  operator *(Point p) => Point(y*p.z-p.y*z, p.x*z-x*p.z, x*p.y-p.x*y);
  double operator &(Point p) => x*p.x+y*p.y+z*p.z; //скалярное произведение

  @override
  bool operator ==(Object p) {
    if (identical(this, p)) return true;
    if (p.runtimeType != runtimeType)  return false;
    return p is Point
        && p.x == x
        && p.y == y
        && p.z == x;
  }

  double length() => math.sqrt(this&this);

  /// Расстояние до точки p
  double distanceTo(Point p) => math.sqrt((this-p)&(this-p));

  /// Возвращает площадь треугольника с вершинами в точках p1, p2, p3
  /// как половину модуля векторного произведения (p2-p1)x(p3-p1)
  static double triangleArea(Point p1, Point p2, Point p3) {
    var _cp = (p2 - p1)*(p3 - p1);
    return 0.5*math.sqrt(_cp&_cp);
  }

  @override
  String toString() => '(${x}, ${y}, ${z})';

}