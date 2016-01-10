(*type modifier = *)
(*  | Static | Abstract | Final | Strictfp*)

type package = Package of string


type import = Import of importType
and importType =
  {
	isStatic : bool;
 	name : string;
  }
type importList = import list



type resultTypeAst = 
  | AttributType of AstUtil.attributType | Void

type parameter = 
{
  parametertype : AstUtil.attributType;
  name : string
}


type attributAst = {
  typeof : AstUtil.attributType;
  name : string;
}



type attributList = attributAst list

type blockstmts = BlockStatements of AstExpr.statement list

type methodClassType =
{
  name : string;
  access : AstUtil.modifiers option;
  parameters : parameter list option;
  resultType : resultTypeAst;
  methodbody: blockstmts option
}

type classMemberType =
  | MethodClass of methodClassType
  | Attribut of attributAst

type constructorBodyAst =
{
  invocation : constructorInvocation option;
  liststatements : blockstmts;
}
and constructorInvocation =
  { 
	invocator : thisOrSuper;
	argumentlist: AstExpr.expression list option
}
and thisOrSuper =
  |This | Super


type constructorAst =
{
  name : string;
  access : AstUtil.modifiers option;
  parameters : parameter list option;
  constructorbody : constructorBodyAst option;
}


type constructorType = ConstructorType of constructorAst

type classContentAst =
{
  listClassMember : classMemberType list;
  listConstructors : constructorType list;
}

type classBodyDeclaration =
  | ClassMemberType of classMemberType
  | ConstructorType of constructorAst

type classBodyAst = classBodyDeclaration list

type classBodyType = 
  | ClassBodyType of classBodyAst

type enumBodyAst = 
{
  enumConstants : enumConstant list option;
  enumDeclarations : classBodyDeclaration list option
}
and enumConstant =
  {
	name : string;
    argumentlist : AstExpr.expression list option;
  }

type classAst =
  {
    classename : string;
    access : AstUtil.modifiers option;
	inheritance : string option;
 	interfaces : string list option;
	classbody : classBodyAst option;
  }

type enumAst =
  {
    enumname : string;
    access : AstUtil.modifiers option;
 	interfaces : string list option;
	enumbody : enumBodyAst;
  }

type interfaceAst =
{ 
  interfacename : string;
  access : AstUtil.modifiers option;
}

type interfaceType = 
  | InterfaceType of interfaceAst

type classType = 
  | ClassType of classAst
  | InterfaceType of interfaceAst
  | EnumType of enumAst

type classList = classType list

type fileAst =
{
  packagename: package option;
  listImport: import list option;
  listClass: classType;
}

type fileType = FileType of fileAst



