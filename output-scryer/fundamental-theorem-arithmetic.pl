scenario_ok.
answer('For n = 202692987, the prime factors are 3 * 3 * 7 * 829 * 3881, the prime-power form is 3^2 * 7 * 829 * 3881, and the product of these factors is 202692987 with 4 distinct primes.').
reason('Existence: If n >= 2 is composite, write n = a*b with a,b >= 2 and split each composite factor again until all factors are prime; the process terminates, so every integer n >= 2 has a prime factorization. Uniqueness: If n = p1*...*pr = q1*...*qs with primes, Euclid\'s lemma says that a prime dividing a product must divide one of the factors; matching and cancelling equal primes on both sides shows that the two multisets of primes are the same, so the factorization is unique up to order.').
check(1,true,'PASS 1: Factorization of 202692987 is correct and its product equals n.').
check(2,true,'PASS 2: All factors of 202692987 are prime (verified by trial division).').
check(3,true,'PASS 3: Prime-power string for 202692987 is 3^2 * 7 * 829 * 3881.').
check(4,true,'PASS 4: Multiset of primes is unique (smallest-first vs largest-first).').
check(5,true,'PASS 5: Smallest and largest prime factors of 202692987 are 3 and 3881.').
