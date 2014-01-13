(* ****** ****** *)
(*
**
** Some utility functions
** for turning ATS2 syntax trees into JSON format
**
*)
(* ****** ****** *)
(*
**
** Author: Hongwei Xi
** Authoremail: gmhwxiATgmailDOTcom
** Start Time: November, 2013
**
*)
(* ****** ****** *)

staload
UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload _(*anon*) = "prelude/DATS/list.dats"
staload _(*anon*) = "prelude/DATS/list_vt.dats"

(* ****** ****** *)

staload
STDIO = "libc/SATS/stdio.sats"

(* ****** ****** *)

staload "src/pats_dynexp2.sats"

(* ****** ****** *)
  
staload "./../SATS/libatsyn2json.sats"

(* ****** ****** *)

implement
jsonize_p2at
  (out, p2t0) = let
in
//
case+ p2t0.p2at_node of
| _ => let
    val () = (
      prerrln! ("jsonize_p2at: p2t0 = ", p2t0)
    ) (* end of [val] *)
    val ((*void*)) = assertloc (false)
  in
    exit (1)
  end // end of [_]
//
end // end of [jsonize_p2at]
  
(* ****** ****** *)

(* end of [libatsyn2json_p2at.dats] *)
