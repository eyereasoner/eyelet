:- use_module(library(between)).
:- use_module(library(format)).
:- use_module(library(iso_ext)).
:- use_module(library(lists)).
:- use_module(library(terms)).

:- dynamic(closure/1).
:- dynamic(count/2).
:- dynamic(limit/1).

% EyeProlog's native :+ closure driver maintains closure/1 and limit/1.
stable(Level) :-
    limit(Limit),
    (   Limit < Level
    ->  becomes(limit(Limit), limit(Level))
    ;   true
    ),
    closure(Closure),
    Level =< Closure.

% Linear implication used by Eyelet programs.  State-changing predicates must
% be declared dynamic by the program, just as with the other Eyelet engines.
becomes(A, B) :-
    catch(A, _, fail),
    conj_list(A, C),
    forall(member(D, C), retract(D)),
    conj_list(B, E),
    forall(member(F, E), assertz(F)).

conj_list(true, []).
conj_list(A, [A]) :-
    A \= (_, _),
    A \= false,
    !.
conj_list((A, B), [A|C]) :-
    conj_list(B, C).

% Compatibility debugging helpers retained from eyelet.pl.
fm(A) :-
    format(user_error, "*** ~q~n", [A]),
    count(fm, B),
    C is B+1,
    becomes(count(fm, B), count(fm, C)).

mf(A) :-
    forall(
        catch(A, _, fail),
        (   format(user_error, "*** ", []),
            portray_clause(user_error, A),
            count(mf, B),
            C is B+1,
            becomes(count(mf, B), count(mf, C))
        )
    ).
