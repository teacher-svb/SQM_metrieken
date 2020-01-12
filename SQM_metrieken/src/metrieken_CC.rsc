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


lrel[int, int] CyclComplexTable = [<11, 1>, <21, 2>, <51, 3>];

public int CalcComplexity(Statement impl) {
	int count = 1;
   	visit(impl) {  
	 	case \if(_, thenBranch): {
	 		count += 1;
		}
	 	case \if(_, thenBranch, elseBranch): {
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
}public int CalcComplexity2(set[Declaration] impl) {
	int count = 1;
   	visit(impl) {  
	 	case \if(_, thenBranch): {
	 		count += 1;
		}
	 	case \if(_, thenBranch, elseBranch): {
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
	 	case \do(body, _): {
	 		count += 1;
		}
		case \case(expr): {
			count += 1;
		}
		case \defaultCase(): {
			count += 1;
		}
		case \foreach(_,_,_):{
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

//public map[loc source, lrel[str methodname,int complexity] CC] printComplexity() {
public tuple[real extreme, real high, real moderate] GetComplexity(loc project){
   set[loc] files = javaBestanden(project);
   set[Declaration] decls = createAstsFromFiles(files, false); 
   
  real total=0.0;
  real moderate=0.0;
  real high =0.0;
  real extreme=0.0;
   
   lrel[str method,loc src] source=[];
   lrel[str methodname,int complexity] CC =[];
   visit(decls) {  
      case \method(_, name, _, _, impl): {
      	int count=CalcComplexity(impl);
         
         int totals = calcLOC(impl);
         if(count >50)
         	extreme+=totals;
         else if(count>20)
         	high+=totals;
         else if(count>10)	
         	moderate+=totals;
         total+=totals;
         source += <name, impl.src>;
         CC+=<name,count>;
      
      } 
   }
   //println("<extreme*100/total>,<high*100/total>,<moderate*100/total>,<total>");
   return <extreme*100/total,high*100/total,moderate*100/total>;
}

public int calcLOC(Statement decl) {
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
		case \foreach(_,_,_):{
			count += 1;
		}
	}
	return count;
}