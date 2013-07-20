(* ****** ****** *)
//
// Linear Algebra matrix operations
//
(* ****** ****** *)

staload
UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "libats/SATS/gvector.sats"
staload "libats/SATS/gmatrix.sats"
staload "libats/SATS/gmatrix_col.sats"
staload "libats/SATS/gmatrix_row.sats"
staload "libats/SATS/refcount.sats"

(* ****** ****** *)

staload "libfloats/SATS/blas.sats"

(* ****** ****** *)

staload "libfloats/SATS/lavector.sats"
staload "libfloats/SATS/lamatrix.sats"

(* ****** ****** *)

extern
praxi
LAgmat_initize
  {a:t0p}{mo:mord}{m,n:int}
  (M: !LAgmat(a?, mo, m, n) >> LAgmat(a, mo, m, n)): void
// end of [LAgmat_initize]

(* ****** ****** *)

fun{}
LAgmat_TPN_assert
  {tp:transp}
(
  tp: TRANSP (tp), msg: string
) : void = let
in
//
case+ tp of
| TPN () => ()
| TPT () => let
    val () = prerrln! (msg) in assertexn (false)
  end // end of [TRANSP_T]
| TPC () => let
    val () = prerrln! (msg) in assertexn (false)
  end // end of [TRANSP_C]
//
end // end of [LAgmat_TPN_assert]

(* ****** ****** *)

local

vtypedef
sourcerfc = refcnt (ptr)

datavtype
LAgmat
(
  a:t@ype
, mord, int, int
) =
  {mo:mord}
  {m,n:int}
  {ld:int}
  {tp:transp}
  LAGMAT (a, mo, m, n) of
  (
    uint(*rfc*), sourcerfc
  , ptr, MORD(mo), int(m), int(n), int(ld), TRANSP(tp)
  )
// end of [LAgmat]

assume
LAgmat_vtype
  (a:t0p, mo: int, l:addr, m: int, n:int) = LAgmat (a, mo, m, n)
// end of [assume]

in (* in of [local] *)

(* ****** ****** *)

implement{}
LAgmat_mord
  (M) = mo where
{
val+LAGMAT
  (_, _, _, mo, _, _, _, _) = M
} (* end of [LAgmat_nrow] *)

(* ****** ****** *)

implement{}
LAgmat_nrow
  (M) = m where
{
val+LAGMAT (_, _, _, _, m, _, _, _) = M
} (* end of [LAgmat_nrow] *)

implement{}
LAgmat_ncol
  (M) = n where
{
val+LAGMAT (_, _, _, _, _, n, _, _) = M
} (* end of [LAgmat_ncol] *)

(* ****** ****** *)

implement{}
LAgmat_vtakeout_matrix
  {a}{mo}{m,n}
  (M, m2, n2, ld0, tp0) = let
//
val+LAGMAT
  (_, _, gmp, mo, m, n, ld, tp) = M
//
val () = ld0 := ld
val () = tp0 := tp
//
prval [ld:int]
  INTEQ () = inteq_make_gint (ld)
//
in
//
case+ tp of
//
| TPN () => let
    val () = m2 := m
    val () = n2 := n
    val (pf, fpf | gmp) = $UN.ptr_vtake{gmatrix(a,mo,m,n,ld)}(gmp)
  in
    (pf, fpf, TPDIM_N () | gmp)
  end
//
| TPT () => let
    val () = m2 := n
    val () = n2 := m
    val (pf, fpf | gmp) = $UN.ptr_vtake{gmatrix(a,mo,n,m,ld)}(gmp)
  in
    (pf, fpf, TPDIM_T () | gmp)
  end
//
| TPC () => let
    val () = m2 := n
    val () = n2 := m
    val (pf, fpf | gmp) = $UN.ptr_vtake{gmatrix(a,mo,n,m,ld)}(gmp)
  in
    (pf, fpf, TPDIM_C () | gmp)
  end
