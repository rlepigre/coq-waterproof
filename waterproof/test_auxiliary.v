(** * Tescases for[auxiliary.v]

Authors: 
    - Lulof Pirée (1363638)
Creation date: 16 May 2021

Auxiliary functions for testing.

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
From Ltac2 Require Import Int.

Require Import Waterproof.string_auxiliary.
Require Import Waterproof.auxiliary.

(** * Introduce global test verbosity. *)
Ltac2 mutable test_verbosity () := 0.

Ltac2 Type exn ::= [ TestFailedError(message) ].

Ltac2 fail_test (msg:message) := 
    Control.zero (TestFailedError msg).

(*  Same function as [type_of] in [auxiliary.v].
        Repeated here to avoid double imports
        in modules that import both 
        [auxiliary.v] AND [test_auxiliary.v]. *)
Definition type_of_test_aux {T : Type} (x : T) := T.

(** * print_success
    A function that prints a message in case
    a test is passed. The function only prints 
    if the global test_verbosity is larger than or equal 
    than 1.

    Arguments:
        - [msg : message] The message to print on success.
*)
Ltac2 print_success (msg : message) := 
  match (ge (test_verbosity ()) 1) with 
  |  false => ()
  |  _ => print msg
  end.

(*
    Check if the function "f" raises an error when evaluated.

    Arguments:
        * f, function without arguments.
    
    Raises Exceptions:
        * TestFailedError, if the execution of "f"
            does NOT raise a catchable exception.
*)
Ltac2 assert_raises_error f :=
    match Control.case f with
    | Val _ => fail_test (of_string "Should raise an error")
    | Err exn => print_success (concat 
        (of_string "Test passed, got error:") 
        (of_exn exn))
    end.

(*
    Check if two lists (of arbitrary type) are equal. 
    Raise an error if they have different lengths,
    or that there exists an index such that their value at that index
    differs.

    Arguments:
        * x, y: ('a list), lists of arbitrary type to be compared.

    Raises Exceptions:
        * TestFailedError, if x and y have a different length.
        * TestFailedError, if there exists an i such that x[i] ≠ y[i].
*)
Ltac2 rec assert_list_equal (f : 'a -> 'a -> bool) (of_a : 'a -> message) (x:'a list) (y: 'a list) :=    
    match x with
    | x_head::x_tail =>
        match y with
        | y_head::y_tail =>
            match (f x_head y_head) with
            | true => assert_list_equal f of_a x_tail y_tail
            | false => fail_test (concat (of_string "Unequal elements:") 
                                    (concat (of_a x_head) 
                                            (of_a y_head)
                                    )
                            )
            end
        | [] => fail_test (of_string "First list has more elements")
        end
    | [] => 
        match y with
            | [] => print_success (of_string "Test passed: lists indeed equal")
            | y_head::y_tai => fail_test (of_string "Second list has more elements")
        end
    end.

(** * assert_hyp_exists
    Assert that the hypothesis of the given ident
    exists in the current environment.

    Arguments:
        - [h : ident], identifier of target hypothesis

    Raises Exceptions:
        - [TestFailedError], if there is no hypothesis with the identifier
            stored in [h] in the current context.
*)
Ltac2 assert_hyp_exists (h: ident) :=
    match Control.case (fun () => Control.hyp h) with
    | Val _ => print_success(concat (of_string "Indeed hyp exists:") (of_ident h))
    | Err exn => fail_test (concat (of_exn exn) (of_string "Hyp not found"))
    end.

(** * assert_hyp_has_type
    Assert that the hypothesis of the given ident
    exists in the current environment, AND has the indicated type.

    Arguments:
        - [h : ident], identifier of target hypothesis.
        - [t : constr], expected type of the hypothesis identified
            by the value of [h].

    Raises Exceptions:
        - [TestFailedError], if there is no hypothesis with the identifier
            stored in [h] in the current context.
        - [TestFailedError], if the hypothesis identified by [h] has a 
            different type than [t]. Types are normalized before comparison.
*)
Ltac2 assert_hyp_has_type (h: ident) (t: constr) :=
    assert_hyp_exists h;
    let h_val := Control.hyp h in
    let h_normalized :=  (eval cbv in (type_of_test_aux $h_val)) in
    let t_normalized :=  (eval cbv in $t) in
    match Constr.equal h_normalized t_normalized with
    | true => print_success (concat (concat (of_string "Hypothesis '") (of_ident h))
                            (concat (of_string "' indeed has type: ") 
                                    (of_constr t))
                    )
    | false => fail_test (
            concat  (concat  (of_string "Hypothesis has wrong type. Expected type: ") 
                            (of_constr t))
                    (concat (of_string ", actual type: ") 
                            (of_constr 
                            (eval cbv in (type_of_test_aux $h_val))))
            )
    end.

(** * assert_constr_is_true
    Assert that the constr-variable describes 
    a Gallina [bool] with value [true].

    Arguments:
        - [b: constr], should equal [true].

    Raises Exceptions:
        - [TestFailedError], if [b] is not a [bool].
        - [TestFailedError], if [b] is [false].
*)
Ltac2 assert_constr_is_true (b:constr) :=
    match Constr.equal b constr:(true) with
    | true => print_success (of_string "Test passed: received constr:(true)")
    | false => fail_test (of_string "Did not get a constr equal to a bool with value true")
    end.

(** * assert_is_true
    Assert that the Ltac2-variable is a bool with value [true].

    Arguments:
        - [b: bool], should equal [true].

    Raises Exceptions:
        - [TestFailedError], if [b] is not a [bool].
        - [TestFailedError], if [b] is [false].
*)
Ltac2 assert_is_true (b:bool) :=
    match b with
    | true => print_success (of_string "Test passed: received true")
    | false => fail_test (of_string "Expected Ltac2 true, got Ltac2 bool 'false'")
    end.

(** * assert_is_false
    Assert that the Ltac2-variable is a bool with value [false].

    Arguments:
        - [b: bool], should equal [false].

    Raises Exceptions:
        - [TestFailedError], if b is not a [bool].
        - [TestFailedError], if b is [true].
*)
Ltac2 assert_is_false (b:bool) :=
    match b with
    | false => print_success (of_string "Test passed: received false")
    |  true => fail_test (of_string "Expected Ltac2 FALSE, got Ltac2 bool 'true'")
    end.

(** * assert_string_equal
    Assert two Ltac2 strings are equal.

    Arguments:
        * [s1, s2: string], strings to compare.

    Raises Exceptions:
        - [TestFailedError], if [s1] has different characters or a different
            length as [s2].
*)
Ltac2 assert_string_equal (s1:string) (s2:string) :=
    match string_equal s1 s2 with
    | true => print_success (of_string "Test passed: strings are equal")
    | false => fail_test (of_string "Strings not equal")
    end.


(** * assert_goal_is
    Check if the current goal under focus is judgementally equal
    to the provided [constr].

    Arguments:
        - [target: constr], expression that should be 
            judgementally equal to the goal.

    Raises exceptions:
        - [TestFailedError], if [target] is not 
            judgementally equal to the goal.
*)
Ltac2 assert_goal_is (target:constr) :=
    let g := Control.goal () in
    let g' :=  (eval cbv in $g) in
    let t' :=  (eval cbv in $target) in
    match Constr.equal g' t' with
    | true => print_success (of_string "Target is indeed equal to the goal.")
    | false => fail_test (of_string "Target not equal to the goal.")
    end.

(** * assert_type_equal 
    Check if the type of a term corresponds to an expected type.
    
    Arguments:
        - [term : constr] the term to determine the type of
        - [expected_type : constr] the expected type

    Raises exceptions:
        - [TestFailedError] if the type of term doesn't correspond to expected_type.
*)
Ltac2 assert_type_equal (term:constr) (expected_type:constr) :=
    match (Constr.equal 
        (eval cbv in (Aux.type_of $term))
        (eval cbv in $expected_type)) with
    | true => print_success (of_string "Type is as expected")
    | false => fail_test (concat 
             (concat
                 (of_string "Type not as expected, got: ")
                 (of_constr (eval cbv in (Aux.type_of $term)))
             )
             (concat
                 (of_string "but expected: ")
                 (of_constr (eval cbv in ($expected_type))))
    )
    end.

(** * assert_constr_equal
    Check if two [constr] are equal without normalization.

    Arguments:
        - [c1, c2: constr], any constr.

    Raises exceptions:
        - [TestFailedError], if [c1] is not equal to [c2].
*)
Ltac2 assert_constr_equal (c1: constr) (c2: constr) :=
    match Constr.equal c1 c2 with
    | true => print_success (of_string "Constr indeed equal.")
    | false => fail_test (concat
        (concat
            (of_string "Constr not equal, got: ")
            (of_constr c1)
        )
        (concat
            (of_string " and: ")
            (of_constr c2)
        )
    )
    end.