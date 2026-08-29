% Wolf, goat and cabbage puzzle
% Verify that the classic puzzle has a safe solution and that seven
% crossings are minimal.

:- op(1200, xfx, :+).

solution([e, e, e, e], []).
solution(Config, [Move|Rest]) :-
    move(Config, Move, NextConfig),
    safe(NextConfig),
    solution(NextConfig, Rest).

move([X, X, Goat, Cabbage], wolf, [Y, Y, Goat, Cabbage]) :-
    change(X, Y).
move([X, Wolf, X, Cabbage], goat, [Y, Wolf, Y, Cabbage]) :-
    change(X, Y).
move([X, Wolf, Goat, X], cabbage, [Y, Wolf, Goat, Y]) :-
    change(X, Y).
move([X, Wolf, Goat, C], nothing, [Y, Wolf, Goat, C]) :-
    change(X, Y).

change(e, w).
change(w, e).

safe([Man, Wolf, Goat, Cabbage]) :-
    one_eq(Man, Goat, Wolf),
    one_eq(Man, Goat, Cabbage).

one_eq(X, X, _).
one_eq(X, _, X).

% No safe plan exists with fewer than seven crossings, while one does
% exist with exactly seven crossings.
shorter_solution :-
    between(0, 6, N),
    length(Moves, N),
    solution([w, w, w, w], Moves),
    !.

wolf_goat_cabbage_verified(7) :-
    \+ shorter_solution,
    length(Moves, 7),
    solution([w, w, w, w], Moves),
    !.

true :+ wolf_goat_cabbage_verified(7).
