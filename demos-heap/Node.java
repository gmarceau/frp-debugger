
class Node implements Comparable { 
  static final double notReached = Double.POSITIVE_INFINITY;
  String label;
  int x, y;
  double weight;
  Node(String label, int x, int y) {
    this.label = label;
    this.x = x;
    this.y = y;
    this.weight = notReached;
  }
  public int compareTo(Object obj) {
    Node other = (Node)obj;
    if (weight < other.weight) return -1;
    else if (weight > other.weight) return 1;
    else return 0;
  }
  public boolean equals(Object other) {
    if (other instanceof String)  return other.equals(label);
    else if (other instanceof Node) return ((Node)other).label.equals(label);
    else return false;
  }
  public int hashCode() { return label.hashCode(); }
  public String toString() { return "[node " + label + " : x " + x + "  y " + y + "  weight " + (int)weight + "]"; }
  static double sqr(double x) { return x * x; }

  double distanceTo(Node to) {
    return Math.sqrt(sqr(x - to.x) + sqr(y - to.y));
  }


}
