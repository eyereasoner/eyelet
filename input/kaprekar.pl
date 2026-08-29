% Kaprekar's constant (6174)
% Exhaustively verify the four-digit Kaprekar routine.
%
% The first Kaprekar step depends only on the multiset of the four digits,
% so it is sufficient to test each nondecreasing digit multiset once rather
% than all 10,000 permutations.  There are only 705 nontrivial multisets.

:- op(1200, xfx, :+).

kaprekar_step(A, B) :-
    number_to_digits(A, D),
    keysort(D, Asc),
    reverse(Asc, Desc),
    digits_to_number(Asc, Low),
    digits_to_number(Desc, High),
    B is High-Low.

number_to_digits(A, [B-0, C-0, D-0, E-0]) :-
    B is A // 1000,
    F is A rem 1000,
    C is F // 100,
    G is F rem 100,
    D is G // 10,
    E is G rem 10.

digits_to_number([A-0, B-0, C-0, D-0], E) :-
    E is A*1000+B*100+C*10+D.

% One representative for every multiset of four decimal digits.
digit_multiset(N) :-
    between(0, 9, A),
    between(A, 9, B),
    between(B, 9, C),
    between(C, 9, D),
    \+ (A =:= B, B =:= C, C =:= D),
    N is A*1000+B*100+C*10+D.

reaches_6174(6174, _).
reaches_6174(A, Steps) :-
    Steps < 7,
    kaprekar_step(A, B),
    Next is Steps+1,
    reaches_6174(B, Next).

counterexample(A) :-
    digit_multiset(A),
    \+ reaches_6174(A, 0).

kaprekar_verified(6174, 7) :-
    \+ counterexample(_).

true :+ kaprekar_verified(6174, 7).
