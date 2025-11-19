% Braking safety
%
% We model road braking in continuous time with:
%   - speed v (m/s),
%   - friction coefficient mu (0 < mu <= 1),
%   - available distance d_avail (m) to brake before impact.
%
% Physical world: stopping distance
%   d_stop = d_react + d_brake
%          = v * t_react + v^2 / (2 * mu * g)
% with reaction time t_react ≈ 1.0 s and gravitational acceleration
% g ≈ 9.8 m/s². A scenario is
%   - "safe"  if d_stop <= d_avail
%   - "risky" if d_stop  > d_avail.
%
% We apply this to four illustrative scenarios:
%   - CityDry           ~50 km/h, dry asphalt, generous gap
%   - HighwayDryShortGap ~100 km/h, dry asphalt, short gap
%   - CityWet           ~50 km/h, wet surface, moderate gap
%   - CityIce           ~50 km/h, icy surface, short gap
%
% ARC-style predicates:
%   scenario_ok/0 : physical model classifies the scenarios as expected
%   answer/1      : textual summary (single solution)
%   reason/1      : textual explanation (single solution)
%   check/3       : 5 harness checks
%
% Eyelet seeds at the bottom:
%   true :+ scenario_ok.
%   true :+ answer(_).
%   true :+ reason(_).
%   true :+ check(_, _, _).

:- op(1200, xfx, :+).

% ----------------------------------------------------------------------
% Parameters and scenarios
% ----------------------------------------------------------------------

bs_g(9.8).          % gravitational acceleration m/s^2
bs_reaction_time(1.0).  % reaction time in seconds

% bs_scenario(Id, Speed_mps, Mu, AvailDistance_m, Description)
bs_scenario(city_dry,
            13.9, 0.8, 40.0,
            'city driving ~50 km/h, dry asphalt, generous gap').

bs_scenario(highway_dry_short_gap,
            27.8, 0.8, 60.0,
            'highway ~100 km/h, dry asphalt, short gap to obstacle').

bs_scenario(city_wet,
            13.9, 0.4, 40.0,
            'city ~50 km/h, wet surface, moderate gap').

bs_scenario(city_ice,
            13.9, 0.2, 30.0,
            'city ~50 km/h, icy surface, short gap').

% ----------------------------------------------------------------------
% Physics: reaction and braking distances
% ----------------------------------------------------------------------

% bs_components(Id, V, Mu, Avail, Desc, D_react, D_brake, D_stop)
bs_components(Id, V, Mu, Avail, Desc, D_react, D_brake, D_stop) :-
    bs_scenario(Id, V, Mu, Avail, Desc),
    bs_reaction_time(T),
    D_react is V * T,
    bs_g(G),
    Den is 2.0 * Mu * G,
    V2 is V * V,
    D_brake is V2 / Den,
    D_stop is D_react + D_brake.

% total stopping distance
bs_stop_distance(Id, D_stop) :-
    bs_components(Id, _V, _Mu, _Avail, _Desc, _DR, _DB, D_stop).

% available distance
bs_avail_distance(Id, Avail) :-
    bs_scenario(Id, _V, _Mu, Avail, _Desc).

% classification
bs_safe(Id) :-
    bs_stop_distance(Id, D),
    bs_avail_distance(Id, A),
    D =< A.

bs_risky(Id) :-
    bs_stop_distance(Id, D),
    bs_avail_distance(Id, A),
    D > A.

% ----------------------------------------------------------------------
% Small utilities: atom building without depending on atom_concat/3
% ----------------------------------------------------------------------

bs_number_atom(Number, Atom) :-
    number_codes(Number, Codes),
    atom_codes(Atom, Codes).

% bs_cat(A,B,C): C = A ++ B (atoms)
bs_cat(A, B, C) :-
    atom_codes(A, AC),
    atom_codes(B, BC),
    append(AC, BC, CC),
    atom_codes(C, CC).

% ----------------------------------------------------------------------
% Scenario: classification in the physical world
% ----------------------------------------------------------------------

% Expected pattern in the physical world:
%   - CityDry           safe
%   - CityWet           safe
%   - HighwayDryShortGap risky
%   - CityIce           risky

