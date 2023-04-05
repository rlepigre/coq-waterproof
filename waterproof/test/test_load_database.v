(** * Testcases for changing the global variable [global_database_selection]
Authors: 
    - Lulof Pirée (1363638)
    - Tudor Voicu (1339532)
    - Adrian Vrămuleţ (1284487)
    - Cosmin Manea (small changes)
    - Jim Portegies
Creation date: 18 June 2021

Test whether the populate_database file loads the 
databases and if changing the global variable [global_database_selection] 
changes the behavior of [waterprove].

--------------------------------------------------------------------------------

This file is part of Waterproof-lib.

Waterproof-lib is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Waterproof-lib is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Waterproof-lib.  If not, see <https://www.gnu.org/licenses/>.
*)

From Ltac2 Require Import Ltac2.
From Ltac2 Require Option.


Require Import Waterproof.message.

Require Import Reals.
Require Import Waterproof.test_auxiliary.
Require Import Waterproof.auxiliary.
Require Import Waterproof.waterprove.waterprove.
Require Import Waterproof.init_automation_global_variables.
Require Import Waterproof.populate_database.
Import Waterproof.populate_database.wp_all.

(* Note: [core] is always *implicitly* included. *)

Require Import Waterproof.theory.logic_and_set_theory.subsets.
Local Open Scope R_scope.
(*
--------------------------------------------------------------------------------
*)(** * Testcases for empty selection
    Only the database [nocore] should be loaded.
*)

(** * Test 1a
    Lemma that should be proveable with [nocore].
*)
Lemma load_db_test_1a: True.
    waterprove (Control.goal ()) [] false.
Qed.

Ltac2 Set global_database_selection as old_selection := fun () => [].

(** * Test 1b
    Lemma that should be NOT proveable with [nocore].
*)
Lemma load_db_test_1b: forall x y:R, (x + y)^2 = x^2 + y^2 + 2*x*y.
    let result () := waterprove (Control.goal ()) [] false in
    assert_raises_error result.
Abort.

(*
--------------------------------------------------------------------------------
*)(** * Testcases for WaterproofDBMultiplication. 
*)

(* loding the specified database*)
Ltac2 Set global_database_selection as old_selection := fun () => [ @wp_eq_mult].
Require Import Waterproof.set_search_depth.To_3.

(** * Test 2a
    Test for sufficiency. 
    Passes if the goal can be solved by the specified database alone.
*)
Lemma load_db_test_2a: forall x y:R, (x + y)*x = x*x + x*y.
    intros.
    waterprove (Control.goal ()) [] false.
Qed.

(** * Test 2b
    Test for expressiveness (power) of the specified database.
    The database cannot solve goals that do not fall within its scope.
    Passes 
    when an error is raised.
*)
Lemma load_db_test_2b: forall x y:R, x + y = y + x.
    let result () := waterprove (Control.goal ()) [] false in
    assert_raises_error result.

Abort.

(* reset the selection of databases*)
Ltac2 Set global_database_selection as old_selection := fun () => [].

(* loding databases other than the specified one*)
Ltac2 Set global_database_selection := fun () => [ @wp_eq_plus; @wp_eq_minus].
Require Import Waterproof.set_search_depth.To_3.

(** * Test 2c
    Test for necessity, which passes if an error is raised, i.e. when
    the specified database is missing. 
*)
Lemma load_db_test_2c: forall x y:R, (x + y)*x = x*x + x*y.
    let result () := waterprove (Control.goal ()) [] false in
    assert_raises_error result.
Abort.



(* reset the selection of databases*)
Ltac2 Set global_database_selection as old_selection := fun () => [].


(*
--------------------------------------------------------------------------------
*)(** * Testcases for WaterproofDBPlusMinus. 
*)

(* loading the specified database*)
Ltac2 Set global_database_selection := fun () => [ @wp_eq_plus; @wp_eq_minus].
Require Import Waterproof.set_search_depth.To_3.

(** * Test 3a
    Test for sufficiency. 
    Passes if the goal can be solved by the specified database alone.
*)
Lemma load_db_test_3a: forall x y:R, x + x + y = x + y + x.
    intros.
    waterprove (Control.goal ()) [] false.
