scenario_ok.
answer('Matrix multiplication on 2x2 integer matrices is not commutative. A concrete counterexample is A = [[1,2],[0,1]] and B = [[1,0],[3,1]], for which AB = [[7,2],[3,1]] but BA = [[1,2],[3,7]], so AB \\= BA.').
reason('Take A = [[1,2],[0,1]] and B = [[1,0],[3,1]]. Computing AB gives [[7,2],[3,1]], while BA gives [[1,2],[3,7]]. Since AB and BA are different, matrix multiplication is not commutative in general; a single counterexample suffices to disprove commutativity for all matrices. In addition, the commutator [A,B] = AB-BA is nonzero, which is another way to witness the failure of commutativity.').
check(1,true,'PASS 1: AB and BA for the chosen 2x2 matrices are correctly computed.').
check(2,true,'PASS 2: AB and BA differ, so the chosen matrices do not commute.').
check(3,true,'PASS 3: The commutator [A,B] = AB - BA is nonzero for the counterexample.').
check(4,true,'PASS 4: Identity and zero commute with every 2x2 matrix with entries in [-1,1].').
check(5,true,'PASS 5: All diagonal 2x2 matrices with entries in [-1,1] commute with each other.').