//
end // end of [LAgmat_vtakeout_matrix]

(* ****** ****** *)

implement{}
LAgmat_incref
  {a}{mo}{l}{m,n} (M) = let
//
val+@LAGMAT
  (rfc, _, _, _, _, _, _, _) = M
val ((*void*)) = (rfc := succ(rfc))
prval () = fold@(M)
//
in
  $UN.castvwtp1{LAgmat(a,mo,l,m,n)}(M)
end // end of [LAgmat_incref]

(* ****** ****** *)

implement{}
LAgmat_decref
  {a}{mo}{l}{m,n} (M) = let
//
val+@LAGMAT
  (rfc, src, _, _, _, _, _, _) = M
val rfc1 = pred (rfc)
//
in (* in of [LAgmat_decref] *)
//
if
isgtz(rfc1)
then let
  val () = rfc := rfc1
  prval () = fold@(M)
  prval () = $UN.cast2void (M)
in
  // nothing
end else let
  val opt =
    refcnt_decref_opt (src)
  val () = free@{a}{mo}{m,n}{1}(M)
  extern
  fun __free (ptr): void = "mac#atspre_mfree_gc"
in
  case+ opt of
  | ~Some_vt (gmp) => __free(gmp) | ~None_vt () => ()
end // end of [if]
//
end // end of [LAgmat_decref]

(* ****** ****** *)

implement{}
LAgmat_make_arrayptr
  (mo, A, m, n) = let
//
val pA = $UN.castvwtp0{ptr}(A)
val src = refcnt_make<ptr> (pA)
//
val ld =
(
  case+ mo of MORDrow () => n | MORDcol () => m
) : Int // end of [val]
//
in
  LAGMAT (1u(*rfc*), src, pA, mo, m, n, ld, TPN)
end // end of [LAgmat_make_arrayptr]

implement{}
LAgmat_make_matrixptr
  (M, m, n) = let
//
val pM = $UN.castvwtp0{ptr}(M)
val src = refcnt_make<ptr> (pM)
//
in
  LAGMAT (1u(*rfc*), src, pM, MORDrow, m, n, n, TPN)
end // end of [LAgmat_make_matrixptr]

(* ****** ****** *)

implement{a}
LAgmat_make_uninitized
  {mo}{m,n} (mo, m, n) = let
//
val mn = m * n
prval () = mul_gte_gte_gte{m,n}()
//
val A = arrayptr_make_uninitized<a> (i2sz(mn))
//
in
  LAgmat_make_arrayptr (mo, A, m, n)
end // end of [LAgmat_make_uninitized]

(* ****** ****** *)

implement{a}
LAgmat_transp
  {mo}{m,n} (M) = let
//
val+LAGMAT
  (_, src, gmp, mo, m, n, ld, tp) = M
//
val () = LAgmat_TPN_assert (tp, "LAgmat_transp:transposed:M")
//
val src2 = refcnt_incref (src)
//
in
  LAGMAT (1u(*rfc*), src2, gmp, mo, n, m, ld, TPT)
end // end of [LAgmat_transp]

(* ****** ****** *)

implement{a}
LAgmat_split_1x2
  (M, j) = let
//
val+LAGMAT
  (_, src, p, mo, m, n, ld, tp) = M
//
val (
) = LAgmat_TPN_assert (tp, "LAgmat_split_1x2:transposed:M")
//
val src1 = refcnt_incref (src)
val src2 = refcnt_incref (src)
val ((*void*)) = LAgmat_decref (M)
//
val p1 = p
val p2 = (
case+ mo of
| MORDrow () => ptr_add<a> (p, j   )
| MORDcol () => ptr_add<a> (p, j*ld)
) : ptr // endval
//
val j1 = j and j2 = n-j
//
val M1 = LAGMAT (1u(*rfc*), src1, p1, mo, m, j1, ld, tp)
val M2 = LAGMAT (1u(*rfc*), src2, p2, mo, m, j2, ld, tp)
//
in
  (M1, M2)
