% Ackermann-style hyperoperation benchmark.
% The implementation is shared with EyeProlog's examples/ackermann.pl so the
% exponentiation level uses native arithmetic instead of tens of thousands of
% recursive Prolog calls.

ackermann([X, Y], A) :-
    ackermann(X, Y, A).

ackermann(X, Y, A) :-
    B is Y+3,
    hyper(X, B, 2, C),
    A is C-3.

hyper(0, Y, _Z, A) :- A is Y+1.
hyper(1, Y, Z, A) :- A is Y+Z.
hyper(2, Y, Z, A) :- A is Y*Z.
hyper(3, Y, Z, A) :- A is Z^Y.

hyper(X, 0, _Z, 1) :-
    X > 3.
hyper(X, Y, Z, A) :-
    X > 3,
    Y \= 0,
    B is Y-1,
    hyper(X, B, Z, C),
    D is X-1,
    hyper(D, C, Z, A).

true :+ ackermann([0, 6], _).
true :+ ackermann([1, 2], _).
true :+ ackermann([1, 7], _).
true :+ ackermann([2, 2], _).
true :+ ackermann([2, 9], _).
true :+ ackermann([3, 4], _).
true :+ ackermann([3, 14], _).
true :+ ackermann([4, 0], _).
true :+ ackermann([4, 1], _).
true :+ ackermann([4, 2], _).
true :+ ackermann([5, 0], _).
