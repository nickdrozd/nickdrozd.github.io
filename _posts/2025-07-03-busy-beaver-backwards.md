---
title: "Busy Beaver Backwards"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2025-07-03 Thu&gt;</span></span>
layout: post
categories: 
tags: 
---

In the **classic Busy Beaver game** we ask: what is the longest that a Turing machine program of N states and K colors can run before halting when started on the blank tape? The basic approach to solving this problem is to generate a list of candidate programs, then subject each program to a sequence of **deciders**, where a decider is a function that takes a program as input and returns a result of type `Option<bool>`. This result is interpreted as follows:

-   `Some(true)`: the program provably halts
-   `Some(false)`: the program provably does not halt
-   `None`: haltingness could not be determined

Proving non-haltingness means **refuting the possibility of halting**, usually by showing that the program's halt conditions are unreachable.

One of the fundamental methods for refuting haltingness is **backward reasoning**. The idea is to start with a program's halt conditions and work backwards, reconstructing possible paths that could have reached it. If it can be shown that there are no valid paths, then the program's haltingness is refuted.

Here is a simple example:

{% highlight nil %}
    +-----+-----+
    |  0  |  1  |
+---+-----+-----+
| A | 1RB | 0LA |
+---+-----+-----+
| B | 1LA | --- |
+---+-----+-----+
{% endhighlight %}

This program halts if it scans a `1` while in state `B`. Other than the scanned `1`, the tape contents don't matter. In other words, the **halt configuration** is:

{% highlight nil %}
B1 | ? [1] ?
{% endhighlight %}

The goal now is to figure out the previous configuration. There is only one instruction that reaches state `B`, and that's `A0 : 1RB`. The machine must have been in state `A` scanning a `0`, and since that instruction moves right, that `0` must have been to the left of the current head. The tape contents are unknown other than the current scanned `1`, so it is **consistent** that a `0` be at that spot. The previous configuration must therefore have been:

{% highlight nil %}
A0 | ? [0] 1 ?
{% endhighlight %}

Repeating the process, there are two instructions that lead to state `A`: `A1 : 0LA` and `B0 : 1LA`. Both of these instructions go to the left, so they must have come from the right. `A1 : 0LA` writes a `0`, but the cell to the right of the scan contains a `1`. So the `A1` instruction is impossible. The `B0` instruction is consistent with the tape contents, so we move on to the next configuration:

{% highlight nil %}
B0 | ? 0 [0] ?
{% endhighlight %}

As before, the only possible instruction that could reach this is `A0 : 1RB`. But that instruction writes a `1`, while the cell to the left has a `0`. So the instruction is impossible. There are no other configurations to consider, so we can conclusively say that **this program cannot halt**.

The full sequence of configurations looks like this:

{% highlight nil %}
1 | B1 | ? [1] ?

2 | A0 | ? [0] 1 ?

3 | B0 | ? 0 [0] ?
{% endhighlight %}

We call this a **backward refutation of length 3 and width 1**.

Here is a more complicated example:

{% highlight nil %}
    +-----+-----+
    |  0  |  1  |
+---+-----+-----+
| A | 1RB | 0LA |
+---+-----+-----+
| B | 0RC | 1RC |
+---+-----+-----+
| C | 1LA | --- |
+---+-----+-----+
{% endhighlight %}

As before, we start with the single halting configuration:

{% highlight nil %}
C1 | ? [1] ?
{% endhighlight %}

How was this configuration reached? This time there are **two possibilities**: `B0 : 0RC` and `B1 : 1RC`. Both instructions are consistent with the tape contents, so both must be considered:

{% highlight nil %}
B0 | ? [0] 1 ?
B1 | ? [1] 1 ?
{% endhighlight %}

The same process must now be repeated for **both of these branches**. Here is the full sequence of configurations:

{% highlight nil %}
 1 | C1 | ? [1] ?

 2 | B0 | ? [0] 1 ?
 2 | B1 | ? [1] 1 ?

 3 | A0 | ? [0] 0 1 ?
 3 | A0 | ? [0] 1^2 ?

 4 | A1 | ? 0 [1] 1 ?
 4 | C0 | ? 0 [0] 1 ?

 5 | C0 | ? 0 1 [0] ?
 5 | B0 | ? [0] 0 1 ?

 6 | B1 | ? 0 [1] 0 ?
 6 | A0 | ? [0] 0^2 1 ?

 7 | A1 | ? 0 [1] 0 1 ?

 8 | A1 | ? 0 1 [1] 1 ?

 9 | C0 | ? 0 1^2 [0] ?

