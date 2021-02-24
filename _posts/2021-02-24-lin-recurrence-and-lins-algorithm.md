---
title: "Lin Recurrence and Lin's Algorithm"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2021-02-24 Wed&gt;</span></span>
layout: post
categories:
tags:
---
Suppose someone claims that a particular Turing machine program halts when run on the blank tape. **How can this claim be verified?** The obvious answer is to run it on the blank tape and see if it halts. But what if the program in fact does not halt? The verifier will be stuck running a non-halting program, **waiting forever** for a halt that will never come.

This unpleasant situation is nothing other than the **semidecidability** of halting. But **verification should be decidable**. It's not up to the verifier to hope that the program will behave as claimed, and the verifier shouldn't be on the hook for an open-ended search.

**Tibor Rado** recognized this issue and therefore required contestants in the **Busy Beaver game** to submit candidate programs accompanied by halt steps (emphasis added):

> iii. [The contestant] submits their entry, **as well as the shift-number s**, to any member (in good standing) of the International Busy Beaver Club.
>
> iv. The umpire first verifies that the entry actually stops exactly after s steps. **Note that this is a decidable issue**; the umpire merely operates the entry, persisting through not more than the specified number s of shifts. If the entry fails to stop after s shifts, it is rejected; if it stops after fewer than s shifts, it is returned to the contestant for correction.

Verifying the program by itself is semidecidable, and verifying the program along with some accompanying information is decidable. Call the accompanying information the program's ***attestation***. (I feel like there is a better name for it, but this will have to do for now.)

