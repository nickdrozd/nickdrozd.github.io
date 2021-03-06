---
title: "A New Record in Self-Cleaning Turing Machines"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2021-07-11 Sun&gt;</span></span>
layout: post
categories:
tags:
---
**SCENARIO:** It's 1950, and a brand new Turing machine, the first of its kind, has been installed at a research facility. Lots of people want to use it, but the machine has just one tape. A program's execution can be affected in undesirable ways by data left over on the tape from a previous program run, and so **as a matter of etiquette the convention is adopted among the machine's users that the tape is to be wiped clean after each use**. Rather than cleaning the tape manually after program execution, the programmers soon figure out how to **automate the wiping process** by writing their programs with **cleanup routines** at the end. The Turing machine itself is eventually hacked so that it comes to a halt when and only when it detects that the tape is blank.

Now here's a question: **How long can an *n*-state *k*-color Turing machine program started on the blank tape run before wiping the tape clean?** A basic search over the smaller program spaces yields the following early results:

|---|---|---|
| States | Colors | Steps |
|---|---|---|
| 2 | 2 | 8 |
| 3 | 2 | 34 |
| 2 | 3 | 77 |
|---|---|---|

That is to say, there is a 3-state 2-color program that, starting from the blank tape, renders the tape blank again in 34 steps. The reader might attempt to find that program on their own, or even construct it by hand.

