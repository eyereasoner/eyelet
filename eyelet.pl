% --------------------
% eyelet -- Jos De Roo
% --------------------

:- use_module(library(lists)).
:- use_module(library(terms)).

:- op(1200, xfx, :+).

:- dynamic((:+)/2).
:- dynamic(changed/0).
:- dynamic(closure/1).
:- dynamic(limit/1).
:- dynamic(reported/1).

version('eyelet v2.0.9 (2026-08-30)').

% main goal
main :-
    catch(use_module(library(between)), _, true),
    catch(use_module(library(format)), _, true),
    catch(use_module(library(iso_ext)), _, true),
    set_prolog_flag(double_quotes, chars),
    reset_eyelet_state,
    (   rule_exists
    ->  prepare_rules,
        catch(
            ( eyelet, Exit = 0 ),
            Error,
            eyelet_exception(Error, Exit)
        ),
        halt(Exit)
    ;   version(Version),
        format(user_error, "~w~n", [Version]),
        halt(0)
    ).

reset_eyelet_state :-
    retractall(changed),
    retractall(closure(_)),
    retractall(limit(_)),
    retractall(reported(_)),
    assertz(closure(0)),
    assertz(limit(-1)).

rule_exists :-
    clause((_ :+ _), _),
    !.

eyelet_exception(halt(Exit), Exit) :-
    !.
eyelet_exception(Error, 1) :-
    format(user_error, "*** ~w~n", [Error]).

% Preparation is structural: inspect :+/2 clauses instead of proving their
% premises. This avoids setup-time side effects and also discovers predicates
% mentioned in guarded clauses.
prepare_rules :-
    (   clause((Conc :+ Prem), Body),
        dynify_goal(Conc),
        dynify_goal(Prem),
        dynify_goal(Body),
        fail
    ;   true
    ).

% Query-only files are common. Execute them once instead of entering a fixed
% point that cannot derive anything.
plain_query_program :-
    \+ ( clause((Conc :+ _), _), Conc \== true, Conc \== false ).

% Run all forward rules to a fixed point. A round repeats only when at least one
% new conclusion was asserted. stable/1 can request extra closure levels; those
% levels advance only after a quiescent round.
eyelet :-
    (   plain_query_program
    ->  run_plain_queries
    ;   eyelet_loop
    ).

run_plain_queries :-
    (   (Conc :+ Prem),
        Prem,
        process_control_conclusion(Conc, Prem),
        fail
    ;   true
    ).

eyelet_loop :-
    retractall(changed),
    run_round,
    (   changed
    ->  eyelet_loop
    ;   advance_closure
    ->  eyelet_loop
    ;   true
    ).

run_round :-
    (   (Conc :+ Prem),
        Prem,
        process_conclusion(Conc, Prem),
        fail
    ;   true
    ).

process_conclusion(Conc, Prem) :-
    (   Conc == true
    ->  report_answer(Prem)
    ;   Conc == false
    ->  report_fuse(Prem)
    ;   prepare_conclusion(Conc, Prepared),
        assert_conj(Prepared)
    ).

process_control_conclusion(Conc, Prem) :-
    (   Conc == true
    ->  report_answer(Prem)
    ;   Conc == false
    ->  report_fuse(Prem)
    ;   true
    ).

% Keep an answer once. Storing a copied term preserves the historical Eyelet
% behaviour while avoiding the SWI portray/1 hook name for internal state.
report_answer(Prem) :-
    (   reported(Prem)
    ->  true
    ;   portray_clause(Prem),
        copy_term(Prem, Copy),
        assertz(reported(Copy))
    ).

report_fuse(Prem) :-
    portray_clause(fuse(Prem)),
    throw(halt(2)).

% Conclusion-only variables are existential and become sk_0, sk_1, ... . A
% derived :+/2 rule keeps its variables, so they remain universally quantified.
prepare_conclusion(Conc, Conc) :-
    is_forward_rule(Conc),
    !.
prepare_conclusion(Conc, Conc) :-
    skolemize(Conc, 0, _).

is_forward_rule(Term) :-
    nonvar(Term),
    Term = (_ :+ _).

