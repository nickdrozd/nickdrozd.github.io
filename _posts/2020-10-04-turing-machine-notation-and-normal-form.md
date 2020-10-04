---
title: "Turing Machine Notation and Normal Form"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2020-10-04 Sun&gt;</span></span>
layout: post
categories:
tags:
---
A **Turing machine** (TM) can be defined formally as the collection of the following objects:

-   a finite, non-empty set 𝑸 of *active states*;
-   a distinguished state 𝒒<sub>0</sub> ∈ 𝑸, the *initial state*;
-   an object 𝒒<sub>H</sub> ∉ 𝑸, the *halt state*;
-   a finite set with quantity > 1 𝜞 of *symbols*;
-   a distinguished symbol 𝜸<sub>0</sub> ∈ 𝜞, the *blank symbol*;
-   a 2-element set 𝑫, the *shifts*; and
-   a **total** function 𝜹 : 𝑸 × 𝜞 → 𝜞 × 𝑫 × 𝑸 ∪ { 𝒒<sub>H</sub> }, the *transition function*.

A few remarks about this definition:

1.  Some presentations of TMs allow the transition function to be **partial**, but this difference is inessential; a partial function can be made total by adding a catch-all default case.
2.  Although the halt state is stipulated to be distinct from the "active states", it is occasionally convenient to group together the **set of all states**, 𝑸 ∪ { 𝒒<sub>H</sub> } (for instance, in the range of the transition function). The expression "active states" is used in cases where the halt state is not under consideration
3.  An element of 𝑸 ∪ { 𝒒<sub>H</sub> } × 𝜞 × 𝑫 is known as an ***action***.
4.  **Alternative "architectures"** can be obtained by modifying this definition. The architecture described here is the *quintuple variation*, so called because its transition function can be represented as a set of 5-tuples. Another common architecture is the *quadruple variation*, with the transition function of the form 𝑸 × 𝜞 → 𝑸 ∪ { 𝒒<sub>H</sub> } × 𝜞 ∪ 𝑫. Whereas the quintuple variation prints and moves at each step, the quadruple variation does one or the other but not both. (In other words, the transition function prescribes different kinds of actions.)
5.  TMs are typically **grouped by number of active states and symbols**. An *n-state, m-symbol* TM has *n* active states and *m* symbols.
6.  It has become customary to represent states with capital Roman letters starting with `A`, with the halt state as `H` (or something else if it's needed for the active states), *m* symbols with the numbers *0 &#x2026; m-1* (with *0* as the blank symbol), and the shifts with `L` and `R` (or something else, if these letter are needed for the active states). In the old days, numbers were used for states, symbols, and shifts, and TM programs were much, much harder to read.

Individual TMs are typically **identified** with their transition functions, or with **representations thereof**. These represenations may also be referred to simply as ***programs***<sup><a id="fnr.1" class="footref" href="#fn.1">1</a></sup>. Transition functions are often represented as tables, with actions indexed by state and symbol:

|---|---|---|---|---|---|
| | A | B | C | D | E |
|---|---|---|---|---|---|
| 0 | 1RB | 1RC | 1RD | 1LA | 1RH |
| 1 | 1LC | 1RB | 0LE | 1LD | 0LA |
|---|---|---|---|---|---|

What this says is: if the machine is in state `A` and scanning a `0` on the tape, it will print `1`, shift to the right, and transition to state `B`, and so on. Less transparently but more compactly, TMs can also be represented as **simple strings**. The actions are laid out, delimited by spaces, in such a way that actions from earlier states go earlier than later ones, and actions from the same state are ordered by the symbol they come from. Thus the table above comes out as `1RB 1LC 1RC 1RB 1RD 0LE 1LA 1LD 1RH 0LA`.

Table notation is easier to read than string notation, but since it's not possible in general to tell what a TM does just by looking at it, this is of little benefit. On the other hand, string notation is excellent for **ease of communication**; a string TM description can easily be dropped into an email or a blog comment. String notation is also amenable to the use of **standard text manipulation tools**. For instance, a file of line-separated TMs in string form can be editted with `sed` and searched with `grep`.

Given two distinct TM strings, it might be asked if they represent **meaningfully different** programs or if they are only **superficially different**. This question can be answered by defining a canonical representation. A TM string is in ***lexical normal form*** iff the following conditions obtain:

1.  The first shift is `R`.
2.  The non-initial active states (𝑸 ∖ 𝒒<sub>0</sub>) first occur in ascending order.
3.  The non-blank symbols (𝜞 ∖ 𝜸<sub>0</sub>) first occur in ascending order.

The first condition rules out the possibility of two TMs being identical except for **"mirror images"** of each other. The second and third conditions rule out TMs that are the same except for **permutations of states and symbols**. Note that the second condition is trivially true for 1- and 2-state TMs, and the third condition is trivially true for 2-symbol TMs.

It's **easy** determine whether or not a given TM is in normal form, and reasonably short TMs can be judged as normal or not by **eyeball**. It's also straightforward, though a little more difficult, to **generate** the corresponding normal form for an arbitrary non-normal TM (doing so requires permuting graphs, which can be tricky).

There is another "normal form" that has been in use since the 60s. A TM string is in ***tree normal form*** iff the following conditions obtain:

1.  The first shift is `R`.
2.  When run on a blank tape, the TM enters its non-initial active states in order.
3.  When run on a blank tape, the TM prints its non-blank symbols in order.

Tree normal form is so-named because it is what results from the **tree generation procedure**. In that procedure, a partially-specified TM is partially run and its transition function "holes" are filled in as needed in a "tree" fashion. New states and symbols are added in order, yielding some kind of canonical form.

Notice that the definition of lexical normal form considers only to the TM string itself, and therefore belongs to **static analysis**. In contrast, the definition of tree normal form makes reference to the actual **runtime behavior** of the program represented by the TM string. Unfortunately, this means that it is **not generally decideable** whether a particular TM string is in tree normal form or not, or whether two distinct TM strings have the same tree normal form or not. Without impugning the tree generation procedure, which has been successfully used by researchers for decades, it's safe to say that "tree normal form" is a **misnomer**.

For the reasons above, I propose that **lexical normal form should be considered the canonical representation of TMs, and TM should be communicated and published in lexical normal form**.


# Exercises

1.  Which of the following are in lexical normal form? Which are in tree normal form?
    -   `1LB 0RB 1RA 0LC 1RC 1RA`
    -   `1RB 0LB 1LA 0RC 1LC 1LA`
    -   `1LC 0RC 1RB 1RA 1RA 0LB`
    -   `1RC 0LC 1LB 1LA 1LA 0RB`
2.  Can a program be in both lexical and tree normal forms at once? If so, give an example. If not, why not?
3.  Write a program to determine whether or not an arbitrary TM string is in lexical / tree normal form.
4.  Write a program to convert an arbitrary TM string to lexical / tree normal form.
5.  There are *(2m(n+1))<sup>mn</sup>* *n*-state *m*-symbol TMs. How many are there in lexical normal form? How many are there in tree normal form?

The following questions have to do with Pascal Michel's **[historical survey of Busy Beaver candidate machines](http://www.logique.jussieu.fr/~michel/ha.html)**.

1.  Determine *by eyeball* which programs in the list are in lexical or tree normal forms.
2.  Use your program from exercise 2 above to determine which programs in the list are in lexical or tree normal form.
3.  (Extra credit) Go through the list and convert every program to lexical normal form, then email Pascal Michel and politely ask him to update the list to be lexical-normal.

# Footnotes

<sup><a id="fn.1" href="#fnr.1">1</a></sup> In some philosophical quarters a sharp distinction is drawn between **"use" and "mention"**. However, it's both practical and instructive to let one's eyes go out of focus when looking at the difference between a "Turing machine" and its "representation". See **["Are Turing Machines Programmable?"](https://nickdrozd.github.io/2020/09/14/programmable-turing-machine.html)**
