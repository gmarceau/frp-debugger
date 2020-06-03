import graph.*;
import java.util.*;

class DijkstraSolver {
  
  public HashMap backtrace = new HashMap();
  private PriorityQueue q = new PriorityQueue();

  public DijkstraSolver(DirectedGraph graph, 
                        Node source) {
    source.weight = 0.0;
    q.addAll(graph.getNodes());

    while(!q.isEmpty()) {
      Node node = (Node)q.extractMin();
      List successors = graph.getSuccsOf(node);
      for(Iterator succIt = successors.iterator(); 
          succIt.hasNext(); )
        relax(node, (Node)succIt.next());
    }
    System.out.println("Result backtrace:\n" + 
                       backtrace.keySet());
  }

  public void relax(Node origin, Node dest) {
    double candidateWeight = 
      origin.weight + origin.distanceTo(dest);
    if (candidateWeight < dest.weight) {
      dest.weight = candidateWeight;
      backtrace.put(dest, origin);
    }
  }
}
