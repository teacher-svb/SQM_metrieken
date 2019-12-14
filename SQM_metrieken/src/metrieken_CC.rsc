module metrieken_CC

import IO;
import List;
import Map;
import Relation;
import Set;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import util::Resources;

import metrieken;

public int CalcComplexity(Statement impl) {
	int count = 1;
   	visit(impl) {  
	 	case \if(_, thenBranch): {
	 		count += 1;
			println("IF (<thenBranch.src>): +1");
		}
	 	case \if(_, thenBranch, elseBranch): {
			println("IF ELSE (<thenBranch.src>): +2");
	 		count += 2;
		}
	 	case \while(_, body): {
			println("WHILE (<body.src>): +1");
	 		count += 1;
		}
	 	case \foreach(_, _, body): {
			println("FOREACH (<body.src>): +1");
	 		count += 1;
		}
	 	case \for(_, _, _, body): {
			println("FOR (<body.src>): +1");
	 		count += 1;
		}
	 	case \for(_, _, body): {
			println("FOR (<body.src>): +1");
	 		count += 1;
		}
	 	case \do(body, _): {
			println("DO (<body.src>): +1");
	 		count += 1;
		}
		case \case(expr): {
			println("CASE: +1");
			count += 1;
		}
		case \defaultCase(): {
			count += 1;
			println("CASE: +1");
		}
   	}
   	return count;
}

public void printComplexity() {
   set[loc] files = javaBestanden(|project://SQM_metrieken/JabberPoint|);
   set[Declaration] decls = createAstsFromFiles(files, false);
   visit(decls) {  
      case \method(_, name, _, _, impl): {
         println("<name>(<impl.src>): <CalcComplexity(impl)>\n");
      } 
   }
}