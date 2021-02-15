---
title: "Blanking Beavers"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2021-02-14 Sun&gt;</span></span>
layout: post
categories:
tags:
---
🚰 *This post is a continuation of **["Halt, Quasihalt, Recur"](https://nickdrozd.github.io/2021/01/14/halt-quasihalt-recur.html)**.* 🚰

**Deciding whether a Turing machine is currently halted is trivial.** All you have to do is check the machine's current state. If that state is the halt state, then it's halted. If it isn't, then it isn't.

As a **termination condition**, haltedness is convenient for the **simulator implementor**. It's quick and it's cheap and it's easy. But for the **Busy Beaver programmer**, the requirement to halt is an onerous one. A program of *n* states and *k* colors has only *nk* transitions to work with, and one of those has to be a halt transition. The cost for detecting termination is offloaded from the simulator implementor to the programmer.

Suppose the simulator implementor is willing to bear the burden of detecting termination. What termination condition should be used? A machine is said to have ***quasihalted*** if it reaches a point past which *some and only some* of its internal states becomes unreachable. As a termination condition, quasihaltedness gives the programmer an enormous amount of expressivity. Unfortunately, it isn't decidable in general whether a machine is currently quasihalted; there are programs that quasihalt but cannot be proved to quasihalt. Thus it is **impossible to implement** as a termination condition.

***Lin recurrence*** is a **decidable predicate**, and in theory it can be used as a termination condition. I don't know if there is a simple, non-technical description of Lin recurrence. It was devised by **Shen Lin** in order to **[prove the third Busy Beaver number](https://nickdrozd.github.io/2020/12/15/lin-rado-proof.html)**. The way it works is that on every step of the machine, a copy of the current tape contents is stored away, along with the machine's current state and scanned color. Then on every step, every previous tape matching the current state and scanned color is compared to the current tape for the span of tape traversed between then and now. If there is a match, then the machine is said to be ***in recurrence***. (Note that this method, the **Lin algorithm**, does not detect recurrence until after the recurrence has transpired for one *period*. It would be nice to able to detect recurrence as soon as it is entered.)

Implementing Lin recurrence as a termination condition is **theoretically possible, but not practically**. The Lin algorithm runs **quadratic** in the number steps the machine has run, meaning that a Turing machine that checks for recurrence will run slower the longer it runs. It's like there's a **memory leak**, which considering how the algorithm actually works is not so far from the truth.

🛂 **EXERCISE** 🛂 Come up with a predicate that is **feasible** to implement as a termination condition for a Turing machine that does not need to be explicitly indicated by the programmer.

The **Busy Beaver problem** requires that programs be run starting on the blank tape. Ashes to ashes and dust to dust, so why not blank to blank? Just say that **a machine terminates when its tape becomes blank again at some point after the first step**. Call a program that leaves the tape blank a *blanker*. Or don't. It's not a great name.

The **blank tape termination condition** is fairly cheap to implement as a termination condition. There's a trick to doing it right, but I won't say what it is. Unlike haltingness, blankness doesn't take up space in the program, although it does fatally constrain the programmer's ability to leave anything on the tape. Remember though, we're not talking about general Turing machine programmers here. We're talking about *Busy Beaver programmers*, who are insane. All they're interested in is running programs for as long as possible. Who cares what's left on the tape? Who cares what the program does, so long as it runs for a long time?

Just as halting gives rise to the Busy Beaver question and as quasihalting gives rise to the [Beeping Busy Beaver](https://nickdrozd.github.io/2020/10/09/beeping-busy-beaver-results.html) question and as Lin recurrence gives rise to a question that still needs a catchy name, so too does the blank tape condition give rise to the ***Blanking Beaver*** question: **what is the longest that an *n*-state *k*-color Turing machine program can run before leaving the tape blank, in a grim reminder of the ultimate futility of all endeavors?**

🛂 **EXERCISE** 🛂 Try to work out the ❷② Blanking Beaver champion **by hand**. Try to find the ❸② and ❷③ champions by computer search, or by hand if you're ambitious or bored.

🛂 **EXERCISE** 🛂 Come up with a **catchy name** for the question given rise to by Lin recurrence as the termination predicate.

The ❸② Blanking Beaver champion program is `1RB 1LB 1LA 1LC 1RC 0LC`. It runs for **34 steps** before blanking the tape. Here is its tape evolution over 40 steps:

{% highlight nil %}
 0 A _________________________[<_>]________________________
 1 B _________________________<#>[_]_______________________
 2 A _________________________[<#>]#_______________________
 3 B ________________________[_]<#>#_______________________
 4 A _______________________[_]#<#>#_______________________
 5 B _______________________#[#]<#>#_______________________
 6 C _______________________[#]#<#>#_______________________  <-- quasihalt
 7 C ______________________[_]_#<#>#_______________________
 8 C ______________________#[_]#<#>#_______________________
 9 C ______________________##[#]<#>#_______________________
10 C ______________________#[#]_<#>#_______________________
11 C ______________________[#]__<#>#_______________________
12 C _____________________[_]___<#>#_______________________
13 C _____________________#[_]__<#>#_______________________
14 C _____________________##[_]_<#>#_______________________
15 C _____________________###[_]<#>#_______________________
16 C _____________________####[<#>]#_______________________
17 C _____________________###[#]<_>#_______________________
18 C _____________________##[#]_<_>#_______________________
19 C _____________________#[#]__<_>#_______________________
20 C _____________________[#]___<_>#_______________________
21 C ____________________[_]____<_>#_______________________
22 C ____________________#[_]___<_>#_______________________
23 C ____________________##[_]__<_>#_______________________
24 C ____________________###[_]_<_>#_______________________
25 C ____________________####[_]<_>#_______________________
26 C ____________________#####[<_>]#_______________________
27 C ____________________#####<#>[#]_______________________
28 C ____________________#####[<#>]________________________
29 C ____________________####[#]<_>________________________
30 C ____________________###[#]_<_>________________________
31 C ____________________##[#]__<_>________________________
32 C ____________________#[#]___<_>________________________
33 C ____________________[#]____<_>________________________
34 C ___________________[_]_____<_>________________________  <-- blank tape, recurrence
35 C ___________________#[_]____<_>________________________
36 C ___________________##[_]___<_>________________________
37 C ___________________###[_]__<_>________________________
38 C ___________________####[_]_<_>________________________
39 C ___________________#####[_]<_>________________________
40 C ___________________######[<_>]________________________
{% endhighlight %}

This program uses its first six steps and states `A` and `B` to prepare a solid block of four marks. Then it switches to state `C`, never to reach another state again (and thus quasihalting). Over the course of the subsequent 28 steps that single state is miraculously able to clear the tape.

The preceding program description evinces a clear **subroutine structure** &#x2013; first arrange for the tape block to be filled in, then switch to the wipe state and wipe it. Indeed, this program appears to have been "constructed" in a modular fashion. Its `A` and `B` states are identical to the ❷② halting champion, `1RB 1LB 1LA 1RH`, except that instead of halting, it transitions to the appended `C` state. The state transition graph is not *strongly connected*, contravening the **[Spaghetti Code Conjecture](https://nickdrozd.github.io/2021/01/26/spaghetti-code-conjecture.html)**. (It isn't a proper counterexample though, since it can be dismissed as being "not sufficiently large".)

The **❹② Blanking Beaver champion** reaches the blank tape in **66345 steps**. That number may sound familiar, as the champions for quasihalting and Lin recurrence both terminate in **66349 steps**. The presumptive champion program for all three termination conditions is the same: `1RB 0LC 1LD 0LA 1RC 1RD 1LA 0LD`. The different termination conditions are intended to be different ways of measuring the amount of complexity that can be fit into a program of a certain size. The fact that these unrelated predicates all seem to point to the same program suggests that in some sense, **that program really is as complex as a ❹② program can be**.

Here are the best known values for these various sequences:


# ❷②

|---|---|---|
| Predicate | Steps | Program |
|---|---|---|
| Quasihalt | 6 | `1RB 1LB 1LB 1LA` |
| Halt | 6 | `1RB 1LB 1LA 1RH` |
| Blank Tape | 8 | `1RB 0RA 1LB 1LA` |
| Recurrence | 9 | `1RB 0LB 1LA 0RB` |
|---|---|---|


# ❸②

|---|---|---|
| Predicate | Steps | Program |
|---|---|---|
| Halt | 21 | `1RB 1RH 1LB 0RC 1LC 1LA` |
| Blank Tape | 34 | `1RB 1LB 1LA 1LC 1RC 0LC` |
| Quasihalt | 55 | `1RB 0LB 1LA 0RC 1LC 1LA` |
| Recurrence | 101 | `1RB 1LB 0RC 0LA 1LC 0LA` |
|---|---|---|


# ❷③

|---|---|---|
| Predicate | Steps | Program |
|---|---|---|
| Halt | 38 | `1RB 2LB 1RH 2LA 2RB 1LB` |
| Quasihalt | 59 | `1RB 2LB 1LA 2LB 2RA 0RA` |
| Blank Tape | 77 | `1RB 2LA 0RB 1LA 0LB 1RA` |
| Recurrence | 165 | `1RB 0LA ... 1LB 2LA 0RB` |
|---|---|---|


# ❹②

|---|---|---|
| Predicate | Steps | Program |
|---|---|---|
| Halt | 107 | `1RB 1LB 1LA 0LC 1RH 1LD 1RD 0RA` |
| Blank Tape | 66345 | `1RB 0LC 1LD 0LA 1RC 1RD 1LA 0LD` |
| Quasihalt | 66349 | `1RB 0LC 1LD 0LA 1RC 1RD 1LA 0LD` |
| Recurrence | 66349 | `1RB 0LC 1LD 0LA 1RC 1RD 1LA 0LD` |
|---|---|---|

**Computability theory** tells us that the quasihalting sequence must eventually dominate the halting sequence. Additionally, it's almost certainly the case that the recurrence and blank tape sequences also dominate the halting sequence, but that has not been proved. All that said, no values have been found that beat the halting sequence for the ❺② and ❷④ cases. **Finding new champions will not be easy.**

🛂 **EXERCISE** 🛂 This post makes **two major changes to previously used terminology**. What are the changes, and why were they made?

🛂 **EXERCISE** 🛂 Fill in the following table to show the **resource access** required to implement each termination predicate:

|---|---|---|---|---|
| | Halt | Quasihalt | Recurrence | Blank Tape |
|---|---|---|---|---|
| **Machine state** | | | | |
| **Program** | | | | |
| **Current tape contents** | | | | |
| **Past tape contents** | | | | |
| **Oracle for halting** | | | | |
| **Other (please specify)** | | | | |
|---|---|---|---|---|
