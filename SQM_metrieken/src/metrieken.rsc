module metrieken

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

// Alle bestanden in een project met extensie java
public set[loc] javaBestanden(loc project) {
   Resource r = getProject(project);
   return { a | /file(a) <- r, a.extension == "java" };
}

public void metrieken_test() {
	set[loc] files = javaBestanden(|project://hsqldb/|);
	
	list[str] linesPer6 = [];
	for (fileloc <- files) {
		print("*");
		list[str] lines = readFileLines(fileloc);
		list[str] result = [];
		
		for (l <- lines) {
			if (ignoreLine(l) == false) {
				result += l;
				if (size(result) >= 6) {
					str resultstring = ("" | "<it>\n<s>" | s <- result);
					linesPer6 += resultstring;
					result = result[1..];
				}
			}
		}
	}
	
	int dupSearchSize = size(linesPer6);
	map[str, int] distr = distribution(linesPer6);
	
	int dupSize = (0 | it + (b > 1 ? b : 0) | <a, b> <- toRel(distr));
	
	real ratio = 100.0 * dupSize / dupSearchSize;
	
	println(dupSize);
	println(dupSearchSize);
	println(ratio);
}









// ------------------------------------------------------



bool multilineStarted = false;
public bool ignoreLine(str line) {

	str printstr = "          ";
	// note: the order of cases is important. 
	switch(line) {
		case /".*\/\*.*?\*\/"/: { // multiline comment in string, so should not be ignored (cases can not be empty in rascal, so just used an empty statement)
			;
			return false;
		}
		case /".*\/\/.*"/: {  // single line comment in string, so should not be ignored (cases can not be empty in rascal, so just used an empty statement)
			;
			return false;
		}
		case /^\s*\/\/.*$/: {  // single line comment, count as ignored
			printstr = "SL COMMENT";
			return true;
		}
		case /^\s*\/\*.*\*\/\s*$/: { // multiline comment on one line, count as ignored
			//linesIgnored += 1;
			printstr = "ML COMMENT";
			return true;
		}
		case /^.*\/\*.*\*\/.*$/: { // inline multiline comment (between two pieces of code on one line), so should not be ignored
			;
			return false;
		}
		case /^\s*\/\*/: { // multiline comment start, count as ignored
			multilineStarted = true;
			//linesIgnored += 1;
			printstr = "ML CMT STR";
			return true;
		}
		case /\*\/\s*$/: { // multiline comment end, count as ignored
			multilineStarted = false;
			//linesIgnored += 1;
			printstr = "ML CMT END";
			return true;
		}
		case /\/\*/: { // multiline comment start after code, so should not be ignored
			multilineStarted = true;
			return false;
		}
		case /\*\//: { // multiline comment end before code, so should not be ignored
			multilineStarted = false;
			return false;
		}
		case /^\s*$/: { // empty line, count as ignored
			//linesIgnored += 1; 
			printstr = "EMPTY LINE";
			return true;
		}
		case /./: {
			if (multilineStarted) {  // line in between a multiline start and a multiline end, count as ignored
				//linesIgnored += 1;
				printstr = "ML CMT ---";
				return true;
			}
		}
	}
	bool multilineStarted = false;
	// FOR DEBUGGING PURPOSES
	/*print("<printstr><l>"); 
	print("\n");*/
	return false;
}