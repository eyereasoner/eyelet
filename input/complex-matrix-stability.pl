% Complex matrices and stability (discrete time).
%
% A 2x2 complex matrix A (we write entries as c(Re,Im)) defines a linear
% update x_{k+1} = A x_k. The eigenvalues λ of A describe the growth or
% decay of modes: if |λ| < 1 the corresponding mode decays, if |λ| = 1
% it neither grows nor decays, and if |λ| > 1 it grows. The spectral
% radius ρ(A) is the maximum of |λ| over all eigenvalues.
%
% For discrete-time systems, this leads to three qualitative behaviours:
%   - damped   : ρ(A) < 1  (all modes decay to zero)
%   - stable   : ρ(A) = 1  (modes are bounded but do not decay)
%   - unstable : ρ(A) > 1  (some mode grows without bound)
%
% In this file we use three diagonal 2x2 complex matrices:
%   A_unstable = diag(1+i, 2)     with ρ(A_unstable) = 2   (unstable)
%   A_stable   = diag(1,  -1)     with ρ(A_stable)   = 1   (marginally stable)
%   A_damped   = diag(0,   0)     with ρ(A_damped)   = 0   (strongly damped)
%
% ARC-style predicates:
%   scenario_ok/0 : all three matrices are correctly classified
%   answer/1      : summary of the three cases (single solution)
%   reason/1      : explanation of the classification (single solution)
%   check/3       : 5 harness checks
%
% Eyelet seeds at the bottom:
%   true :+ scenario_ok.
%   true :+ answer(_).
%   true :+ reason(_).
%   true :+ check(_, _, _).

:- op(1200, xfx, :+).

% ----------------------------------------------------------------------
% Complex numbers: c(Re,Im) with integer Re,Im
% ----------------------------------------------------------------------

cms_c_add(c(Ar,Ai), c(Br,Bi), c(Cr,Ci)) :-
    Cr is Ar + Br,
    Ci is Ai + Bi.

cms_c_mul(c(Ar,Ai), c(Br,Bi), c(Cr,Ci)) :-
    Cr is Ar*Br - Ai*Bi,
    Ci is Ar*Bi + Ai*Br.

cms_c_eq(c(Ar,Ai), c(Br,Bi)) :-
    Ar =:= Br,
    Ai =:= Bi.

% squared modulus |z|^2 = Re^2 + Im^2
cms_c_abs2(c(R,I), A2) :-
    A2 is R*R + I*I.

cms_c_zero(c(0,0)).

% ----------------------------------------------------------------------
% 2x2 complex matrices: m2(C11,C12,C21,C22)
% ----------------------------------------------------------------------

% Three target matrices: unstable, stable, damped
target_unstable_matrix(
    m2(
        c(1,1),  c(0,0),
        c(0,0),  c(2,0)
    )
).

target_stable_matrix(
    m2(
        c(1,0),  c(0,0),
        c(0,0),  c(-1,0)
    )
).

target_damped_matrix(
    m2(
        c(0,0),  c(0,0),
        c(0,0),  c(0,0)
    )
).

zero_matrix(
    m2(
        c(0,0), c(0,0),
        c(0,0), c(0,0)
    )
).

cms_cm_eq(
    m2(A11,A12,A21,A22),
    m2(B11,B12,B21,B22)
) :-
    cms_c_eq(A11,B11),
    cms_c_eq(A12,B12),
    cms_c_eq(A21,B21),
    cms_c_eq(A22,B22).

cms_cm_zero(M) :-
    zero_matrix(Z),
    cms_cm_eq(M,Z).

% matrix multiplication C = A * B
cms_cm_mul(
    m2(A11,A12,A21,A22),
    m2(B11,B12,B21,B22),
    m2(C11,C12,C21,C22)
) :-
    cms_c_mul(A11,B11,T11),
    cms_c_mul(A12,B21,T12),
    cms_c_add(T11,T12,C11),

    cms_c_mul(A11,B12,T13),
    cms_c_mul(A12,B22,T14),
    cms_c_add(T13,T14,C12),

    cms_c_mul(A21,B11,T21),
    cms_c_mul(A22,B21,T22),
    cms_c_add(T21,T22,C21),

    cms_c_mul(A21,B12,T23),
    cms_c_mul(A22,B22,T24),
    cms_c_add(T23,T24,C22).

% scalar multiplication K*A
cms_cm_scalar_mul(K,
    m2(A11,A12,A21,A22),
    m2(B11,B12,B21,B22)
) :-
    cms_c_scalar_mul(K,A11,B11),
    cms_c_scalar_mul(K,A12,B12),
    cms_c_scalar_mul(K,A21,B21),
    cms_c_scalar_mul(K,A22,B22).

