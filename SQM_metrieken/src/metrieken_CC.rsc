module metrieken_CC

import IO;
import List;
import Map;
import Relation;
import ListRelation;
import Set;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import util::Resources;


import metrieken_util;
import metrieken_LOC;

public int CalcOR(Expression exp){
	int count =0;
	visit(exp) {
		case  \infix( _,  op,  _): {
			if(op == "||") {
				count += 1;
			}
		}
	}
	return count;
}

public tuple[real extreme, 
			 real high, 
			 real moderate,
			 real avgComplexity] GetComplexity(loc project) {
   set[loc] files = javaBestanden(project);
   
	real total=0.0;
	real moderate=0.0;
	real high =0.0;
	real extreme=0.0;
	real agrComp =0.0;
	real unitCount=0.0;
	lrel[str method,loc src] source=[];
	lrel[str methodname,int complexity] CC =[];
   
	for (file <- files) {
		list[Declaration] methods = getMethods(file);
		for (m <- methods) {
	      	int count=CalcComplexity(m);
			agrComp+=count;
			unitCount+=1;
			int totals = calcLLOC(m);
			if(count >50) {
				extreme+=totals;
			}
			else if(count>20) {
				high+=totals;
			}
			else if(count>10) {	
				moderate+=totals;
			}
			total+=totals;
			source += <m.name, m.src>;
			CC+=<m.name,count>;
		}
	}

   return <extreme * 100 / total, 
   		   high * 100 / total, 
   		   moderate * 100 / total, 
   		   agrComp / unitCount>;
}

public tuple[int,int] calcLLOCvsComplexity(Declaration decl) {
	int count = calcLLOC(decl);
	int ccCount = CalcComplexity(decl);
	
	return <count,ccCount>;
}

public int CalcComplexity(Declaration decl) {
	int count = 1;
   	visit(decl) {  
	 	case \if(condition, _): {
	 		count+= CalcOR(condition);
	 		count += 1;
		}
	 	case \if(condition, _, _): {
	 		count+= CalcOR(condition);
	 		count += 2;
		}
	 	case \while(_, body): {
	 		count += 1;
		}
	 	case \foreach(_, _, body): {
	 		count += 1;
		}
	 	case \for(_, _, _, body): {
	 		count += 1;
		}
	 	case \for(_, _, body): {
	 		count += 1;
		}
		case \foreach(_,_,_):{
			count += 1;
		}
	 	case \do(body, _): {
	 		count += 1;
		}
		case \case(expr): {
			count += 1;
		}
		case \defaultCase(): {
			count += 1;
		}
   	}
   	return count;
}