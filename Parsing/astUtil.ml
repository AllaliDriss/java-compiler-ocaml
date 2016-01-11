(* AST *)

type modifier = 
  | Public | Protected | Private | Static | Abstract | Final | Strictfp | Volatile | Transient

type modifiers = modifier list

and primitive = 
  | Int | Float | Double | Char | Boolean | Byte | Short | Long

type typ =
  | Primitive of primitive
  | Type of string


(* STRING_OF *)

let string_of_modifier c = match c with
  | Public -> "public"
  | Protected -> "protected"
  | Private -> "private"
  | Abstract -> "abstract"
  | Static -> "static"
  | Final -> "final"
  | Strictfp -> "strictfp"
  | Volatile -> "volatile"
  | Transient -> "transient"

let rec string_of_modifiers l = match l with
  | Some([]) -> ""
  | Some(x::xs) -> string_of_modifier(x) ^ " " ^ string_of_modifiers(Some(xs))
  | None -> "No modifier"

let string_of_primitive = function
  | Int -> "int"
  | Float -> "float"
  | Double -> "double"
  | Boolean -> "boolean"
  | Char -> "Char"
  | Long -> "long"
  | Byte -> "byte"
  | Short -> "short"

(*let string_of_attributType t = match t with*)
(*  | String str -> str*)
(*  | Primitive p -> string_of_primitive p*)

let string_of_type t = match t with
  | Primitive p -> string_of_primitive p
  | Type t -> t

exception Illegal_ConstructorException

exception Illegal_package

exception Illegal_variable 

exception Illegal_result

exception Illegal_methodeBody

exception Illegal_variableDeclarator

exception Illegal_interfaceBody

exception Illegal_expression

exception Illegal_enumConstant

exception Illegal_import

exception External_error
