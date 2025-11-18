scenario_ok.
answer("In this nitrogen-balance model, LowInputDry ends up under-supplied in N, BalancedLoam is close to the crop’s demand, and both HighInputRisk and SandyOverFertil are over-supplied. LowInputDry has too little total N input, so even after modest losses the available N falls clearly below the crop demand. BalancedLoam combines soil N and fertilizer N so that, after typical field losses, the available N lies within about plus or minus ten percent of the target demand. HighInputRisk applies more fertilizer than the crop needs, so available N overshoots the demand and some surplus is exposed to loss. SandyOverFertil applies even more N on a soil with a larger loss fraction, leading to the biggest surplus and the highest leaching index of all fields.").
answer(scenario_ok).
reason("The model uses a simple nitrogen balance: totalN = soilN + fertN, then availN = totalN · (1 − lossFrac). The crop’s N demand defines a target level. If availN falls below about 0.9 × demand, the field is classified as under-supplied; if it lies between 0.9 and 1.1 times demand it is called balanced; and if it exceeds 1.1 × demand it is over-supplied. In LowInputDry, soil N plus fertilizer N is modest, so even after multiplying by (1 − lossFrac) the available N is much smaller than the demand, generating a large deficit. In BalancedLoam, the chosen fertilizer rate brings totalN high enough that, after losses, availN sits close to the target demand. In HighInputRisk and SandyOverFertil, totalN is large enough that availN overshoots the demand, creating a positive surplus. The leaching index is defined as surplusN × lossFrac, so it grows both with the size of the surplus and with the loss fraction. SandyOverFertil combines a large surplus with a high lossFrac, which makes its leaching index the largest among the four fields. These behaviours follow directly from the linear dependence of availN on soilN, fertN and lossFrac and from comparing availN with the crop’s N demand.").
check(1, true, "Check 1: all example fields have derived total N, available N, deficit, surplus and a leaching index.").
check(2, true, "Check 2: the under-supplied LowInputDry field has a positive N deficit and no surplus, while the over-supplied fields have positive surpluses and essentially no deficit.").
check(3, true, "Check 3: the BalancedLoam field has the smallest N imbalance: its deficit is smaller than the deficit in LowInputDry and smaller than the surpluses in the two over-supplied fields.").
check(4, true, "Check 4: moving from the BalancedLoam to the HighInputRisk field increases fertilizer N, which raises total N, available N and the N surplus.").
check(5, true, "Check 5: the SandyOverFertil field has the largest leaching index, confirming that combining a large N surplus with a high loss fraction yields the highest potential loss in this model.").
status(low_input_dry, under).
status(balanced_loam, balanced).
status(high_input_risk, over).
status(sandy_over_fertil, over).
leach_index(high_input_risk, 5.0).
leach_index(sandy_over_fertil, 7.2).
leach_index(low_input_dry, 0.0).
leach_index(balanced_loam, 0.0).
answer(answer("In this nitrogen-balance model, LowInputDry ends up under-supplied in N, BalancedLoam is close to the crop’s demand, and both HighInputRisk and SandyOverFertil are over-supplied. LowInputDry has too little total N input, so even after modest losses the available N falls clearly below the crop demand. BalancedLoam combines soil N and fertilizer N so that, after typical field losses, the available N lies within about plus or minus ten percent of the target demand. HighInputRisk applies more fertilizer than the crop needs, so available N overshoots the demand and some surplus is exposed to loss. SandyOverFertil applies even more N on a soil with a larger loss fraction, leading to the biggest surplus and the highest leaching index of all fields.")).
answer(answer(scenario_ok)).
answer(reason("The model uses a simple nitrogen balance: totalN = soilN + fertN, then availN = totalN · (1 − lossFrac). The crop’s N demand defines a target level. If availN falls below about 0.9 × demand, the field is classified as under-supplied; if it lies between 0.9 and 1.1 times demand it is called balanced; and if it exceeds 1.1 × demand it is over-supplied. In LowInputDry, soil N plus fertilizer N is modest, so even after multiplying by (1 − lossFrac) the available N is much smaller than the demand, generating a large deficit. In BalancedLoam, the chosen fertilizer rate brings totalN high enough that, after losses, availN sits close to the target demand. In HighInputRisk and SandyOverFertil, totalN is large enough that availN overshoots the demand, creating a positive surplus. The leaching index is defined as surplusN × lossFrac, so it grows both with the size of the surplus and with the loss fraction. SandyOverFertil combines a large surplus with a high lossFrac, which makes its leaching index the largest among the four fields. These behaviours follow directly from the linear dependence of availN on soilN, fertN and lossFrac and from comparing availN with the crop’s N demand.")).
answer(check(1, true, "Check 1: all example fields have derived total N, available N, deficit, surplus and a leaching index.")).
answer(check(2, true, "Check 2: the under-supplied LowInputDry field has a positive N deficit and no surplus, while the over-supplied fields have positive surpluses and essentially no deficit.")).
answer(check(3, true, "Check 3: the BalancedLoam field has the smallest N imbalance: its deficit is smaller than the deficit in LowInputDry and smaller than the surpluses in the two over-supplied fields.")).
answer(check(4, true, "Check 4: moving from the BalancedLoam to the HighInputRisk field increases fertilizer N, which raises total N, available N and the N surplus.")).
answer(check(5, true, "Check 5: the SandyOverFertil field has the largest leaching index, confirming that combining a large N surplus with a high loss fraction yields the highest potential loss in this model.")).
answer(status(low_input_dry, under)).
answer(status(balanced_loam, balanced)).
answer(status(high_input_risk, over)).
answer(status(sandy_over_fertil, over)).
answer(leach_index(high_input_risk, 5.0)).
answer(leach_index(sandy_over_fertil, 7.2)).
answer(leach_index(low_input_dry, 0.0)).
answer(leach_index(balanced_loam, 0.0)).
