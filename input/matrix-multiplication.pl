% Matrix Multiplication is Not Commutative (AB ≠ BA)
%
% Fixed 2x2 integer counterexample:
%   A = [[1,2],[0,1]]
%   B = [[1,0],[3,1]]
%   AB = [[7,2],[3,1]]
%   BA = [[1,2],[3,7]]
%
% ARC-style predicates:
%   scenario_ok/0 : AB and BA for the chosen A,B are computed correctly and AB ≠ BA
%   answer/1      : high-level answer (single solution)
%   reason/1      : explanation of the non-commutativity (single solution)
%   check/3       : 5 harness checks
%
% Eyelet seeds at the bottom:
%   true :+ scenario_ok.
%   true :+ answer(_).
%   true :+ reason(_).
%   true :+ check(_, _, _).

:- op(1200, xfx, :+).

% ----------------------------------------------------------------------
% Matrix representation and basic arithmetic
% ----------------------------------------------------------------------

% 2x2 matrix as m(A11,A12,A21,A22)
% Example matrices A and B
mm_A(m(1,2,0,1)).
mm_B(m(1,0,3,1)).

mm_expected_AB(m(7,2,3,1)).
mm_expected_BA(m(1,2,3,7)).

% matrix multiplication: C = A * B
mm_mul(m(A11,A12,A21,A22),
       m(B11,B12,B21,B22),
       m(C11,C12,C21,C22)) :-
    C11 is A11*B11 + A12*B21,
    C12 is A11*B12 + A12*B22,
    C21 is A21*B11 + A22*B21,
    C22 is A21*B12 + A22*B22.

% matrix equality
mm_eq(m(A11,A12,A21,A22), m(B11,B12,B21,B22)) :-
    A11 =:= B11,
    A12 =:= B12,
    A21 =:= B21,
    A22 =:= B22.

% zero and identity matrices
mm_zero(m(0,0,0,0)).
mm_identity(m(1,0,0,1)).

% diagonal matrices
mm_diagonal(m(_,0,0,_)).

% scalar matrices λI
mm_scalar(L, m(L,0,0,L)).

% commutator [A,B] = AB - BA
mm_commutator(A,B,m(C11,C12,C21,C22)) :-
    mm_mul(A,B,m(AB11,AB12,AB21,AB22)),
    mm_mul(B,A,m(BA11,BA12,BA21,BA22)),
    C11 is AB11 - BA11,
    C12 is AB12 - BA12,
    C21 is AB21 - BA21,
    C22 is AB22 - BA22.

mm_commute(A,B) :-
    mm_mul(A,B,AB),
    mm_mul(B,A,BA),
    mm_eq(AB,BA).

% ----------------------------------------------------------------------
% Utility: numbers and matrices as atoms (for answer/1 text)
% ----------------------------------------------------------------------

mm_number_atom(Number, Atom) :-
    number_codes(Number, Codes),
    atom_codes(Atom, Codes).

% pretty print [[a,b],[c,d]]
mm_matrix_to_atom(m(A11,A12,A21,A22), Atom) :-
    mm_number_atom(A11, A11A),
    mm_number_atom(A12, A12A),
    mm_number_atom(A21, A21A),
    mm_number_atom(A22, A22A),
    atom_concat('[[', A11A, T1),
    atom_concat(T1, ',', T2),
    atom_concat(T2, A12A, T3),
    atom_concat(T3, '],[', T4),
    atom_concat(T4, A21A, T5),
    atom_concat(T5, ',', T6),
    atom_concat(T6, A22A, T7),
    atom_concat(T7, ']]', Atom).

% lists
mm_reverse(List, Rev) :-
    mm_rev_acc(List, [], Rev).

mm_rev_acc([], Acc, Acc).
mm_rev_acc([X|Xs], Acc, Rev) :-
    mm_rev_acc(Xs, [X|Acc], Rev).

mm_list_last([X], X).
mm_list_last([_|Xs], Last) :-
    mm_list_last(Xs, Last).

% join list of atoms with separator
mm_join_atoms([], _Sep, '').
mm_join_atoms([A], _Sep, A) :- !.
mm_join_atoms([A|As], Sep, Atom) :-
    mm_join_atoms(As, Sep, Rest),
    ( Rest = '' ->
        Atom = A
    ; atom_concat(A, Sep, Temp),
      atom_concat(Temp, Rest, Atom)
    ).

% ----------------------------------------------------------------------
% Small finite ranges of integer matrices (for harness checks)
% ----------------------------------------------------------------------

% entries in [Low,High]
mm_entry_in_range(Low,High,X) :-
    between(Low,High,X).

