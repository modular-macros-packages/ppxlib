type t =
  (*IF_NOT_AT_LEAST 504 Ocaml_common.Longident.t = *)
  | Lident of string
  | Ldot of t * string
  | Lapply of t * t

let rec flat accu = function
  | Lident s -> s :: accu
  | Ldot (lid, s) -> flat (s :: accu) lid
  | Lapply (_, _) -> Misc.fatal_error "Longident.flat"

let flatten lid = flat [] lid

let rec split_at_dots s pos =
  try
    let dot = String.index_from s pos '.' in
    String.sub s pos (dot - pos) :: split_at_dots s (dot + 1)
  with Not_found -> [ String.sub s pos (String.length s - pos) ]

let unflatten l =
  match l with
  | [] -> None
  | hd :: tl -> Some (List.fold_left (fun p s -> Ldot (p, s)) (Lident hd) tl)

let parse s =
  match unflatten (split_at_dots s 0) with
  | None ->
      Lident ""
      (* should not happen, but don't put assert false
                          so as not to crash the toplevel (see Genprintval) *)
  | Some v -> v

let[@warning "-32"] rec to_504_plus lid =
  let loc = Location.none in
  match lid with
  | Lident s -> Longident_504.Lident s
  | Ldot (lid, s) ->
    Longident_504.Ldot ({txt = to_504_plus lid; loc}, { txt = s; loc})
  | Lapply (lid, lid2) ->
    Longident_504.Lapply
      ({txt = to_504_plus lid; loc}, {txt= to_504_plus lid2; loc})

let[@warning "-32"] rec from_504_plus lid =
  match lid with
  | Longident_504.Lident s -> Lident s
  | Longident_504.Ldot (lid, s) -> Ldot (from_504_plus lid.txt, s.txt)
  | Longident_504.Lapply (lid, lid2) ->
    Lapply (from_504_plus lid.txt, from_504_plus lid2.txt)

let template_mark = Encoding_505.Ext_name.template

let[@warning "-32"] rec to_505_plus lid =
  let loc = Location.none in
  match lid with
  | Lident s -> Longident_505.Lident s
  | Ldot (lid, s) ->
    Longident_505.Ldot ({txt = to_505_plus lid; loc}, { txt = s; loc})
  | Lapply (Ldot (lid, s), lid2) when String.equal s template_mark ->
    Longident_505.Lapply
      (Template, {txt = to_505_plus lid; loc}, {txt = to_505_plus lid2; loc})
  | Lapply (lid, lid2) ->
    Longident_505.Lapply
      (Plain, {txt = to_505_plus lid; loc}, {txt = to_505_plus lid2; loc})

let[@warning "-32"] rec from_505_plus lid =
  match lid with
  | Longident_505.Lident s -> Lident s
  | Longident_505.Ldot (lid, s) -> Ldot (from_505_plus lid.txt, s.txt)
  | Longident_505.Lapply (Plain, lid, lid2) ->
    Lapply (from_505_plus lid.txt, from_505_plus lid2.txt)
  | Longident_505.Lapply (Template, lid, lid2) ->
    Lapply (Ldot (from_505_plus lid.txt, template_mark), from_505_plus lid2.txt)

let to_compiler lid =
  (*IF_NOT_AT_LEAST 504 lid *)
  (*IF_EXACTLY 504 to_504_plus lid *)
  (*IF_AT_LEAST 505 to_505_plus lid *)

let from_compiler lid =
  (*IF_NOT_AT_LEAST 504 lid *)
  (*IF_EXACTLY 504 from_504_plus lid *)
  (*IF_AT_LEAST 505 from_505_plus lid *)
