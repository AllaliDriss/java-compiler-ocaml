%{
    open Expr
%}

/**********/
/* Tokens */
/**********/

/* Operators */
%token PLUS MINUS TIMES DIV MOD
%token AND OR NOT
%token GT GE LT LE EQ NEQ
%token NULL
%token INCR DECR BITWISE
%token ASS MULASS DIVASS MODASS PLUSASS MINUSASS

/* Statements */
%token IF ELSE WHILE FOR SWITCH CASE
%token BREAK CONTINUE THROW SYNCHRONIZED

%token QUESTMARK COLUMN PIPE CIRCUMFLEX AMP COMA

/* Literal values */
%token <float> FLOAT
%token <int> INT
%token <bool> BOOL
%token <string> STRING
%token <string> CHAR

/********************************/
/* Priorities and associativity */
/********************************/

%left OR
%left AND
%left EQ NEQ
%left GT GE LT LE
%left PLUS MINUS
%left TIMES DIV MOD
%right UMINUS UPLUS NOT INCR DECR BITWISE

/******************************/
/* Entry points of the parser */
/******************************/

%start statements
%type <Expr.statement list> statements

%%

/*********/
/* Rules */
/*********/

statements:
  | s = statement                 { [s] }
  | s = statement rest = statements   { s::rest }

primary:
  | l = literal                       { l }
  | LPAR e = expression RPAR          { e }

literal:
  | i = INT                           { Int i }
  | f = FLOAT                         { Float f }
  | b = BOOL                          { Bool b }
  | c = CHAR                          { Char c }
  | str = STRING                      { String str }
  | NULL                              { Null }

expression:
  | c = conditional     { c }
  | ass = assignment    { ass }

conditional:
  | co = condor         { co }
  (*| co = condor QUESTMARK e = expression COLUMN c = conditional*)

condor:
  | ca = condand                              { ca }
  | co = condor OR ca = condand               { Binop(co, Bor, ca) }

condand:
  | io = inclusiveor                          { io }
  | ca = condand AND io = inclusiveor         { Binop(ca, Band, io) }

inclusiveor:
  | eo = exclusiveor                          { eo }
  | io = inclusiveor PIPE eo = exclusiveor    { Binop(io, Bpipe, eo) }

exclusiveor:
  | ae = andexpr                              { ae }
  | eo = exclusiveor CIRCUMFLEX ae = andexpr  { Binop(eo, Bcirc, ae) }

andexpr:
  | ee = equalexpr                            { ee }
  | ae = andexpr AMP ee = equalexpr           { Binop(ae, Bamp, ee) }

equalexpr:
  | re = relationalexpr                         { re }
  | ee = equalexpr EQUAL re = relationalexpr    { Binop(ee, Beq, re) }
  | ee = equalexpr NEQUAL re = relationalexpr   { Binop(ee, Bneq, re) }

relationalexpr:
  | se = shiftexpr                                     { se }
  | re = relationalexpr op = binoprel se = shiftexpr   { Binop(re, op, se) }
  (*| re = relationalexpr INSTANCEOF rt = referencetype*)

shiftexpr:
  | ae = addexpr    { ae }
  (*| se = shiftexpr "<<" ae = addexpr
  | se = shiftexpr ">>" ae = addexpr
  | se = shiftexpr ">>>" ae = addexpr*)

addexpr:
  | me = multexpr                      { me }
  | ae = addexpr PLUS me = multexpr    { Binop(ae, Badd, me) }
  | ae = addexpr MINUS me = multexpr   { Binop(ae, Bsub, me) }

multexpr:
  | ue = unary                               { ue }
  | me = multexpr op = binopmul ue = unary   { Binop(me, op, ue) }

unary:
  | op = unop u = unary   { Unop(op, u) }
  | u = unarynot      { u }

unarynot:
  | pe = postfix      { pe }
  (*| BITWISE u = unary
  | NOT u = unary
  | ca = castexpr*)

postfix:
  | p = primary      { p }
  | id = IDENT       { Var id }
  (*| p = postfix INCR 
  | p = postfix DECR*)

assignment:
  | l = leftside ass = assign e = expression  { Assign(l, ass, e) }

