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

public void metrieken_test2() {
	//loc fileloc = |project://smallsql/src/smallsql/database/language/Language.java|;
	loc fileloc = |project://smallsql/src/smallsql/junit/TestTokenizer.java|;
	list[str] lines = readFileLines(fileloc);
	list[str] result = [];
	
	for (l <- lines) {
		l = filterLine(l);
		if (l != "") {
			println(l);
			result += l;
		}
	}
	println(fileloc);
	println(size(result));
	
}

public void metrieken_test3() {
	str l = "{ STXADD_COMMENT_OPEN			  , \"Missing end comment mark (\'\'*/\'\').\" },";
	l = filterLine(l);
	println("filtered:");
	println(l);
}



// Alle bestanden in een project met extensie java
public set[loc] javaBestanden(loc project) {
   Resource r = getProject(project);
   return { a | /file(a) <- r, a.extension == "java" };
}

public void metrieken_test() {
	set[loc] files = javaBestanden(|project://smallsql/|);
	
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
	
	println(dupSize);
	println(dupSearchSize);
	println(ratio);
}

bool multilineStarted = false;
public str filterLine(str line) {
	// note: the order of cases is important. 
	switch(line) {
		case /^\s*\/\/.+$/: {  // single line comment, count as ignored
			return "";
		}
		case /^\s*\/\*.+\*\/\s*$/: { // multiline comment on one line, count as ignored
			return "";
		}
		case /".*((\*\/)|(\/\*)).*"/: { // multiline comment in string, so should not be ignored (cases can not be empty in rascal, so just used an empty statement)
			if (multilineStarted == false)
				return line;
		}
		case /'.*((\*\/)|(\/\*)).*'/: { // multiline comment in string, so should not be ignored (cases can not be empty in rascal, so just used an empty statement)
			if (multilineStarted == false)
				return line;
		}
		case /".*\/\/.*"/: {  // single line comment in string, so should not be ignored (cases can not be empty in rascal, so just used an empty statement)
			if (multilineStarted == false)
				return line;
		}
		case /^\s*<part1:.*?>\s*\/\/.*$/: {  // single line comment after code, so should not be ignored
			if (multilineStarted == false)
				return part1;
		}
		case /^\s*<part1:.*?>\s*\/\*.+\*\/\s*<part2:.*?>\s*$/: { // inline multiline comment (between two pieces of code on one line), so should not be ignored
			if (multilineStarted == false)
				return part1 + part2;
		}
		case /^\s*\/\*/: { // multiline comment start, count as ignored
			multilineStarted = true;
			return "";
		}
		case /\*\/\s*$/: { // multiline comment end, count as ignored
			multilineStarted = false;
			return "";
		}
		case /\s*<part1:.+>\s*\/\*/: { // multiline comment start after code, so should not be ignored
			multilineStarted = true;
			return part1;
		}
		case /\*\/\s*<part1:.*?>\s*/: { // multiline comment end before code, so should not be ignored
			multilineStarted = false;
			return part1;
		}
		case /^\s*$/: { // empty line, count as ignored
			return "";
		}
		case /^\s*<part1:.*>\s*$/: {
			if (multilineStarted == false) {  // line in between a multiline start and a multiline end, count as ignored
				return part1;
			}
			else {
				return "";
			}
		}
	}
	
	return "";
}