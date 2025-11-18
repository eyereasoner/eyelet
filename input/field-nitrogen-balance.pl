% Case study: nitrogen balance for field crops.

:- op(1200, xfx, :+).

% -------------------------------------------------------------------
% Field designs and N properties
% -------------------------------------------------------------------

field(low_input_dry).
field(balanced_loam).
field(high_input_risk).
field(sandy_over_fertil).

description(low_input_dry,
    "low-input wheat field in a drier season").
description(balanced_loam,
    "loam field with reasonably balanced N management").
description(high_input_risk,
    "high-input field with risk of unnecessary N surplus").
description(sandy_over_fertil,
    "sandy field with high N rates and strong leaching").

% Group facts per predicate to avoid discontiguous warnings

soil_n(low_input_dry,        40.0).
soil_n(balanced_loam,        50.0).
soil_n(high_input_risk,      60.0).
soil_n(sandy_over_fertil,    40.0).

fert_n(low_input_dry,        60.0).
fert_n(balanced_loam,        90.0).
fert_n(high_input_risk,      180.0).
fert_n(sandy_over_fertil,    240.0).

loss_frac(low_input_dry,     0.15).
loss_frac(balanced_loam,     0.15).
loss_frac(high_input_risk,   0.25).
loss_frac(sandy_over_fertil, 0.40).

demand_n(low_input_dry,      130.0).
demand_n(balanced_loam,      130.0).
demand_n(high_input_risk,    160.0).
demand_n(sandy_over_fertil,  150.0).

% -------------------------------------------------------------------
% Derived quantities (rules)
% -------------------------------------------------------------------
% total_n   = soil_n + fert_n
% avail_n   = total_n * (1 - loss_frac)
% deficit_n = demand_n - avail_n  (if avail_n < demand_n, else 0)
% surplus_n = avail_n - demand_n  (if avail_n > demand_n, else 0)
% leach_index = surplus_n * loss_frac

total_n(F, Tot) :-
    field(F),
    soil_n(F, Soil),
    fert_n(F, Fert),
    Tot is Soil + Fert.

avail_n(F, Avail) :-
    total_n(F, Tot),
    loss_frac(F, Lf),
    KeepFrac is 1.0 - Lf,
    Avail is Tot * KeepFrac.

deficit_n(F, Def) :-
    demand_n(F, Dem),
    avail_n(F, Avail),
    Avail < Dem,
    Def is Dem - Avail.

deficit_n(F, 0.0) :-
    demand_n(F, Dem),
    avail_n(F, Avail),
    Avail >= Dem.

surplus_n(F, Surp) :-
    demand_n(F, Dem),
    avail_n(F, Avail),
    Avail > Dem,
    Surp is Avail - Dem.

surplus_n(F, 0.0) :-
    demand_n(F, Dem),
    avail_n(F, Avail),
    Avail =< Dem.

leach_index(F, L) :-
    surplus_n(F, Surp),
    loss_frac(F, Lf),
    L is Surp * Lf.

% -------------------------------------------------------------------
% Status classification
%
% Let d = demand_n(F), a = avail_n(F)
% under    : a < 0.9 * d
% balanced : 0.9 d =< a =< 1.1 d
% over     : a > 1.1 * d
% -------------------------------------------------------------------

status(F, under) :-
    demand_n(F, D),
    avail_n(F, A),
    DLow is 0.9 * D,
    A < DLow.

status(F, balanced) :-
    demand_n(F, D),
    avail_n(F, A),
    DLow  is 0.9 * D,
    DHigh is 1.1 * D,
    A >= DLow,
    A =< DHigh.

status(F, over) :-
    demand_n(F, D),
    avail_n(F, A),
    DHigh is 1.1 * D,
    A > DHigh.

% -------------------------------------------------------------------
% scenario_ok — main harness condition
% -------------------------------------------------------------------

