module metrieken_LOC

import IO;
import List;
import ListRelation;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;

import util::Resources;
import util::Editors;
import util::Math;

import vis::Figure;
import vis::Figure::ColorModel;
import vis::Render;
import vis::KeySym;

import metrieken_util;



/**
	function calcLLOCForProjectFiles
	calculates the LLOC for each file in a given project.
*/
public lrel[loc, int] calcLLOCForProjectFiles(loc project) {
   	set[loc] files = javaBestanden(project);
	return [<a, calcLLOC(createAstFromFile(a, false))> | a <- files];
}


public int numUnits(loc project) {
   	set[loc] files = javaBestanden(project);
	int total = 0;
	for (f <- files)  {
		total += size(getMethods(f));
	}
	return total;
}


/**
	function calcLLOCForProjectFiles
	calculates the PLOC for each file in a given project.
*/
public lrel[loc, int] calcPLOCForProjectFiles(loc project) { 
   	set[loc] files = javaBestanden(project);
	return [<a, calcPLOC(a)> | a <- files];
}

/**
	function createLLOCTreeMap
	creates a treemap based on the LLOC value per file(main tree)/per method (subtree)
	
*/
public Figure createBaseTreeMap(loc project)
{
lrel[loc, int] LLOCs = calcLLOCForProjectFiles(project);
	
	list[Figure] figures = [];
	for(<l,c> <-LLOCs){
	b0 = box(area(c), fillColor("white"));
	bC = box(b0,hshrink(0.5),vshrink(0.9),align(0,0));
	bD = box(b0,hshrink(0.5),vshrink(0.9),align(0,1));
	
	}
}
public Figure createLLOCTreeMap(loc project) { 
a =box(fillColor(color("yellow")));
b= box(fillColor(color("green")));
	lrel[loc, int] LLOCs = calcLLOCForProjectFiles(project);
	
	list[Figure] figures = [];
	for (<l1, s1> <- LLOCs) {
		// make a local copy of l1 and s1, to use in the popup (otherwise it will use the scoped var l1, and refer to the last value of l1)
		loc l1copy = l1;
		int s1copy = s1;
		
		// generate an arbitrary color that will be used for both the file box and method subtree
		Color c = arbColor();
		lrel[loc, tuple[int,int]] methodLLOCs = calcCCForMethods({l1});
		list[Figure] subfigures = [];
		
		int subtreeArea = 0;
		for (<l2, <s2,s2cc>> <- methodLLOCs) {
			subtreeArea += s2;
			// make a local copy of l2 and s2, to use in the popup (otherwise it will use the scoped var l2, and refer to the last value of l1)
			loc l2copy = l2;
			int s2copy = s2;
			int s2ccCopy = s2cc;
			Color col;
			
			
			if(s2cc<=10)
				col = color("green");
			else if(s2cc<=20)
				col = interpolateColor(color("green"), color("yellow"),((s2cc-10)/10.0));
			else if(s2cc<=50)
				col = interpolateColor(color("yellow"), color("red"),((s2cc-20)/30.0));
				else col= color("red");
			
			// add a box to the subtree for every method. 
			subfigures += box(area(s2),
							  fillColor(col), 
							  // clicking the box opens the file and selects the method
							  onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
									edit(l2copy);
									return true;
							  }),
							  // hovering over the box shows the LLOC count of that method
						      mouseOver(box(text("LLOC:<s2copy> Comlexity:<s2ccCopy>"), 
						   			 		fillColor("lightyellow"),
						   			 		grow(1.2),
						   			 		resizable(false)
					   			 		)
			   			      )
						);
		}
		// add a box to the subtree that shows how many LLOCs are NOT in a method
		subfigures += box(area(s1 - subtreeArea),fillColor(color("blue")), 
						  // clicking the box renders a previously saved image
						  onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
						  if(butnr==1)
								render(a);
						  if(butnr==3)
								render(b);
								//edit(l1copy);
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
		figures += box(vcat([treemap(subfigures)], shrink(0.9)), 
					   area(s1), 
					   fillColor(color("white")),
					   lineWidth(0),
					   shrink(0.9),
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


// TODO: use m3
public list[Declaration] getMethods(loc file) {
	
   	set[loc] files = javaBestanden(file);
   	
	list[Declaration] result = [];
   	for (f <- files) {	
		Declaration decl = createAstFromFile(f, false);
		
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
	}
	
	return result;
}

/**
	function calcLLOCForMethods
	calculates the amount of Logical Lines Of Code for each method in a set of locations.
*/
public lrel[loc, tuple[int LLOC,int CC]] calcCCForMethods(set[loc] files) {
	lrel[loc, tuple[int,int]] methodLLOCs = [];
	
	for (a <- files) { 
		Declaration decl = createAstFromFile(a, false);
		
		visit(decl) {
			case \class(_, _, _, list[Declaration] body): {
				for (b <- body) {
					switch(b) {
						case \method(_, _, _, _, _): {
							methodLLOCs += <b.src, calcCC(b)>;
						}
						case \constructor(_, _, _, _): {
							methodLLOCs += <b.src, calcCC(b)>;
						}
					}
				}
			}
		}
	}
	return methodLLOCs;
}
public lrel[loc, int] calcLLOCForMethods(set[loc] files) {
	lrel[loc, int] methodLLOCs = [];
	
	for (a <- files) { 
		/*list[Declaration] methods = getMethods(a);
		
		for (m <- methods) {
		
			methodLLOCs += <m.src,calcLLOC(m)>;
		}*/
		
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
		list[Declaration] methods = getMethods(a);
		
		for (m <- methods) {
			methodPLOCs += <m.src, calcPLOC(m.src)>;
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
	//bool multilineStarted = false;
	for (l <- lines) {
		l = filterLine(l);
		if (l == "") {
			linesIgnored += 1;
		}
	}
	multilineStarted = false;
	
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
		case \method(_, _, _, _,_): {
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
public int CalcOR(Expression exp){
int count =0;
visit(exp){
  case  \infix( _,  op,  _): {
  	if(op=="||")
      	count +=1;
      	}
}
return count;
}
public tuple[int,int] calcCC(Declaration decl) {
	int count = 0;
	int ccCount=0;
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
		case \method(_, _, _, _,_): {
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
	 	case \if(condition, _): {
	 		ccCount+= CalcOR(condition);
	 		ccCount += 1;
		}
	 	case \if(condition, _, _): {
	 		ccCount+= CalcOR(condition);
	 		ccCount += 2;
		}
	 	case \while(_, body): {
	 		ccCount += 1;
		}
	 	case \foreach(_, _, body): {
	 		ccCount += 1;
		}
	 	case \for(_, _, _, body): {
	 		ccCount += 1;
		}
	 	case \for(_, _, body): {
	 		ccCount += 1;
		}
		case \foreach(_,_,_):{
			ccCount += 1;
		}
	 	case \do(body, _): {
	 		ccCount += 1;
		}
		case \case(expr): {
			ccCount += 1;
		}
		case \defaultCase(): {
			ccCount += 1;
		}
	}
	return <count,ccCount>;
}