Qed.

(** * Test 3b
    Test for expressiveness (power) of the specified database.
    The database cannot solve goals that do not fall within its scope.
    Passes 
    when an error is raised.
*)
Lemma load_db_test_3b: forall x y:R, x*y = y *x.
    let result () := waterprove (Control.goal ()) [] false in
    assert_raises_error result.
Abort.

(* reset the selection of databases*)
Ltac2 Set global_database_selection as old_selection := fun () => [].

(* loding databases other than the specified one*)
Ltac2 Set global_database_selection := fun () => [ @wp_eq_mult].
Require Import Waterproof.set_search_depth.To_3.

(** * Test 3c
    Test for necessity, which passes if an error is raised, i.e. when
    the specified database is missing. 
*)
Lemma load_db_test_3c: forall x y:R, x + x + y = x + y + x.
    let result () := waterprove (Control.goal ()) [] false in
    assert_raises_error result.
Abort.

(* reset the selection of databases*)
Ltac2 Set global_database_selection as old_selection := fun () => [].


(*
--------------------------------------------------------------------------------
*)(** * Testcases for WaterproofDBZeroOne. 
*)

(* loding the specified database*)
Ltac2 Set global_database_selection := fun () => [ @wp_eq_one; @wp_eq_zero].
Require Import Waterproof.set_search_depth.To_3.

(** * Test 4a
    Test for sufficiency. 
    Passes if the goal can be solved by the specified database alone.
*)
Lemma load_db_test_4a: forall x y:R, x*1 + 1 + 0 = x +1.
    intros.
    waterprove (Control.goal ()) [] false.
Qed.

(** * Test 4b
    Test for expressiveness (power) of the specified database.
    The database cannot solve goals that do not fall within its scope.
    Passes 
    when an error is raised.
*)
Lemma load_db_test_4b: forall x y:R, x*y = y *x.
    let result () := waterprove (Control.goal ()) [] false in
    assert_raises_error result.

Abort.

(* reset the selection of databases*)
Ltac2 Set global_database_selection as old_selection :=
    fun () => [ @wp_eq_mult].

(* loding databases other than the specified one*)
Require Import Waterproof.set_search_depth.To_3.

(** * Test 4c
    Test for necessity, which passes if an error is raised, i.e. when
    the specified database is missing. 
*)
Lemma load_db_test_4c: forall x y:R, x*1 + 1 + 0 = x +1.
    let result () := waterprove (Control.goal ()) [] false in
    assert_raises_error result.
Abort.

(* reset the selection of databases*)
Ltac2 Set global_database_selection as old_selection :=
    fun () => [ @wp_eq_mult].

(** * Test 12
    Same as test 2, but now the WRONG database is loaded.
*)
Lemma load_db_test_12: forall x y:R, (x + y)^2 = x^2 + y^2 + 2*x*y.
    let result () := waterprove (Control.goal ()) [] false in
    assert_raises_error result.
Abort.

(* Empty the database *)
Ltac2 Set global_database_selection as old_selection :=
    fun () => [ @wp_reals].

(** * Test 13
    Same as test 2, but now the REQUIRED database is loaded.
*)
Lemma load_db_test_13: forall x y:R, (x + y)^2 = x^2 + y^2 + 2*x*y.
    intros.
    waterprove (Control.goal ()) [] false.
Qed.

(*Empty the database*)
Ltac2 Set global_database_selection as old_selection :=
    fun () => [].