(* affichage de l'AST *)


let string_of_import i = match i with
  | Import({ name=str; isStatic=b }) -> if(b) then "static " ^ str else str

let string_of_inheritance i = match i with
  | Some(i) -> "extends " ^ i
  | None -> ""

let rec string_of_interfaces liste = match liste with
  | Some([]) -> ""
  | Some(x::xs) -> x ^ " " ^ string_of_interfaces(Some(xs))
  | None -> ""

let rec printListImport liste = match liste with
  | Some([]) -> print_endline("End of Import" ^ "\n")
  | Some(x::xs) -> print_endline("Import: " ^ string_of_import(x)); printListImport(Some(xs))
  | None -> print_endline("No import in file")

let printPackage p = match p with
  | Some(Package(str)) -> print_string("File package name: " ^ str ^ "\n")
  | None -> print_string("file package name: none" ^ "\n")



let string_of_paramater p = match p with
  | { parametertype=typeof; name=str } -> AstUtil.string_of_attributType(typeof) ^ " " ^ str

let rec string_of_listparameters params = match params with
  | Some([]) -> ""
  | Some(x::xs)-> " " ^ string_of_paramater(x) ^" "^ string_of_listparameters(Some(xs))
  | None -> ""


let rec string_of_statements stmts = match stmts with
  | [] -> ""
  | (x::xs) -> "\t" ^ "\t"  ^ "\t" ^ AstExpr.string_of_statement(x) ^ "\n" ^ string_of_statements(xs)

let rec string_of_expressions stmts = match stmts with
  | [] -> ""
  | (x::xs) -> " " ^ AstExpr.string_of_expr(x) ^ string_of_expressions(xs)

let rec string_of_expressionsOption stmts = match stmts with
  | Some([]) -> ""
  | Some(x::xs) -> " " ^ AstExpr.string_of_expr(x) ^ string_of_expressionsOption(Some(xs))	
  | None -> ""

let string_of_thisorsuper str = match str with
  | This -> "this"
  | Super -> "super"


let string_of_resultType t = match t with
  | Void -> "void"
  | AttributType(a) -> AstUtil.string_of_attributType(a)

let string_of_constructorinvocation inv = match inv with
  | Some({ invocator = i ; argumentlist=Some(params) }) -> "\t" ^ "\t" ^ "\t" ^ string_of_thisorsuper(i) ^ "(" ^ string_of_expressions(params) ^ ")"
  | None -> ""


let string_of_constructorBody body = match body with
  | Some( { liststatements=BlockStatements(stmts); invocation=inv } )-> string_of_constructorinvocation(inv) ^ "\n" ^ string_of_statements stmts
  | None -> "\t" ^ "\t" ^ "\t"  ^ "No body"


let string_of_constructor c = match c with
  | { name=str; access= modi; constructorbody=body; parameters= params } -> "\t" ^ "constructor de class: " ^ str ^ "(" ^ string_of_listparameters(params) ^ ")" ^ ", access: " ^ AstUtil.string_of_modifiers(modi) ^ "\n" ^ "\t" ^ "\t" ^  "constructor body:\n" ^ string_of_constructorBody(body)

let string_of_classmember c = match c with
  | MethodClass( { name=str; access=modi; resultType=result; parameters=liste; methodbody=Some(BlockStatements(body))  }) -> "\tMethod: " ^ string_of_resultType(result) ^ " " ^ str ^ "(" ^ string_of_listparameters(liste) ^ "), access: " ^ AstUtil.string_of_modifiers(modi) ^ "\n \t\tMethod Body : \n" ^ string_of_statements(body)

let string_of_classDeclaration decl = match decl with
  | ConstructorType(constructor) -> string_of_constructor(constructor)
  | ClassMemberType(member) -> string_of_classmember(member)

let rec string_of_classDeclarations liste = match liste with
  | Some([]) -> ""
  | Some(x::xs) -> string_of_classDeclaration(x) ^ "\n" ^ string_of_classDeclarations(Some(xs))
  | None -> ""

let string_of_enumConstant cons = match cons with
  | { name=str; argumentlist=liste } -> str ^ "(" ^ string_of_expressionsOption(liste) ^ ")"

let rec string_of_enumConstants liste = match liste with
  | Some([]) -> ""
  | Some(x::xs)-> " " ^ string_of_enumConstant(x) ^ string_of_enumConstants(Some(xs))
  | None -> ""

let string_of_enumBody body = match body with
  | {  enumConstants=constants; enumDeclarations=decl } -> string_of_enumConstants(constants) ^ "\n" ^ string_of_classDeclarations(decl)


let printClassDeclaration decl = match decl with
  | ConstructorType(constructor) -> print_endline(string_of_constructor(constructor))
  | ClassMemberType(member) -> print_endline(string_of_classmember(member))

let rec printClassBodyDeclarations liste = match liste with
  | [] -> print_endline("end of declarations")
  | (x::xs) -> printClassDeclaration(x) ; printClassBodyDeclarations(xs)

let printClassTree c = match c with
  | ClassType({classename=name; access=acc; inheritance=herit; interfaces=listeinterface; classbody=Some(body)}) -> print_endline(AstUtil.string_of_modifiers(acc) ^ "class " ^ name ^ " " ^ string_of_inheritance(herit) ^ " implements "^ string_of_interfaces(listeinterface)); printClassBodyDeclarations(body)
  | InterfaceType({interfacename=name; access=acc}) -> print_endline( "Interface: " ^ name ^ ", " ^ AstUtil.string_of_modifiers(acc))
  | EnumType({enumname=name; access=acc; interfaces=listeinterface; enumbody=body}) -> print_endline(AstUtil.string_of_modifiers(acc) ^ "class " ^ name ^ " implements "^ string_of_interfaces(listeinterface)); print_endline(string_of_enumBody(body))

let printFileTree c = match c with
  | FileType({packagename=package; listImport=imports; listClass=classes}) -> printPackage(package); printListImport(imports); printClassTree(classes)
