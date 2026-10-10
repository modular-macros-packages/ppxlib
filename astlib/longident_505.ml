
type functor_kind =
  (*IF_AT_LEAST 505 Ocaml_common.Asttypes.functor_kind = *)
  | Template
  | Plain

type t =
  (*IF_AT_LEAST 505 Ocaml_common.Longident.t = *)
  | Lident of string
  | Ldot of t Location.loc * string Location.loc
  | Lapply of functor_kind * t Location.loc * t Location.loc
