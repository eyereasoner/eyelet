scenario_ok.
answer('We compare three 2x2 complex matrices for discrete-time stability. An unstable matrix A_unstable = [[(1,1),(0,0)],[(0,0),(2,0)]], a marginally stable matrix A_stable = [[(1,0),(0,0)],[(0,0),(-1,0)]], and a damped matrix A_damped = [[(0,0),(0,0)],[(0,0),(0,0)]]. Their spectral radii are ρ(A_unstable) = 2, ρ(A_stable) = 1, and ρ(A_damped) = 0. Since ρ(A_unstable) > 1 the system is unstable, since ρ(A_stable) = 1 the modes are bounded but do not decay, and since ρ(A_damped) < 1 all modes decay to zero.').
reason('For a discrete-time linear system x_{k+1} = A x_k, the eigenvalues of A determine the behaviour of each mode. The spectral radius ρ(A) is the maximum of the moduli of the eigenvalues. If ρ(A) > 1, some mode grows and the system is unstable. If ρ(A) = 1 and A is diagonal with eigenvalues on the unit circle, the modes are bounded but neither grow nor decay. If ρ(A) < 1, every mode decays to zero and the system is damped. In our three examples this gives ρ(A_unstable) = 2 > 1 (unstable), ρ(A_stable) = 1 (marginally stable), and ρ(A_damped) = 0 < 1 (strongly damped).').
check(1,true,'PASS 1: A_unstable has eigenvalues 1+i and 2 with spectral radius 2.').
check(2,true,'PASS 2: A_stable has eigenvalues 1 and -1 with spectral radius 1.').
check(3,true,'PASS 3: A_damped has eigenvalues 0 and 0 with spectral radius 0 (fully damped).').
check(4,true,'PASS 4: For sample complex numbers z and w, |z*w|^2 = |z|^2 * |w|^2.').
check(5,true,'PASS 5: Spectral radius squared of 2*A_unstable is 4 times that of A_unstable.').
