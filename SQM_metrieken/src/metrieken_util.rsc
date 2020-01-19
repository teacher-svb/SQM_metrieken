module metrieken_util

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

public list[Declaration] getMethodsFromProject(loc project) {
	
   	set[loc] files = javaBestanden(project);
   	
	list[Declaration] result = [];
   	for (f <- files) {	
   		result += getMethods(f);
   	}
   	return result;
}

// TODO: use m3
public list[Declaration] getMethods(loc file) {
   	
	list[Declaration] result = [];
	Declaration decl = createAstFromFile(file, false);
	
	visit(decl) {
		case \class(_, _, _, list[Declaration] body): {
			for (b <- body) {
				switch(b) {
					case \method(_, _, _, _, _): {
						result += b;
					}
					case \constructor(_, _, _, _): {
						result += b;
					}
				}
			}
		}
	}

	return result;
}



// Alle bestanden in een project met extensie java
public set[loc] javaBestanden(loc project) {
   Resource r = getProject(project);
   return { a | /file(a) <- r, a.extension == "java" };
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