Different claims can require different forms of attestation. The **classic Busy Beaver** problem for halting requires just a single number, the halt step. The **[Beeping Busy Beaver](https://nickdrozd.github.io/2020/10/09/beeping-busy-beaver-results.html)** problem for quasihalting requires a number (the step at which the program quasihalts) as well as a proof that the program quasihalts at that step. The **[Blanking Beaver](https://nickdrozd.github.io/2021/02/14/blanking-beavers.html)** problem for the blank tape condition, as for halting, requires just a number.

What about the Busy Beaver problem for **Lin recurrence**? Sadly, this sequence still lacks a catchy name. Call now; operators are standing by. It looks for the longest that a program of such and such length can run before entering into a certain simple, detectable repetetive pattern.

Suppose somebody comes to you with a program and claims that it enters into recurrence after *s* steps. **How can *this* claim be verified?** Run the program for *s* steps, then check for recurrence after that. After one step, recurrence is not detected. After two steps, recurrence is not detected. After three steps&#x2026;you get the picture. **Detecting recurrence is another potentially open-ended search.** Thus Lin recurrence requires for attestation two numbers: a step *s* and a ***period*** *p*, the length of the recurrence pattern.

Now, let's stop for a moment and address the elephant in the room: **what exactly is Lin recurrence anyway?** This question was raised by the renowned Busy Beaver trapper **Shawn Ligocki**:

> From a practical point-of-view, I think we will have to define BBLR() more concretely in order to entice people to search for better candidates. After reading [your article](https://nickdrozd.github.io/2021/01/14/halt-quasihalt-recur.html) and the linked one [The Lin-Rado Busy Beaver Proof](https://nickdrozd.github.io/2020/12/15/lin-rado-proof.html) I am left with a lot of uncertainty about the exact criteria that activate this algorithm. Perhaps we could specify mathematically this criteria some concise way so that it could be easier to argue over which recurrences count and which do not?

Ligocki is entirely right to ask for clarification, as I have not done a very good job of explaining it so far. **Shen Lin** himself also did not give a **definition of recurrence**; he just described an **algorithm for detecting it**. Of course in a sense the algorithm does define something, namely, whatever the algorithm produces (compare "Lin recurrence" with *["tree-normal form"](https://nickdrozd.github.io/2020/10/04/turing-machine-notation-and-normal-form.html)*). But still, a pithy definition would be much easier to communicate.

It would also, as Ligocki mentions, make **adjudication** easier. For simple programs like the three-state recurrence champion, it's possible to verify recurrence by just looking at its tape evolution. But what if someone claims that a program enters into recurrence with a wildly long period? This isn't a hypothetical: friend-of-the-blog **[Boyd Johnson](https://github.com/boydjohnson/lin-rado-turing)** has recently discovered some programs with periods that definitely cannot be verified manually:

|---|---|---|
| Program | Steps | Period |
|---|---|---|
| `1RB 0RC 1LB 1LD 0RA 0LD 1LA 1RC` | 158491 | 17620 |
| `1RB 0RA 1RC 0RB 1LD 1LC 1RA 0LC` | 7170 | 29117 |
| `1RB 1RA 0RC 0LB 0RD 0RA 1LD 0LA` | 28812 | 5588 |
|---|---|---|

Running these programs for a few thousand steps is enough to show that they are at least somewhat interesting, and so the claimed steps and periods are **not obviously bullshit**. But still, they are extraodinairy claims. They need decisive evidence, and that requires a clear definition.

Before getting to a definition, note that **Lin's algorithm** is a terrible way to verify claims like this. Lin's algorithm is a method for detecting recurrence in arbitrary programs. It runs **quadratic** in the length of the period being checked. On my laptop running my **[Python implementation](https://github.com/nickdrozd/pytur/blob/7795b92ebc0332e81b9f65e65350df3f89db4506/turing.py#L157)** of Lin's algorithm, the third program above was verified in three minutes. The second one was verified in three hours. The first one is as yet unverified by that method.

Lin's algorithm is **general**: it detects any recurrence for an **arbitrary program** within some specified bound. But from the verifier's perspective, such generality is totally unnecessary. It's a **specific program** that needs to be verified, not an arbitrary one.

With that in mind, here is the **verification procedure** I've devised. This procedure constitutes a definition of some kind (though still not one that can be easily communicated).

**[Lin recurrence verification]** Run the program for *s+p* steps, and keep a record of the tape contents for every step after *s*. Compare the tape configuration after *s* steps with the tape configuration after *s+p* steps. If the machine does not have the same internal state at those times, then it is NOT in recurrence. So assume that the states are the same. The next step is to compare the tape contents at the two moments, which will be determined by the relative positions of the tape heads. Either the tape head is scanning the same square or it isn't.

-   *If the square is the same*, then look at the tape history and determine the farthest the tape head has traveled to the left and the right over the course of the steps from *s+1* through *s+p*. The machine is in recurrence iff the tape for that left-right span after step *s* is the same as the tape for that left-right span after step *s+p*. (An even simpler way would be to compare the entire tape contents, rather than just that particular span.)

-   *If the square is different*, then the tape head has moved to the left or the right over the course of the *p* steps after *s*. WLOG, assume it has moved left. Call the difference the offeset. Look at the tape history and determine the farthest the tape head has traveled to the right over the course of the steps from *s+1* through *s+p*. The relevant section of the tape after step *s* is from that rightmost position through the left edge of the tape, and the relevant section of the tape after step *s+p* is from that rightmost position minus the offset through the left edge of the tape. The machine is in recurrence iff those two tapes sections are the same.

Actually implementing this check is not easy. There are many opportunities for **off-by-one errors**. As they say, the three hardest things in programming are off-by-one errors, cache invalidation, and.

Lin's algorithm amounts to running this verification check for **every possible period** of a machine's runtime. At every step, the current tape contents are compared to the tape contents of every previous step with the same machine state and scanned color. If the machine is run for *t* steps, then this routine will detect any step / period such that *s+p ≤ t*. But again, such generality is frivolous when verifying a particular program with a specified step and period.

Ligocki has proposed an **alternate definition for recurrence**:

> Here's my stab at such a mathematical description. It's been a while since I read Lin's paper, so I will call this shift-recurrence so as not to confuse it with a (perhaps slightly different) criteria that LR used.
>
> A TM is left-shift-recurrent if:
>
> -   There exists integer: n
> -   There exist strings of symbols: X, Y, Z
> -   There exists state S and symbol g
> -   Such that the TM in configuration: 0<sup>inf</sup> X (S g) Y &#x2026;
> -   Transitions after n steps to configuration: 0<sup>inf</sup> X (S g) Y Z &#x2026;
> -   Without ever traveling into the "&#x2026;" area
>
> A TM is shift-recurrent if it is either left-shift-recurrent or it's mirror image is left-shift-recurrent.

I don't know if the specific details here are exactly right, but this is probably the right way to go. The **algorithmic definition** requires the reader to reverse engineer the method to acquire a mental picture of what's going on, while this **picture definition** just is a picture. On the other hand, it still isn't short, and it still can't be communicated easily.

Let's close by looking at some **integer sequences**, since the purpose of all this research is, after all, to win the **[Bigger Number Game](https://www.scottaaronson.com/writings/bignumbers.html)**. The classic Busy Beaver *n*-state 2-color halting shift sequence seems to go like this:

{% highlight nil %}
1 : 1
2 : 6
3 : 21
4 : 107
5 : 47176870 (?)
...
{% endhighlight %}

Changing the termination predicate from halting to entrance into recurrence gives what is apparently a **faster-growing sequence**:

{% highlight nil %}
1 : 1
2 : 9
3 : 101
4 : 158491 (?)
...
{% endhighlight %}

Here's a different kind of sequence: not the longest a program can run before entering into recurrence, but **the longest recurrence period** a program can have:

{% highlight nil %}
1 : 1
2 : 8
3 : 92
4 : 29117 (?)
...
{% endhighlight %}

Clearly the recurrence-termination sequence grows faster than the halt-termination sequence for early values, and it seems likely that it **dominates it in the long term** as well. The **periodic sequence** also grows faster than the halt-termination sequence for early values, but I am not so sure that it will dominate in the long term. A recurrence pattern, no matter its length, is decidable; in contrast, a program may exhibit undecidable behavior before halting. My *current hypothesis* is that **the halt-termination sequence will eventually dominate the recurrence period sequence**. Needless to say, this is highly speculative. Is there any **computability theory** that can be brought to bear on this question?


# Exercises

1.  Implement Lin's algorithm.
2.  Implement fast recurrence verification.
3.  Implement a recurrence detection mechanism based on Ligocki's definition.
4.  Find a champion 5-state recurrent program.
5.  Prove or disprove the conjecture about the recurrence period sequence.
