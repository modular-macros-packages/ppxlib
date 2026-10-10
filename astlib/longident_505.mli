(* MacoCaml's 5.5 long identifiers: an application records whether it
   applies a functor, [F(M).t], or a template, [F$(M).t].  On 5.5 this is
   the compiler's own type; 5.4 has no kind (see Longident_504, and
   Encoding_505 for how a template application crosses the 5.4 gap). *)

type functor_kind =
  (*IF_AT_LEAST 505 Ocaml_common.Asttypes.functor_kind = *)
  | Template
  | Plain

type t =
  (*IF_AT_LEAST 505 Ocaml_common.Longident.t = *)
  | Lident of string
  | Ldot of t Location.loc * string Location.loc
  | Lapply of functor_kind * t Location.loc * t Location.loc
