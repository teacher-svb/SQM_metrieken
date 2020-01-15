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
import vis::Figure;
import vis::Render;
import analysis::graphs::Graph;

import metrieken_util;



public real calcDuplicationRatio(loc project) {
	
	lrel[loc location, str blocks] linesPer6 = getBlocksOf6Lines(project);
	
	int dupSearchSize = size(linesPer6);
	map[str, int] distr = distribution(linesPer6.blocks);
	
	int dupSize = (0 | it + (b > 1 ? b : 0) | <a, b> <- toRel(distr));
	
	real ratio = 100.0 * dupSize / dupSearchSize;
	
	return ratio;
}

public Figure showGraph(lrel[loc, loc] listrelation) {
	Graph[loc] g = {<a,b> | <a,b> <- listrelation};

   nodes = [ box(text(s.file), size(40), id(s.uri), lineWidth(size(g[s]) + size(invert(g)[s])), fillColor("yellow"))
           | s <- carrier(g)
           ];
   edges = [ edge(a.uri, b.uri, lineWidth((0 | it + 1 | c <- listrelation, (c[0] == a && c[1] == b) || (c[0] == b && c[1] == a) )))
           | <a, b> <- g
           ];
   return graph(nodes, edges, hint("layered"), gap(40));
}

public void createDuplicationGraph(loc project) {
	
	map[str block, list[loc] locs] linesPer6WithFiles = getBlocksOf6LinesWithFiles(project);
	println("blocks calculated");
	
	lrel[loc, loc] graph = [];
	
	for (files <- linesPer6WithFiles.locs) {
		graph += [<a,b> | <a, b> <- files join files, a != b];
	}
	print("graph assembled");
	
	
	render(showGraph(graph));
}

public lrel[loc, str] getBlocksOf6Lines(loc project) {
	set[loc] files = javaBestanden(project);
	
	lrel[loc location, str blocks] linesPer6 = [];
	for (fileloc <- files) {
		list[str] lines = readFileLines(fileloc);
		list[str] result = [];
		
		for (l <- lines) {
			l = filterLine(l);
			if (l != "") {
			
				result += l;
				if (size(result) >= 6) {
					str resultstring = ("" | "<it><s>" | s <- result);
					linesPer6 += <fileloc, resultstring>;
					result = result[1..];
				}
			}
		}
	}
	return linesPer6;
}

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