leftside:
  | id = IDENT                        { Var id }
  (*| fa = fieldaccess  { fa }
  | aa = arrayaccess  { aa }*)


(* BLOCKS AND STATEMENTS *)

block:
  | LBRACE bs = blockstatements RBRACE    { bs }

blockstatements:
  | bs = blockstatement                         { [bs] }
  | bs = blockstatement rest = blockstatements  { bs::rest }

blockstatement:
  (*| lv = localvariabledeclstat
  | cd = classdeclar*)
  | s = statement       { s }

(*localvariabledeclstat:
  | lv = localvariabledecl SC     { lv }

localvariabledecl:
  | vm = variablemodifiers t = typ vd = variabledecls

variablemodifiers:
  | vm = variablemodifier                         { [vm] }
  | vs = variablemodifiers vm = variablemodifier  { vs::vm }

variablemodifier:
  | (* TODO: Use the class parser? *)

variabledecls:
  | vd = variabledecl                             { [vd] }
  | vs = variabledecls COMA vd = variabledecl     { vs::vd }*)

statement:
  | s = statwithoutsubstat    { s }
  | ls = labeledstatement     { ls }
  | i = ifstatement           { i }
  | ie = ifelsestatement      { ie }
  | ws = whilestatement       { ws }
  (*| fs = forstatement         { fs }*)

statwithoutsubstat:
  | b = block                                         { Statements(b) }
  (*| es = emptystatement         { es }*)
  | es = exprstatement                                { Expression(es) }
  (*| ast = assertstatement       { ast }
  | ss = switchstatement        { ss }
  | ds = dostatement            { ds }*)
  | BREAK id = IDENT SC                               { Break(id) }
  (* TODO | BREAK SC *)
  | CONTINUE id = IDENT SC                            { Continue(id) }
  (* TODO | CONTINUE SC *)
  | RETURN e = expression SC                          { Return(e) }
  (* TODO: | RETURN SC*)
  | SYNCHRONIZED LPAR e = expression RPAR b = block   { Synchro(e, b) }
  | THROW e = expression SC                           { Throw(e) }
  (*| ts = trystatement           { ts }*)

exprstatements:
  | es = exprstatement                         { [es] }
  | es = exprstatement rest = exprstatements   { es::rest }

exprstatement:
  | ass = assignment SC       { ass }
  | INCR u = unary SC         { Unop(Uincr, u) }
  | DECR u = unary SC         { Unop(Udecr, u) }
  (*| p = postfix INCR SC
  | p = postfix DECR SC
  | MethodInvocation SC
  | ClassInstanceCreationExpression SC*)

labeledstatement:
  | id = IDENT COLUMN s = statement                                   { Label(id, s) }

ifstatement:
  | IF LPAR e = expression RPAR s = statement                         { If(e, s) }

ifelsestatement:
  | IF LPAR e = expression RPAR s1 = statement ELSE s2 = statement    { Ifelse(e, s1, s2) }

whilestatement:
  | WHILE LPAR e = expression RPAR s = statement                      { While(e, s) }

(*forstatement:
  | bf = basicfor       { bf }
  | ef = enhancedfor    { ef }*)

(*basicfor:
  | FOR LPAR fi = forinit SC e = expression SC es = exprstatements RPAR s = statement   { For() }

forinit:
  | es = exprstatements         { es }
  | lv = localvariabledecl      { lv }*)

%inline binopmul:
  | PLUS      { Badd }
  | DIV       { Bdiv }
  | MOD       { Bmod }

%inline binoprel:
  | GT        { Bgt }
  | GE        { Bge }
  | LT        { Blt }
  | LE        { Ble }

%inline unop:
  | INCR      { Uincr }
  | DECR      { Udecr }
  | PLUS      { Uplus }
  | MINUS     { Uminus }

%inline assign:
  | ASS       { Ass }
  | MULASS    { Assmul }
  | DIVASS    { Assdiv }
  | MODASS    { Assmod }
  | PLUSASS   { Assplus }
  | MINUSASS  { Assminus }
  (* TODO: Add <<= >>= >>>= &= ^= and|= *)

%%

