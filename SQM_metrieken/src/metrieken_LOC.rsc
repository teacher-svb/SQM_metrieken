module metrieken_LOC

import IO;
import List;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import util::Resources;

import metrieken;



public void printLLOCForProjectFiles() {
   	set[loc] files = javaBestanden(|project://hsqldb/|);
   	
	for (a <- files) { 
		Declaration decl = createAstFromFile(a, false);
		int count = calcLLOC(decl);
		println("<a>: <count>");
	}
}

public void printLLOCForMethods() {
   	set[loc] files = javaBestanden(|project://hsqldb/|);
   	
	for (a <- files) { 
		Declaration decl = createAstFromFile(a, false);
		
		visit(decl) {
			case \class(_, _, _, list[Declaration] body): {
				for (b <- body) {
					switch(b) {
						case \method(_, _, _, _, _): {
							calcMethodLLOC(b);
						}
						case \constructor(_, _, _, _): {
							calcMethodLLOC(b);
						}
					}
				}
			}
		}
	}
}

public void calcMethodLLOC(Declaration decl) {
	int count = calcLLOC(decl);
	count-=1;
	println("<decl.name>: <count>");
}



public void printPLOCForProjectFiles() {
   	set[loc] files = javaBestanden(|project://smallsql/|);
   	
   	int counter = 0;
	for (a <- files) { 
		int count = calcPLOC(a);
		println("<a>: PLOC: <count> ");
	}
}

public int calcPLOC(loc file) {
	list[str] lines = readFileLines(file);
	int totalFileLines = size(lines);
	int linesIgnored = 0;
	bool multilineStarted = false;
	for (l <- lines) {
		switch(l) {
			case /".*\/\*.*?\*\/"/: { // multiline comment in string, so count
				int counter = 0;
			}
			case /".*\/\/.*"/: {  // single line comment in string, so count
				int counter = 0;
			}
			case /^\s*\/\/.*$/: {
				linesIgnored += 1;
			}
			case /^\s*\/\*.*\*\/\s*$/: { // multiline comment on one line, dont count
				linesIgnored += 1;
			}
			case /^\s*\/\*/: { // multiline comment start, dont count
				multilineStarted = true;
				linesIgnored += 1;
			}
			case /\*\/\s*$/: { // multiline comment end, dont count
				multilineStarted = false;
				linesIgnored += 1;
			}
			case /\/\*/: { // multiline comment start after code, so count
				multilineStarted = true;
			}
			case /\*\//: { // multiline comment end before code, so count
				multilineStarted = false;
			}
			case /^\s*$/: {
				linesIgnored += 1;
			}
			case /./: {
				if (multilineStarted) {
					linesIgnored += 1;
				}
			}
		}
	}
	return totalFileLines - linesIgnored;
}


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
		
		case \block(_): {
			count += 1;
		}

		case \class(_): {
			count += 1;
		}
		case \switch(_, _): {
			count += 1;
		}
		case \class(_, _, _, _): {
			count += 1;
		}
		case \interface(_, _, _, _): {
			count += 1;
		}
	}
	return count;
}