module Ext_name : sig
  val pexp_struct_item : string
  val ptyp_functor : string
  val preserve_ppat_constraint : string
  val ptype_kind_external : string
  val external_psig : string
  val external_pstr_type : string
  val external_pmty_with : string

  (** MacoCaml constructs (T29): extension/attribute names used to carry
      quotes, splices, macro bindings and template functors across the
      504 migration gap.  Rewriters may also construct these nodes
      directly (e.g. to emit a splice); the 504->505 upgrade migration
      materialises them into real Parsetree constructs. *)

  val pexp_quote : string
  val pexp_splice : string
  val pstr_value_macro : string
  val pval_macro : string
  val template : string
end

module To_504 : sig
  open Ast_504.Asttypes
  open Ast_504.Parsetree

  val encode_pexp_struct_item :
    loc:Location.t -> structure_item * expression -> expression_desc

  val decode_pexp_struct_item :
    loc:Location.t -> payload -> structure_item * expression

  val encode_ptyp_functor :
    loc:Location.t ->
    arg_label * string loc * package_type * core_type ->
    core_type_desc

  val decode_ptyp_functor :
    loc:Location.t ->
    payload ->
    arg_label * string loc * package_type * core_type

  val encode_ptype_kind_external :
    loc:Location.t -> string -> attributes -> type_kind * attributes

  val decode_ptype_kind_external :
    type_declaration -> (string * attributes) option

  val encode_external_psig_type :
    loc:Location.t -> rec_flag -> type_declaration list -> signature_item_desc

  val encode_external_psig_typesubst :
    loc:Location.t -> type_declaration list -> signature_item_desc

  val decode_external_psig :
    loc:Location.t -> payload -> attributes -> signature_item_desc

  val encode_external_pstr_type :
    loc:Location.t -> rec_flag -> type_declaration list -> structure_item_desc

  val decode_external_pstr_type :
    loc:Location.t -> payload -> attributes -> structure_item_desc

  val encode_external_pmty_with :
    loc:Location.t -> module_type -> with_constraint list -> module_type_desc

  val decode_external_pmty_with : loc:Location.t -> payload -> module_type_desc

  val must_preserve_ppat_constraint : attributes -> attributes option
  (** Returns [None] if the list does not contain
      [@ppxlib.migration.preserve_ppat_constraint_505] or [Some l] where [l] is
      the remainder of the attributes. Should be used to determine whether a
      [Ppat_constraint (Ppat_unpack m, Ptyp_package s)] node should be preserved
      when migrated to 5.5 or turned into [Ppat_unpack (m, Some s)]. The
      attribute should be attached to the [Ppat_unpack] node within the
      [Ppat_constraint]. *)

  val preserve_ppat_constraint : pattern -> core_type -> pattern_desc

  (** {2 MacoCaml constructs (T29)} *)

  val encode_pexp_quote : loc:Location.t -> expression -> expression_desc
  val decode_pexp_quote : loc:Location.t -> payload -> expression
  val encode_pexp_splice : loc:Location.t -> expression -> expression_desc
  val decode_pexp_splice : loc:Location.t -> payload -> expression

  val encode_pstr_value_macro :
    loc:Location.t -> rec_flag -> value_binding list -> structure_item_desc

  val decode_pstr_value_macro :
    loc:Location.t -> payload -> rec_flag * value_binding list

  val pval_macro_attr : loc:Location.t -> attribute

  val extract_pval_macro : attributes -> attributes option
  (** Returns [Some rest] (the attributes minus the marker) if the
      [pval_macro] marker is present, [None] otherwise. *)

  val template_attr : loc:Location.t -> attribute

  val extract_template : attributes -> attributes option
  (** As {!extract_pval_macro}, for the [template] marker.  The marker
      sits on the child node the encoding designates: the body of an
      encoded template [Pmty_functor]/[Pmod_functor], and the functor
      position of an encoded template [Pmod_apply]/[Pmod_apply_unit]. *)
end
