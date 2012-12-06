(***********************************************************************)
(*                                                                     *)
(*                         Applied Type System                         *)
(*                                                                     *)
(*                              Hongwei Xi                             *)
(*                                                                     *)
(***********************************************************************)

(*
** ATS - Unleashing the Potential of Types!
** Copyright (C) 2002-2011 Hongwei Xi, Boston University
** All rights reserved
**
** ATS is free software;  you can  redistribute it and/or modify it under
** the terms of the GNU LESSER GENERAL PUBLIC LICENSE as published by the
** Free Software Foundation; either version 2.1, or (at your option)  any
** later version.
** 
** ATS is distributed in the hope that it will be useful, but WITHOUT ANY
** WARRANTY; without  even  the  implied  warranty  of MERCHANTABILITY or
** FITNESS FOR A PARTICULAR PURPOSE.  See the  GNU General Public License
** for more details.
** 
** You  should  have  received  a  copy of the GNU General Public License
** along  with  ATS;  see the  file COPYING.  If not, please write to the
** Free Software Foundation,  51 Franklin Street, Fifth Floor, Boston, MA
** 02110-1301, USA.
*)

(* ****** ****** *)

(* Author: Hongwei Xi *)
(* Authoremail: hwxi AT cs DOT bu DOT edu *)
(* Start time: November, 2011 *)

(* ****** ****** *)
//
// HX-2012-12: ported to ATS/Postiats
//
(* ****** ****** *)
//
// License: LGPL 3.0 (available at http://www.gnu.org/licenses/lgpl.txt)
//
(* ****** ****** *)

#define ATS_DYNLOADFLAG 0 // no dynamic loading at run-time

(* ****** ****** *)

staload "libats/SATS/linheap_binomial.sats"

(* ****** ****** *)

#define nullp the_null_ptr

(* ****** ****** *)
//
// binomial trees:
// btree(a, n) is for a binomial tree of rank(n)
//
datavtype btree (
  a:viewt@ype+, int(*rank*)
) =
  | {n:nat}
    btnode (a, n) of (int (n), a, btreelst (a, n))
// end of [btree]

and btreelst (
  a:viewt@ype+, int(*rank*)
) =
  | {n:nat}
    btlst_cons (a, n+1) of (btree (a, n), btreelst (a, n))
  | btlst_nil (a, 0)
// end of [btreelst]

(* ****** ****** *)

datavtype bheap (
  a:viewt@ype+, int(*rank*), int(*size*)
) =
  | {n:nat}
    bheap_nil (a, n, 0) of ()
  | {n:nat}{p:int}{sz:nat}{n1:int | n1 > n}
    bheap_cons (a, n, p+sz) of (EXP2 (n, p) | btree (a, n), bheap (a, n1, sz))
// end of [bheap]

(* ****** ****** *)

fun{
a:vt0p
} btree_rank
  {n:nat} .<>. (
  bt: !btree (a, n)
) :<> int (n) = let
  val btnode (n, _, _) = bt in n
end // end of [btree_rank]

(* ****** ****** *)

fun{
a:t0p
} btree_free
  {n:nat} .<n,1>.
  (bt: btree (a, n)) :<!wrt> void = let 
  val ~btnode (_, _, bts) = bt in btreelst_free (bts)
end // end of [btree_free]

and
btreelst_free
  {n:nat} .<n,0>. (
  bts: btreelst (a, n)
) :<!wrt> void = let
in
//
case+ bts of
| ~btlst_cons
    (bt, bts) => let
    val () = btree_free (bt) in btreelst_free (bts)
  end // end of [btlst_cons]
|  ~btlst_nil () => ()
end // end of [btreelst_free]

(* ****** ****** *)

fun{a:vt0p}
btree_btree_merge
  {n:nat} .<>. (
  bt1: btree (a, n)
, bt2: btree (a, n)
) :<!wrt> btree (a, n+1) = let
  val @btnode (n1, x1, bts1) = bt1
  val @btnode (n2, x2, bts2) = bt2
  val sgn = compare_elt_elt<a> (x1, x2)
in
  if sgn <= 0 then let
    prval () = fold@ (bt2)
    val () = n1 := n1 + 1
    val () = bts1 := btlst_cons (bt2, bts1)
  in
    fold@ (bt1); bt1
  end else let
    prval () = fold@ (bt1)
    val () = n2 := n2 + 1
    val () = bts2 := btlst_cons (bt1, bts2)
  in
    fold@ (bt2); bt2
  end // end of [if]
end // end of [btree_btree_merge]

(* ****** ****** *)

fun{a:vt0p}
btree_bheap_merge
  {sz:nat}{n,n1:nat | n <= n1}{p:int} .<sz>. (
  pf: EXP2 (n, p)
| bt: btree (a, n), n: int (n), hp: bheap (a, n1, sz)
) :<!wrt> [n2:int | n2 >= min(n, n1)] bheap (a, n2, sz+p) =
  case+ hp of
  | ~bheap_nil () =>
      bheap_cons (pf | bt, bheap_nil {a} {n+1} ())
    // end of [bheap_nil]
  | @bheap_cons (pf1 | bt1, hp1) => let
      val n1 = btree_rank<a> (bt1)
    in
      if n < n1 then let
        prval () = fold@ (hp) in bheap_cons {a} (pf | bt, hp)
      end else if n > n1 then let
        val () = hp1 := btree_bheap_merge<a> (pf | bt, n, hp1)
        prval () = fold@ (hp) 
      in
        hp
      end else let
        prval () = exp2_ispos (pf1)
        prval () = exp2_isfun (pf, pf1)
        val bt = btree_btree_merge (bt, bt1)
        val hp1 = hp1
        val () = free@ {a}{0}{0}{0}{1} (hp)
      in
        btree_bheap_merge (EXP2ind (pf) | bt, n+1, hp1)
      end // end of [if]
    end (* end of [bheap_cons] *)
