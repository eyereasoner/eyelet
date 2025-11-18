scenario_ok.
answer("In this nitrogen-balance model, LowInputDry ends up under-supplied in N, BalancedLoam is close to th"||... ).
answer(scenario_ok).
reason("The model uses a simple nitrogen balance: totalN = soilN + fertN, then availN = totalN · (1 − lossFr"||... ).
check(1,true,"Check 1: all example fields have derived total N, available N, deficit, surplus and a leaching index"||... ).
check(2,true,"Check 2: the under-supplied LowInputDry field has a positive N deficit and no surplus, while the ove"||... ).
check(3,true,"Check 3: the BalancedLoam field has the smallest N imbalance: its deficit is smaller than the defici"||... ).
check(4,true,"Check 4: moving from the BalancedLoam to the HighInputRisk field increases fertilizer N, which raise"||... ).
check(5,true,"Check 5: the SandyOverFertil field has the largest leaching index, confirming that combining a large"||... ).
status(low_input_dry,under).
status(balanced_loam,balanced).
status(high_input_risk,over).
status(sandy_over_fertil,over).
leach_index(high_input_risk,5.0).
leach_index(sandy_over_fertil,7.2).
leach_index(low_input_dry,0.0).
leach_index(balanced_loam,0.0).
answer(answer("In this nitrogen-balance model, LowInputDry ends up under-supplied in N, BalancedLoam is close to th"||... )).
answer(answer(scenario_ok)).
answer(reason("The model uses a simple nitrogen balance: totalN = soilN + fertN, then availN = totalN · (1 − lossFr"||... )).
answer(check(1,true,"Check 1: all example fields have derived total N, available N, deficit, surplus and a leaching index"||... )).
answer(check(2,true,"Check 2: the under-supplied LowInputDry field has a positive N deficit and no surplus, while the ove"||... )).
answer(check(3,true,"Check 3: the BalancedLoam field has the smallest N imbalance: its deficit is smaller than the defici"||... )).
answer(check(4,true,"Check 4: moving from the BalancedLoam to the HighInputRisk field increases fertilizer N, which raise"||... )).
answer(check(5,true,"Check 5: the SandyOverFertil field has the largest leaching index, confirming that combining a large"||... )).
answer(status(low_input_dry,under)).
answer(status(balanced_loam,balanced)).
answer(status(high_input_risk,over)).
answer(status(sandy_over_fertil,over)).
answer(leach_index(high_input_risk,5.0)).
answer(leach_index(sandy_over_fertil,7.2)).
answer(leach_index(low_input_dry,0.0)).
answer(leach_index(balanced_loam,0.0)).
