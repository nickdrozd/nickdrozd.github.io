---
title: "The Afterlife Behavior of Quasihalting Turing Machines"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2020-10-08 Thu&gt;</span></span>
layout: post
categories:
tags:
---
**When a Turing machine halts, that's it.** The computation is over, and all that's left to talk about is whatever is on the tape. The program itself has nothing else to say.

**When a Turing machine quasihalts, things may not be so simple.** A TM is said to be *quasihalting* if it has any reachable states that are reached no more than a fixed number of times over the course of a computation, and a TM is said to *quasihalt* upon exiting its last such state. Every halting machine is quasihalting, while only some non-halting machines quasihalt. Call these latter machines *strictly quasihalting*. (The rest of this post will only be concerned with strictly quasihalting machines, so for convenience the word "strictly" will not be used.)

**What do quasihalting machines do after they quasihalt?** Let's look at the **tape evolutions** of some quasihalting machines, just before and just after quasihalting.

The following program quasihalts in **2819** steps:

{% highlight nil %}
1RB 1RC 1LC 1RD 1RA 1LD 0RD 0LB
{% endhighlight %}

{% highlight nil %}
___###############################################################[#]_#__#
___################################################################[_]#__#
___#################################################################[#]__#
___##################################################################[_]_#
___###################################################################[_]#
___####################################################################[#]
___#####################################################################[_]    <-- quasihalted
___#####################################################################_[_]
___#####################################################################__[_]
___#####################################################################___[_]
___#####################################################################____[_]  <-- forever
{% endhighlight %}

After step 2818, the head is scanning the rightmost marked square on the tape (indeed, of a **solid block of 69 marks**) and the machine is in state `B`. The `B1` action is `1RD`, so the head moves right and the machine shifts into state `D`. Now the head is scanning a blank cell, and since the `D0` action is `0RD`, the head moves right and remains in state `D`. That pattern goes on forever, so the post-quasihalting behavior of this program is simple and **uninteresting**.

Here's another one, which quasihalts in **2568** steps:

{% highlight nil %}
1RB 1RA 0RC 0RB 0RD 1RA 1LD 1LB
{% endhighlight %}

