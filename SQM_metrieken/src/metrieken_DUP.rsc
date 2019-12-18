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

import metrieken_util;



public real calcDuplicationRatio(loc project) {
	set[loc] files = javaBestanden(project);
	
	list[str] linesPer6 = [];
	for (fileloc <- files) {
		list[str] lines = readFileLines(fileloc);
		list[str] result = [];
		
		for (l <- lines) {
			l = filterLine(l);
			if (l != "") {
			
				result += l;
				if (size(result) >= 6) {
					str resultstring = ("" | "<it><s>" | s <- result);
					linesPer6 += resultstring;
					result = result[1..];
				}
			}
		}
		bool multilineStarted = false;
	}
	
	int dupSearchSize = size(linesPer6);
	map[str, int] distr = distribution(linesPer6);
	
	int dupSize = (0 | it + (b > 1 ? b : 0) | <a, b> <- toRel(distr));
	
	real ratio = 100.0 * dupSize / dupSearchSize;
	
	return ratio;
}