scenario_ok :-
    status(low_input_dry,      under),
    status(balanced_loam,      balanced),
    status(high_input_risk,    over),
    status(sandy_over_fertil,  over),
    leach_index(low_input_dry,      Llow),
    leach_index(balanced_loam,      Lbal),
    leach_index(high_input_risk,    Lhigh),
    leach_index(sandy_over_fertil,  Lsand),
    Lsand > Llow,
    Lsand > Lbal,
    Lsand > Lhigh.

% -------------------------------------------------------------------
% A: Answer – summary text
% -------------------------------------------------------------------

answer(Text) :-
    scenario_ok,
    Text =
"In this nitrogen-balance model, LowInputDry ends up under-supplied in N, \
BalancedLoam is close to the crop’s demand, and both HighInputRisk and \
SandyOverFertil are over-supplied. LowInputDry has too little total N input, \
so even after modest losses the available N falls clearly below the crop demand. \
BalancedLoam combines soil N and fertilizer N so that, after typical field losses, \
the available N lies within about plus or minus ten percent of the target demand. \
HighInputRisk applies more fertilizer than the crop needs, so available N overshoots \
the demand and some surplus is exposed to loss. SandyOverFertil applies even more N \
on a soil with a larger loss fraction, leading to the biggest surplus and the highest \
leaching index of all fields.".

answer_uses_field(low_input_dry)      :- scenario_ok.
answer_uses_field(balanced_loam)      :- scenario_ok.
answer_uses_field(high_input_risk)    :- scenario_ok.
answer_uses_field(sandy_over_fertil)  :- scenario_ok.

% -------------------------------------------------------------------
% R: Reason – explanation text
% -------------------------------------------------------------------

reason(Text) :-
    scenario_ok,
    % ensure derived quantities exist
    total_n(low_input_dry,      _TotLow),
    avail_n(low_input_dry,      _AvailLow),
    demand_n(low_input_dry,     _DemLow),
    total_n(balanced_loam,      _TotBal),
    avail_n(balanced_loam,      _AvailBal),
    demand_n(balanced_loam,     _DemBal),
    total_n(high_input_risk,    _TotHigh),
    avail_n(high_input_risk,    _AvailHigh),
    demand_n(high_input_risk,   _DemHigh),
    total_n(sandy_over_fertil,  _TotSand),
    avail_n(sandy_over_fertil,  _AvailSand),
    demand_n(sandy_over_fertil, _DemSand),
    leach_index(sandy_over_fertil, _Lsand),
    Text =
"The model uses a simple nitrogen balance: totalN = soilN + fertN, then \
availN = totalN · (1 − lossFrac). The crop’s N demand defines a target level. \
If availN falls below about 0.9 × demand, the field is classified as under-supplied; \
if it lies between 0.9 and 1.1 times demand it is called balanced; and if it exceeds \
1.1 × demand it is over-supplied. In LowInputDry, soil N plus fertilizer N is modest, \
so even after multiplying by (1 − lossFrac) the available N is much smaller than the \
demand, generating a large deficit. In BalancedLoam, the chosen fertilizer rate brings \
totalN high enough that, after losses, availN sits close to the target demand. \
In HighInputRisk and SandyOverFertil, totalN is large enough that availN overshoots \
the demand, creating a positive surplus. The leaching index is defined as \
surplusN × lossFrac, so it grows both with the size of the surplus and with the \
loss fraction. SandyOverFertil combines a large surplus with a high lossFrac, \
which makes its leaching index the largest among the four fields. These behaviours \
follow directly from the linear dependence of availN on soilN, fertN and lossFrac \
and from comparing availN with the crop’s N demand.".

% -------------------------------------------------------------------
% C: Checks – harness rules
% -------------------------------------------------------------------

