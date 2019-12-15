module metrieken_LOC

import IO;
import List;
import ListRelation;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import util::Resources;

import metrieken;

public void printPLOC() {
   	set[loc] smallsqlfiles = javaBestanden(|project://smallsql/|);
   	println("smallsql: <(0 | it + a | a <- range(calcPLOCForProjectFiles(smallsqlfiles)))>");
   	set[loc] hsqldbfiles = javaBestanden(|project://hsqldb/|);
   	println("hsqldb: <(0 | it + a | a <- range(calcPLOCForProjectFiles(hsqldbfiles)))>");
}

public lrel[loc, int] calcLLOCForProjectFiles(set[loc] files) {
	return [<a, calcLLOC(createAstFromFile(a, false))> | a <- files];
}


public lrel[loc, int] calcPLOCForProjectFiles(set[loc] files) {
	return [<a, calcPLOC(a)> | a <- files];
}

public lrel[loc, int] calcLLOCForMethods(set[loc] files) {
	lrel[loc, int] methodLLOCs = [];
   	
	for (a <- files) { 
		Declaration decl = createAstFromFile(a, false);
		
		visit(decl) {
			case \class(_, _, _, list[Declaration] body): {
				for (b <- body) {
					switch(b) {
						case \method(_, _, _, _, _): {
							methodLLOCs += <b.src, calcLLOC(b)>;
						}
						case \constructor(_, _, _, _): {
							methodLLOCs += <b.src, calcLLOC(b)>;
						}
					}
				}
			}
		}
	}
	return methodLLOCs;
}


public lrel[loc, int] calcPLOCForMethods(set[loc] files) {
	lrel[loc, int] methodPLOCs = [];
   	
	for (a <- files) { 
		Declaration decl = createAstFromFile(a, false);
		
		visit(decl) {
			case \class(_, _, _, list[Declaration] body): {
				for (b <- body) {
					switch(b) {
						case \method(_, _, _, _, _): {
							methodPLOCs += <b.src, calcPLOC(b.src)>;
						}
						case \constructor(_, _, _, _): {
							methodPLOCs += <b.src, calcPLOC(b.src)>;
						}
					}
				}
			}
		}
	}
	
	return methodPLOCs;
}

/**
	function calcPLOC
	returns the number of Physical Lines Of Code for a given location. Location can be a complete file or a file section.
	Physical Lines Of Code were determined to be all separate lines of code, not including empty lines or comments.
	\param location: the code that needs to be counted.
	\return the number of Physical Lines of Code for the given location 
*/
public int calcPLOC(loc location) {
	list[str] lines = readFileLines(location);
	int totalFileLines = size(lines);
	int linesIgnored = 0;
	bool multilineStarted = false;
	for (l <- lines) {
		// note: the order of cases is important. 
		switch(l) {
			case /".*\/\*.*?\*\/"/: { // multiline comment in string, so should not be ignored (cases can not be empty in rascal, so just used an empty statement)
				;
			}
			case /".*\/\/.*"/: {  // single line comment in string, so should not be ignored (cases can not be empty in rascal, so just used an empty statement)
				;
			}
			case /^\s*\/\/.*$/: {  // single line comment, count as ignored
				linesIgnored += 1;
			}
			case /^\s*\/\*.*\*\/\s*$/: { // multiline comment on one line, count as ignored
				linesIgnored += 1;
			}
			case /^\s*\/\*/: { // multiline comment start, count as ignored
				multilineStarted = true;
				linesIgnored += 1;
			}
			case /\*\/\s*$/: { // multiline comment end, count as ignored
				multilineStarted = false;
				linesIgnored += 1;
			}
			case /\/\*/: { // multiline comment start after code, so should not be ignored
				multilineStarted = true;
			}
			case /\*\//: { // multiline comment end before code, so should not be ignored
				multilineStarted = false;
			}
			case /^\s*$/: { // empty line, count as ignored
				linesIgnored += 1; 
			}
			case /./: {
				if (multilineStarted) {  // line in between a multiline start and a multiline end, count as ignored
					linesIgnored += 1;
				}
			}
		}
	}
	return totalFileLines - linesIgnored;
}



/**
	function calcLLOC
	returns the number of Logical Lines Of Code for a given declaration.
	Logical Lines Of Code were determined to be codeblock headings (including class, try, catch and switch) and statements (including return, break and continue).
	\param decl: the code that needs to be counted.
	\return the number of Physical Lines of Code for the given location 
*/
public int calcLLOC(Declaration decl) {
	int count = 0;
	visit(decl) {  
		case \declarationStatement(_): {
         	count+=1;
      	} 
  		case \expressionStatement(_): {
     		count+=1;
  		} 
  		case \return(_): {
     		count+=1;
  		} 
  		case \return(): {
     		count+=1;
  		} 
  		case \break(_): {
     		count+=1;
  		} 
  		case \break(): {
     		count+=1;
  		} 
  		case \continue(_): {
     		count+=1;
  		} 
  		case \continue(): {
     		count+=1;
  		} 
  		case \constructorCall(_, _, _): {
     		count+=1;
  		} 
  		case \constructorCall(_, _): {
     		count+=1;
  		} 
		case \method(_, _, _, _): {
			count += 1;
		}
		case \field(_, _): {
			count += 1;
		}
		case \initializer(_): {
			count += 1;
		}
		
		case \block(_): {
			count += 1;
		}

		case \switch(_, _): {
			count += 1;
		}
		case \class(_): {
			count += 1;
		}
		case \class(_, _, _, _): {
			count += 1;
		}
		case \interface(_, _, _, _): {
			count += 1;
		}
		case \throw(_): {
			count += 1;
		}
		case \try(_, _): {
			count += 1;
		}
		case \try(_, _, _): {
			count += 1;
		}                                        
		case \catch(_, _): {
			count += 1;
		}
	}
	return count;
}