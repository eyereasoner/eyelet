% Evolutionary algorithm
% Portable deterministic variant for cross-Prolog regression testing.
%
% Proves the main point of the classic "weasel" experiment: repeated random
% mutation plus selection can evolve an initially random string to a target.
% A tiny integer PRNG is threaded explicitly so every Prolog gets the same run.

:- op(1200, xfx, :+).

next_random(Seed0, Seed) :-
    Seed is (Seed0*48271) mod 2147483647.

random_n(N, Seed0, Seed, Value) :-
    next_random(Seed0, Seed),
    Value is (Seed*N + 1073741823) // 2147483647.

random_alpha(Seed0, Seed, Ch) :-
    random_n(26, Seed0, Seed, P),
    ( P =:= 0 -> Ch = 32 ; Ch is P+64 ).

random_text(0, Seed, Seed, []) :- !.
random_text(N, Seed0, Seed, [H|T]) :-
    random_alpha(Seed0, Seed1, H),
    N1 is N-1,
    random_text(N1, Seed1, Seed, T).

score(Target, Text, Score) :-
    score(Target, Text, 0, Score).

score([], [], Score, Score).
score([A|As], [B|Bs], S0, Score) :-
    ( A =:= B -> S1 = S0 ; S1 is S0+1 ),
    score(As, Bs, S1, Score).

mutate(_, [], Seed, Seed, []) :- !.
mutate(Probability, [H|T], Seed0, Seed, [M|Ms]) :-
    random_n(100, Seed0, Seed1, P),
    ( P > Probability ->
        M = H,
        Seed2 = Seed1
    ;
        random_alpha(Seed1, Seed2, M)
    ),
    mutate(Probability, T, Seed2, Seed, Ms).

% Select the best of N mutations without constructing and sorting a population.
best_mutation(N, Probability, Start, Target, Seed0, Seed, Best) :-
    mutate(Probability, Start, Seed0, Seed1, First),
    score(Target, First, FirstScore),
    N1 is N-1,
    best_mutation_(N1, Probability, Start, Target,
                   Seed1, Seed, First, FirstScore, Best).

best_mutation_(0, _, _, _, Seed, Seed, Best, _, Best) :- !.
best_mutation_(N, Probability, Start, Target,
               Seed0, Seed, Best0, BestScore0, Best) :-
    mutate(Probability, Start, Seed0, Seed1, Candidate),
    score(Target, Candidate, CandidateScore),
    ( CandidateScore < BestScore0 ->
        Best1 = Candidate,
        BestScore1 = CandidateScore
    ;
        Best1 = Best0,
        BestScore1 = BestScore0
    ),
    N1 is N-1,
    best_mutation_(N1, Probability, Start, Target,
                   Seed1, Seed, Best1, BestScore1, Best).

solve(TargetAtom, Generations) :-
    atom_codes(TargetAtom, Target),
    length(Target, Len),
    random_text(Len, 80, Seed0, Start),
    evolve(0, 100, 6, 35, Target, Start, Seed0, Generations).

evolve(Generation, _, _, _, Target, Target, _, Generation) :- !.
evolve(Generation, Max, Population, Probability, Target, Start, Seed0, Generations) :-
    Generation < Max,
    best_mutation(Population, Probability, Start, Target, Seed0, Seed, Best),
    Next is Generation+1,
    evolve(Next, Max, Population, Probability, Target, Best, Seed, Generations).

evolution_verified(Target, Generations) :-
    solve(Target, Generations).

true :+ evolution_verified('WEASEL', 15).
