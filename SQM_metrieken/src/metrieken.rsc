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

lrel[int, str] volumeScoreTable = [<0, "++">, <66, "+">, <246, "0">, <665, "-">, <1310, "--">];

lrel[int, str] unitSizeScoreTable = [<0, "++">, <30, "+">, <44, "0">, <74, "-">, <0, "--">];

lrel[int, str] duplicityScoreTable = [<0, "++">, <3, "+">, <5, "0">, <10, "-">, <20, "--">];


// merged "simple" with "moderate" risk, as they are treated equally for complexity score
lrel[int, str] unitComplexityScoreTable = [<0, "moderate">, <21, "high">, <50, "very high">];
list[int] complexityScoreTableModerate = [0, 25, 30, 45, 50];
list[int] complexityScoreTableHigh = [0, 5, 10, 15];
list[int] complexityScoreTableVeryHigh = [0, 5];
lrel[int moder, int high, int vhigh, str score] complexityScoreTable = [<25, 0, 0, "++">, <30, 5, 0, "+">, <45, 10, 0, "0">, <50, 15, 5, "-">, <100, 100, 100, "--">];

public void printResults() {
	loc project = |project://smallsql/|;
	println(project);
	
	int projectPLOC = (0 | it + b | <a,b> <- calcPLOCForProjectFiles(project));
	int projectLLOC = (0 | it + b | <a,b> <- calcLLOCForProjectFiles(project));
	list[Declaration] methods = getMethods(project);
	int numUnits = size(methods);
	real avgUnitPLOC = (0.0 | it + calcPLOC(m.src) | m <- methods) / numUnits;
	real avgUnitLLOC = (0.0 | it + calcLLOC(m) | m <- methods) / numUnits;
	// TODO: steven
	int avgUnitComplexity = 0;
	real projectDuplication = calcDuplicationRatio(project);
	
	println();
	
   	println("lines of code (PLOC|LLOC): <projectPLOC> | <projectLLOC>");
   	println("number of units: <numUnits>");
   	println("average unit size (PLOC): <avgUnitPLOC>");
   	println("average unit size (LLOC): <avgUnitLLOC>");
   	println("average unit complexity: <avgUnitComplexity>");
   	println("duplication: <projectDuplication>%");
   	
   	println();
	// TODO: steven
	int numModerateUnitComplexity = 0;
	// TODO: steven
	int numHighUnitComplexity = 0;
	// TODO: steven
	int numVeryHighUnitComplexity = 0;
	real ratioModerateUnitComplexity = 100.0 * numModerateUnitComplexity / numUnits;
	real ratioHighUnitComplexity = 100.0 * numHighUnitComplexity / numUnits;
	real ratioVeryHighUnitComplexity = 100.0 * numVeryHighUnitComplexity / numUnits;
	println(ratioModerateUnitComplexity);
	println(ratioHighUnitComplexity);
	println(ratioVeryHighUnitComplexity);
	
   	str volumePLOCScore = max([<a,b> | <a, b> <- volumeScoreTable, a <= projectPLOC/1000])[1];
   	str volumeLLOCScore = max([<a,b> | <a, b> <- volumeScoreTable, a <= projectLLOC/1000])[1];
   	str unitSizePLOCScore = max([<a,b> | <a, b> <- unitSizeScoreTable, a <= avgUnitPLOC])[1];
   	str unitSizeLLOCScore = max([<a,b> | <a, b> <- unitSizeScoreTable, a <= avgUnitLLOC])[1];
   	//min([<a,b,c,d> | <a,b,c,d> <- complexityScoreTable, (c >= 6 && b >= 0 && a >= 45)]);[3];
   	str complexityScore = min([<a,b,c,d> | <a,b,c,d> <- complexityScoreTable, 
   										   a >= ratioModerateUnitComplexity && 
   										   b >= ratioHighUnitComplexity && 
   										   c >= ratioVeryHighUnitComplexity])[3];
   	str duplicationScore = max([<a,b> | <a, b> <- duplicityScoreTable, a <= projectDuplication])[1];

   	str analyseScore = "";
   	str changeScore = "";
   	str testScore = "";
   	str maintainScore = "";
   	
   	println("volume score (PLOC|LLOC): <volumePLOCScore> | <volumePLOCScore>");
	println("unit size score (PLOC|LLOC): <unitSizePLOCScore> | <unitSizeLLOCScore>");
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