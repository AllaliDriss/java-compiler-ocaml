open AstExpr

(* verbose is a boolean that you can use to switch to a verbose output (for example, to dump all the ast) *)

let print_statement stat =
  print_string (AstExpr.string_of_statement stat);
  print_newline()

let execute lexbuf verbose = 
  print_endline "Parsing...";
  
(*  try*)
(*    let stat_list = Parser.statements Lexer.nexttoken lexbuf in*)
(*    List.iter print_statement stat_list;*)
(*    print_newline()*)
(*  with*)
(*  | Lexer.Error (kind, start, fin) ->*)
(*    Lexer.report_error kind;*)
(*    Lexer.print_position start fin;*)
(*    print_newline()*)
(*  | AstExpr.Err kind ->*)
(*    AstExpr.report_err kind;*)
(*    print_newline()*)


try
  let exp = Parser.compilationUnit Lexer.nexttoken lexbuf in
  AstClass.printFileTree (exp)
with
  | Lexer.Error (kind, start, fin) ->
     Lexer.report_error kind;
     Lexer.print_position start fin;
     print_newline()