{% highlight nil %}
___________[#]##_____
____________[#]#_____
_____________[#]_____
______________[_]____
_______________[_]___
________________[_]__  <-- quasihalted
_______________[_]#__
______________[_]##__
_____________[_]###__
____________[_]####__
___________[_]#####__  <-- forever
{% endhighlight %}

In this case, the program spends the last steps before it quasihalts erasing the tape, so that when it quasihalts, the tape is completely blank. At that time the machine in state `C`, and since the `C0` action is `0RD` it shifts into state `D`. The tape is still blank, and the `D0` action is `1LD`, so the machine will remain in state `D`, moving left and blasting out 1s forever. Again, this behavior is simple and **uninteresting**.

These examples suggest a **mental picture** for the operation of quasihalting programs: **a turntable playing a record**. The needle is placed at the start of the record, then the turntable starts spinning. It spins until it reaches the end of the record, and then, if it's a cheap turntable, it will keep spinning forever. The interesting part of the record can no longer be reached, so as it spins the needle only runs over its innermost loop ("bump&#x2026;bump&#x2026;bump&#x2026;").

A quasihalting program seems to operate in **two distinct phases**, namely what happens before it quasihalts and what happens after. What should these phases be called? On the basis of this mental picture, I initially called the second phase the **"spin-out"**. In both of the examples above, the machine would be said to "spin out into state `D`".

Except, **the turntable metaphor is wrong**. The definition of "quasihalting" only requires that there be *at least one* state that is never reached again after some point; it is entirely possible that there could be *exactly one*. Consider this program:

{% highlight nil %}
1RB 1RC 1RD 0LC 1LD 0LD 1LB 0RA
{% endhighlight %}

{% highlight nil %}
_#_##__##_##_#_##__##_##_#_##__##_##_#_##__##_##_#_##__##_##_#_##__#_#_##__#_##__#_##__#_##___[_]__##
_#_##__##_##_#_##__##_##_#_##__##_##_#_##__##_##_#_##__##_##_#_##__#_#_##__#_##__#_##__#_##__[_]#__##
_#_##__##_##_#_##__##_##_#_##__##_##_#_##__##_##_#_##__##_##_#_##__#_#_##__#_##__#_##__#_##__#[#]__##
_#_##__##_##_#_##__##_##_#_##__##_##_#_##__##_##_#_##__##_##_#_##__#_#_##__#_##__#_##__#_##__#_[_]_##
_#_##__##_##_#_##__##_##_#_##__##_##_#_##__##_##_#_##__##_##_#_##__#_#_##__#_##__#_##__#_##__#_#[_]##
_#_##__##_##_#_##__##_##_#_##__##_##_#_##__##_##_#_##__##_##_#_##__#_#_##__#_##__#_##__#_##__#_##[#]#  <-- quasihalted
_#_##__##_##_#_##__##_##_#_##__##_##_#_##__##_##_#_##__##_##_#_##__#_#_##__#_##__#_##__#_##__#_##_[#]
_#_##__##_##_#_##__##_##_#_##__##_##_#_##__##_##_#_##__##_##_#_##__#_#_##__#_##__#_##__#_##__#_##_#[_]
_#_##__##_##_#_##__##_##_#_##__##_##_#_##__##_##_#_##__##_##_#_##__#_#_##__#_##__#_##__#_##__#_##_[#]#
_#_##__##_##_#_##__##_##_#_##__##_##_#_##__##_##_#_##__##_##_#_##__#_#_##__#_##__#_##__#_##__#_##__[#]
_#_##__##_##_#_##__##_##_#_##__##_##_#_##__##_##_#_##__##_##_#_##__#_#_##__#_##__#_##__#_##__#_##__#[_]
_#_##__##_##_#_##__##_##_#_##__##_##_#_##__##_##_#_##__##_##_#_##__#_#_##__#_##__#_##__#_##__#_##__[#]#
_#_##__##_##_#_##__##_##_#_##__##_##_#_##__##_##_#_##__##_##_#_##__#_#_##__#_##__#_##__#_##__#_##___[#]
_#_##__##_##_#_##__##_##_#_##__##_##_#_##__##_##_#_##__##_##_#_##__#_#_##__#_##__#_##__#_##__#_##___#[_]
_#_##__##_##_#_##__##_##_#_##__##_##_#_##__##_##_#_##__##_##_#_##__#_#_##__#_##__#_##__#_##__#_##___[#]#
_#_##__##_##_#_##__##_##_#_##__##_##_#_##__##_##_#_##__##_##_#_##__#_#_##__#_##__#_##__#_##__#_##____[#]
_#_##__##_##_#_##__##_##_#_##__##_##_#_##__##_##_#_##__##_##_#_##__#_#_##__#_##__#_##__#_##__#_##____#[_]  <-- forever
{% endhighlight %}

This program quasihalts at step **2332**, at which point there are **56 nonconsecutive marks** on the tape. Scanning a blank cell in state `B`, the machine shifts to state `D`. But then `D` leads to `A`, which leads to `C`, which leads back to `D`, and so on forever. The "spin-out" behavior is: from a marked square, move right, mark, move left, erase, move right. If you were watching the live evolution of this tape, it would look like a single marked square was kind of blurring its way forever to the right. This is not terribly complex behavior, but it is also **not so trivial** as the previous examples.

"Spin-out" therefore is **not a good piece of terminology**, at least in this case, because it's **prejudicial**: it suggests that all post-quasihalting behavior is dumb, but it may not be. It may even **undecidably complex**. Given this, what's the appropriate terminology for the two phases? Perhaps it's overly dramatic, but I'm currently calling them ***life*** and ***afterlife***. Something happens after quasihalting, and it's distinct from and simpler than what happens before quasihalting, but that's all we can say in general.

To finish off, here is a first stab at a **taxonomy of afterlife behavior**:

-   Call a program ***quiet*** if it does not modify the tape in its afterlife, and ***noisy*** otherwise.
-   Call a program ***stationary*** if it spends its afterlife in a fixed range of tape, and ***mobile*** otherwise.
-   Call a program a ***spin-out*** if it spends its afterlife in just one state.


# Exercises

1.  Which of the programs exhibited in this post are "quiet" and which ones are "noisy"? Which ones are "spin-outs"?
2.  All of those programs are "mobile". Find a "stationary" quasihalting program.
    -   3-state 2-symbol example (ROT13): `1EO 1EP 1YP 0YO 1EN 1YN`
3.  (Extra credit) Find a quasihalting 5-state 2-symbol program and describe its behavior.
