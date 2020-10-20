---
title: "Beeping Busy Beaver Results"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2020-10-09 Fri&gt;</span></span>
layout: post
categories:
tags:
---

# Table of Contents

1.  [Introduction](#orgbe80e22)
2.  [❷②](#orge7c7857)
3.  [❸②](#org3ee9cc4)
4.  [❹②](#orgc0f5dc1)
5.  [❷③](#orgeed097f)


<a id="orgbe80e22"></a>

# Introduction

In late July 2020, Scott Aaronson posed the **[Beeping Busy Beaver](https://www.scottaaronson.com/papers/bb.pdf)** problem, which asks: among n-state **[quasihalting Turing machine programs](https://nickdrozd.github.io/2020/10/08/quasihalting-behavior.html)**, which one runs the longest before quasihalting? This function is **super-uncomputable**, so exact values cannot be obtained even in principle. Nevertheless, I spent much of August and September of 2020 trying to establish **nontrivial lower bounds** for some early values of *n*, and I managed to find a few.

This posts summarizes the known results so far, with values for both the **shift** and **sigma** functions (the number of steps executed and the number of marks left on the tape, also known as "activity" and "productivity"). Following Pascal Michel's excellent **[historical survey of Busy Beaver candidates](http://www.logique.jussieu.fr/~michel/ha.html)**, the current champion will be listed along with a few other good programs. Also included, for comparison, are the Busy Beaver champions for each category. (The "shift champion" is the program with the greatest shift score; in the event of a tie, the winner is the program with the greater sigma score. The "sigma champion" is the program with the greatest sigma score; in the event of a tie, the winner is the programm with the least shift score.)

All machines are listed in **[normal form](https://nickdrozd.github.io/2020/10/04/turing-machine-notation-and-normal-form.html)**. Following [Lafitte and Papazian](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.104.3021&rep=rep1&type=pdf), state count will be represented with a black circled number, and symbol count with a white circled number. All programs were discovered by me unless otherwise noted. I'm "pretty sure" in all champ claims except for the ❹② case.


<a id="orge7c7857"></a>

# ❷②

There seem to be exactly four quasihalting ❷② machines. They all quasihalt in six steps, which is how long it takes for the ❷② Busy Beaver champion to halt. None of them have a higher sigma score, so apparently the extra power of quasihalting over halting doesn't "kick in" for such small programs.

|---|---|---|---|
| PROGRAM | SHIFT | SIGMA | NOTES |
|---|---|---|---|
| `1RB 1LB 1LA 1RH` | 6 | 4 | BB / BBB champ |
| `1RB 1LB 1LB 1LA` | 6 | 3 | |
| `1RB 1LB 0LB 1LA` | 6 | 2 | |
| `1RB 0LB 1LB 1LA` | 6 | 2 | |
| `1RB 0LB 0LB 1LA` | 6 | 1 | |
|---|---|---|---|


<a id="org3ee9cc4"></a>

# ❸②

The ❸② shift champion was given in the [Aaronson survey](https://www.scottaaronson.com/papers/bb.pdf).

I think these are all the quasihalting ❸② programs with sigma score > 4.

|---|---|---|---|
| PROGRAM | SHIFT | SIGMA | NOTES |
|---|---|---|---|
| `1RB 0LB 1LA 0RC 1LC 1LA` | 55 | 6 | Shift champ |
| `1RB 1RC 1LC 1RA 1RA 1LA` | 9 | 6 | Sigma champ |
| `1RB 0LB 1RC 0RC 1LC 1LA` | 54 | 6 | |
| `1RB 0LC 1LB 0RC 1LC 1LA` | 52 | 5 | |
| `1RB 0LC 0LC 0RC 1LC 1LA` | 51 | 5 | |
| `1RB 0LC 1LA 0RC 1RC 1RB` | 49 | 5 | |
| `1RB 0LC 0RC 0RC 1LC 1LA` | 48 | 5 | |
| `1RB 1RC 1LC 0LB 1RA 1LA` | 22 | 5 | |
| `1RB 1RH 1LB 0RC 1LC 1LA` | 21 | 5 | BB shift champ |
| `1RB 1LC 1RC 1RH 1LA 0LB` | 11 | 6 | BB sigma champ |
|---|---|---|---|


<a id="orgc0f5dc1"></a>

# ❹②

Three of the four most active programs end up ultimately with a sigma score of zero. This is a strange state of affairs.

The programs with sigma scores 25 and 39 were found by [Terry and Shawn Ligocki](https://github.com/sligocki/busy-beaver). (Or just Shawn? Maybe it's like Lennon-McCartney.)

These are just programs with shift score > 1000. Quasihalting ❹② programs are not especially rare, and it's entirely possible that there are programs with lower shift scores but higher sigma scores.

|---|---|---|---|
| PROGRAM | SHIFT | SIGMA | NOTES |
|---|---|---|---|
| `1RB 0LC 1LD 0LA 1RC 1RD 1LA 0LD` | 66349 | 0 | Shift champ (?) |
| `1RB 1RC 1LC 1RD 1RA 1LD 0RD 0LB` | 2819 | 69 | Sigma champ (?) |
| `1RB 1RA 0RC 0RB 0RD 1RA 1LD 1LB` | 2568 | 0 | |
| `1RB 1RA 0RC 1LA 1LC 1LD 0RB 0RD` | 2512 | 0 | |
| `1RB 1RC 1RD 0LC 1LD 0LD 1LB 0RA` | 2332 | 56 | |
| `1RB 0LC 1RC 1LD 1RD 0RB 0LB 1LA` | 1459 | 35 | |
| `1RB 0LC 1LD 0RC 1RA 0RB 0LD 1LA` | 1459 | 25 | |
| `1RB 1LC 1LC 0RD 1LA 0LB 1LD 0RA` | 1164 | 39 | |
| `1RB 1LB 1RC 0LD 0RD 0RA 1LD 0LA` | 1153 | 20 | |
| `1RB 1LB 1LA 0LC 1RH 1LD 1RD 0RA` | 107 | 13 | BB shift champ |
| `1RB 0RC 1LA 1RA 1RH 1RD 1LD 0LB` | 96 | 13 | BB sigma champ |
|---|---|---|---|


<a id="orgeed097f"></a>

# ❷③

These appear to be all the quasihalting programs with high shift or sigma scores.

|---|---|---|---|
| PROGRAM | SHIFT | SIGMA | NOTES |
|---|---|---|---|
| `1RB 2LB 1LA 2LB 2RA 0RA` | 59 | 8 | Shift champ |
| `1RB 2LB 1RA 2LB 2LA 0RA` | 43 | 10 | Sigma champ |
| `1RB 0LB 1RA 1LB 2LA 2RA` | 45 | 3 | |
| `1RB 2RA 2LB 2LB 2LA 0LA` | 40 | 5 | |
| `1RB 1LA 2RA 2LA 2LB 2RB` | 17 | 8 | |
| `1RB 2LB 1RH 2LA 2RB 1LB` | 38 | 9 | BB champ |
|---|---|---|---|
