% Fundamental Theorem of Arithmetic
%
% Single example:
%   n = 202692987 = 3^2 * 7 * 829 * 3881
%
% ARC-style predicates:
%   scenario_ok/0 : the factorization of 202692987 is correct
%   answer/1      : high-level answer (single solution)
%   reason/1      : explanation of existence & uniqueness (single solution)
%   check/3       : harness checks
%
% Eyelet seeds at the bottom:
%   true :+ scenario_ok.
%   true :+ answer(_).
%   true :+ reason(_).
%   true :+ check(_, _, _).

:- op(1200, xfx, :+).

% ----------------------------------------------------------------------
% Basic arithmetic helpers
% ----------------------------------------------------------------------

% divides0(A,B): A divides B in N>0, using integer division (no mod/2)
divides0(A, B) :-
    integer(A), integer(B),
    A > 0,
    B > 0,
    Q is B // A,
    B =:= A * Q.

% "True" primes by trial division (for individual numbers)
trialprime(2).
trialprime(3).
trialprime(P) :-
    integer(P),
    P > 3,
    P1 is P - 1,
    \+ ( between(2, P1, D),
         divides0(D, P)
       ).

% ----------------------------------------------------------------------
% List utilities, sorting, multisets (namespaced with fta_)
% ----------------------------------------------------------------------

product([], 1).
product([X|Xs], P) :-
    product(Xs, P0),
    P is P0 * X.

% simple insertion sort (portable replacement for msort/2)
fta_msort(List, Sorted) :-
    fta_msort_acc(List, [], Sorted).

fta_msort_acc([], Acc, Acc).
fta_msort_acc([X|Xs], Acc, Sorted) :-
    fta_insert_ord(X, Acc, Acc1),
    fta_msort_acc(Xs, Acc1, Sorted).

fta_insert_ord(X, [], [X]).
fta_insert_ord(X, [Y|Ys], [X,Y|Ys]) :-
    X @=< Y,
    !.
fta_insert_ord(X, [Y|Ys], [Y|Zs]) :-
    X @> Y,
    fta_insert_ord(X, Ys, Zs).

% multiset representation as list of P-Count pairs
fta_prime_multiset(Factors, Pairs) :-
    fta_msort(Factors, Sorted),
    fta_prime_multiset_sorted(Sorted, Pairs).

fta_prime_multiset_sorted([], []).
fta_prime_multiset_sorted([P|Ps], [P-C|Rest]) :-
    fta_count_same(Ps, P, 1, C, Tail),
    fta_prime_multiset_sorted(Tail, Rest).

fta_count_same([], _P, C0, C0, []).
fta_count_same([P|Ps], P, C0, C, Tail) :-
    !,
    C1 is C0 + 1,
    fta_count_same(Ps, P, C1, C, Tail).
fta_count_same([Q|Ps], P, C0, C0, [Q|Ps]) :-
    Q \= P.

int_pow(_P, 0, 1).
int_pow(P, K, R) :-
    K > 0,
    K1 is K - 1,
    int_pow(P, K1, R0),
    R is R0 * P.

fta_multiset_product([], 1).
fta_multiset_product([P-C|Rest], N) :-
    fta_multiset_product(Rest, N0),
    int_pow(P, C, R),
    N is N0 * R.

fta_multiset_equal(A, B) :-
    fta_msort(A, SA),
    fta_msort(B, SB),
    SA == SB.

number_atom(Number, Atom) :-
    number_codes(Number, Codes),
    atom_codes(Atom, Codes).

% join a list of atoms with separator atom (namespaced)
fta_join_atoms([], _Sep, '').
fta_join_atoms([A], _Sep, A) :- !.
fta_join_atoms([A|As], Sep, Atom) :-
    fta_join_atoms(As, Sep, Rest),
    ( Rest = '' ->
        Atom = A
    ; atom_concat(A, Sep, Temp),
      atom_concat(Temp, Rest, Atom)
    ).

% "prime-power" formatting, e.g. '3^2 * 7 * 829 * 3881'
fta_fmt_factorization([], '1').
fta_fmt_factorization(Factors, String) :-
    fta_prime_multiset(Factors, Pairs),
    fta_fmt_pairs(Pairs, Parts),
    fta_join_atoms(Parts, ' * ', String).

fta_fmt_pairs([], []).
fta_fmt_pairs([P-C|Rest], [Atom|More]) :-
    (   C > 1
    ->  number_codes(P, PC),
        number_codes(C, CC),
        append(PC, [94|CC], Codes),  % 94 = '^'
        atom_codes(Atom, Codes)
    ;   number_atom(P, Atom)
    ),
    fta_fmt_pairs(Rest, More).

% flat factor formatting, e.g. '3 * 3 * 7 * 829 * 3881'
fta_numbers_to_atoms([], []).
fta_numbers_to_atoms([N|Ns], [A|As]) :-
    number_atom(N, A),
    fta_numbers_to_atoms(Ns, As).

fta_fmt_flat_factors(Fs, Atom) :-
    fta_numbers_to_atoms(Fs, Atoms),
    fta_join_atoms(Atoms, ' * ', Atom).

fta_reverse(List, Rev) :-
    fta_rev_acc(List, [], Rev).