end // end of [LAgmat_split_1x2]

implement{a}
LAgmat_split_2x1
  (M, i) = let
//
val+LAGMAT
  (_, src, p, mo, m, n, ld, tp) = M
//
val (
) = LAgmat_TPN_assert (tp, "LAgmat_split_2x1:transposed:M")
//
val src1 = refcnt_incref (src)
val src2 = refcnt_incref (src)
val ((*void*)) = LAgmat_decref (M)
//
val p1 = p
val p2 = (
case+ mo of
| MORDrow () => ptr_add<a> (p, i*ld)
| MORDcol () => ptr_add<a> (p, i   )
) : ptr // endval
//
val i1 = i and i2 = m-i
//
val M1 = LAGMAT (1u(*rfc*), src1, p1, mo, i1, n, ld, tp)
val M2 = LAGMAT (1u(*rfc*), src2, p2, mo, i2, n, ld, tp)
//
in
  (M1, M2)
end // end of [LAgmat_split_2x1]

(* ****** ****** *)

implement{a}
LAgmat_split_2x2
  (M, i, j) = let
//
val+LAGMAT
  (_, src, p, mo, m, n, ld, tp) = M
//
val (
) = LAgmat_TPN_assert (tp, "LAgmat_split_2x2:transposed:M")
//
val src11 = refcnt_incref (src)
val src12 = refcnt_incref (src)
val src21 = refcnt_incref (src)
val src22 = refcnt_incref (src)
val ((*void*)) = LAgmat_decref (M)
//
val d12 = (
case+ mo of MORDrow () => j | MORDcol () => j*ld
) : int // endval
val d21 = (
case+ mo of MORDrow () => i*ld | MORDcol () => i
) : int // endval
val d22 = d12 + d21
//
val p11 = p
val p12 = ptr_add<a> (p, d12)
val p21 = ptr_add<a> (p, d21)
val p22 = ptr_add<a> (p, d22)
//
val i1 = i and i2 = m-i
val j1 = j and j2 = n-j
//
val M11 = LAGMAT (1u(*rfc*), src11, p11, mo, i1, j1, ld, tp)
val M12 = LAGMAT (1u(*rfc*), src12, p12, mo, i1, j2, ld, tp)
val M21 = LAGMAT (1u(*rfc*), src21, p21, mo, i2, j1, ld, tp)
val M22 = LAGMAT (1u(*rfc*), src22, p22, mo, i2, j2, ld, tp)
//
in
  (M11, M12, M21, M22)
end // end of [LAgmat_split_2x2]

(* ****** ****** *)

end // end of [local]

(* ****** ****** *)
//
implement{}
fprint_LAgmat$sep1 (out) = fprint (out, ", ")
implement{}
fprint_LAgmat$sep2 (out) = fprint (out, "; ")
//
implement
{a}(*tmp*)
fprint_LAgmat
  (out, M) = let
//
val mo = LAgmat_mord (M)
//
var m: int
and n: int
var ld: int
var tp: ptr?
val (
  pf, fpf, pftr | p
) = LAgmat_vtakeout_matrix (M, m, n, ld, tp)
//
val () =
(
case tp of
| TPN () => ()
| TPT () =>
  (
    fprint (out, "transped:\n")
  )
| TPC () =>
  (
    fprint (out, "ctransped:\n")
  )
) : void // end of [val]
//
local
implement
fprint_gmatrix$sep1<>
  (out) = fprint_LAgmat$sep1 (out)
implement
fprint_gmatrix$sep2<>
  (out) = fprint_LAgmat$sep2 (out)
in (* in of [local] *)
val () = fprint_gmatrix (out, !p, mo, m, n, ld)
end // end of [local]
//
prval () = fpf (pf)
//
in
  // nothing