cms_c_scalar_mul(K, c(R,I), c(R2,I2)) :-
    R2 is K*R,
    I2 is K*I.

% diagonal matrices
cms_cm_is_diagonal(
    m2(A11,A12,A21,A22)
) :-
    cms_c_zero(A12),
    cms_c_zero(A21),
    A11 = c(_,_),
    A22 = c(_, _).

% ----------------------------------------------------------------------
% Eigenvalues for diagonal 2x2 complex matrices
% ----------------------------------------------------------------------

cms_cm_eigenvalues_diag(m2(A11,A12,A21,A22), [A11,A22]) :-
    cms_cm_is_diagonal(m2(A11,A12,A21,A22)).

% spectral radius squared ρ(A)^2 = max(|λ_i|^2)
cms_spectral_radius_sq(M, R2) :-
    cms_cm_eigenvalues_diag(M, EVs),
    cms_abs2_list(EVs, Abs2List),
    cms_list_max(Abs2List, R2).

cms_abs2_list([], []).
cms_abs2_list([C|Cs], [A2|Rest]) :-
    cms_c_abs2(C,A2),
    cms_abs2_list(Cs, Rest).

cms_list_max([X], X).
cms_list_max([X,Y|Rest], Max) :-
    ( X >= Y -> M is X ; M is Y ),
    cms_list_max([M|Rest], Max).

