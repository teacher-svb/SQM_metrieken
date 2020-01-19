module metrieken_DUP

import IO;
import List;
import Map;
import Relation;
import ListRelation;
import Set;
import String;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import util::Resources;
import util::Math;
import vis::Figure;
import vis::Render;
import analysis::graphs::Graph;

import metrieken_util;


/**
	function calcDuplicationRatio
	calculates the duplication ratio for a complete project
	\return a percentage, comparing the number of duplicated lines vs the total number of lines to check for duplication
*/
public real calcDuplicationRatio(loc project) {
	lrel[str, list[loc]] linesPer6 = toList(getBlocksOf6LinesWithFiles(project));
	
	int totalBlocks = (0 | it + size(b) | <a, b> <- linesPer6);
	
	int dupSize = (0 | it + (size(b) > 1 ? size(b) : 0) | <a, b> <- linesPer6);
	
	real ratio = 100.0 * dupSize / totalBlocks;
	return ratio;
}

/**
	function createDuplicationGraph
	creates a graph figure that shows where duplicate code is located, and between what files this
	duplicate code is shared.
	\return a figure, where a graph with its components (= subgraphs) are layed out in a grid
*/
public Figure createDuplicationGraph(loc project) {
	
	map[str block, list[loc] locs] linesPer6WithFiles = getBlocksOf6LinesWithFiles(project);
	println("blocks calculated");
	
	// join the locations for every block with itself
	// this creates a list relation where all locations of that block are connected with eachother
	// (a list relation is used, so duplicates are maintained)
	lrel[loc, loc] graphList = [];
	for (files <- linesPer6WithFiles.locs) {
		graphList += [<a,b> | <a, b> <- files join files, a != b];
	}
	println("graph assembled");
	
	// cast the list relation to a graph
	Graph[loc] g = {<a,b> | <a,b> <- graphList};
	// deconstruct the graph into its components (= separating the 'subgraphs')
	set[set[loc]] components = connectedComponents(g);
	components = { a | a <- components, size(a) > 2};
	println("graph deconstructed to components");
	
	// we want to show the subgraphs in a square grid, so we need to know how many subgraphs will be drawn
	int numComps = size(components);
	// the column size is the square root of the number of subgraphs
	int colSize = ceil(sqrt(numComps));
	
	// a grid needs a list of a list of figures
	list[Figures] figuresList = [];
	// each row is a list of figures
	Figures figures = [];
	
	println([size(a) | a <- components]);
	
	int counter = 0;
	// casting the list relation to a graph removed all the duplicates
	// however, the duplicates indicate the amount of duplicate code in a relation or file
	// so now we recapture those duplicates, that occured in the original list relation
	// and match them to each component (= subgraph)
	for (compFiles <- components) {
		counter += 1;
		// find all relations that occur in the component (= subgraph) that also occur in the
		// original list relation from which the graph was created
		// this recaptures the duplicates
		//lrel[loc, loc] subgraphList = [<a,b> | <a, b> <- compFiles join compFiles, a != b];
		
		// create a graph from the subgraphlist, to easily convert to nodes and edges
		//Graph[loc] subgraph = {<a,b> | <a,b> <- compFiles join compFiles, a != b};
		
		
		Graph[loc] subgraph = {<a,b> | <a,b> <- graphList, a != b, a in compFiles, b in compFiles};
        
        // construct nodes and edges from the subgraph and original graphlist (edge width)
		nodes = [ ellipse(text(s.file), size(80), id(s.uri), lineWidth(size(subgraph[s]) + size(invert(subgraph)[s])), fillColor("yellow"))
				| s <- carrier(subgraph)];
		edges = [ edge(a.uri, b.uri, lineWidth((0 | it + 1 | c <- graphList, (c[0] == a && c[1] == b) || (c[0] == b && c[1] == a) )))
				| <a, b> <- subgraph];
		        
		Figure subgraphFigure = graph(nodes, edges, hint("layered"), std(size(30)), gap(40));
		figures += subgraphFigure;
		
		if (counter % colSize == 0) {
			figuresList += [figures];
			figures = [];
		}
		print("*");
	}
	
	Figure f = grid(figuresList);
	return f;
}

/**
	function getBlocksOf6LinesWithFiles
	deconstruct each file into blocks of 6 lines of code (using the same filter as PLOC)
	for each block, assemble a list of locations where that block occurs
*/
public map[str, list[loc]] getBlocksOf6LinesWithFiles(loc project) {
	set[loc] files = javaBestanden(project);
	
	map[str, list[loc]] linesPer6WithFiles = ();
	
	for (fileloc <- files) {
		list[str] lines = readFileLines(fileloc);
		list[str] result = [];
		
		for (l <- lines) {
			l = filterLine(l);
			if (l != "") {
			
				result += l;
				if (size(result) >= 6) {
					str resultstring = ("" | "<it><s>" | s <- result);
					
					if (resultstring in linesPer6WithFiles) {
						linesPer6WithFiles[resultstring] += fileloc;
					}
					else {
						linesPer6WithFiles += (resultstring : [fileloc]);
					}
					
					result = result[1..];
				}
			}
		}
	}
	return linesPer6WithFiles;
}