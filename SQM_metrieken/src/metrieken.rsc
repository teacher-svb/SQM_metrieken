module metrieken

import IO;
import List;
import Map;
import Relation;
import Set;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import util::Resources;

// Alle bestanden in een project met extensie java
public set[loc] javaBestanden(loc project) {
   Resource r = getProject(project);
   return { a | /file(a) <- r, a.extension == "java" };
}

