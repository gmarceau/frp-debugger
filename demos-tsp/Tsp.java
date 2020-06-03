import java.io.*;
import java.util.*;

public class Tsp {
    static double distances[][];
    static int n;
    static boolean ignore[];
    static double bestCost;
    static int bestSoln[];
    static Edge edges[];
    static Edge neighbors[][];

    static class Edge implements Comparable {
	public double length;
	public int v1;
	public int v2;
	public Edge(int _1, int _2, double _len) {
	    v1 = _1;
	    v2 = _2;
	    length = _len;
	}
	public int compareTo(Object o) {
	    Edge e = (Edge) o;
	    if (length < e.length)
		return -1;
	    else if (length == e.length)
		return 0;
	    else
		return 1;
	}
    }

    static double dist(int x1, int y1, int x2, int y2) {
	double dx = x2 - x1;
	double dy = y2 - y1;
	return Math.sqrt(dx * dx + dy * dy);
    }

    static double tourCost(int tour[], int length) {
	double cost = 0.0;
	for (int i = 0; i < length; i++)
	    cost += distances[tour[i]]
		[tour[(i + 1) % length]];
	return cost;
    }

    static boolean dfs(boolean edgeMatrix[][],
			      int start, int goal,
			      int prev) {
	if (start == goal)
	    return true;
	else {
	    for (int i = 0; i < n; i++)
		if (edgeMatrix[start][i] &&
		    (i != prev) &&
		    dfs(edgeMatrix, i, goal, start))
		    return true;
	    return false;
	}
    }

    static double mst(int finalSize) {
	boolean edgeMatrix[][] = new boolean[n][n];
	int size = 0;
	double cost = 0.0;
	for (int i = 0; i < n * (n - 1) / 2; i++)
	    if (size == finalSize)
		return cost;
	    else {
		Edge e = edges[i];
		if (!(ignore[e.v1] ||
		      ignore[e.v2] ||
		      dfs(edgeMatrix, e.v1, e.v2, -1))) {
		    edgeMatrix[e.v1][e.v2] = true;
		    edgeMatrix[e.v2][e.v1] = true;
		    cost += e.length;
		    size++;
		}
	    }
	return 1000000.0;
    }

    static double bestRemainingEdge(int v) {
	double best = 100000.0;
	for (int i = 0; i < n; i++)
	    if (!ignore[i] && (distances[v][i] < best))
		best = distances[v][i];
	return best;
    }

    static int findRemaining() {
	int i;
	for (i = 0; (i < n) && ignore[i]; i++) {
	}
	return i;
    }

    static void bnb(int vertices[], int nVertices,
			   double cost) {
	int v = vertices[nVertices - 1];
	if (nVertices == n - 1) {
	    int lastNode = findRemaining();
	    vertices[n - 1] = lastNode;
	    double finalCost = cost + distances[v][lastNode]
		+ distances[lastNode][vertices[0]];
	    if (finalCost < bestCost) {
		System.out.println("found a solution with cost " + finalCost);
		bestCost = finalCost;
		for (int i = 0; i < n; i++)
		    bestSoln[i] = vertices[i];
	    }
	} else {
	    for (int i = 0; i < n - 1; i++) {
		int neigh = neighbors[v][i].v1;
		if (!ignore[neigh]) {
		    ignore[neigh] = true;
		    if (mst(n - 2 - nVertices) + cost +
			distances[v][neigh] +
			bestRemainingEdge(vertices[0]) +
			bestRemainingEdge(vertices[neigh]) <
			bestCost) {
			vertices[nVertices] = neigh;
			bnb(vertices, nVertices + 1,
			    cost + distances[v][neigh]);
		    }
		    ignore[neigh] = false;
		}
	    }
	}
    }

    public static void main(String args[]) 
	throws FileNotFoundException, IOException
    {
	PrintWriter err = new PrintWriter(System.err);
	BufferedReader inp = null;
	double bound = 1000000.0;
	switch (args.length) {
	case 0:
	    inp = new BufferedReader(new InputStreamReader(System.in));
	    break;
	case 2:
	    bound = new Double(args[1]).doubleValue();
	case 1:
	    inp = new BufferedReader(new FileReader(args[0]));
	    break;
	default:
	    err.println("usage: java Tsp [filename [bound]]");
	    System.exit(1);
	}
	inp.readLine();
	inp.readLine();
	inp.readLine();
	n = new Integer(inp.readLine()).intValue();
	int xcoords[] = new int[n];
	int ycoords[] = new int[n];
	int x, y;
	for (int i = 0; i < n; i++) {
	    String ln = inp.readLine();
	    String s1 = ln.substring(1, ln.length() - 1);
	    String ss[] = s1.split(",");
	    x = new Integer(ss[0]).intValue();
	    y = new Integer(ss[1]).intValue();
	    xcoords[i] = x;
	    ycoords[i] = y;
	}
	edges = new Edge[n * (n - 1) / 2];
	Vector[] neighs = new Vector[n];
	for (int i = 0; i < n; i++)
	    neighs[i] = new Vector();
	distances = new double[n][n];
	int nextEdge = 0;
	for (int i = 0; i < n - 1; i++) {
	    for (int j = i + 1; j < n; j++) {
		double d = dist(xcoords[i], ycoords[i],
				xcoords[j], ycoords[j]);
		distances[i][j] = d;
		distances[j][i] = d;
		edges[nextEdge] = new Edge(i, j, d);
		neighs[i].add(new Edge(j, i, d));
		neighs[j].add(new Edge(i, j, d));
		nextEdge++;
	    }
	}
	// Arrays.sort(edges);
	neighbors = new Edge[n][n - 1];
	for (int i = 0; i < n; i++) {
	    Edge[] es = (Edge[]) neighs[i].toArray(neighbors[i]);
	    Arrays.sort(es);
	    neighbors[i] = es;
	}
	ignore = new boolean[n];
	//ignore[1] = true;
	int vertices[] = new int[n];
	vertices[0] = 18;
	bestCost = bound;
	bestSoln = new int[n];
	bnb(vertices, 1, 0.0);
	System.out.println("bestCost = " + bestCost);
	System.out.print("bestSoln = [");
	for (int i = 0; i < n - 1; i++)
	    System.out.print("" + bestSoln[i] + ", ");
	System.out.println("" + bestSoln[n - 1] + "]");
    }
}
