---
title: "Beeping Busy Beavers"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2020-08-13 Thu&gt;</span></span>
layout: post
categories:
tags:
---
The **Busy Beaver** problem asks: among n-state halting Turing machine programs, which one runs the longest? The function BB(n) is famously **uncomputable**, since calculating it in general would require solving the **halting problem**. It grows with spectacular speed:

-   BB(1) = 1,
-   BB(2) = 6,
-   BB(3) = 21,
-   BB(4) = 107, and
-   **BB(5) ≥ 47,176,870**.

Beyond that, the numbers get too large to comprehend at a glance.

In his recent [Busy Beaver survey](https://www.scottaaronson.com/papers/bb.pdf#subsection.5.10), Scott Aaronson proposed a variation called the **Beeping Busy Beaver** problem, and it goes like this. Call a program ***quasihalting*** if it has any states which are reached no more than a fixed number of times during the course of a computation, and call such a state a *quasihalt state*. **Among n-state quasihalting programs, which one runs the longest before leaving its last quasihalt state?**

(The problem was initially described in terms of a machine that **"beeps"** upon exiting a certain designated "beep state". I think the "quasihalting" description is more straightforward, but "Beeping Busy Beaver" is a **catchy name**, and "BBB" is a convenient abbreviation for the function, so that name stays.)

BBB(1) = BB(1) = 1, and BBB(2) = BB(2) = 6, but BBB(3) = 55 > BB(3) = 21, and it is overwhelmingly likely that BBB(n) > BB(n) for all n ≥ 3. In fact, BBB turns out to be equivalent to BB<sub>1</sub>, which is like BB but defined over programs with access to a BB **oracle**, so there is even a j such that BBB(k) > BB(k + 1) for all k ≥ j. Thus BBB is **even more uncomputable** than BB.

I read all that in the BB survey article, and I thought it would be fun to try and find BBB(4), or at least find some program that would establish a **lower bound** better than BB(4) = 107. And I succeeded:

-   **BBB(4) ≥ 2819**

I'll exhibit that program later, but before doing that, **the reader should stop and consider how they would attempt to search for such a program, or even better, actually do the searching.** See [this page](http://www.logique.jussieu.fr/~michel/tmi.html) for the formal details about Turing machine programs.


# Program Generation

Here's how I went about it. First, it's easy to write a **Python** program to generate **all possible 4-state program strings**:

{% highlight python %}
COLOR = ('0', '1')
SHIFT = ('L', 'R')
STATE = ('A', 'B', 'C', 'D', 'H')

ACTIONS = tuple(
    color + shift + state
    for color in COLOR
    for shift in SHIFT
    for state in STATE
)

INSTRUCTIONS = tuple(
    ' '.join((a, b))
    for a in ACTIONS
    for b in ACTIONS
)

for i in INSTRUCTIONS:
    for j in INSTRUCTIONS:
        for k in INSTRUCTIONS:
            print(' '.join((i, j, k)))
{% endhighlight %}

Note that while it's easy to write code to generate all of them, it's not easy to run it. That's because there are **25,600,000,000** 4-state programs, and while it may be possible to generate all of them on a single laptop, it isn't pleasant to attempt. **Aggressive pruning** is required.

The easiest way to cut down on the space of possible programs is to **get rid of the halt state**. BB(n) is the longest running n-state program that halts, so if BBB(n) > BB(n) (as is surely the case for all n > 2), then the candidate programs are certainly going to be nonhalting. And if the programs are certainly going to be nonhalting, why bother including the halt state at all?

Call a program ***halt-free*** if none of its states leads to the halt state. There are (4(n+1))<sup>2n</sup> n-state programs, but only (4n)<sup>2n</sup> halt-free n-state programs. For 4-state programs, this brings the total down to a nearly-manageable **4,294,967,296**, about one sixth as many.

Next, **stupid programs should be dropped**. For example, any programs whose A0 action points to state A will immediately spin out into dumb infinity, so don't bother printing it; just `continue` the `for` loop and keep going. It's also safe to assume that any program that always prints one or always prints zero will be of no interest, and so on.

By now my file of 4-state programs was still over one billion lines long. Even running `wc -l` took around fifteen seconds, so I had to reduce the search space even further. Obvious pruning gave way to **speculative pruning**, meaning that programs were pruned according to guesses about the structure of "productive" programs. For example, the survey conjectures that every state of a BB program will reachable from every other state; or in other words, that **spaghetti code** is the best way to maximize runtime. I don't know of an easy way to test a program string for this property, but it is at least possible to prune every program string that does not contain all four states. I also made the assumption that **most of the program's actions will print one rather than zero**. Why? Roughly, the program should be doing something most of the time, and since the tape starts off totally blank (all zeros), most of the time "doing something" will mean printing a one. A 4-state program will have eight print actions, so I got rid of all programs with fewer than five one-prints. That may well turn out to be incorrect, but **there's no choice but to take some risks**.


# Program Execution

All this pruning got my program file down to around 400,000,000 lines, and from there I started running the programs. Now, every program involved is halt-free, and so will definitely not halt. (Solving the halting problem for halt-free programs is easy: the answer is always NO.) This means that the programs have to **run for only some bounded number of steps**. But what bound? What kind of value should someone expect for BBB(4)? It's greater than 107, but by how much?

My **working hypothesis** has been that BBB(4) < 10,000. I don't know if that's actually true, but it feels true from the relatively thin slice of programs that I've looked at. Under that assumption, I can run the programs for 10,000 steps, then look at when each state was last hit. One of them will certainly have been hit last at step 10,000 (why?), so I look to the next greatest last step.

One pattern that comes up a lot is for three states to be all over 9,900 and then one to be between 3,000 and 7,000. Invariably, these numbers all continued to grow when the programs were re-run for longer. Those programs are **duds** because they do not quasihalt. Therefore, I took to checking only the second greatest last step hit, filtering out values over 8,000 or less than 2,000.

Thus I ended up with **the reigning BBB(4) "champion"**:

-   **`1LB 1LC 1RC 1LD 1LA 1RD 0LD 0RB`**

It hits state B at step 2819 before spinning out forever into state D. At that time, there is a solid block of **69 ones** on the tape. For comparison, the 4-state Busy Beaver leaves only 13 ones on the tape when it halts.


# Discussion Questions

1.  What makes a strictly quasihalting program more powerful than a halting program?
2.  What is the least j such that BBB(k) > BB(k + 1) for all k ≥ j?
3.  Prove or disprove: BBB(n) > BB(n) for all n > 2.
4.  Is quasihaltingness decidable for 4-state programs? That is, given an input I and a 4-state program P, is there either a proof that P quasihalts when run on I or a proof that P does not quasihalt on I? What about for 5-state programs?
5.  Find a better lower bound than 2819 for BBB(4), or else prove that BBB(4) = 2819.
6.  Find a nontrivial candidate program for BBB(5).
7.  Describe the behavior of the BBB(4) candidate program. Even better, write an equivalent program in a high-level language.
8.  Describe the behavior of this program: **`1LB 0LA 1LC 1RB 0RB 1LD 0LA 0LC`**.
9.  Is the value of BBB(4) provable? What about BBB(5)?
