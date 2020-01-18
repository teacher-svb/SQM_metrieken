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
import analysis::graphs::Graph;
import metrieken_DUP;
import metrieken_LOC;


public Figure createBaseMenu(loc project){
		render(box(vcat(
		[
			box(shrink(0.8),filColor())
			])));
}