% Assert every novel conjunct. For a derived :+/2 rule, only an identical fact
% clause counts as already present: a guarded source rule must not suppress an
% unconditional derived rule with the same head.
assert_conj(true) :-
    !.
assert_conj(false) :-
    !.
assert_conj((A, B)) :-
    !,
    assert_conj(A),
    assert_conj(B).
assert_conj(Goal) :-
    dynify_goal(Goal),
    (   known_conclusion(Goal)
    ->  true
    ;   assertz(Goal),
        mark_changed
    ).

known_conclusion(Goal) :-
    is_forward_rule(Goal),
    !,
    clause(Goal, true).
known_conclusion(Goal) :-
    Goal.

mark_changed :-
    ( changed -> true ; assertz(changed) ).

advance_closure :-
    closure(Closure),
    limit(Limit),
    Closure < Limit,
    NewClosure is Closure + 1,
    retract(closure(Closure)),
    assertz(closure(NewClosure)).

% skolemize(+Term, +N0, -N)
skolemize(Term, N0, N) :-
    term_variables(Term, Vars),
    skolemize_vars(Vars, N0, N).

skolemize_vars([], N, N).
skolemize_vars([Sk|Vars], N0, N) :-
    number_chars(N0, Digits),
    atom_chars(Number, Digits),
    atom_concat(sk_, Number, Sk),
    N1 is N0 + 1,
    skolemize_vars(Vars, N1, N).

% stable(+Level)
% Fail until the requested closure level has been reached. Asking for a higher
% level raises the target; the driver advances it only at a quiescent round.
stable(Level) :-
    limit(Limit),
    (   Limit < Level
    ->  retract(limit(Limit)),
        assertz(limit(Level))
    ;   true
    ),
    closure(Closure),
    Level =< Closure.

% becomes(+From, +To)
% Linear implication over mutable state. Prepare both sides first so a source
% predicate does not require a separate dynamic/1 declaration on engines that
% allow an empty dynamic procedure to be created by assert/retract.
becomes(From, To) :-
    dynify_goal(From),
    dynify_goal(To),
    catch(From, _, fail),
    conj_list(From, Old),
    retract_conj(Old),
    conj_list(To, New),
    assert_conj_list(New).

retract_conj([]).
retract_conj([Clause|Clauses]) :-
    retract(Clause),
    retract_conj(Clauses).

assert_conj_list([]).
assert_conj_list([Clause|Clauses]) :-
    assertz(Clause),
    assert_conj_list(Clauses).

% Flatten conjunctions in either association direction without append/3.
conj_list(Goal, List) :-
    conj_list(Goal, List, []).

conj_list(true, Tail, Tail) :-
    !.
conj_list(false, _, _) :-
    !,
    fail.
conj_list((A, B), List, Tail) :-
    !,
    conj_list(A, List, Rest),
    conj_list(B, Rest, Tail).
conj_list(Goal, [Goal|Tail], Tail).

% Prepare a callable goal. Compound arguments are visited too, matching classic
% Eyelet's permissive treatment of embedded callable shapes and controls.
dynify_goal(Term) :-
    var(Term),
    !.
dynify_goal(Term) :-
    atom(Term),
    !,
    dynify_predicate(Term, 0).
dynify_goal(Term) :-
    atomic(Term),
    !.
dynify_goal(Term) :-
    dynify_term(Term).

dynify_term(Term) :-
    var(Term),
    !.
dynify_term(Term) :-
    atomic(Term),
    !.
dynify_term([]) :-
    !.
dynify_term([Head|Tail]) :-
    !,
    dynify_term(Head),
    dynify_term(Tail).
dynify_term(Term) :-
    functor(Term, Name, Arity),
    dynify_predicate(Name, Arity),
    Term =.. [_|Args],
    dynify_list(Args).

dynify_list([]).
dynify_list([Term|Terms]) :-
    dynify_term(Term),
    dynify_list(Terms).

dynify_predicate(Name, Arity) :-
    (   current_predicate(Name/Arity)
    ->  true
    ;   functor(Template, Name, Arity),
        catch((assertz(Template), retract(Template)), _, true)
    ).
