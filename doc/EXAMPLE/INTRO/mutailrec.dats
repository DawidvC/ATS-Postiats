//
// Illustrating mutual tail-recursion
//
// Author: Hongwei Xi (December 31, 2012)
//

(* ****** ****** *)
//
(*
[isevn] and [isodd] are defined mutually
tail-recursively, that is, the recursive
calls in their bodies are all tail-calls.
*)
fnx isevn (x: int): bool =
  if x > 0 then isodd (x-1) else true
and isodd (x: int): bool =
  if x > 0 then isevn (x-1) else false
//
(* ****** ****** *)

implement
main (
) = 0 where {
  val () = assertloc (isevn (1000000))
  val () = assertloc (isodd (1000001))
} // end of [main]

(* ****** ****** *)

(* end of [mutailrec.dats] *)