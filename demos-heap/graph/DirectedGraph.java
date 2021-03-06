/* Soot - a J*va Optimization Framework
 * Copyright (C) 1999 Patrice Pominville, Raja Vallee-Rai, Patrick Lam
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

/*
 * Modified by the Sable Research Group and others 1997-1999.  
 * See the 'credits' file distributed with Soot for the complete list of
 * contributors.  (Soot is distributed at http://www.sable.mcgill.ca/soot)
 */

/* Reference Version: $SootVersion: 1.2.3.dev.4 $ */

package graph;


import java.util.*;
import java.util.*;




/**
 *   HashMap based implementation of a MutableBlockGraph.
 */

public class DirectedGraph {
		

    protected HashMap nodeToPreds = new HashMap();
    protected HashMap nodeToSuccs = new HashMap();

    protected List heads = new ArrayList();
    protected List tails = new ArrayList();

    public DirectedGraph()
    {
    }

    /** Removes all nodes and edges. */
    public void clearAll() {
        nodeToPreds = new HashMap();
        nodeToSuccs = new HashMap();
        heads = new ArrayList();
        tails = new ArrayList();
    }

    public Object clone() {
        DirectedGraph g = new DirectedGraph();
        g.nodeToPreds = (HashMap)nodeToPreds.clone();
        g.nodeToSuccs = (HashMap)nodeToSuccs.clone();
        g.heads = new ArrayList(heads);
        g.tails = new ArrayList(tails);
        return g;
    }

    /* Returns an unbacked list of heads for this graph. */
    public List getHeads()
    {
        ArrayList l = new ArrayList(); l.addAll(heads);
        return Collections.unmodifiableList(l);
    }

    /* Returns an unbacked list of tails for this graph. */
    public List getTails()
    {
        ArrayList l = new ArrayList(); l.addAll(tails);
        return Collections.unmodifiableList(l);
    }

    public List getPredsOf(Object s)
    {
        List l = (List) nodeToPreds.get(s);
        if (l != null)
            return Collections.unmodifiableList(l);
        else
            throw new RuntimeException(s+"not in graph!");
    }

    public List getSuccsOf(Object s)
    {
        List l = (List) nodeToSuccs.get(s);
        if (l != null)
            return Collections.unmodifiableList(l);
        else
            throw new RuntimeException(s+"not in graph!");
    }

    public int size()
    {
        return nodeToPreds.keySet().size();
    }

    public Iterator iterator()
    {
        return nodeToPreds.keySet().iterator();
    }

    public void addEdge(Object from, Object to)
    {
        if (from == null || to == null)
						throw new RuntimeException("edge from or to null");

        if (containsEdge(from, to))
            return;

        List succsList = (List)nodeToSuccs.get(from);
        if (succsList == null)
            throw new RuntimeException(from + " not in graph!");

        List predsList = (List)nodeToPreds.get(to);
        if (predsList == null)
            throw new RuntimeException(to + " not in graph!");

        if (heads.contains(to))
            heads.remove(to);

        if (tails.contains(from))
            tails.remove(from);

        succsList.add(to);
        predsList.add(from);
    }

    public void removeEdge(Object from, Object to)
    {
        if (!containsEdge(from, to))
            return;

        List succsList = (List)nodeToSuccs.get(from);
        if (succsList == null)
            throw new RuntimeException(from + " not in graph!");

        List predsList = (List)nodeToPreds.get(to);
        if (predsList == null)
            throw new RuntimeException(to + " not in graph!");

        succsList.remove(to);
        predsList.remove(from);

        if (succsList.isEmpty())
            tails.add(from);

        if (predsList.isEmpty())
            heads.add(to);
    }

    public boolean containsEdge(Object from, Object to)
    {
				List succs = (List)nodeToSuccs.get(from);
				if (succs == null)
						return false;
        return succs.contains(to);
    }

    public boolean containsNode(Object node)
    {
        return nodeToPreds.keySet().contains(node);
    }
    public List getNodes()
    {
        return Arrays.asList(nodeToPreds.keySet().toArray());
    }

    public void addNode(Object node)
    {
				if (containsNode(node))
						throw new RuntimeException("Node already in graph");
				
				nodeToSuccs.put(node, new ArrayList());
        nodeToPreds.put(node, new ArrayList());
        heads.add(node); 
				tails.add(node);
    }

    public void removeNode(Object node)
    {
        List succs = (List)((ArrayList)nodeToSuccs.get(node)).clone();
        for (Iterator succsIt = succs.iterator(); succsIt.hasNext(); )
            removeEdge(node, succsIt.next());
        nodeToSuccs.remove(node);

        List preds = (List)((ArrayList)nodeToPreds.get(node)).clone();
        for (Iterator predsIt = preds.iterator(); predsIt.hasNext(); )
            removeEdge(predsIt.next(), node);
        nodeToPreds.remove(node);

        if (heads.contains(node))
            heads.remove(node); 

        if (tails.contains(node))
            tails.remove(node);
    }

    public void printGraph() {

	for (Iterator it = iterator(); it.hasNext(); ) {
	    Object node = it.next();
	    System.out.println("Node = "+node);
	    System.out.println("Preds:");
	    for (Iterator predsIt = getPredsOf(node).iterator(); predsIt.hasNext(); ) {
		System.out.print("     ");
		System.out.println(predsIt.next());
	    }
	    System.out.println("Succs:");
	    for (Iterator succsIt = getSuccsOf(node).iterator(); succsIt.hasNext(); ) {
		System.out.print("     ");
		System.out.println(succsIt.next());
	    }
	}
    }


}

 
