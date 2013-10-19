(* ****** ****** *)
//
// HX-2013-10-17
//
(* ****** ****** *)

#define NPHIL 2

(* ****** ****** *)

typedef phil = int

(* ****** ****** *)

fun phil_left (n: phil): int
fun phil_right (n: phil): int

(* ****** ****** *)
//
absvt@ype
fork_vtype = int
//
vtypedef fork = fork_vtype
//
(* ****** ****** *)

fun randsleep (n: intGte(1)): void

(* ****** ****** *)

fun phil_acquire_lfork (n: phil): fork
fun phil_acquire_rfork (n: phil): fork

(* ****** ****** *)

fun phil_release_lfork (n: phil, f: fork): void
fun phil_release_rfork (n: phil, f: fork): void

(* ****** ****** *)

fun phil_eat (n: phil): void
fun phil_think (n: phil): void

(* ****** ****** *)

fun phil_loop (n: phil): void

(* ****** ****** *)

(* end of [DiningPhil.sats] *)