% exact integer square root (only used when we know it's a perfect square)
cms_int_sqrt(N,S) :-
    integer(N),
    N >= 0,
    between(0,N,S),
    S*S =:= N,
    !.

% stability classifications
cms_unstable(M) :-
    cms_spectral_radius_sq(M, R2),
    R2 > 1.

cms_stable_unit(M) :-
    cms_spectral_radius_sq(M, R2),
    R2 =:= 1.

cms_damped(M) :-
    cms_spectral_radius_sq(M, R2),
    R2 < 1.

% ----------------------------------------------------------------------
% Utility: building atoms
% ----------------------------------------------------------------------

cms_number_atom(Number, Atom) :-
    number_codes(Number, Codes),
    atom_codes(Atom, Codes).

% pretty print complex as "(Re,Im)"
cms_c_to_atom(c(Re,Im), Atom) :-
    cms_number_atom(Re, ReA),
    cms_number_atom(Im, ImA),
    atom_concat('(', ReA, T1),
    atom_concat(T1, ',', T2),
    atom_concat(T2, ImA, T3),
    atom_concat(T3, ')', Atom).

% pretty print matrix as [[(r11,i11),(r12,i12)],[(r21,i21),(r22,i22)]]
cms_matrix_to_atom(m2(A11,A12,A21,A22), Atom) :-
    cms_c_to_atom(A11, A11A),
    cms_c_to_atom(A12, A12A),
    cms_c_to_atom(A21, A21A),
    cms_c_to_atom(A22, A22A),
    atom_concat('[[', A11A, T1),
    atom_concat(T1, ',',   T2),
    atom_concat(T2, A12A,  T3),
    atom_concat(T3, '],[', T4),
    atom_concat(T4, A21A,  T5),
    atom_concat(T5, ',',   T6),
    atom_concat(T6, A22A,  T7),
    atom_concat(T7, ']]',  Atom).

% ----------------------------------------------------------------------
% Scenario: three matrices correctly classified
% ----------------------------------------------------------------------

scenario_ok :-
    target_unstable_matrix(Mu),
    cms_unstable(Mu),

    target_stable_matrix(Ms),
    cms_stable_unit(Ms),

    target_damped_matrix(Md),
    cms_damped(Md).

% ----------------------------------------------------------------------
% ARC-style Answer and Reason (single solutions)
% ----------------------------------------------------------------------

answer(Text) :-
    scenario_ok,
    !,
    target_unstable_matrix(Mu),
    target_stable_matrix(Ms),
    target_damped_matrix(Md),

    cms_spectral_radius_sq(Mu,Ru2),
    cms_spectral_radius_sq(Ms,Rs2),
    cms_spectral_radius_sq(Md,Rd2),

    cms_int_sqrt(Ru2,Ru),
    cms_int_sqrt(Rs2,Rs),
    cms_int_sqrt(Rd2,Rd),

    cms_number_atom(Ru, RuA),
    cms_number_atom(Rs, RsA),
    cms_number_atom(Rd, RdA),

    cms_matrix_to_atom(Mu, MuA),
    cms_matrix_to_atom(Ms, MsA),
    cms_matrix_to_atom(Md, MdA),

    % Build answer text
    S0  = 'We compare three 2x2 complex matrices for discrete-time stability. ',
    atom_concat(S0, 'An unstable matrix A_unstable = ', T1),
    atom_concat(T1, MuA, T2),
    atom_concat(T2, ', a marginally stable matrix A_stable = ', T3),
    atom_concat(T3, MsA, T4),
    atom_concat(T4, ', and a damped matrix A_damped = ', T5),
    atom_concat(T5, MdA, T6),

    atom_concat(T6, '. Their spectral radii are ρ(A_unstable) = ', T7),
    atom_concat(T7, RuA, T8),
    atom_concat(T8, ', ρ(A_stable) = ', T9),
    atom_concat(T9, RsA, T10),
    atom_concat(T10, ', and ρ(A_damped) = ', T11),
    atom_concat(T11, RdA, T12),
    atom_concat(T12, '. Since ρ(A_unstable) > 1 the system is unstable, ', T13),
    atom_concat(T13, 'since ρ(A_stable) = 1 the modes are bounded but do not decay, ', T14),
    atom_concat(T14, 'and since ρ(A_damped) < 1 all modes decay to zero.', Text).

reason(Text) :-
    scenario_ok,
    !,
    Text =
'For a discrete-time linear system x_{k+1} = A x_k, the eigenvalues of A \
determine the behaviour of each mode. The spectral radius ρ(A) is the maximum \
of the moduli of the eigenvalues. If ρ(A) > 1, some mode grows and the system \
is unstable. If ρ(A) = 1 and A is diagonal with eigenvalues on the unit circle, \
the modes are bounded but neither grow nor decay. If ρ(A) < 1, every mode \
decays to zero and the system is damped. In our three examples this gives \
ρ(A_unstable) = 2 > 1 (unstable), ρ(A_stable) = 1 (marginally stable), and \
ρ(A_damped) = 0 < 1 (strongly damped).'.

% ----------------------------------------------------------------------
% Checks: harness tests (5 checks)
% ----------------------------------------------------------------------

% Check 1: unstable matrix has eigenvalues 1+i and 2, spectral radius^2 = 4, ρ=2
check(1, true, 'PASS 1: A_unstable has eigenvalues 1+i and 2 with spectral radius 2.') :-
    target_unstable_matrix(Mu),
    cms_cm_eigenvalues_diag(Mu, [c(1,1), c(2,0)]),
    cms_spectral_radius_sq(Mu, Ru2),
    Ru2 =:= 4,
    cms_int_sqrt(Ru2,Ru),
    Ru =:= 2,
    cms_unstable(Mu).

% Check 2: stable matrix has eigenvalues 1 and -1, spectral radius^2 = 1, ρ=1
check(2, true, 'PASS 2: A_stable has eigenvalues 1 and -1 with spectral radius 1.') :-
    target_stable_matrix(Ms),
    cms_cm_eigenvalues_diag(Ms, [c(1,0), c(-1,0)]),
    cms_spectral_radius_sq(Ms, Rs2),
    Rs2 =:= 1,
    cms_int_sqrt(Rs2,Rs),
    Rs =:= 1,
    cms_stable_unit(Ms).

% Check 3: damped matrix has eigenvalues 0 and 0, spectral radius^2 = 0, ρ=0
check(3, true, 'PASS 3: A_damped has eigenvalues 0 and 0 with spectral radius 0 (fully damped).') :-
    target_damped_matrix(Md),
    cms_cm_eigenvalues_diag(Md, [c(0,0), c(0,0)]),
    cms_spectral_radius_sq(Md, Rd2),
    Rd2 =:= 0,
    cms_int_sqrt(Rd2,Rd),
    Rd =:= 0,
    cms_damped(Md).

% Check 4: multiplicative property of modulus for a sample pair: |z*w|^2 = |z|^2 * |w|^2
check(4, true, 'PASS 4: For sample complex numbers z and w, |z*w|^2 = |z|^2 * |w|^2.') :-
    Z = c(1,2),
    W = c(0,1),
    cms_c_mul(Z,W,ZW),
    cms_c_abs2(Z, AZ2),
    cms_c_abs2(W, AW2),
    cms_c_abs2(ZW, AZW2),
    AZW2 =:= AZ2 * AW2.

% Check 5: spectral radius squared of 2*A_unstable is 4 times that of A_unstable.
check(5, true, 'PASS 5: Spectral radius squared of 2*A_unstable is 4 times that of A_unstable.') :-
    target_unstable_matrix(Mu),
    cms_spectral_radius_sq(Mu, Ru2),
    cms_cm_scalar_mul(2, Mu, M2),
    cms_spectral_radius_sq(M2, Ru2_2),
    Ru2_2 =:= 4 * Ru2.

% ----------------------------------------------------------------------
% Eyelet-style query seeds
% ----------------------------------------------------------------------

true :+ scenario_ok.
true :+ answer(_).
true :+ reason(_).
true :+ check(_, _, _).

