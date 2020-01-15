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

public Figure showGraph(Graph[str] g) {
   nodes = [ box(text(s), id(s), size(30), fillColor("yellow"))
           | s <- carrier(g) 
           ];
   edges = [ edge(a, b, toArrow(ellipse(size(10))))
           | <a, b> <- g
           ];
   return graph(nodes, edges, hint("layered"), gap(40));
}

public void createDuplicationGraph(loc project) {
	
	/*lrel[loc location, str blocks] filesWithLinesPer6 = getBlocksOf6Lines(project);
	println("blocks calculated");*/
	
	map[str block, list[loc] locs] linesPer6WithFiles = getBlocksOf6LinesWithFiles(project);
	println("blocks calculated");
	
	/*
	// count how many times each location exists in linesPer6
	map[loc, int] locDistr = distribution(filesWithLinesPer6.location);
	print("*");
	// count how many times each block exists in linesPer6
	map[str, int] blockDistr = distribution(filesWithLinesPer6.blocks);
	print("*");
	*/
	
	Graph[str] graph = {};
	
	/*list[list[loc]] groupedFiles = groupDomainByRange(filesWithLinesPer6);
	println("files grouped");*/
	
	for (files <- linesPer6WithFiles.locs) {
		graph += {<a.file,b.file> | <a, b> <- files join files, a != b};
	}
	print("graph assembled");
	
	
	
	/*lrel[str blocks, list[loc location] locations] linesPer6WithFiles = [];
	
	for (block <- filesWithLinesPer6) {
		list[loc] files = [];
		files += [ a | <a,b> <- filesWithLinesPer6, b == block[1]];
		linesPer6WithFiles += <block[1], files>;
	}
	println("files grouped per block");
	
	for (block <- linesPer6WithFiles) {
		graph += {<a.uri.file,b.uri.file> | <a, b> <- block[1] join block[1], a != b};
	}
	print("graph assembled");*/
	
	render(showGraph(graph));
	
	
	/*lrel[loc location, str block, int locSize, int blockDupes] dupScoresPerFile = [];
	
	for (locSize <- locDistr) {
		list[str] blocks = [b | <a, b> <- linesPer6, a == locSize[0]];
		
		for (block <- blocks) {
			dupScoresPerFile += <locSize[0], block, locSize[1], blockDistr[block]>;
		}
	}*/
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