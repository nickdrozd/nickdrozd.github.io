---
title: "Formal Proof Challenge: The Half-Collatz Theorem"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2022-06-07 Tue&gt;</span></span>
layout: post
categories:
tags:
---

# Table of Contents

1.  [The Collatz Conjecture](#orgf7a64b1)
2.  [The Half-Collatz Theorem](#orgedbbb30)
3.  [Challenge: Formally prove the Half-Collatz function to be total.](#orgdf1f4bc)


<a id="orgf7a64b1"></a>

# The Collatz Conjecture

Recently I posted about an extension of Peano arithmetic (PA) called **[Collatz arithmetic](https://nickdrozd.github.io/2022/04/07/collatz-arithmetic.html)** (CA). CA is just like PA, except that it has the **Collatz conjecture** (CC) appended as an additional axiom. If CC is provably false in PA, then CA is inconsistent; and if CC is provably true in PA, then CA is just the same as PA. But if, as [John Conway](https://www.jstor.org/stable/10.4169/amer.math.monthly.120.03.192) proposed, CC is **unsettleable**, then CA is a consistent proper extension of PA.

Recall the Collatz transformation *CT : N -> N*:

-   if *n* is even, *CT(n) = n/2*;
-   if *n* is odd, *CT(n) = 3n + 1*;

And the Collatz loop function *C* is defined as follows:

-   *C(0) = 1*;
-   *C(1) = 1*;
-   *C(n) = C(CT(n))*;

The Collatz conjecture says that *C(n) = 1* for all *n*, or in other words, that *C* is a **[total function](https://nickdrozd.github.io/2022/04/01/total-partial-functions.html)**.


<a id="orgedbbb30"></a>

# The Half-Collatz Theorem

Note that if *n* is odd, then *3n + 1* will be even, and so every application of the odd rule will immediately be followed by an application of the even rule. This means that the odd rule can be **accelerated** slightly:

-   if *n* is odd, *CT(n) = 3k + 2*, where *n = 2k + 1*.

The Collatz loop function applies the odd and even rules until the value reaches 1, and then it terminates. Suppose instead we start from an odd number and then apply the accelerated odd rule until an even number is reached, and then stop. Will this loop function always terminate? I called this the **Half Collatz cojecture** (HCC) and proposed it as an example of a theorem that could be proved in CA but not in PA.

Well, it turns out that is not the case. Alert reader [Isaac Grosof](https://isaacg1.github.io/blog/) pointed out to me that **HCC was proved more than fifteen years ago**, and is in fact just a theorem of PA. I guess Half Collatz Theorem (HCT) would be a more appropriate name.

To be clear, we define the Half-Collatz transformation *HT* on odd numbers:

-   *HT(n = 2k + 1) = 3k + 2*.
    -   Or equivalently, *HT(n = 2k + 1) = n + k + 1*).

And the Half-Collatz function *HC*:

-   *HC(n) = HC(HT(n))* if *n* is odd;
-   *HC(n) = n* otherwise.

***HC* is provably total**. To see why, observe this **key fact** (which can be proved with a little algebra):

-   *HT(n) + 1 = (3/2)(n + 1)* (assuming *n* is odd).

Further, if *HT(n)* is still odd, then *HT(HT(n)) = (3/2)(3/2)(n + 1)*. So repeatedly applying *HT* entails repeatedly halving *n + 1*. But a number can only be halved so many times, and exactly how many is known as the number's **2-adic valuation**. Specifically, this is the greatest *m* such that *2<sup>m</sup>* divides *n*.

For example:

-   *n = 15*. *n + 1* = 16, the 2-adic valuation of which is 4. The trajectory of repeated applications of *HT* goes: 15 -> 23 -> 35 -> 53 -> 80, which makes 4 applications.
-   *n = 13*. *n + 1* = 14, with a 2-adic valuation of just 1. And 13 undergoes a trajectory of length 1: 13 -> 20.

In general, **the length of the trajectory of *n* under repeated applications of *HT* is exactly the 2-adic valuation of *n + 1***. The 2-adic valuation function is total, and therefore so is the Half-Collatz function.


<a id="orgdf1f4bc"></a>

# Challenge: Formally prove the Half-Collatz function to be total.

That's the hand-wavy natural language version of the proof. But as is well-known, constructing a **formal proof** can be quite a bit trickier. And when I say "formal proof", I mean a proof in a programming language such as: **Lean, Coq, Idris, Agda, etc.**

The challenge here is simple (to state): **formally prove that the Half-Collatz function is total**.

I'll lay out some basic definitions as starting points, but feel free to modify them. The language used here is Idris. I imagine that anyone who has read this far can figure out how to translate it into their own language of choice.

To say that *n* is even is just to say that there is a *k* such that *n = 2k*, and to say that *n* is odd is just to say that there is a *k* such that *n = 2k + 1*.

{% highlight idris %}
Even : Nat -> Type
Even n = (k : Nat ** n = k + k)

Odd : Nat -> Type
Odd n = (k : Nat ** n = 1 + (k + k))
{% endhighlight %}

A handy fact is that every number is either even or odd (proof left as a warmup exercise).

{% highlight idris %}
total
evenOrOdd : (n : Nat) -> Either (Even n) (Odd n)
{% endhighlight %}

Next, there is the 2-adic valuation function. I've implemented this with an **`assert_smaller`** statement, justified because *2/k < k*. Except when *k = 0*; that gets the output 0 here, which is arbitrary. I'm sure there is a more elegant implementation.

{% highlight idris %}
total
twoAdicValuation : Nat -> Nat
twoAdicValuation n = loop 0 n where
  loop : Nat -> Nat -> Nat
  loop acc 0 = 0
  loop acc k =
    case evenOrOdd k of
      -- odd
      Right _ => acc
      -- even
      Left (j ** _) => loop (S acc) $ assert_smaller k j
{% endhighlight %}

After those basics, there is the Half-Collatz function itself. As usual, we define the transformation function `ht` (defined only for odd numbers) and the looping function `halfCollatz`. For convenience, the output of `halfCollatz` is the list of numbers reached in its trajectory.

{% highlight idris %}
total
ht : Odd n -> Nat
ht (k ** _) = 2 + 3 * k

partial
halfCollatz : Nat -> List Nat
halfCollatz n = n ::
  case evenOrOdd n of
    -- even
    Left  _ => []
    -- odd
    Right prf => halfCollatz $ ht prf
{% endhighlight %}

Last, there is the **key fact** mentioned earlier. I was able to prove a modified version of this in Idris, but the proof is tedious, long-winded, and not even a little bit enlightening. Being a merciful blogger, I spare the reader the details.

{% highlight idris %}
total
keyFact : {n : Nat} -> (odd : Odd n) -> 2 + 2 * (h odd) = 3 + (3 * n)
{% endhighlight %}

Most of these functions are accompanied by a **`total` declaration**. This means that the **totality checker** is able to verify that the function definition will always terminate one way or another. In the case of recursive functions, it must be shown that some input argument will always shrink down towards some base case.

In contrast, `halfCollatz` is flagged as `partial`. It is defined recursively, but the argument does not shrink. To make the challenge even more specific: **flip the `partial` flag to `total`**.