(** Before putting something in the additional database, proving after loading all won't work. *)

Goal forall x y:R, (x + y)^2 = x^2 + y^2 + 2*x*y.
    intros.
    Fail waterprove (Control.goal ()) [] false.
Abort.

Local Hint Resolve Rmax_r : additional.

(*Empty the database*)
Ltac2 Set global_database_selection as old_selection := fun () => [].

(** * Test 15
    Since there exists a lemma for this goal, 
    it can now be proven with only the lemma.
*)
Goal forall x y:R, (x + y)^2 = x^2 + y^2 + 2*x*y.

    waterprove (Control.goal ()) [(fun() => constr:(load_db_test_13))] false.
Qed.

Ltac2 Set global_database_selection as old_selection :=
    fun () => [ @wp_eq_mult].
Ltac2 Set global_search_depth := 4.
(** * Test 16
    This goal requires can not be solved by only one database.
*)
Goal forall x y, x * y = y * x + 0.
Proof.
    let result () := waterprove (Control.goal ()) [] false in
    assert_raises_error result.
    Ltac2 Set global_database_selection as old_selection :=
        fun () => [ @wp_eq_zero].
    let result () := waterprove (Control.goal ()) [] false in
    assert_raises_error result.
Abort.

Ltac2 Set global_database_selection as old_selection :=
    fun () => [ @wp_eq_mult; @wp_eq_zero].
Ltac2 Set global_search_depth := 1.

(** * Test 17
    However, it can be solved with combinig the two databases.
    Nevertheless, this test will still fail, since currently,
    it needs to be split into more subgoals.
*)
Goal forall x y, x * y = y * x + 0 .
Proof.
    let result () := waterprove (Control.goal ()) [] false in
    assert_raises_error result.
Abort.
Ltac2 Set global_search_depth := 3.


(** * Test 18
    Now, the test should work.
*)
Goal forall x y, x * y = y * x + 0 .
Proof.
    intros.
    waterprove (Control.goal ()) [] false.
Qed.
Ltac2 Set global_database_selection as old_selection :=
    fun () => [ @wp_eq_minus; @wp_eq_plus; @wp_eq_mult; @wp_eq_one; @wp_eq_zero; @wp_eq_sqr; @wp_eq_abs].

(** * Test 19
    This test should not be solved, since it doesn't have 
    the required wp_eq_abs database.
*)
Goal forall a:R, ln(exp a) = a.
    let result () := waterprove (Control.goal ()) [] false in
    assert_raises_error result.
Abort.

Ltac2 Set global_database_selection as old_selection :=
    fun () => [ @wp_eq_exp].
(** * Test 20
    This test should work just fine now.
*)
Goal forall a:R, ln(exp a) = a.
    intros.
    waterprove (Control.goal ()) [] false.
Abort.

Ltac2 Set global_database_selection as old_selection :=
    fun () =>
        [ @wp_eq_zero; @wp_eq_one; @wp_eq_mult; 
          @wp_eq_plus; @wp_eq_minus; @wp_eq_sqr;
          @wp_eq_exp
        ].

(** * Test 21
    This test should not be solved, since it has all 
    databases except the required one.
*)
Goal forall a:R, Rabs(a) = Rabs(-a).
  let result () := waterprove (Control.goal ()) [] false in
    assert_raises_error result.
Abort.

Ltac2 Set global_database_selection as old_selection :=
    fun () => [ @wp_eq_abs].

(** * Test 22
    This test should work just fine now.
*)
Goal forall a:R, Rabs(a) = Rabs(-a).
    intro a.
    waterprove (Control.goal ()) [] false.
Abort.
Ltac2 Set global_database_selection as old_selection :=
    fun () => [ @wp_eq_abs; @wp_reals].

(** * Test 23
    Another test that uses two databases, for good measure.
*)
Goal forall x y:R, (x+y)^2 = Rabs(x)^2 + 2*x*y + y^2.
  intros.
  waterprove (Control.goal ()) [] false.
Qed.

(** * Test 24
    However, even if this goal is correct and seems solvable, 
    there is no hint stating that |a^2| = a^2.
    Therefore, this test will fail.
*)
Goal forall x y:R, (x+y)^2 = Rabs(x^2) + 2*x*y + y^2.
  let result () := waterprove (Control.goal ()) [] false in
    assert_raises_error result.
Abort.

Lemma abs_sqr : forall x:R, Rabs(x^2) = x^2.
Proof.
  intro x.
  apply Rabs_pos_eq.
  apply pow2_ge_0.
Qed.

#[local] Hint Resolve abs_sqr: dummy.
Lemma lm_abs_srq : forall x:R, Rabs(x^2) = x^2.
    solve[auto with nocore dummy].
Qed.


(** * Test 25
    The reals database should be able to solve for all x : R, ~( x > x).
*)
Goal forall x : R, ~ (x > x).
intro x.
solve [auto with wp_reals].
Qed.