end // end of [fprint_LAgmat]

(* ****** ****** *)

implement
{a}(*tmp*)
fprint_LAgmat_sep
  (out, M, sep1, sep2) = let
//
implement
fprint_LAgmat$sep1<> (out) = fprint_string (out, sep1)
implement
fprint_LAgmat$sep2<> (out) = fprint_string (out, sep2)
//
in
  fprint_LAgmat (out, M)
end // end of [fprint_LAgmat_sep]

(* ****** ****** *)

implement{a}
LAgmat_tabulate
  (mo, m, n) = let
//
infixl (/) %
#define % g0uint_mod
//
val m2 = i2sz(m)
val n2 = i2sz(n)
val mn = m2 * n2
//
in
//
case+ mo of
| MORDrow () => let
    implement
    array_tabulate$fopr<a> (isz) = let
      val i = isz / n2 and j = isz % n2
    in
      LAgmat_tabulate$fopr<a> (g0u2i(i), g0u2i(j))
    end
  in
    LAgmat_make_arrayptr (mo, arrayptr_tabulate<a> (mn), m, n)
  end // end of [MORDrow]
| MORDcol () => let
    implement
    array_tabulate$fopr<a> (isz) = let
      val i = isz % m2 and j = isz / m2
    in
      LAgmat_tabulate$fopr<a> (g0u2i(i), g0u2i(j))
    end
  in
    LAgmat_make_arrayptr (mo, arrayptr_tabulate<a> (mn), m, n)
  end // end of [MORDcol]
//
end // end of [LAgmat_tabulate]

(* ****** ****** *)

implement
{a}(*tmp*)
LAgmat_scal
  (alpha, M) = let
//
val m = LAgmat_nrow (M)
val n = LAgmat_ncol (M)
val ord = LAgmat_mord (M)
//
var m2: int and n2: int
var ld: int and tp: ptr
//
val
(
  pf, fpf, pftp | p
) = LAgmat_vtakeout_matrix (M, m2, n2, ld, tp)
//
in
//
case+ ord of
| MORDrow () => let
    val () =
    blas_scal2_row (alpha, !p, m2, n2, ld)
    prval () = fpf (pf)
  in
    // nothing
  end // end of [MORDrow]
| MORDcol () => let
    val () =
    blas_scal2_col (alpha, !p, m2, n2, ld)
    prval () = fpf (pf)
  in
    // nothing
  end // end of [MORDcol]
//
end // end of [LAgmat_scal]

(* ****** ****** *)

implement
{a}(*tmp*)
scal_LAgmat
  (alpha, M) = M2 where
{
//
val m = LAgmat_nrow (M)
val n = LAgmat_ncol (M)
val ord = LAgmat_mord (M)
//
prval () = lemma_LAgmat_param (M)
//
val M2 = LAgmat_make_uninitized<a> (ord, m, n)
val () = LAgmat_initize (M2)
//
val _0 = gnumber_int<a>(0)
local
implement
blas$_alpha_beta<a>
  (alpha, x, beta, y) = gmul_val<a> (alpha, x)
in (* in of [local] *)
val () = LAgmat_axby (alpha, M, _0, M2)
end // end of [local]
//
} // end of [scal_LAgmat]

(* ****** ****** *)

implement
{a}(*tmp*)
LAgmat_copy
  (M1, M2) = let