scenario_ok :-
    bs_safe(city_dry),
    bs_safe(city_wet),
    bs_risky(highway_dry_short_gap),
    bs_risky(city_ice).

% ----------------------------------------------------------------------
% ARC-style Answer and Reason (single solutions)
% ----------------------------------------------------------------------

answer(Text) :-
    scenario_ok,
    !,
    % We just hard-code scenario names in the text; the numeric values
    % are in the model and used for classification.
    S0  = 'In the physics-based braking model with a 1 s reaction time and g≈9.8 m/s², ',
    bs_cat(S0, 'the stopping distance is d_stop = v*1.0 + v^2/(2*mu*g). ', S1),
    bs_cat(S1, 'On the four example scenarios, this world judges ', S2),
    bs_cat(S2, 'CityDry and CityWet as safe, because their available distance is larger than the computed stopping distance, ', S3),
    bs_cat(S3, 'while HighwayDryShortGap and CityIce are risky: at highway speed or on ice, the required stopping distance exceeds the available gap.', Text).

reason(Text) :-
    scenario_ok,
    !,
    Text =
'The physical world combines a reaction-distance term v*1.0 with a braking \
distance v^2/(2*mu*g) limited by friction mu and gravity g≈9.8 m/s². At a \
given speed, lowering the friction (wet or icy surface) increases the braking \
distance; at a fixed mu, going faster increases both the reaction and braking \
distances. In CityDry and CityWet the available distance still exceeds the \
computed stopping distance, so the model calls them safe. In HighwayDryShortGap \
the higher speed makes the stopping distance longer than the gap, and in \
CityIce the low friction does the same, so both are classified as risky.'.

% ----------------------------------------------------------------------
% Checks: harness tests (5 checks)
% ----------------------------------------------------------------------

% Check 1: classification matches the intended pattern.
check(1, true,
      'PASS 1: CityDry and CityWet are safe; HighwayDryShortGap and CityIce are risky in the physical world.') :-
    bs_safe(city_dry),
    bs_safe(city_wet),
    bs_risky(highway_dry_short_gap),
    bs_risky(city_ice).

% Check 2: with same friction mu=0.8, higher speed gives larger stopping distance.
check(2, true,
      'PASS 2: At the same friction (mu=0.8), the highway scenario has a longer stopping distance than city dry.') :-
    bs_stop_distance(city_dry, D_city),
    bs_stop_distance(highway_dry_short_gap, D_highway),
    D_highway > D_city.

% Check 3: with same speed, lower friction gives larger stopping distance.
check(3, true,
      'PASS 3: At the same speed, lowering friction from dry to wet to ice increases the stopping distance.') :-
    bs_stop_distance(city_dry, D_dry),
    bs_stop_distance(city_wet, D_wet),
    bs_stop_distance(city_ice, D_ice),
    D_wet > D_dry,
    D_ice > D_wet.

% Check 4: for every scenario, reaction and braking distances are positive and d_stop > d_react.
check(4, true,
      'PASS 4: In every scenario, reaction and braking distances are positive and stopping distance exceeds reaction distance.') :-
    \+ ( bs_scenario(Id, _V, _Mu, _A, _Desc),
         bs_components(Id, _V2, _Mu2, _A2, _Desc2, D_react, D_brake, D_stop),
         ( D_react =< 0.0
         ; D_brake =< 0.0
         ; D_stop  =< D_react
         )
       ).

% Check 5: every scenario is either safe or risky, but never both (clean partition).
check(5, true,
      'PASS 5: Each scenario is classified as either safe or risky, and never both.') :-
    % no scenario is both safe and risky
    \+ ( bs_scenario(Id, _V, _Mu, _A, _Desc),
         bs_safe(Id),
         bs_risky(Id)
       ),
    % no scenario is unclassified
    \+ ( bs_scenario(Id, _V2, _Mu2, _A2, _Desc2),
         \+ bs_safe(Id),
         \+ bs_risky(Id)
       ).

% ----------------------------------------------------------------------
% Eyelet-style query seeds
% ----------------------------------------------------------------------

true :+ scenario_ok.
true :+ answer(_).
true :+ reason(_).
true :+ check(_, _, _).

