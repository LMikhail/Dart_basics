import 'dart:math' as math;

class Point {
  double x, y, z;
  Point(this.x, this.y, this.z);
  factory Point.zero() => Point(0.0, 0.0, 0.0);
  factory Point.abscissa()  => Point(1.0, 0.0, 0.0);
  factory Point.ordinate()  => Point(0.0, 1.0, 0.0);
  factory Point.applicate() => Point(0.0, 0.0, 1.0);

  /// Расстояние до точки p
  double distanceTo(Point p) {
    var _p = diff(this, p);
    return math.sqrt(scalarProduct(_p,_p));
  }

  /// Разность векторов
  Point diff(Point p1, Point p2) => Point(p1.x-p2.x, p1.y-p2.y, p1.z-p2.z);

  /// Скалярное произведение векторов p1, p2
  double scalarProduct(Point p1, Point p2) => p1.x*p2.x+p1.y*p2.y+p1.z*p2.z;

  /// Векторное произведение векторов p1, p2
  Point crossProduct(Point p1, Point p2) =>
      Point(p1.y*p2.z-p2.y*p1.z, p2.x*p1.z-p1.x*p2.z, p1.x*p2.y-p2.x*p1.y);

  /// Возвращает площадь треугольника с вершинами в точках p1, p2, p3
  /// как половину модуля векторного произведения (p2-p1)x(p3-p1)
  double triangleArea(Point p1, Point p2, Point p3) {
    var _cp = crossProduct(diff(p2, p1), diff(p3, p1));
    return 0.5*math.sqrt(scalarProduct(_cp, _cp));

  }
}