import java.awt.Frame;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.awt.Graphics;
import java.awt.Color;
import java.io.*;
import graph.*;
import java.util.*;

class DijkstraTest {
  public static void main(String[] args) throws IOException {
    //DirectedGraph graph = readGraph(args[0]);
    DirectedGraph graph = readGraph("test8.gml");
    
    DijkstraSolver d = new DijkstraSolver(graph, firstNode); 
    //graph.printGraph();
    //graphWindow(graph);
  }

  static Node firstNode = null;

  public static DirectedGraph readGraph(String filename) throws IOException {
    BufferedReader reader = new BufferedReader(new FileReader(filename));
    DirectedGraph graph = new DirectedGraph();
    HashMap adjs = new HashMap();
    HashMap label2node = new HashMap();
    
    for(;;) {
      String fatLine = reader.readLine();
      if (fatLine == null) break;
      String line = fatLine.trim();
      if (line.equals("")) continue;

      StringTokenizer tok = new StringTokenizer(line);
      String label = tok.nextToken();
      int x = Integer.parseInt(tok.nextToken());
      int y = Integer.parseInt(tok.nextToken());
      String colon = tok.nextToken();
      Node node = new Node(label, x, y);
      if (firstNode == null) firstNode = node;
      graph.addNode(node);
      label2node.put(label, node);
      
      if (!colon.equals(":")) 
        throw new RuntimeException("Missing a colon in node definition");
      
      LinkedList adj = new LinkedList();
      while(tok.hasMoreTokens())
        adj.add(tok.nextToken());
      
      adjs.put(node, adj);
    } 
    
    for(Iterator nodeIt = adjs.keySet().iterator(); nodeIt.hasNext(); )
    {
      Node node = (Node)nodeIt.next();
      for(Iterator adjIt = ((List)adjs.get(node)).iterator(); adjIt.hasNext(); )
        try { graph.addEdge(node, label2node.get(adjIt.next())); }
        catch(RuntimeException e) { System.out.println("Error: " + node); throw e; }
    }
    return graph;
  }

  public static void graphWindow(final DirectedGraph graph) {
    double maxX = 0;
    double maxY = 0;
    for(Iterator nodeIt = graph.getNodes().iterator(); nodeIt.hasNext(); )
    {
      Node node = (Node)nodeIt.next();
      maxX = Math.max(maxX, node.weight);
      maxY = Math.max(maxY, node.weight);
    }

    final Frame frame = new Frame("Directed Graph") { 
      public void paint(Graphics g) {
        
        g.setColor(Color.black);
        for(Iterator nodeIt = graph.getNodes().iterator(); nodeIt.hasNext(); )
        {
          Node from = (Node)nodeIt.next();
          for(Iterator succIt = graph.getSuccsOf(from).iterator(); succIt.hasNext(); )
          {
            Node to = (Node)succIt.next();
            g.drawLine(from.x, from.y, to.x, to.y);
            double dx = to.x - from.x;
            double dy = to.y - from.y;
            g.fillOval((int)(to.x - dx * 0.05), (int)(to.y - dy * 0.05), 4, 4);
          }        
        }
        
        g.setColor(Color.blue);
        for(Iterator nodeIt = graph.getNodes().iterator(); nodeIt.hasNext(); )
        {
          Node node = (Node)nodeIt.next();
          g.fillOval(node.x-3, node.y-3, 6, 6);
          g.drawString(node.label, node.x - 6, node.y - 10);
        }
      }
    };
    frame.addWindowListener(new WindowAdapter() {
      public void windowClosing(WindowEvent e) { frame.dispose(); }
    });
    frame.setLocation((int)maxX+20, (int)maxY+20);
    frame.show();
  }
}