10 | B1 | ? 0 1 [1] 0 ?

11 | A0 | ? 0 [0] 1 0 ?

12 | C0 | ? 0^2 [0] 0 ?

13 | B0 | ? 0 [0] 0^2 ?
{% endhighlight %}

This is a **backward refutation of length 13 and width 2** &#x2013; width 2 because that is the maximum number of configurations at any step.

In these examples, we have seen a 2-state 2-color program with a refutation of length 2 and a 3-state 2-color program with a refutation of length 13. Are there any longer ones? Perhaps you can see where this is going. We can ask the general **Busy Beaver Backward** question: **among backward-refutable programs of N states and K colors, what is the length of the longest refutation?**

(What would be a good name for this function? **BBBack**? *I want my BBBack, BBBack, BBBack, &#x2026;*)

I will claim tentatively that these values are in fact the **winners**: the longest 2/2 refutation has length 2 and the longest 3/2 refutation has length 13. I don't have a proof, although whatever the true values are, they are certainly provable.

Here are the best values that I have been able to find, along with their witnessing programs:

|---|---|---|---|
| States | Colors | Program | Refutation Length |
|---|---|---|---|
| 2 | 2 | `1RB0LA_1LA---` | 3 |
| 2 | 3 | `1RB1RB---_0LB2RB1LA` | 8 |
| 3 | 2 | `1RB0LA_0RC1RC_1LA---` | 13 |
| 2 | 4 | `1RB0RA3LA2RB_2LA---2RB3LA` | 17 |
| | | `1RB1LA---3RB_2LA3RB0LB1LA` | 17 |
| | | `1RB1LA---3RB_2LB3RB0LA1LA` | 17 |
| 2 | 5 | `1RB4RB---1RB2RB_2LB3LA3RB0LA1LA` | 41 |
| | | `1RB3RA0RB0LA2RB_2LA---4LA---3LA` | 41 |
| 4 | 2 | `1RB0RB_1RC1LD_1LA---_0LD0RA` | 46 |
| | | `1RB0LA_0RC1RC_1RD1LA_1LB---` | 46 |
| 3 | 3 | `1RB0LA0RB_2RC1RC1LA_1LA2LA---` | 50 |
| | | 7 others (8-way tie) | 50 |
| 5 | 2 | `1RB0LA_0RC1RC_1RD1LA_0RE1LB_1LC---` | 115 |
| | | `1RB0RB_1RC1LE_1RD1LA_1LB---_0LE0RA` | 115 |
|---|---|---|---|

I would be very interested to know if these values can be beaten. Alternatively, if there is a bug in my backward reasoner and any of the values are illegitimate, I would be very interested to know that too.

A trend that shows up in this data is that longer refutations correlate with more states and fewer colors. This is because more colors means **exponentially more backward branching possibilities**, and this tends to foil the backward reasoning method. I interpret this as yet more evidence that **colors are more powerful than states**.


# Questions and Exercises

1.  Verify the claimed BBBack values, or find better ones, or show that they are illegitimate.

2.  How can the backward reasoning method be used to prove haltingness?

3.  A similar question is: among backward-refutable programs of N states and K colors, what is the **width** of the **widest refutation**? Find the best values for this function and exhibit their witnessing programs.

4.  Is BBBack computable? Why or why not?

5.  Backward reasoning can be used to refute haltingness, but it can be used for other conditions as well. Use backward reasoning to show that the following programs **cannot erase the tape**. How many steps do they take?

{% highlight nil %}
1RB0RD_1LC0LA_0RA1LB_1RE0LB_0LB1RD
1RB0RD_1LC0LA_0RA1LB_1RE0LB_1LE1RD
1RB0LC_1LC0RD_0RE1LA_0LA1RD_0RB1LB
1RB0RB_1RC1RA_1LC0LD_0RA0LE_1LD1LE
1RB1RD_1LB0LC_0RD0LE_1RA0RA_1LC1LE
{% endhighlight %}
