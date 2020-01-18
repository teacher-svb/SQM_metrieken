module metrieken_vis

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
import vis::Figure;
import vis::Render;
import vis::KeySym;
import analysis::graphs::Graph;
import metrieken_DUP;
import metrieken_LOC;

public void renderBaseMenu(){
	render(createBaseMenu(|project://smallsql/|));
}

public Figure createBaseMenu(loc project){
		return vcat(
		[
			box(text("LOC and CC Treemap"),hshrink(0.8),fillColor("green"), 
							  onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
									render(createLLOCTreeMap(project));
									return true;
							  })),
			box(text("Duplication graph"),hshrink(0.8),fillColor("yellow"), 
							  onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
									renderDuplicationGraph(project);
									return true;
							  }))
		]);
}
