module metrieken_LOC

import IO;
import List;
import ListRelation;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;

import util::Resources;
import util::Editors;

import vis::Figure;
import vis::Render;
import vis::KeySym;

import metrieken;


public void printTest() {
	set[loc] file = {|project://smallsql/src/smallsql/database/Command.java|};
	
	println("file PLOC: <(0 | it + b | <a,b> <- calcPLOCForProjectFiles(file))>");
}

public void printPLOC() {
   	set[loc] smallsqlfiles = javaBestanden(|project://smallsql/|);
   	println("smallsql: <(0 | it + b | <a,b> <- calcPLOCForProjectFiles(smallsqlfiles))>");
   	set[loc] hsqldbfiles = javaBestanden(|project://hsqldb/|);
   	println("hsqldb: <(0 | it + b | <a,b> <- calcPLOCForProjectFiles(hsqldbfiles))>");
}

public lrel[loc, int] calcLLOCForProjectFiles(set[loc] files) {
	return [<a, calcLLOC(createAstFromFile(a, false))> | a <- files];
}


public lrel[loc, int] calcPLOCForProjectFiles(set[loc] files) {
	return [<a, calcPLOC(a)> | a <- files];
}

public void showLLOCTreemaps() {
   	set[loc] smallsqlfiles = javaBestanden(|project://smallsql/|);
	render("treemap smallsql", createLLOCTreeMap(smallsqlfiles));
	
   	/*set[loc] hsqldbfiles = javaBestanden(|project://hsqldb/|);
	render("treemap hsqldb", createLLOCTreeMap(hsqldbfiles));*/
}

/**
	function createLLOCTreeMap
	creates a treemap based on the LLOC value per file(main tree)/per method (subtree)
	
*/
public Figure createLLOCTreeMap(set[loc] files) {
	lrel[loc, int] LLOCs = calcLLOCForProjectFiles(files);
	
	list[Figure] figures = [];
	for (<l1, s1> <- LLOCs) {
		// make a local copy of l1 and s1, to use in the popup (otherwise it will use the scoped var l1, and refer to the last value of l1)
		loc l1copy = l1;
		int s1copy = s1;
		
		// generate an arbitrary color that will be used for both the file box and method subtree
		Color c = arbColor();
		lrel[loc, int] methodLLOCs = calcLLOCForMethods({l1});
		list[Figure] subfigures = [];
		
		int subtreeArea = 0;
		for (<l2, s2> <- methodLLOCs) {
			subtreeArea += s2;
			// make a local copy of l2 and s2, to use in the popup (otherwise it will use the scoped var l2, and refer to the last value of l1)
			loc l2copy = l2;
			int s2copy = s2;
			// add a box to the subtree for every method. 
			subfigures += box(area(s2),
							  fillColor(c), 
							  // clicking the box opens the file and selects the method
							  onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
									edit(l2copy);
									return true;
							  }),
							  // hovering over the box shows the LLOC count of that method
						      mouseOver(box(text("<s2copy>"), 
						   			 		fillColor("lightyellow"),
						   			 		grow(1.2),
						   			 		resizable(false)
					   			 		)
			   			      )
						);
		}
		// add a box to the subtree that shows how many LLOCs are NOT in a method
		subfigures += box(area(s1 - subtreeArea),fillColor(interpolateColor(color("white"), c, 0.5)), 
						  // clicking the box opens the file
						  onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
								edit(l1copy);
								return true;
						  }),
						  // hovering over the box shows the LLOC count of lines outside methods
					      mouseOver(box(text("<s1 - subtreeArea>"), 
						   			 		fillColor("lightyellow"),
						   			 		grow(1.2),
						   			 		resizable(false)
					   			 		)
		 		  		  )
				  );
						  
	    // add a box to the main tree structure for every file
	    // the subtree is added to this box
		figures += box(vcat([treemap(subfigures)]), 
					   area(s1), 
					   fillColor(c),
						  // hovering over the box shows the filename and LLOC count of that file
					   mouseOver(box(text("<l1copy.file> (<s1copy>)"), 
					   			 	 fillColor("lightyellow"),
					   			 	 grow(1.2),
					   			 	 resizable(false)
				   			 	 )
		   			   )
				);
	}
	
	return treemap(figures);
}

/**
	function calcLLOCForMethods
	calculates the amount of Logical Lines Of Code for each method in a set of locations.
*/

// TODO: use m3
// TODO: this function isn't necessary. SHould be replaced by a GetMethodsFromProject() function, that returns a set of methods
// then this function can be merged with calcLLOCForProjectFiles()
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


// TODO: use m3
// TODO: this function isn't necessary. SHould be replaced by a GetMethodsFromProject() function, that returns a set of methods
// then this function can be merged with calcLLOCForProjectFiles()
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
		str printstr = "          ";
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
				printstr = "SL COMMENT";
			}
			case /^\s*\/\*.*\*\/\s*$/: { // multiline comment on one line, count as ignored
				linesIgnored += 1;
				printstr = "ML COMMENT";
			}
			case /^.*\/\*.*\*\/.*$/: { // inline multiline comment (between two pieces of code on one line), so should not be ignored
				;
			}
			case /^\s*\/\*/: { // multiline comment start, count as ignored
				multilineStarted = true;
				linesIgnored += 1;
				printstr = "ML CMT STR";
			}
			case /\*\/\s*$/: { // multiline comment end, count as ignored
				multilineStarted = false;
				linesIgnored += 1;
				printstr = "ML CMT END";
			}
			case /\/\*/: { // multiline comment start after code, so should not be ignored
				multilineStarted = true;
			}
			case /\*\//: { // multiline comment end before code, so should not be ignored
				multilineStarted = false;
			}
			case /^\s*$/: { // empty line, count as ignored
				linesIgnored += 1; 
				printstr = "EMPTY LINE";
			}
			case /./: {
				if (multilineStarted) {  // line in between a multiline start and a multiline end, count as ignored
					linesIgnored += 1;
					printstr = "ML CMT ---";
				}
			}
		}
		// FOR DEBUGGING PURPOSES
		/*print("<printstr><l>"); 
		print("\n");*/
	}
	
	//println("<location>: <totalFileLines - linesIgnored>");
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