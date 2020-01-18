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
import util::Math;

import vis::Figure;
import vis::Render;
import vis::KeySym;


import metrieken_LOC;
import metrieken_DUP;
import metrieken_CC;

lrel[int, int] volumeScoreTable = [<0, 2>, <66, 1>, <246, 0>, <665, -1>, <1310, -2>];

lrel[int, int] unitSizeScoreTable = [<0, 2>, <30, 1>, <44, 0>, <74, -1>];

lrel[int, int] duplicityScoreTable = [<3, 2>, <5, 1>, <10, 0>, <20, -1>, <100, -2>];


// merged "simple" with "moderate" risk, as they are treated equally for complexity score
lrel[int, str] unitComplexityScoreTable = [<0, "moderate">, <21, "high">, <50, "very high">];
list[int] complexityScoreTableModerate = [0, 25, 30, 45, 50];
list[int] complexityScoreTableHigh = [0, 5, 10, 15];
list[int] complexityScoreTableVeryHigh = [0, 5];
lrel[int moder, int high, int vhigh, int score] complexityScoreTable = [<25, 0, 0, 2>, <30, 5, 0, 1>, <45, 10, 0, 0>, <50, 15, 5, -1>, <100, 100, 100, -2>];

map[int score, str scorename] scoreTranslation = (2: "++", 1: "+", 0: "0",-1: "-", -2: "--");

public void printResults() {
	loc project = |project://smallsql/|;
	println(project);
	
	<extreme,high,moderate,avgComplexity>  = GetComplexity(project);
	
	int projectPLOC = (0 | it + b | <a,b> <- calcPLOCForProjectFiles(project));
	int projectLLOC = (0 | it + b | <a,b> <- calcLLOCForProjectFiles(project));
	list[Declaration] methods = getMethods(project);
	int numUnits = size(methods);
	real avgUnitPLOC = (0.0 | it + calcPLOC(m.src) | m <- methods) / numUnits;
	real avgUnitLLOC = (0.0 | it + calcLLOC(m) | m <- methods) / numUnits;
	// TODO: steven
	real avgUnitComplexity = avgComplexity;
	real projectDuplication = calcDuplicationRatio(project);
	
	println();
	
   	println("lines of code (PLOC|LLOC): <projectPLOC> | <projectLLOC>");
   	println("number of units: <numUnits>");
   	println("average unit size (PLOC): <avgUnitPLOC>");
   	println("average unit size (LLOC): <avgUnitLLOC>");
   	println("average unit complexity: <avgUnitComplexity>");
   	println("duplication: <projectDuplication>%");
   	
   	println();
   	
	real ratioModerateUnitComplexity =  extreme;
	real ratioHighUnitComplexity =  high;
	real ratioVeryHighUnitComplexity = moderate;

	
   	int volumePLOCScore = max([<a,b> | <a, b> <- volumeScoreTable, a <= projectPLOC/1000])[1];
   	int volumeLLOCScore = max([<a,b> | <a, b> <- volumeScoreTable, a <= projectLLOC/1000])[1];
   	int unitSizePLOCScore = max([<a,b> | <a, b> <- unitSizeScoreTable, a <= avgUnitPLOC])[1];
   	int unitSizeLLOCScore = max([<a,b> | <a, b> <- unitSizeScoreTable, a <= avgUnitLLOC])[1];
   	int complexityScore = min([<a,b,c,d> | <a,b,c,d> <- complexityScoreTable, 
   										   a >= ratioModerateUnitComplexity && 
   										   b >= ratioHighUnitComplexity && 
   										   c >= ratioVeryHighUnitComplexity])[3];
   	int duplicationScore = min([<a,b> | <a, b> <- duplicityScoreTable, a >= projectDuplication])[1];

   	int analyseScore = toInt((volumeLLOCScore + duplicationScore + unitSizeLLOCScore) / 3.0); // volume + duplication + avg unit size
   	int changeScore = toInt((complexityScore + duplicationScore) / 2.0); // complexity + duplication
   	int testScore = toInt((complexityScore + unitSizeLLOCScore) / 3.0); // complexity + avg unit size
   	int maintainScore = toInt((analyseScore + changeScore + testScore) / 3.0); // analyse + change + test
   	
   	println("volume score (PLOC|LLOC): <scoreTranslation[volumePLOCScore]> | <scoreTranslation[volumePLOCScore]>");
	println("unit size score (PLOC|LLOC): <scoreTranslation[unitSizePLOCScore]> | <scoreTranslation[unitSizeLLOCScore]>");
	println("unit complexity score: <scoreTranslation[complexityScore]>");
	println("duplication score: <scoreTranslation[duplicationScore]>");
   	
   	println();
	
	println("analysability score: <scoreTranslation[analyseScore]>");
	println("changability score: <scoreTranslation[changeScore]>");
	println("testability score: <scoreTranslation[testScore]>");
   	
   	println();
	
	println("overall maintainability score: <scoreTranslation[maintainScore]>");
}

public void showDuplicationGraph() {
	Figure duplicationGraph = createDuplicationGraph(|project://smallsql/|);
	render("Duplication Graph", duplicationGraph);
	renderSave(duplicationGraph, |file:///C:/Users/somsg/Documents/GitHub/SQM_metrieken/SQM_metrieken/dupgraph.png|);
}

public void showLLOCTreemaps() {
	
	Figure LocTreemap = createLLOCTreeMap(|project://smallsql/|);
	render("LOC Treemap",LocTreemap);
	renderSave(LocTreemap, |file:///C:/Users/somsg/Documents/GitHub/SQM_metrieken/SQM_metrieken/LocTreemap.png|);
}

public void printPLOC() {
	lrel[loc, int] PLOC = calcPLOCForProjectFiles(|project://smallsql/|);
   	println("smallsql: <(0 | it + b | <a,b> <- PLOC)>");
}

public void printLLOC() {
   	println("smallsql: <(0 | it + b | <a,b> <- calcLLOCForProjectFiles(|project://smallsql/|))>");
}