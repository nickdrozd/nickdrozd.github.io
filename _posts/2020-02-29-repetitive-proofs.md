---
title: "Dependently-Typed Proofs are Code, and Repetitive Code is Bad, So..."
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2020-02-29 Sat&gt;</span></span>
layout: post
categories:
tags:
---
Here are some **type-level definitions** of parity functions written in **Idris**:

{% highlight idris %}
Even : Nat -> Type
Even n = (half : Nat ** n = half * 2)

Odd : Nat -> Type
Odd n = (haf : Nat ** n = S $ haf * 2)
{% endhighlight %}

Given some natural number `n`, `Even n` says that there exists a number `half` such that `n` is equal to `half` times two, while `Odd n` says that there exists a number `haf` such that `n` one more than `haf` times two. (These definitions, along with the "haf" terminology, come from [***The Little Typer***](https://nickdrozd.github.io/2019/08/01/little-typer.html).)

`Even n` doesn't prove that `n` is even, it just makes the **claim** that it is. A **proof** of this claim (or equivelently, an instance of the type) takes the form of a *dependent pair*, a **witness** together with a proof that the witness satisfies the stated condition. A witness is required because dependently-typed languages like Idris use [**constructive logic**](http://localhost:4000/2019/04/10/idris-props.html).

It can be proved without too much trouble that the sum of two even numbers is also even:

{% highlight idris %}
evenPlusEven : Even j -> Even k -> Even (j + k)
evenPlusEven (half_j ** pf_j) (half_k ** pf_k) =
  (half_j + half_k **
    rewrite pf_j in    -- j = half_j * 2
      rewrite pf_k in  -- k = half_k * 2
        sym $ multDistributesOverPlusLeft half_j half_k 2)
{% endhighlight %}

The type signature there says: given a proof that `j` is even and a proof that `k` is even, produce a proof that `j + k` is even. So we're given numbers `half_j` and `half_k`, plus proofs that `j = half_j * 2` and `k = half_k * 2`, and the goal is to produce a witness such that `j + k` is equal to the witness times two. The first line in the implementation shows that the witness is the sum of the two halves.

The rest of the implementation is the proof, the details of which can be illustrated with a simple example: `6 + 8 = (3 * 2) + (4 * 2) = (3 + 4) * 2`. The last line in the proof, an instance of `multDistributesOverPlusLeft`, is what moves from `(3 * 2) + (4 * 2)` to `(3 + 4) * 2`. It's not an interesting part of the proof, but it's needed to appease the type checker.

It can also be proved without too much trouble that the sum of an odd number and an even number is odd:

{% highlight idris %}
oddPlusEven : Odd j -> Even k -> Odd (j + k)
oddPlusEven (haf_j ** pf_j) (half_k ** pf_k) =
  (haf_j + half_k **
    rewrite pf_k in
      rewrite pf_j in
        cong {f = S} $
          sym $ multDistributesOverPlusLeft haf_j half_k 2)
{% endhighlight %}

This proof looks almost exactly like that of `evenPlusEven`, except for an extra line. That line handles the odd one. Another example might make it clear, and again the arithmetic looks almost the same as before: `7 + 8 = 1 + 6 + 8 = 1 + (3 * 2) + (4 * 2) = 1 + (3 * 2) + (4 * 2) = 1 + ((3 + 4) * 2)`.

**This is repetitive code, and repetitive code is bad.** In particular, the repeated invocation of the low-level number-shuffler `multDistributesOverPlusLeft` grates. That work was done before, so why do it again?

There is a better way. First, observe that any odd number is the successor of an even number:

{% highlight idris %}
oddSuccEven : Odd n -> (m : Nat ** (n = S m, Even m))
oddSuccEven (haf ** pf) = (haf * 2 ** (pf, (haf ** Refl)))
{% endhighlight %}

Then, instead of proving `oddPlusEven` from scratch, extract an even number from the odd and then add it to the other even number using the already-proved `evenPlusEven`:

{% highlight idris %}
oddPlusEven : Odd j -> Even k -> Odd (j + k)
oddPlusEven j_odd k_even =
  let
    (i ** (i_pred_j, i_even)) = oddSuccEven j_odd
    (half_i_plus_k ** i_plus_k_even) = evenPlusEven i_even k_even
      in
  (half_i_plus_k **
    rewrite i_pred_j in  -- i = S j
      cong {f = S} i_plus_k_even)
{% endhighlight %}

To my taste, this is a nicer proof. The initial proof arguments are passed intact into other functions rather than being destructured, a sign that computation is taking place elsewhere. Everything is at the appropriate level of abstraction, and there is no annoying algebra to deal with.

Maybe it's an obvious point, but I haven't seen it discussed anywhere, so I'll make it plain: **dependently-typed proofs are code, and repetitive code is bad, so repetitive dependently-typed proofs are bad.**
