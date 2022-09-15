---
title: "Collatz Counterexamples"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2022-09-15 Thu&gt;</span></span>
layout: post
categories:
tags:
---

Pick a natural number greater than 1, then apply the following transformation until 1 is reached:

-   if the number is even, divide it by 2;
-   if the number is odd, multiply it by 3 and add 1.

The **Collatz Conjecture** says that this procedure will **always terminate**, or in other words that it is a ***[total function](https://nickdrozd.github.io/2022/04/01/total-partial-functions.html)***. This conjecture is widely believed, but it hasn't been proven. As far as is known for sure, it could be false. **What would a counterexample look like?**

Before we can get into that, let's go over what it means for the conjecutre to be **true**. We have a certain transformation function *C*. If the conjecture is true, then for any number *N*, there is a number *K* such that *N* reaches 1 after *K* applications of *C* (or in symbols: *C<sup>K</sup>(N) = 1*). For any particular *N* and *K*, determining whether or not this obtains is **computable**.

If true, the conjecture could be **provable** or it could be **unprovable**. But for now, let's assume the conjecture is **false**. There are two possibilities.


# Cycle

There could be a number *Y* such that after *K* applications of *C* we **come back around to *Y*** (in symbols: *C<sup>K</sup>(Y) = Y*). Such a sequence will never reach 1, and so *Y* is a Collatz counterexample. Actually, so are *C(Y)*, *C(C(Y))*, etc, so we'll just **identify the cycle with its smallest member**.

Suppose *Y* is a cycle counterexample. **Are there any other cycle counterexamples?** As far as I know, this isn't known. There just could be just one cycle, or exactly seventeen, or infinitely many.

Just as it is computable to determine whether *C<sup>K</sup>(N) = 1*, it is also computable to determine whether *C<sup>K</sup>(N) = N*. Thus it is **morally equivalent** to the Collatz Conjecture to say that every number either reaches 1 or reaches itself.

I don't know the details, but it has been proved that there are **no short cycles**.


# Infinite Sequence

There could be a number *S* such that the sequence *Q = S, C(S), C(C(S)), &#x2026;* **never reaches 1 and never repeats**. Every element of *Q* is a Collatz counterexample, so again we'll identify *Q* by its earliest element.

As with cycles, the existence of one infinite sequence is not known to imply the **existence or nonexistence** of any other infinite sequences. But whereas cycles are always computable, **an infinite sequence might or might not be computable**.

Suppose *S* is, in fact, the earliest element of an infinite sequence *Q*, but this isn't known. No number of applications of *C* will terminate. But from the perspective of the verifier, this will be indistinguishable from the case in which the number of applications required to terminate is merely infeasiably large.

An infinite sequence *Q* is ***computably definable*** if there is a formula *P* such that *P(N)* is computable and holds if and only if *N* belongs to *Q*. Formulas are finite, so there are only **countably many** of them. But there are **uncountably many** infinite sequences, so all but vanishingly few of them are definable. An infinite sequnce Collatz counterexample could be computably definable, in which case the sequence would provaby be a counterexample. But if the sequence is not computably definable, this would be **unprovable**.

The sequences obtained from iterating the Collatz function on various numbers are referred to as ***hailstone sequences*** because the values sometimes increase and sometimes decrease (that is, the sequences are not *monotonically increasing*.). If *N* is odd, then *C(N)* is even, and then *C(C(N))* will be half of *C(N)*. If *C(C(N))* is odd, this will happen again, and this odd-even-odd-even pattern could go on for a while. But it can be proved that if there is an infinite sequence counterexample, it cannot follow this pattern forever; there must be infinitely many even-even steps. This result is known as the ***[Half-Collatz theorem](https://nickdrozd.github.io/2022/06/07/half-collatz.html)***.


# Truth and Provability

Not much is known about the provability of the Collatz Conjecture. If it is true, it could be provable or not; and if it is false, there could be one or more cycles ***and / or*** one or more infinite sequences. Apriori there are a variety of circumstances to consider.

This is in contrast to the simpler logical situation of a statement like **Goldbach's Conjecture**, which says that every even number can be expressed as the sum of two primes. A counterexample would be an even number *E* that could not be expressed as the sum of two primes. If such a number actually existed, it would be possible (in principle) to verify it: there are only finitely many primes less than *E*, so it's just a matter of checking every possible pair of them. Thus if Goldbach's Conjecture is in fact false, it is **provably false**; in other words, it is **true if independent**.

There are no such guarantees about the Collatz Conjecture because of the possibility of **undefinable infinite sequences**. In that case the conjecture would be **false, but not provably so**.