//
val m = LAgmat_nrow (M1)
val n = LAgmat_ncol (M1)
val ord = LAgmat_mord (M1)
//
var m1: int and n1: int
var m2: int and n2: int
var ld1: int and ld2: int
var tp1: ptr and tp2: ptr
//
val
(
  pf1, fpf1, pftp1 | p1
) = LAgmat_vtakeout_matrix (M1, m1, n1, ld1, tp1)
val
(
  pf2, fpf2, pftp2 | p2
) = LAgmat_vtakeout_matrix (M2, m2, n2, ld2, tp2)
//
val (
) = LAgmat_TPN_assert (tp1, "LAgmat_copy:transposed:M1")
val (
) = LAgmat_TPN_assert (tp2, "LAgmat_copy:transposed:M2")
//
val-TPN () = tp1
val-TPN () = tp2
//
prval TPDIM_N () = pftp1
prval TPDIM_N () = pftp2
//
in
//
case+ ord of
| MORDrow () => let
    val () =
    blas_copy2_row (!p1, !p2, m, n, ld1, ld2)
    prval () = gmatrix_uninitize(!p2)
    prval () = fpf1 (pf1) and () = fpf2 (pf2)
    prval () = LAgmat_initize{a}(M2)
  in
    // nothing
  end // end of [MORDrow]
| MORDcol () => let
    val () =
    blas_copy2_col (!p1, !p2, m, n, ld1, ld2)
    prval () = gmatrix_uninitize(!p2)
    prval () = fpf1 (pf1) and () = fpf2 (pf2)
    prval () = LAgmat_initize{a}(M2)
  in
    // nothing
  end // end of [MORDcol]
//
end // end of [LAgmat_copy]

(* ****** ****** *)

implement
{a}(*tmp*)
copy_LAgmat
  (M) = M2 where
{
//
val m = LAgmat_nrow (M)
and n = LAgmat_ncol (M)
val ord = LAgmat_mord (M)
//
prval () = lemma_LAgmat_param (M)
//
val M2 = LAgmat_make_uninitized<a> (ord, m, n)
val () = LAgmat_copy (M, M2)
//
} // end of [copy_LAgmat]

(* ****** ****** *)

implement
{a}(*tmp*)
LAgmat_1x1y
(
  A, B
) = let
//
val _1 = gnumber_int<a>(1)
//
implement
blas$_alpha_beta<a>
  (alpha, x, beta, y) = gadd_val<a> (x, y)
//
in
  LAgmat_axby (_1, A, _1, B)
end // end of [LAgmat_1x1y]

(* ****** ****** *)

implement
{a}(*tmp*)
LAgmat_ax1y
(
  alpha, A, B
) = let
//
val _1 = gnumber_int<a>(1)
implement
blas$_alpha_beta<a>
  (alpha, x, beta, y) = blas$_alpha_1<a> (alpha, x, y)
//
in
  LAgmat_axby (alpha, A, _1, B)
end // end of [LAgmat_ax1y]

(* ****** ****** *)

implement
{a}(*tmp*)
LAgmat_axby
(
  alpha, A, beta, B
) = let
//
val mo = LAgmat_mord (A)
val nrow = LAgmat_nrow (A)
val ncol = LAgmat_ncol (A)
//
var ma: int and mb: int
var na: int and nb: int
var lda: int and ldb: int
var tpa: ptr and tpb: ptr
//
val
(
  pfa, fpfa, pftpa | pA
) = LAgmat_vtakeout_matrix (A, ma, na, lda, tpa)
val
(
  pfb, fpfb, pftpb | pB
) = LAgmat_vtakeout_matrix (B, mb, nb, ldb, tpb)
//
val (
) = LAgmat_TPN_assert (tpa, "LAgmat_axby:transposed:A")
val (
) = LAgmat_TPN_assert (tpb, "LAgmat_axby:transposed:B")
//
val-TPN () = tpa
val-TPN () = tpb
//
prval TPDIM_N () = pftpa
prval TPDIM_N () = pftpb
//
val () =
(
case+ mo of
| MORDrow () =>
    blas_axby2_row (alpha, !pA, beta, !pB, nrow, ncol, lda, ldb)
| MORDcol () =>
    blas_axby2_col (alpha, !pA, beta, !pB, nrow, ncol, lda, ldb)
) : void // end of [val]
//
prval () = fpfa (pfa)
prval () = fpfb (pfb)
//
in
  // nothing
end // end of [LAgmat_axby]

