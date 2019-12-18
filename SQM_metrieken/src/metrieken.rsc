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

import metrieken_LOC;
import metrieken_DUP;

public void printResults() {
	loc project = |project://smallsql/|;
	println(project);
	
	int projectPLOC = (0 | it + b | <a,b> <- calcPLOCForProjectFiles(project));
	int projectLLOC = (0 | it + b | <a,b> <- calcLLOCForProjectFiles(project));
	list[Declaration] methods = getMethods(project);
	int numUnits = size(methods);
	real avgUnitPLOC = (0.0 | it + calcPLOC(m.src) | m <- methods) / numUnits;
	real avgUnitLLOC = (0.0 | it + calcLLOC(m) | m <- methods) / numUnits;
	int avgUnitComplexity = 0;
	real projectDuplication = calcDuplicationRatio(project);
	
	println();
	
   	println("lines of code (PLOC): <projectPLOC>");
   	println("lines of code (LLOC): <projectLLOC>");
   	println("number of units: <numUnits>");
   	println("average unit size (PLOC): <avgUnitPLOC>");
   	println("average unit size (LLOC): <avgUnitLLOC>");
   	println("average unit complexity: <avgUnitComplexity>");
   	println("duplication: <projectDuplication>%");
   	
   	println();
   	
   	str volumeScore = "";
   	str unitSizeScore = "";
   	str complexityScore = "";
   	str duplicationScore = "";
   	str analyseScore = "";
   	str changeScore = "";
   	str testScore = "";
   	str maintainScore = "";
   	
   	println("volume score: <volumeScore>");
	println("unit size score: <unitSizeScore>");
	println("unit complexity score: <complexityScore>");
	println("duplication score: <duplicationScore>");
   	
   	println();
	
	println("analysability score: <analyseScore>");
	println("changability score: <changeScore>");
	println("testability score: <testScore>");
   	
   	println();
	
	println("overall maintainability score: <maintainScore>");
}

public void showLLOCTreemaps() {
	render("treemap smallsql", createLLOCTreeMap(|project://smallsql/|));
	
	//render("treemap hsqldb", createLLOCTreeMap(|project://hsqldb/|));
}

public void printPLOC() {
	lrel[loc, int] PLOC = calcPLOCForProjectFiles(|project://smallsql/|);
   	println("smallsql: <(0 | it + b | <a,b> <- PLOC)>");

   	//println("hsqldb: <(0 | it + b | <a,b> <- calcPLOCForProjectFiles(|project://hsqldb/|))>");
}

public void printLLOC() {
   	println("smallsql: <(0 | it + b | <a,b> <- calcLLOCForProjectFiles(|project://smallsql/|))>");

   	//println("hsqldb: <(0 | it + b | <a,b> <- calcPLOCForProjectFiles(|project://hsqldb/|))>");
}

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