mm_matrix_in_range(Low,High,m(A11,A12,A21,A22)) :-
    mm_entry_in_range(Low,High,A11),
    mm_entry_in_range(Low,High,A12),
    mm_entry_in_range(Low,High,A21),
    mm_entry_in_range(Low,High,A22).

mm_diagonal_in_range(Low,High,m(A,0,0,D)) :-
    mm_entry_in_range(Low,High,A),
    mm_entry_in_range(Low,High,D).

% ----------------------------------------------------------------------
% Scenario: AB correctly computed and AB ≠ BA for the chosen A,B
% ----------------------------------------------------------------------

scenario_ok :-
    mm_A(A),
    mm_B(B),
    mm_mul(A,B,AB),
    mm_mul(B,A,BA),
    mm_expected_AB(AB),
    mm_expected_BA(BA),
    \+ mm_eq(AB,BA).

% ----------------------------------------------------------------------
% ARC-style Answer and Reason (single solutions)
% ----------------------------------------------------------------------

answer(Text) :-
    scenario_ok,
    !,
    mm_A(A),
    mm_B(B),
    mm_mul(A,B,AB),
    mm_mul(B,A,BA),
    mm_matrix_to_atom(A,  AAtom),
    mm_matrix_to_atom(B,  BAtom),
    mm_matrix_to_atom(AB, ABAtom),
    mm_matrix_to_atom(BA, BAAtom),
    T0 = 'Matrix multiplication on 2x2 integer matrices is not commutative. ',
    atom_concat(T0, 'A concrete counterexample is A = ', T1),
    atom_concat(T1, AAtom, T2),
    atom_concat(T2, ' and B = ', T3),
    atom_concat(T3, BAtom, T4),
    atom_concat(T4, ', for which AB = ', T5),
    atom_concat(T5, ABAtom, T6),
    atom_concat(T6, ' but BA = ', T7),
    atom_concat(T7, BAAtom, T8),
    atom_concat(T8, ', so AB \\= BA.', Text).

reason(Text) :-
    scenario_ok,
    !,
    Text =
'Take A = [[1,2],[0,1]] and B = [[1,0],[3,1]]. Computing AB gives [[7,2],[3,1]], \
while BA gives [[1,2],[3,7]]. Since AB and BA are different, matrix multiplication \
is not commutative in general; a single counterexample suffices to disprove \
commutativity for all matrices. In addition, the commutator [A,B] = AB-BA is \
nonzero, which is another way to witness the failure of commutativity.'.

% ----------------------------------------------------------------------
% Checks: harness tests (5 checks)
% ----------------------------------------------------------------------

% Check #1: AB and BA match the expected numeric results for the fixed A,B.
check(1, true, 'PASS 1: AB and BA for the chosen 2x2 matrices are correctly computed.') :-
    mm_A(A),
    mm_B(B),
    mm_mul(A,B,AB),
    mm_mul(B,A,BA),
    mm_expected_AB(AB),
    mm_expected_BA(BA).

% Check #2: AB ≠ BA (non-commuting pair).
check(2, true, 'PASS 2: AB and BA differ, so the chosen matrices do not commute.') :-
    mm_A(A),
    mm_B(B),
    mm_mul(A,B,AB),
    mm_mul(B,A,BA),
    \+ mm_eq(AB,BA).

% Check #3: Commutator AB-BA is nonzero.
check(3, true, 'PASS 3: The commutator [A,B] = AB - BA is nonzero for the counterexample.') :-
    mm_A(A),
    mm_B(B),
    mm_commutator(A,B,C),
    \+ mm_zero(C).

% Check #4: Identity and zero commute with all matrices in the small range [-1,1]^2x2.
check(4, true, 'PASS 4: Identity and zero commute with every 2x2 matrix with entries in [-1,1].') :-
    mm_identity(I),
    mm_zero(Z),
    \+ ( mm_matrix_in_range(-1,1,M),
         (  \+ mm_commute(I,M)
         ;  \+ mm_commute(M,I)
         ;  \+ mm_commute(Z,M)
         ;  \+ mm_commute(M,Z)
         )
       ).

% Check #5: Diagonal matrices commute with each other (for entries in [-1,1]).
check(5, true, 'PASS 5: All diagonal 2x2 matrices with entries in [-1,1] commute with each other.') :-
    \+ ( mm_diagonal_in_range(-1,1,D1),
         mm_diagonal_in_range(-1,1,D2),
         \+ mm_commute(D1,D2)
       ).

% ----------------------------------------------------------------------
% Eyelet-style query seeds
% ----------------------------------------------------------------------

true :+ scenario_ok.
true :+ answer(_).
true :+ reason(_).
true :+ check(_, _, _).