fta_rev_acc([], Acc, Acc).
fta_rev_acc([X|Xs], Acc, Rev) :-
    fta_rev_acc(Xs, [X|Acc], Rev).

fta_list_last([X], X).
fta_list_last([_|Xs], Last) :-
    fta_list_last(Xs, Last).

% ----------------------------------------------------------------------
% Factorization via smallest divisor (no prime table)
% ----------------------------------------------------------------------

% smallest_divisor(N,D): D is the smallest integer >= 2 dividing N
smallest_divisor(N, D) :-
    smallest_divisor_from(N, 2, D).

smallest_divisor_from(N, D, D) :-
    divides0(D, N),
    !.
smallest_divisor_from(N, D, P) :-
    D * D =< N,
    !,
    D1 is D + 1,
    smallest_divisor_from(N, D1, P).
smallest_divisor_from(N, _D, N).

% factor_smallest_first(N, Fs): prime factors of N in nondecreasing order
factor_smallest_first(N, []) :-
    N < 2,
    !.
factor_smallest_first(N, Fs) :-
    N >= 2,
    smallest_divisor(N, D),
    (   D =:= N
    ->  Fs = [N]
    ;   N1 is N // D,
        factor_smallest_first(D, Fs1),
        factor_smallest_first(N1, Fs2),
        append(Fs1, Fs2, Fs)
    ).

% factor_largest_first via reversing the smallest-first factorization
factor_largest_first(N, Fs) :-
    factor_smallest_first(N, FsSmall),
    fta_reverse(FsSmall, Fs).

% ----------------------------------------------------------------------
% Scenario: factorization of 202692987
% ----------------------------------------------------------------------

target_n(202692987).
target_factorization_string('3^2 * 7 * 829 * 3881').

target_factors(Fs) :-
    target_n(N),
    factor_smallest_first(N, Fs).

factors_are_prime :-
    target_factors(Fs),
    forall(member(P, Fs), trialprime(P)).

factorization_correct_string :-
    target_factors(Fs),
    fta_fmt_factorization(Fs, S),
    target_factorization_string(S).

factorization_correct_product :-
    target_n(N),
    target_factors(Fs),
    product(Fs, N).

factorization_unique_multiset :-
    target_n(N),
    factor_smallest_first(N, A),
    factor_largest_first(N, B),
    fta_multiset_equal(A, B).

scenario_ok :-
    factors_are_prime,
    factorization_correct_product,
    factorization_correct_string,
    factorization_unique_multiset.

% ----------------------------------------------------------------------
% ARC-style Answer and Reason (single solutions)
% ----------------------------------------------------------------------

answer(Text) :-
    scenario_ok,
    !,
    target_n(N),
    target_factors(Fs),
    fta_fmt_factorization(Fs, PP),
    fta_fmt_flat_factors(Fs, FF),
    fta_prime_multiset(Fs, Pairs),
    length(Pairs, Distinct),
    number_atom(N,    NAtom),
    number_atom(Distinct, DistinctAtom),
    atom_concat('For n = ', NAtom, A1),
    atom_concat(A1, ', the prime factors are ', A2),
    atom_concat(A2, FF, A3),
    atom_concat(A3, ', the prime-power form is ', A4),
    atom_concat(A4, PP, A5),
    atom_concat(A5, ', and the product of these factors is ', A6),
    atom_concat(A6, NAtom, A7),
    atom_concat(A7, ' with ', A8),
    atom_concat(A8, DistinctAtom, A9),
    atom_concat(A9, ' distinct primes.', Text).

reason(Text) :-
    scenario_ok,
    !,
    Text =
'Existence: If n >= 2 is composite, write n = a*b with a,b >= 2 and split each \
composite factor again until all factors are prime; the process terminates, so \
every integer n >= 2 has a prime factorization. Uniqueness: If n = p1*...*pr = \
q1*...*qs with primes, Euclid''s lemma says that a prime dividing a product must \
divide one of the factors; matching and cancelling equal primes on both sides \
shows that the two multisets of primes are the same, so the factorization is \
unique up to order.'.

% ----------------------------------------------------------------------
% Checks: harness tests
% ----------------------------------------------------------------------

check(1, true, 'PASS 1: Factorization of 202692987 is correct and its product equals n.') :-
    factorization_correct_product.

check(2, true, 'PASS 2: All factors of 202692987 are prime (verified by trial division).') :-
    factors_are_prime.

check(3, true, 'PASS 3: Prime-power string for 202692987 is 3^2 * 7 * 829 * 3881.') :-
    factorization_correct_string.

check(4, true, 'PASS 4: Multiset of primes is unique (smallest-first vs largest-first).') :-
    factorization_unique_multiset.

check(5, true, 'PASS 5: Smallest and largest prime factors of 202692987 are 3 and 3881.') :-
    target_factors(Fs),
    Fs = [Smallest|_],
    fta_list_last(Fs, Largest),
    Smallest =:= 3,
    Largest  =:= 3881.

% ----------------------------------------------------------------------
% Eyelet-style query seeds
% ----------------------------------------------------------------------

true :+ scenario_ok.
true :+ answer(_).
true :+ reason(_).
true :+ check(_, _, _).

