module metrieken_LOC

import IO;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import util::Resources;

import metrieken;

public void printLLOCForProjectFiles() {
	loc project = |project://SQM_metrieken/JabberPoint/|;
   	Resource r = getProject(project);
   	set[loc] bestanden = { a | /file(a) <- r, a.extension == "java" };
   	
	for (a <- bestanden) { 
		Declaration decl = createAstFromFile(a, false);
		int count = calcLLOC(decl);
		println("<a>: <count>");
	}
}

public void printLLOCForMethods() {
	loc project = |project://SQM_metrieken/JabberPoint/|;
   	Resource r = getProject(project);
   	set[loc] bestanden = { a | /file(a) <- r, a.extension == "java" };
   	
	for (a <- bestanden) { 
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