At this point, you might think that this all sounds similar to the **[Busy Beaver problem](https://nickdrozd.github.io/2020/10/15/busy-beaver-well-defined.html)**. You're right, it is similar, and in fact it is known as the **[Blanking Beaver problem](https://nickdrozd.github.io/2021/02/14/blanking-beavers.html)**. The classic Busy Beaver problem asks how long a TM program can run before executing a halt instruction; here we change the **termination condition** to require that programs blank the tape.

The Busy Beaver function is **uncomputable** and **notoriously fast-growing**. Take a look at its early values and note the sharp increase after the 4-state 2-color case:

|---|---|---|
| States | Colors | Steps |
|---|---|---|
| 2 | 2 | 6 |
| 3 | 2 | 21 |
| 2 | 3 | 38 |
| 4 | 2 | 107 |
| 2 | 4 | 3,932,964 |
| 5 | 2 | 47,176,870 |
|---|---|---|

Among short programs, the Blanking Beaver values are greater than the Busy Beaver values, but not by a lot. What about for later values? **How fast does the Blanking Beaver function grow with respect to the Busy Beaver function?** One hypothesis is that the two functions stay fairly close to each other, with the Blanking coming out a little greater at every stage.

Well, I am happy to report that that hypothesis is false. On the morning of **8 July 2021**, I made the shocking discovery of a 4-state 2-color program that blanks the tape in **32,779,477** steps! So the Blanking Beaver table looks like this:

|---|---|---|
| States | Colors | Steps |
|---|---|---|
| 2 | 2 | 8 |
| 3 | 2 | 34 |
| 2 | 3 | 77 |
| 4 | 2 | 32,779,477 |
| 2 | 4 | |
| 5 | 2 | |
|---|---|---|

The Busy Beaver function grows unremarkably for its first few values and then takes off at a certain point. The Blanking Beaver function evidently follows the same pattern, except that **its jump occurs sooner**. I have no idea how to prove it, but I think it's safe to conclude empirically that **the Blanking Beaver function grows faster than the classic Busy Beaver function**. (This implies that the Blanking Beaver function is uncomputable as well, since the Busy Beaver function grows faster than any computable function.)

Of course, a wild claim such as this one ought to be independently verified. Here is the **witnessing program** in [lexical normal form](https://nickdrozd.github.io/2020/10/04/turing-machine-notation-and-normal-form.html):

{% highlight nil %}
1RB 1LC  1RD 1RB  0RD 0RC  1LD 1LA
{% endhighlight %}

Actually, the program was not discovered in that form. It came out of the **tree generation procedure** (more to be written on that topic at a later time), and was therefore in so-called **"tree normal form"**:

{% highlight nil %}
1RB 1LD  1RC 1RB  1LC 1LA  0RC 0RD
{% endhighlight %}

The previous Blanking Beaver record was **66,345 steps**, for a program that I discovered on **17 September 2020**. I had become convinced that this was the true champion. 66,345 is greater than the 4-2 halting champion's 107 steps, but not terribly so, and this led me to the hypothesis mentioned earlier that the two sequences aren't too far apart. Still, that's just a hunch, not a proof, and so I have been periodically double- and triple- and quadruple-checking.

To search for these long-running programs, I employ a team of **beaver scientists** who operate a set of large **mainframes**. Here is a picture of the beavers hard at work:

![img](/assets/2021-07-11-self-cleaning-turing-machine/beaver-mainframe.png)

As I arrived on the day of the discovery, there was a frantic air in the lab. I mean, the beavers are always running around in a hurry doing this and that, but that morning the mood was especially pronounced. Before I had even reached our in-office coffee vending machine, the principal beaver investigator approached and with a nervous look in its eyes invited me to take a seat in its office.

I entered the office, but I declined to sit, because beaver offices are gross. There's all sorts of weird forest debris all over the place, half-chewed-up stacks of paper, and it really doesn't smell good. It's not the kind of place a human would normally want to be, but it keeps the beavers productive.

![img](/assets/2021-07-11-self-cleaning-turing-machine/beaver-office.png)

Anyway, the beaver says to me, this shocking new blank-tape program turned up in our search, and we're pretty sure it's legit. I thought, there **must be a bug** somewhere, probably in the Turing machine simulator. So the first thing to do was to **run the program through some other simulators**.

Note that at 32,779,477 steps, the program in question **runs too long to visually inspect its behavior**. We can't look at it and "see what it does"; instead, we have to rely on the answers delivered by the simulator programs that we ourselves have written. Trust that this result is accurate requires trust in our simulator code. **Can our code be trusted?**

Our team maintains [Turing machine simulators](https://nickdrozd.github.io/2020/09/14/programmable-turing-machine.html) written in three different languages: **[Python](https://github.com/nickdrozd/pytur/tree/master/tm)**, **[C](https://github.com/nickdrozd/pytur/tree/master/machines)**, and **[Idris](https://github.com/nickdrozd/rado)**. It was the C simulator that had actually detected the new program. That code has been running for a while, so I had no particular reason to distrust it, but you know, C can be tricky, so we ran the program through the Python simulator. The result was confirmed.

We then ran the program through the Idris simulator, and the simulator hung. Ah, I thought, something is wrong here, the result is no good. Indeed something was wrong, but it wasn't the result: it turned out that **an "optimization" I had made a few days earlier was wrong**. Upon reverting that change, the simulator returned the new result, 32,779,477 steps.

That number, 32,779,477, is not the kind of number that can just get made up or guessed. It's **way too specific** for that. So here we had three simulators, written at different times and in different styles and for different purposes, all returning that same number. The discovered program even managed to work as a new test case and **flush out a bug** in one of them. This increased our confidence in the result to the point that we felt comfortable sending it to experts in the field for independent confirmation. Our beaver technical writer drew up a memo:

![img](/assets/2021-07-11-self-cleaning-turing-machine/beaver-memo.png)

The memo was sent out to some of the world's leading Busy Beaver experts, including **[Terry and Shawn Ligocki](https://github.com/sligocki/busy-beaver)** and **[Boyd Johnson](https://github.com/boydjohnson/lin-rado-turing/)**. They reported back with that same very specific large number, and so we conclude that the result is accurate: **BLB(4) ≥ 32,779,477**.


# Discussion Questions

1.  Why should the Blanking Beaver sequence grow faster than the Busy Beaver sequence?
2.  What does this new result tell us about other Busy Beaver-like sequences, like the [Beeping Busy Beaver sequence](https://nickdrozd.github.io/2020/08/13/beeping-busy-beavers.html)?
3.  What does this Blanking Beaver champion program "do"? How does it "work"?
4.  Do you trust the code that you write? I mean, really trust it?
5.  What sort of [control flow](https://nickdrozd.github.io/2021/04/21/structured-programming-for-busy-beavers.html) does this champion program employ? What does its [state transition graph](https://nickdrozd.github.io/2021/01/26/spaghetti-code-conjecture.html) look like?


# Open Problems

1.  Find a better 4-state 2-color Blanking Beaver champion, or else prove that this one is the true champion.
2.  Find a 2-state 4-color Blanking Beaver program that beats the existing 2-4 halting champion (3,932,964 steps), or else prove that there is no such program.
3.  Find a 5-state 2-color Blanking Beaver program that beats the existing 5-2 halting champion (47,176,870 steps). Such a program definitely exists.
4.  Prove formally that the Blanking Beaver sequence grows faster than the Busy Beaver sequence. Or else disprove it if you can, but I don't think that's going to happen.