% Check 1: all fields have totalN, availN, deficitN, surplusN, leachIndex
check(1, true, Msg) :-
    total_n(low_input_dry,        _T1),
    avail_n(low_input_dry,        _A1),
    deficit_n(low_input_dry,      _D1),
    surplus_n(low_input_dry,      _S1),
    leach_index(low_input_dry,    _L1),

    total_n(balanced_loam,        _T2),
    avail_n(balanced_loam,        _A2),
    deficit_n(balanced_loam,      _D2),
    surplus_n(balanced_loam,      _S2),
    leach_index(balanced_loam,    _L2),

    total_n(high_input_risk,      _T3),
    avail_n(high_input_risk,      _A3),
    deficit_n(high_input_risk,    _D3),
    surplus_n(high_input_risk,    _S3),
    leach_index(high_input_risk,  _L3),

    total_n(sandy_over_fertil,    _T4),
    avail_n(sandy_over_fertil,    _A4),
    deficit_n(sandy_over_fertil,  _D4),
    surplus_n(sandy_over_fertil,  _S4),
    leach_index(sandy_over_fertil,_L4),

    Msg =
"Check 1: all example fields have derived total N, available N, deficit, \
surplus and a leaching index.".

% Check 2: under-supplied field has positive deficit, no surplus;
%          over-supplied fields have positive surplus, no deficit
check(2, true, Msg) :-
    status(low_input_dry,      under),
    deficit_n(low_input_dry,   DLow),
    surplus_n(low_input_dry,   SLow),

    status(high_input_risk,    over),
    deficit_n(high_input_risk, DHigh),
    surplus_n(high_input_risk, SHigh),

    status(sandy_over_fertil,  over),
    deficit_n(sandy_over_fertil, DSand),
    surplus_n(sandy_over_fertil, SSand),

    DLow  >  0.0,
    SLow  =< 0.0,
    SHigh >  0.0,
    DHigh =< 0.0,
    SSand >  0.0,
    DSand =< 0.0,

    Msg =
"Check 2: the under-supplied LowInputDry field has a positive N deficit and \
no surplus, while the over-supplied fields have positive surpluses and \
essentially no deficit.".

% Check 3: BalancedLoam has the smallest imbalance
check(3, true, Msg) :-
    deficit_n(low_input_dry,     DLow),
    deficit_n(balanced_loam,     DBal),
    surplus_n(high_input_risk,   SHigh),
    surplus_n(sandy_over_fertil, SSand),

    DBal  >  0.0,
    DLow  >  DBal,
    SHigh >  DBal,
    SSand >  DBal,

    Msg =
"Check 3: the BalancedLoam field has the smallest N imbalance: its deficit \
is smaller than the deficit in LowInputDry and smaller than the surpluses in \
the two over-supplied fields.".

% Check 4: more fert on HighInputRisk raises totalN, availN, surplusN
check(4, true, Msg) :-
    fert_n(balanced_loam,      FBal),
    total_n(balanced_loam,     TBal),
    avail_n(balanced_loam,     ABal),
    surplus_n(balanced_loam,   SBal),

    fert_n(high_input_risk,    FHigh),
    total_n(high_input_risk,   THigh),
    avail_n(high_input_risk,   AHigh),
    surplus_n(high_input_risk, SHigh),

    FHigh > FBal,
    THigh > TBal,
    AHigh > ABal,
    SHigh > SBal,

    Msg =
"Check 4: moving from the BalancedLoam to the HighInputRisk field increases \
fertilizer N, which raises total N, available N and the N surplus.".

% Check 5: SandyOverFertil has the largest leach_index
check(5, true, Msg) :-
    leach_index(low_input_dry,      LLow),
    leach_index(balanced_loam,      LBal),
    leach_index(high_input_risk,    LHigh),
    leach_index(sandy_over_fertil,  LSand),

    LSand > LLow,
    LSand > LBal,
    LSand > LHigh,

    Msg =
"Check 5: the SandyOverFertil field has the largest leaching index, \
confirming that combining a large N surplus with a high loss fraction \
yields the highest potential loss in this model.".

% -------------------------------------------------------------------
% Example Eyelet-style queries
% -------------------------------------------------------------------

true :+ scenario_ok.
true :+ answer(_).
true :+ reason(_).
true :+ check(_, _, _).
true :+ status(_, _).
true :+ leach_index(_, _).

