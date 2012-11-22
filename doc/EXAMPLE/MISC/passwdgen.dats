(*
**
** random password generation
**
** Author: Hongwei Xi (hwxi AT cs DOT bu DOT edu)
** Time: August, 2008
**
*)

(* ****** ****** *)
//
// HX: ported to Postiats on November 22, 2012 // Happy Thanksgiving!
//
(* ****** ****** *)

staload RAND =
  "contrib/atshwxi/testing/SATS/randgen.sats"
// end of [staload]

macdef randint = $RAND.randint

(* ****** ****** *)

extern fun string2int (str: string): int

(* ****** ****** *)

implement
main (
  argc, argv
) = 0 where {
  var n: int = 8
  val () =
    if argc >= 2 then n := string2int (argv[1])
  // end of [val]
  val [n:int] n = g1ofg0_int (n)
  val () = assert (n >= 0)
  val () = srand48_with_time () where {
    extern fun srand48_with_time (): void = "srand48_with_time"
  } // end of [val]
  val asz = g1int2uint (n)
  val passwd =
    arrayref_make_elt<char> (asz, '\000')
  val () = loop (n, 0) where {
    fun loop {i:nat | i <= n} .<n-i>.
      (n: int n, i: int i):<cloref1> void =
      if (i < n) then let
        val () = passwd[i] := int2char0 (randint (94) + 33)
      in
        loop (n, i+1)
      end else () // end of [if]
  } // end of [where]
//
  val out = stdout_ref
  val () = fprint_arrayref_sep (out, passwd, asz, "")
  val () = fprint_newline (out)
//
} // end of [main]

(* ****** ****** *)

(* end of [passwdgen.dats] *)
