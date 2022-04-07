---
title: "Collatz Arithmetic"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2022-04-07 Thu&gt;</span></span>
layout: post
categories:
tags:
---
Pick a natural number *n* and apply the following transformation to it: if *n* is even, the output will be ***n / 2***; otherwise, if *n* is odd, the output will be ***3n + 1***. Keep doing this until *1* is reached.

Will this procedure always reach *1*? That is, is this a **[total function](https://nickdrozd.github.io/2022/04/01/total-partial-functions.html)**? The **Collatz Conjecture** says yes, but this has not been proved or disproved. It has also not been proved or disproved that it can be proved or disproved.

**[John Conway](https://www.jstor.org/stable/10.4169/amer.math.monthly.120.03.192)** argued that the Collatz Conjecture is both *true* and ***unsettleable***: it cannot be proved, and it cannot be proved that it cannot be proved, and so on. This is not a particularly satisfying situation, but it could very well be the case.

Call the Collatz transformation *C*. Notice that if *C(n)* really does reach *1* and terminate for a given *n*, this is **always provable**, and indeed the number of iterations required can be explictly calculated. That is, we can exhibit a number *k* such that *C<sup>k</sup>(n) = 1*. So if the conjecture is true but not provable, then this means that each **instance** is provable, but the **generalization** is not. In symbols:

-   ⊢ *∃k C<sup>k</sup>(1) = 1*
-   ⊢ *∃k C<sup>k</sup>(2) = 1*
-   ⊢ *∃k C<sup>k</sup>(3) = 1*
-   ⊢ *∃k C<sup>k</sup>(4) = 1*
-   &#x2026;
-   ⊬ *∀n ∃k C<sup>k</sup>(n) = 1*

This last statement is formalization of the Collatz conjecture, and we'll refer to it as **CC**.

But "provable" isn't an absolute property &#x2013; provability is always with respect to some **theory**. What theory are we talking about here? The answer is: **take your pick**. The conjecture is not known to be decided by any theory in common use: **Peano arithmetic (PA)**, set theory, whatever. For simplicity, we'll assume PA as our background theory.

**Let's assume that CC is true and also not provable in PA.** These assumptions imply that the **negation** of CC is not provable either, or in other words that CC is **independent** of PA. This being the case, we are free to add either CC or its negation to PA as **new axioms** and the resulting theory will be **consistent**. Adding the negation, however, yields a theory that is ***𝜔-inconsistent***, or more simply, **unsound**. It says things about the natural numbers that are **not true**. (Alternatively, it can be looked at as a theory of *number-like objects* that are not numbers.)

So we'll add CC as a new axiom to PA. Call the resulting theory **Collatz arithmetic (CA)**. CA is strictly stronger than PA, since CA ⊢ CC but (by hypothesis) PA ⊬ CC. **What other kinds of things can be proved in CA but not PA?**

Before getting to that, let's get *C* into a more workable form. To say that *n* is even is to say that has the form *2k*, so instead of saying that *C(n) = n / 2*, we can say that ***C(2k) = k***. Similarly, to say that *n* is odd is to say that it has the form *2k + 1*, and *3(2k + 1) + 1 = 6k + 4*. But notice that if *n* is odd, *3n + 1* will always be even, immediately triggering the even clause. The Collatz function can be "accelerated" slightly by applying this immediately. With a little algebra, this works out to ***C(2k + 1) = 3k + 2***.

Let's consider a variation of the Collatz function that we'll call the **Half Collatz** function. Define a transformation function *H* to be just like *C* except that it leaves its even arguments alone &#x2013; in other words, ***H(n = 2k) = n*** and ***H(2k + 1) = 3k + 2***. And instead of applying its tranformation until the argument reaches *1*, apply it until its argument is even.

Will the Half Collatz function eventually reach an even number for all inputs? Call this statement the **Half Collatz Conjecture (HCC)**. Like CC, HCC appears to be both true and unprovable, PA ⊬ HCC. **But HCC is provable in CA, CA ⊢ HCC.** For suppose that *n* is a number > 1 such that repeated applications of *H* never reach an even number. By CC, there is a *k* such that *C<sup>k</sup>(n) = 1*. *n > 1*, so it must get reduced at some point. That reduction only happens when the even clause of *C* is triggered, so *n* must eventually reach an even number. ⊣

Finally, consider one more transformation function: ***B(n = 3k) = n*** and ***B(3k + r) = 5k + 3 + r*** (with *r = 1* or *r = 2*). We'll call this the **Beaver Collatz** function, since this is the function implemented by the **[4-state 2-color Beeping Busy Beaver champion](https://nickdrozd.github.io/2021/10/31/busy-beaver-derived.html)**. The **Beaver Collatz Conjecture (BCC)** says that repeated applications of *B* will eventually reach a number divisible by *3* for all inputs. (For a good time, try starting with *2*.) BCC seems to be true, and presumably it is also unprovable in PA. **Is BCC provable in CA, CA ⊢ BCC?** I conjecture that it is.

We saw that CA ⊢ HCC. But this is equivalent to saying that PA ⊢ CC → HCC, so **why bother with a new axiom?** Why not just stick with PA and take CC as a hypothesis? Well, if Conway is right, CC is both true and unsettleable. To me this says that CC opens up **a whole new method of reasoning**, a method of reasoning that is totally inaccessible otherwise. "Unsettleable" is a strong word, and Collatz-based arguments must be correspondingly strong.

But if CA ⊬ BCC, then the new method of reasoning seems somewhat weak. BCC would presumably be **unsettleable even in CA**, and would therefore have to be added as **yet another new axiom**. There's a whole world of **[Collatz-like functions](https://arxiv.org/pdf/1311.1029.pdf)**; are they all **co-unsettleable**? I suppose that's possible, but it's also possible that there are classes of such functions that are **co-provable**. That is my feeling.