(* ****** ****** *)

implement{a}
add11_LAgmat_LAgmat
  (A, B) = res where
{
//
val res = copy_LAgmat (B)
val ((*void*)) = LAgmat_1x1y (A, res)
//
} // end of [add11_LAgmat_LAgmat]

(* ****** ****** *)

implement{a}
sub11_LAgmat_LAgmat
  (A, B) = res where
{
//
val _n1 = gnumber_int<a>(~1)
val res = scal_LAgmat (_n1, B)
val ((*void*)) = LAgmat_1x1y (A, res)
//
} // end of [sub11_LAgmat_LAgmat]

(* ****** ****** *)

implement{a}
LAgmat_gemm
(
  alpha, A, B, beta, C
) = let
//
val p = LAgmat_nrow (A)
val q = LAgmat_nrow (B)
val r = LAgmat_ncol (C)
val ord = LAgmat_mord (C)
//
var ma: int and mb: int and mc: int
var na: int and nb: int and nc: int
var lda: int and ldb: int and ldc: int
var tpa: ptr and tpb: ptr and tpc: ptr
//
val
(
  pfa, fpfa, pftpa | pA
) = LAgmat_vtakeout_matrix (A, ma, na, lda, tpa)
val
(
  pfb, fpfb, pftpb | pB
) = LAgmat_vtakeout_matrix (B, mb, nb, ldb, tpb)
val
(
  pfc, fpfc, pftpc | pC
) = LAgmat_vtakeout_matrix (C, mc, nc, ldc, tpc)
//
val () = LAgmat_TPN_assert (tpc, "LAgmat_gemm:transposed:C")
//
val-TPN () = tpc
prval TPDIM_N () = pftpc
//
val () = (
case+ ord of
| MORDrow () =>
  blas_gemm_row
  (
    pftpa, pftpb | alpha, !pA, tpa, !pB, tpb, beta, !pC, p, q, r, lda, ldb, ldc
  )
| MORDcol () =>
  blas_gemm_col
  (
    pftpa, pftpb | alpha, !pA, tpa, !pB, tpb, beta, !pC, p, q, r, lda, ldb, ldc
  )
) : void // end of [val]
//
prval () = fpfa (pfa)
prval () = fpfb (pfb)
prval () = fpfc (pfc)
//
in
  // nothing
end // end of [LAgmat_gemm]

(* ****** ****** *)

implement{a}
mul00_LAgmat_LAgmat
  (A, B) = AB where
{
val AB = A * B
val () = LAgmat_decref2 (A, B)
} // end of [mul00_LAgmat_LAgmat]

implement{a}
mul01_LAgmat_LAgmat
  (A, B) = AB where
{
val AB = A * B
val () = LAgmat_decref (A)
} // end of [mul00_LAgmat_LAgmat]

implement{a}
mul10_LAgmat_LAgmat
  (A, B) = AB where
{
val AB = A * B
val () = LAgmat_decref (B)
} // end of [mul00_LAgmat_LAgmat]

(* ****** ****** *)

implement{a}
mul11_LAgmat_LAgmat
  (A, B) = C where
{
//
val p = LAgmat_nrow (A)
val r = LAgmat_ncol (B)
val ord = LAgmat_mord (A)
//
prval () = lemma_LAgmat_param (A)
prval () = lemma_LAgmat_param (B)
//
val C = LAgmat_make_uninitized (ord, p, r)
//
val _1 = gnumber_int<a>(1)
val _0 = gnumber_int<a>(0)
prval () = LAgmat_initize (C)
//
local
implement
blas$_alpha_beta<a> (alpha, x, beta, y) = x
in (* in of [local] *)
val ((*void*)) = LAgmat_gemm (_1, A, B, _0, C)
end // end of [local]
//
} // end of [mul11_LAgmat_LAgmat]

(* ****** ****** *)

(* end of [lamatrix.dats] *)