// end of [btree_bheap_merge]

(* ****** ****** *)

fun{a:vt0p}
bheap_bheap_merge
  {n1,n2:nat}
  {sz1,sz2:nat} .<sz1+sz2>. (
  hp1: bheap (a, n1, sz1), hp2: bheap (a, n2, sz2)
) :<!wrt> [n:int | n >= min(n1, n2)] bheap (a, n, sz1+sz2) =
  case+ hp1 of
  | ~bheap_nil () => hp2
  | @bheap_cons (pf1 | bt1, hp11) => (
    case+ hp2 of
    | ~bheap_nil () => (fold@ (hp1); hp1)
    | @bheap_cons (pf2 | bt2, hp21) => let
//
        prval pf1 = pf1 and pf2 = pf2
        prval () = exp2_ispos (pf1) and () = exp2_ispos (pf2)
//
        val n1 = btree_rank<a> (bt1)
        and n2 = btree_rank<a> (bt2)
      in
        if n1 < n2 then let
          prval () = fold@ (hp2)
          val () = hp11 := bheap_bheap_merge (hp11, hp2)
          prval () = fold@ (hp1)
        in
          hp1
        end else if n1 > n2 then let
          prval () = fold@ (hp1)
          val () = hp21 := bheap_bheap_merge (hp1, hp21)
          prval () = fold@ (hp2)
        in
          hp2
        end else let
          prval () = exp2_isfun (pf1, pf2)
          val bt12 = btree_btree_merge (bt1, bt2)
          val hp11 = hp11 and hp21 = hp21
          val () = free@ {a}{0}{0}{0}{1} (hp1)
          val () = free@ {a}{0}{0}{0}{1} (hp2)
        in
          btree_bheap_merge (EXP2ind (pf1) | bt12, n1+1, bheap_bheap_merge (hp11, hp21))
        end // end of [if]
      end (* end of [bheap_cons] *)
    ) // end of [bheap_cons]
// end of [bheap_bheap_merge]

(* ****** ****** *)

assume
heap_viewtype
  (a:vt0p) = [n,sz:nat] bheap (a, n, sz)
// end of [heap_viewtype]

(* ****** ****** *)

implement{}
linheap_nil {a} () = bheap_nil {a}{0} ()

(* ****** ****** *)

implement
linheap_is_nil
  (hp) = let
in
//
case+ hp of
| bheap_cons (_ | _, _) => false | bheap_nil () => true
//
end // end of [linheap_is_nil]

implement
linheap_isnot_nil (hp) =
  if linheap_is_nil (hp) then false else true
// end of [linheap_isnot_nil]

(* ****** ****** *)

implement{a}
linheap_insert
  (hp, x0) = let
  val bt = btnode (0, x0, btlst_nil ())
in
  hp := btree_bheap_merge (EXP2bas () | bt, 0, hp)
end // end of [linheap_insert]

(* ****** ****** *)

implement{a}
linheap_getmin
  (hp0, res) = let
  val p_min = linheap_getmin_ref (hp0)
in
//
if p_min > nullp then let
  prval (pf, fpf) = __assert (p_min) where {
    extern praxi __assert
      {l:addr} (p: ptr l): (a @ l, a @ l -<lin,prf> void)
    // end of [extern]
  } // end of [prval]
  val () = res := !p_min
  prval () = fpf (pf)
  prval () = opt_some {a} (res) in true
end else let
  prval () = opt_none {a} (res) in false
end // end of [if]
//
end // end of [linheap_getmin]

(* ****** ****** *)
  
implement{a}
linheap_merge
  (hp1, hp2) = bheap_bheap_merge<a> (hp1, hp2)
// end of [linheap_merge]

(* ****** ****** *)

implement{a}
linheap_free (hp) = let
in
//
case+ hp of
| ~bheap_cons
    (_ | bt, hp) => let
    val () = btree_free (bt) in linheap_free (hp)
  end // end of [bheap]
| ~bheap_nil () => ()
//
end // end of [linheap_free]

(* ****** ****** *)

implement{a}
linheap_free_vt
  (hp) = let
  viewtypedef hp = heap (a)
in
//
case+ hp of
| bheap_cons
    (_ | _, _) => let
    prval () = opt_some {hp} (hp) in true
  end // end of [bheap_cons]
| bheap_nil () => let
    prval () =
      __assert (hp) where {
      extern fun __assert
        {n:int} (hp: !bheap (a, n, 0) >> ptr):<> void
      // end of [extern]
    } // end of [prval]
    prval () = opt_none {hp} (hp) in false
  end // end of [bheap_nil]
//
end // end of [linheap_free_vt]

(* ****** ****** *)

(* linheap_binomial.dats *)
